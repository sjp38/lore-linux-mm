Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2D34A8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 12:54:32 -0500 (EST)
Subject: Re: [RFC][PATCH 14/15] mm, sparc32: Convert sparc32 to generic tlb
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110307172207.445811237@chello.nl>
References: <20110307171350.989666626@chello.nl>
	 <20110307172207.445811237@chello.nl>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 07 Mar 2011 18:54:12 +0100
Message-ID: <1299520452.2308.240.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Mon, 2011-03-07 at 18:14 +0100, Peter Zijlstra wrote:
> plain text document attachment (sparc32-mmu_range.patch)
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  arch/sparc/Kconfig              |    1 +
>  arch/sparc/include/asm/tlb_32.h |   10 ----------
>  2 files changed, 1 insertion(+), 10 deletions(-)
>=20
> Index: linux-2.6/arch/sparc/Kconfig
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/arch/sparc/Kconfig
> +++ linux-2.6/arch/sparc/Kconfig
> @@ -25,6 +25,7 @@ config SPARC
>  	select HAVE_DMA_ATTRS
>  	select HAVE_DMA_API_DEBUG
>  	select HAVE_ARCH_JUMP_LABEL
> +	select HAVE_MMU_GATHER_RANGE
> =20
>  config SPARC32
>  	def_bool !64BIT

Ah, I probably should put that in the SPARC32 bit.. ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
