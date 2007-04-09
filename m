Date: Mon, 9 Apr 2007 11:46:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [QUICKLIST 3/4] Quicklist support for x86_64
In-Reply-To: <200704092043.14335.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0704091144270.8783@schroedinger.engr.sgi.com>
References: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
 <20070409182520.8559.33529.sendpatchset@schroedinger.engr.sgi.com>
 <200704092043.14335.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Apr 2007, Andi Kleen wrote:

> On Monday 09 April 2007 20:25:20 Christoph Lameter wrote:
> 
> >  #endif /* _X86_64_PGALLOC_H */
> > Index: linux-2.6.21-rc5-mm4/arch/x86_64/kernel/process.c
> > ===================================================================
> > --- linux-2.6.21-rc5-mm4.orig/arch/x86_64/kernel/process.c	2007-04-07 18:07:47.000000000 -0700
> > +++ linux-2.6.21-rc5-mm4/arch/x86_64/kernel/process.c	2007-04-07 18:09:30.000000000 -0700
> > @@ -207,6 +207,7 @@
> >  			if (__get_cpu_var(cpu_idle_state))
> >  				__get_cpu_var(cpu_idle_state) = 0;
> >  
> > +			check_pgt_cache();
> 
> Wouldn't it be better to do that on memory pressure only (register
> it as a shrinker)?

It has to be done in sync with tlb flushing. Doing that on memory pressure 
would complicate things significantly. Also idling means that the cache 
grows cold.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
