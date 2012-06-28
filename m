Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id CBE6E6B0075
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 12:39:06 -0400 (EDT)
Message-ID: <1340901493.28750.76.camel@twins>
Subject: Re: [PATCH 08/20] mm: Optimize fullmm TLB flushing
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 28 Jun 2012 18:38:13 +0200
In-Reply-To: <1340900425.28750.73.camel@twins>
References: <20120627211540.459910855@chello.nl>
	 <20120627212831.137126018@chello.nl>
	 <CA+55aFwZoVK76ue7tFveV0XZpPUmoCVXJx8550OxPm+XKCSSZA@mail.gmail.com>
	 <1340838154.10063.86.camel@twins> <1340838807.10063.90.camel@twins>
	 <CA+55aFy6m967fMxyBsRoXVecdpGtSphXi_XdhwS0DB81Qaocdw@mail.gmail.com>
	 <CA+55aFzLNsVRkp_US8rAmygEkQpp1s1YdakV86Ck-4RZM7TTdA@mail.gmail.com>
	 <20120628091627.GB8573@arm.com> <1340879984.20977.80.camel@pasglop>
	 <1340881196.28750.16.camel@twins> <20120628145327.GA17242@arm.com>
	 <1340900425.28750.73.camel@twins>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Thu, 2012-06-28 at 18:20 +0200, Peter Zijlstra wrote:
> Now the switch_mm should imply the same cache+TBL flush we'd otherwise
> do, and I'd think that that would be the majority of the cost. Am I
> wrong there?=20

The advantage of doing this is that you don't need any of the batching
and possibly multiple invalidate nonsense you otherwise need. So it
might still be an over-all win, even if the switch is slightly more
expensive than a regular flush. Simply because you can avoid most (if
not all) the usual complexities.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
