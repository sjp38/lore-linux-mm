Date: Fri, 14 Jan 2005 09:08:54 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: page table lock patch V15 [0/7]: overview
In-Reply-To: <20050114170140.GB4634@muc.de>
Message-ID: <Pine.LNX.4.58.0501140906550.27552@schroedinger.engr.sgi.com>
References: <41E5B7AD.40304@yahoo.com.au> <Pine.LNX.4.58.0501121552170.12669@schroedinger.engr.sgi.com>
 <41E5BC60.3090309@yahoo.com.au> <Pine.LNX.4.58.0501121611590.12872@schroedinger.engr.sgi.com>
 <20050113031807.GA97340@muc.de> <Pine.LNX.4.58.0501130907050.18742@schroedinger.engr.sgi.com>
 <20050113180205.GA17600@muc.de> <Pine.LNX.4.58.0501131701150.21743@schroedinger.engr.sgi.com>
 <20050114043944.GB41559@muc.de> <Pine.LNX.4.58.0501140838240.27382@schroedinger.engr.sgi.com>
 <20050114170140.GB4634@muc.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

On Fri, 14 Jan 2005, Andi Kleen wrote:

> > Looked at  arch/i386/lib/mmx.c. It avoids the mmx ops in an interrupt
> > context but the rest of the prep for mmx only saves the fpu state if its
> > in use. So that code would only be used rarely. The mmx 64 bit
> > instructions seem to be quite fast according to the manual. Double the
> > cycles than the 32 bit instructions on Pentium M (somewhat higher on Pentium 4).
>
> With all the other overhead (disabling exceptions, saving register etc.)
> will be likely slower. Also you would need fallback paths for CPUs
> without MMX but with PAE (like Ppro). You can benchmark
> it if you want, but I wouldn't be very optimistic.

So the PentiumPro is a cpu with atomic 64 bit operations in a cmpxchg but
no instruction to do an atomic 64 bit store or load although the
architecture conceptually supports 64bit atomic stores and loads? Wild.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
