Date: Sun, 17 Aug 2003 08:54:18 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [uClinux-dev] uClinux 2.6.x memory allocator brokenness
Message-ID: <20030817065417.GA16969@lst.de>
References: <200308162245.16480.bernie@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200308162245.16480.bernie@develer.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bernardo Innocenti <bernie@develer.com>
Cc: linux-mm@kvack.org, uClinux development list <uclinux-dev@uclinux.org>
List-ID: <linux-mm.kvack.org>

The right list for this would be linux-mm I guess..

On Sat, Aug 16, 2003 at 10:45:16PM +0200, Bernardo Innocenti wrote:
> Hello,
> 
> not sure if anybody else experienced this problem. 2.5.x/2.6.x
> kernels seem to have some nasty bug in mm/page_alloc.c.
> 
> When I allocate over 256KB of memory, the allocator steps into
> __alloc_pages() with order=7 and finds nothing free in the 512KB
> slab, then it splits the 1MB block in two 512MB blocks and fails
> miserably for some unknown reason.
> 
> I also noticed that any allocation (even smaller ones) always
> fail in the fast path and falls down into the slowish code
> that wakes up kswapd to free some more pages.
> 
> This happens because zone->pages_low is set to 512 while
> free_pages is consistently below 400 on my system.
> 
> Perhaps these values would have to be retuned on embedded targets.
> 
> -- 
>   // Bernardo Innocenti - Develer S.r.l., R&D dept.
> \X/  http://www.develer.com/
> 
> Please don't send Word attachments - http://www.gnu.org/philosophy/no-word-attachments.html
> 
> 
> _______________________________________________
> uClinux-dev mailing list
> uClinux-dev@uclinux.org
> http://mailman.uclinux.org/mailman/listinfo/uclinux-dev
> This message was resent by uclinux-dev@uclinux.org
---end quoted text---
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
