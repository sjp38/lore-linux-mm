Date: Tue, 6 Dec 2005 21:06:07 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC 1/3] Framework for accurate node based statistics
Message-ID: <20051206200607.GY11190@wotan.suse.de>
References: <20051206182843.19188.82045.sendpatchset@schroedinger.engr.sgi.com> <20051206183524.GU11190@wotan.suse.de> <Pine.LNX.4.62.0512061105220.19475@schroedinger.engr.sgi.com> <20051206192603.GX11190@wotan.suse.de> <Pine.LNX.4.62.0512061131500.19637@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0512061131500.19637@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 06, 2005 at 11:36:43AM -0800, Christoph Lameter wrote:
> On Tue, 6 Dec 2005, Andi Kleen wrote:
> 
> > > Yuck. That code uses atomic operations and is not aware of atomic64_t.
> > Hmm? What code are you looking at? 
> include/asm-generic/local.h. this is the default right? And 
> include/asm-ia64/local.h.
>  
> > At least i386/x86-64/generic don't use any atomic operations, just
> > normal non atomic on bus but atomic for interrupts local rmw.
> 
> inc/dec are atomic by default on x86_64?

They are atomic against interrupts on the same CPU. And on Linux
also atomic against preempt moving you to another CPU. And all that
without the cost of a bus lock. And that is what local_t is about.

>  
> > Do you actually need 64bit? 
> 
> 32 bit limits us in the worst case to 8 Terabytes of RAM (assuming a very 
> small page size of 4k and 31 bit available for an atomic variable 
> [sparc]). SGI already has installations with 15 Terabytes of RAM.

Ok we'll need a local64_t then. No big deal - can be easily added.
Or perhaps better a long_local_t so that 32bit doesn't need to
pay the cost.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
