Date: Tue, 29 Apr 2008 23:05:43 -0700 (PDT)
Message-Id: <20080429.230543.98200575.davem@davemloft.net>
Subject: Re: [rfc] data race in page table setup/walking?
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080430060340.GE27652@wotan.suse.de>
References: <20080429050054.GC21795@wotan.suse.de>
	<Pine.LNX.4.64.0804291333540.22025@blonde.site>
	<20080430060340.GE27652@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Date: Wed, 30 Apr 2008 08:03:40 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: hugh@veritas.com, torvalds@linux-foundation.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

> Hardware walkers, I shouldn't worry too much about, except as a thought
> exercise to realise that we have lockless readers. I think(?) alpha can
> walk the linux ptes in hardware on TLB miss, but surely they will have
> to do the requisite barriers in hardware too (otherwise things get
> really messy)

My understanding is that all Alpha implementations walk the
page tables in PAL code.

> Powerpc's find_linux_pte is one of the software walked lockless ones.
> That's basically how I imagine hardware walkers essentially should operate.

Sparc64 walks the page tables lockless in it's TLB hash table miss
handling.

MIPS does something similar.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
