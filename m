Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EF5988D003A
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 16:16:48 -0400 (EDT)
Received: by fxm18 with SMTP id 18so2660324fxm.14
        for <linux-mm@kvack.org>; Wed, 16 Mar 2011 13:16:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1300301742.2203.1899.camel@twins>
References: <20110217162327.434629380@chello.nl>
	<20110217163234.823185666@chello.nl>
	<20110310155032.GB32302@csn.ul.ie>
	<1300301742.2203.1899.camel@twins>
Date: Wed, 16 Mar 2011 21:15:58 +0100
Message-ID: <AANLkTimB4NFSPz5dSQCuEy3Rj5968n5k0=4c7tvhErE5@mail.gmail.com>
Subject: Re: [PATCH 02/17] mm: mmu_gather rework
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Tony Luck <tony.luck@intel.com>, Hugh Dickins <hughd@google.com>

On Wed, Mar 16, 2011 at 19:55, Peter Zijlstra <a.p.zijlstra@chello.nl> wrot=
e:
> On Thu, 2011-03-10 at 15:50 +0000, Mel Gorman wrote:
>
>> > +static inline void
>> > +tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned=
 int full_mm_flush)
>> > =C2=A0{
>>
>> checkpatch will bitch about line length.
>
> I did a s/full_mm_flush/fullmm/ which puts the line length at 81. At
> which point I'll ignore it ;-)

But what does "fullmm" mean here? Shouldn't that be documented.
BTW, the function no longer returns a struct, but void, so the documentatio=
n
should be updated for sure.

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
