Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 59E4A8D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 08:08:12 -0400 (EDT)
Subject: Re: [PATCH 02/17] mm: mmu_gather rework
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <4D87109A.1010005@redhat.com>
References: <20110217162327.434629380@chello.nl>
	 <20110217163234.823185666@chello.nl>  <20110310155032.GB32302@csn.ul.ie>
	 <1300301742.2203.1899.camel@twins>  <4D87109A.1010005@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 01 Apr 2011 14:07:11 +0200
Message-ID: <1301659631.4859.565.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Tony Luck <tony.luck@intel.com>, Hugh Dickins <hughd@google.com>

On Mon, 2011-03-21 at 10:47 +0200, Avi Kivity wrote:
> On 03/16/2011 08:55 PM, Peter Zijlstra wrote:
> > On Thu, 2011-03-10 at 15:50 +0000, Mel Gorman wrote:
> >
> > >  >  +static inline void
> > >  >  +tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, uns=
igned int full_mm_flush)
> > >  >   {
> > >
> > >  checkpatch will bitch about line length.
> >
> > I did a s/full_mm_flush/fullmm/ which puts the line length at 81. At
> > which point I'll ignore it ;-)
>=20
> How about s/unsigned int/bool/?  IIRC you aren't a "bool was invented=20
> after 1971, therefore it is evil" type.

No, although I do try to avoid it in structures because I'm ever unsure
of the storage type used. But yes, good suggestion, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
