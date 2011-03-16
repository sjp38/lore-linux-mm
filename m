Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1E2578D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 17:06:34 -0400 (EDT)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1PzxvK-0006j3-TT
	for linux-mm@kvack.org; Wed, 16 Mar 2011 21:06:31 +0000
Subject: Re: [PATCH 02/17] mm: mmu_gather rework
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <AANLkTimB4NFSPz5dSQCuEy3Rj5968n5k0=4c7tvhErE5@mail.gmail.com>
References: <20110217162327.434629380@chello.nl>
	 <20110217163234.823185666@chello.nl> <20110310155032.GB32302@csn.ul.ie>
	 <1300301742.2203.1899.camel@twins>
	 <AANLkTimB4NFSPz5dSQCuEy3Rj5968n5k0=4c7tvhErE5@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 16 Mar 2011 22:08:21 +0100
Message-ID: <1300309701.2250.89.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Tony Luck <tony.luck@intel.com>, Hugh Dickins <hughd@google.com>

On Wed, 2011-03-16 at 21:15 +0100, Geert Uytterhoeven wrote:
> On Wed, Mar 16, 2011 at 19:55, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > On Thu, 2011-03-10 at 15:50 +0000, Mel Gorman wrote:
> >
> >> > +static inline void
> >> > +tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned int full_mm_flush)
> >> >  {
> >>
> >> checkpatch will bitch about line length.
> >
> > I did a s/full_mm_flush/fullmm/ which puts the line length at 81. At
> > which point I'll ignore it ;-)
> 
> But what does "fullmm" mean here? Shouldn't that be documented.
> BTW, the function no longer returns a struct, but void, so the documentation
> should be updated for sure.

You're talking about the comment right? I'll update that. I was also
considering writing Documentation/mmugather.txt, but that's a slightly
bigger undertaking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
