Date: Wed, 30 Apr 2008 08:17:42 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] data race in page table setup/walking?
Message-ID: <20080430061741.GG27652@wotan.suse.de>
References: <20080429050054.GC21795@wotan.suse.de> <Pine.LNX.4.64.0804291333540.22025@blonde.site> <20080430060340.GE27652@wotan.suse.de> <20080429.230543.98200575.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080429.230543.98200575.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: hugh@veritas.com, torvalds@linux-foundation.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2008 at 11:05:43PM -0700, David Miller wrote:
> From: Nick Piggin <npiggin@suse.de>
> Date: Wed, 30 Apr 2008 08:03:40 +0200
> 
> > Hardware walkers, I shouldn't worry too much about, except as a thought
> > exercise to realise that we have lockless readers. I think(?) alpha can
> > walk the linux ptes in hardware on TLB miss, but surely they will have
> > to do the requisite barriers in hardware too (otherwise things get
> > really messy)
> 
> My understanding is that all Alpha implementations walk the
> page tables in PAL code.

Ah OK. I guess that's effectively "hardware" as far as Linux is concerned.
I guess even x86 really walks the page tables in microcode as well. Basically
I just mean something that is invisible to, and obvlivious of, Linux's
locking.

 
> > Powerpc's find_linux_pte is one of the software walked lockless ones.
> > That's basically how I imagine hardware walkers essentially should operate.
> 
> Sparc64 walks the page tables lockless in it's TLB hash table miss
> handling.
> 
> MIPS does something similar.

Interesting, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
