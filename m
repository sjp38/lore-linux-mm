Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D01F36B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 09:13:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a188so51436473pfa.3
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 06:13:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s2si14478093plj.119.2017.04.18.06.13.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 06:13:56 -0700 (PDT)
Date: Tue, 18 Apr 2017 06:13:49 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: copy_page() on a kmalloc-ed page with DEBUG_SLAB enabled (was
 "zram: do not use copy_page with non-page alinged address")
Message-ID: <20170418131349.GA18505@bombadil.infradead.org>
References: <20170417014803.GC518@jagdpanzerIV.localdomain>
 <alpine.DEB.2.20.1704171016550.28407@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1704171016550.28407@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon, Apr 17, 2017 at 10:20:42AM -0500, Christoph Lameter wrote:
> Simple solution is to not allocate pages via the slab allocator but use
> the page allocator for this. The page allocator provides proper alignment.
> 
> There is a reason it is called the page allocator because if you want a
> page you use the proper allocator for it.

Previous discussion on this topic:

https://lwn.net/Articles/669015/
https://lwn.net/Articles/669020/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
