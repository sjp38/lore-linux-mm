Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 086466B0003
	for <linux-mm@kvack.org>; Sat, 24 Feb 2018 16:05:19 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c5so6061348pfn.17
        for <linux-mm@kvack.org>; Sat, 24 Feb 2018 13:05:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id 141si4112355pfz.106.2018.02.24.13.05.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 24 Feb 2018 13:05:13 -0800 (PST)
Date: Sat, 24 Feb 2018 13:05:07 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 0/2] mark some slabs as visible not mergeable
Message-ID: <20180224210507.GA28183@bombadil.infradead.org>
References: <20180224190454.23716-1-sthemmin@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180224190454.23716-1-sthemmin@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org, ikomyagin@gmail.com, Stephen Hemminger <sthemmin@microsoft.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Sat, Feb 24, 2018 at 11:04:52AM -0800, Stephen Hemminger wrote:
> This fixes an old bug in iproute2's ss command because it was
> reading slabinfo to get statistics. There isn't a better API
> to do this, and one can argue that /proc is a UAPI that must
> not change.
> 
> Therefore this patch set adds a flag to slab to give another
> reason to prevent merging, and then uses it in network code.

This is exactly the solution I would have suggested.  Note that SLUB
has always had slab merging, so this tool has been broken since 2.6.22
on any kernel with CONFIG_SLUB.

Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
