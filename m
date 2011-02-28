Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C24838D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 08:03:51 -0500 (EST)
Subject: Re: [PATCH 06/17] arm: mmu_gather rework
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110228125058.GD492@flint.arm.linux.org.uk>
References: <20110217162327.434629380@chello.nl>
	 <20110217163235.106239192@chello.nl> <1298565253.2428.288.camel@twins>
	 <1298657083.2428.2483.camel@twins>
	 <20110225215123.GA10026@flint.arm.linux.org.uk>
	 <1298893487.2428.10537.camel@twins>
	 <20110228115907.GB492@flint.arm.linux.org.uk>
	 <1298895612.2428.10621.camel@twins>
	 <20110228122803.GC492@flint.arm.linux.org.uk>
	 <1298897342.2428.10687.camel@twins>
	 <20110228125058.GD492@flint.arm.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 28 Feb 2011 14:03:18 +0100
Message-ID: <1298898198.2428.10728.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, "Luck,Tony" <tony.luck@intel.com>, PaulMundt <lethal@linux-sh.org>, Chris Metcalf <cmetcalf@tilera.com>

On Mon, 2011-02-28 at 12:50 +0000, Russell King wrote:
> On Mon, Feb 28, 2011 at 01:49:02PM +0100, Peter Zijlstra wrote:
> > On Mon, 2011-02-28 at 12:28 +0000, Russell King wrote:
> > > Can you point out where pte_free_tlb() is used with unmap_region()?
> >=20
> > unmap_region()
> >   free_pgtables()
> >     free_pgd_range()
> >       free_pud_range()
> >         free_pmd_range()
> >           free_pte_range()
> >             pte_free_tlb()
>=20
> Damn it.  Okay, I give up with this.  The TLB shootdown interface is
> total crap.

:-)

There's a reason I'd like to make everybody use asm-generic/tlb.h and
unify all the crazy bits. Once there's common code everybody is forced
to think about this stuff instead of endlessly hack their own
architecture to make it work without consideration for the rest of us.

Furthermore, I don't think its actually too hard to do.. (famous last
words).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
