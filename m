Date: Fri, 14 Jan 2005 08:37:15 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: page table lock patch V15 [0/7]: overview
In-Reply-To: <41E73EE4.50200@linux-m68k.org>
Message-ID: <Pine.LNX.4.58.0501140836450.27382@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
 <Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org>
 <Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org>
 <Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412011545060.5721@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0501041129030.805@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0501041137410.805@schroedinger.engr.sgi.com> <m1652ddljp.fsf@muc.de>
 <Pine.LNX.4.58.0501110937450.32744@schroedinger.engr.sgi.com>
 <41E4BCBE.2010001@yahoo.com.au> <20050112014235.7095dcf4.akpm@osdl.org>
 <Pine.LNX.4.58.0501120833060.10380@schroedinger.engr.sgi.com>
 <20050112104326.69b99298.akpm@osdl.org> <Pine.LNX.4.58.0501121055490.11169@schroedinger.engr.sgi.com>
 <41E73EE4.50200@linux-m68k.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Andrew Morton <akpm@osdl.org>, nickpiggin@yahoo.com.au, torvalds@osdl.org, ak@muc.de, hugh@veritas.com, linux-mm@kvack.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

On Fri, 14 Jan 2005, Roman Zippel wrote:

> Hi,
>
> Christoph Lameter wrote:
>
> > Introduction of the cmpxchg is one atomic operations that replaces the two
> > spinlock ops typically necessary in an unpatched kernel. Obtaining the
> > spinlock requires an spinlock (which is an atomic operation) and then the
> > release involves a barrier. So there is a net win for all SMP cases as far
> > as I can see.
>
> But there might be a loss in the UP case. Spinlocks are optimized away,
> but your cmpxchg emulation enables/disables interrupts with every access.

The cmpxchg could become a store in the UP case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
