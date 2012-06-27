Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 9A9A76B005C
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 19:03:20 -0400 (EDT)
Message-ID: <1340838154.10063.86.camel@twins>
Subject: Re: [PATCH 08/20] mm: Optimize fullmm TLB flushing
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 28 Jun 2012 01:02:34 +0200
In-Reply-To: <CA+55aFwZoVK76ue7tFveV0XZpPUmoCVXJx8550OxPm+XKCSSZA@mail.gmail.com>
References: <20120627211540.459910855@chello.nl>
	 <20120627212831.137126018@chello.nl>
	 <CA+55aFwZoVK76ue7tFveV0XZpPUmoCVXJx8550OxPm+XKCSSZA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A.
 Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Wed, 2012-06-27 at 15:26 -0700, Linus Torvalds wrote:
> On Wed, Jun 27, 2012 at 2:15 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> =
wrote:
> > This originated from s390 which does something similar and would allow
> > s390 to use the generic TLB flushing code.
> >
> > The idea is to flush the mm wide cache and tlb a priory and not bother
> > with multiple flushes if the batching isn't large enough.
> >
> > This can be safely done since there cannot be any concurrency on this
> > mm, its either after the process died (exit) or in the middle of
> > execve where the thread switched to the new mm.
>=20
> I think we actually *used* to do the final TLB flush from within the
> context of the process that died. That doesn't seem to ever be the
> case any more, but it does worry me a bit. Maybe a
>=20
>    VM_BUG_ON(current->active_mm =3D=3D mm);
>=20
> or something for the fullmm case?

OK, added it and am rebooting the test box..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
