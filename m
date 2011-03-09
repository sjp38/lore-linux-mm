Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5E46F8D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 10:16:09 -0500 (EST)
Received: by yxt33 with SMTP id 33so352738yxt.14
        for <linux-mm@kvack.org>; Wed, 09 Mar 2011 07:16:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110302180259.109909335@chello.nl>
References: <20110302175928.022902359@chello.nl>
	<20110302180259.109909335@chello.nl>
Date: Wed, 9 Mar 2011 15:16:07 +0000
Message-ID: <AANLkTimbRS++SCcKGrUcL5xKsCO+1ygkg+83x7F+2S4i@mail.gmail.com>
Subject: Re: [RFC][PATCH 4/6] arm, mm: Convert arm to generic tlb
From: Catalin Marinas <catalin.marinas@arm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Hi Peter,

On 2 March 2011 17:59, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> --- linux-2.6.orig/arch/arm/include/asm/tlb.h
> +++ linux-2.6/arch/arm/include/asm/tlb.h
[...]
> +__pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte, unsigned long addr=
)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pgtable_page_dtor(pte);
> - =C2=A0 =C2=A0 =C2=A0 tlb_add_flush(tlb, addr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tlb_remove_page(tlb, pte);
> =C2=A0}

I think we still need a tlb_track_range() call here. On the path to
pte_free_tlb() (for example shift_arg_pages ... free_pte_range) there
doesn't seem to be any code setting the tlb->start/end range. Did I
miss anything?

Thanks.

--=20
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
