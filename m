Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C6C406B0278
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 12:36:53 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id d63so2651611wma.4
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 09:36:53 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:8b0:10b:1236::1])
        by mx.google.com with ESMTPS id p203si4095529wmb.227.2018.02.12.09.36.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Feb 2018 09:36:52 -0800 (PST)
Date: Mon, 12 Feb 2018 09:36:30 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC] Protect larger order pages from breaking up
Message-ID: <20180212173630.GB9396@bombadil.infradead.org>
References: <alpine.DEB.2.20.1802091311090.3059@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1802091311090.3059@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, akpm@linux-foundation.org, Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>

On Fri, Feb 09, 2018 at 01:24:41PM -0600, Christopher Lameter wrote:
> Control over this feature is by writing to /proc/zoneinfo.
> 
> F.e. to ensure that 2000 16K pages stay available for jumbo
> frames do
> 
> 	echo "3=2000" >/proc/zoneinfo

That seems ... wrong.  4k is order 0, 8k is order 1, 16k is order 2,
32k is order 3.

> One can then also f.e. operate the slub allocator with
> 64k pages. Specify "slub_max_order=3 slub_min_order=3" on
> the kernel command line and all slab allocator allocations
> will occur in 16K page sizes.

This example also reads weird ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
