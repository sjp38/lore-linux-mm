Date: Tue, 15 Jun 1999 11:31:27 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: kmem_cache_init() question
In-Reply-To: <000001beb706$5a8b06a0$b7e0a8c0@prashanth.wipinfo.soft.net>
Message-ID: <Pine.LNX.3.96.990615112625.2450A-100000@mole.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Prashanth C." <cprash@wipinfo.soft.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 1999, Prashanth C. wrote:

> This question is with reference to following segment of code [ver 2.2.9] in
> kmem_cache_init() function (mm/slab.c):
> 
> if (num_physpages > (32 << 20) >> PAGE_SHIFT)
>     slab_break_gfp_order = SLAB_BREAK_GFP_ORDER_HI;
> 
> I found that num_physpages is initialized in mem_init() function
> (arch/i386/mm/init.c).  But start_kernel() calls kmem_cache_init() before
> mem_init().  So, num_physpages will always(?) be zero when the above code
> segment is executed.

Interesting...  This was done as a work around for memory fragmentation in
low memory machines.  It was presumed that machines with lots of memory
did not have that problem, but if this code is actually moved to do what
it intended to do, the fragmentation problem might crop up again.  If
anyone changes this, put it into 2.3, not 2.2 -- perhaps a comment should
be added to slab.c pointing this out.

		-ben


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
