Date: 14 Jan 2005 05:14:21 +0100
Date: Fri, 14 Jan 2005 05:14:21 +0100
From: Andi Kleen <ak@muc.de>
Subject: Re: page table lock patch V15 [0/7]: overview
Message-ID: <20050114041421.GA41559@muc.de>
References: <Pine.LNX.4.58.0501041129030.805@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0501041137410.805@schroedinger.engr.sgi.com> <m1652ddljp.fsf@muc.de> <Pine.LNX.4.58.0501110937450.32744@schroedinger.engr.sgi.com> <41E4BCBE.2010001@yahoo.com.au> <20050112014235.7095dcf4.akpm@osdl.org> <Pine.LNX.4.58.0501120833060.10380@schroedinger.engr.sgi.com> <20050112104326.69b99298.akpm@osdl.org> <Pine.LNX.4.58.0501121055490.11169@schroedinger.engr.sgi.com> <41E73EE4.50200@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41E73EE4.50200@linux-m68k.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, nickpiggin@yahoo.com.au, torvalds@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 14, 2005 at 04:39:16AM +0100, Roman Zippel wrote:
> Hi,
> 
> Christoph Lameter wrote:
> 
> >Introduction of the cmpxchg is one atomic operations that replaces the two
> >spinlock ops typically necessary in an unpatched kernel. Obtaining the
> >spinlock requires an spinlock (which is an atomic operation) and then the
> >release involves a barrier. So there is a net win for all SMP cases as far
> >as I can see.
> 
> But there might be a loss in the UP case. Spinlocks are optimized away, 
> but your cmpxchg emulation enables/disables interrupts with every access.

Only for 386s and STI/CLI is quite cheap there.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
