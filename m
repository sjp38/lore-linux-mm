Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A52296B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 04:13:29 -0500 (EST)
Date: Tue, 30 Nov 2010 01:13:25 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Re: Free memory never fully used, swapping
Message-ID: <20101130091325.GA17340@hostway.ca>
References: <20101124092753.GS19571@csn.ul.ie> <20101124191749.GA29511@hostway.ca> <20101125101803.F450.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011260943220.12265@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011260943220.12265@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 26, 2010 at 09:48:14AM -0600, Christoph Lameter wrote:

> On Thu, 25 Nov 2010, KOSAKI Motohiro wrote:
> > Please try SLAB instead SLUB (it can be switched by kernel build option).
> > SLUB try to use high order allocation implicitly.
> 
> SLAB uses orders 0-1. Order is fixed per slab cache and determined based
> on object size at slab creation.
> 
> SLUB uses orders 0-3. Falls back to smallest order if alloc order cannot
> be met by the page allocator.
> 
> One can reduce SLUB to SLAB orders by specifying the following kernel
> commandline parameter:
> 
> slub_max_order=1

Can we also mess with these /sys files on the fly?

[/sys/kernel/slab]# grep . kmalloc-*/order | sort -n -k2 -t-
kmalloc-8/order:0
kmalloc-16/order:0
kmalloc-32/order:0
kmalloc-64/order:0
kmalloc-96/order:0
kmalloc-128/order:0
kmalloc-192/order:0
kmalloc-256/order:1
kmalloc-512/order:2
kmalloc-1024/order:3
kmalloc-2048/order:3
kmalloc-4096/order:3
kmalloc-8192/order:3

I'm not familiar with how slub works, but I assume there's some overhead
or some reason not to just use order 0 for <= kmalloc-4096?  Or is it
purely just trying to reduce cpu by calling alloc_pages less often?

Simon-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
