Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 22DA56B00E9
	for <linux-mm@kvack.org>; Thu, 17 May 2012 12:33:42 -0400 (EDT)
Message-ID: <1337272396.4281.48.camel@twins>
Subject: Re: [RFC][PATCH 4/6] arm, mm: Convert arm to generic tlb
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 17 May 2012 18:33:16 +0200
In-Reply-To: <1337271884.4281.46.camel@twins>
References: <20110302175928.022902359@chello.nl>
	 <20110302180259.109909335@chello.nl> <20120517030551.GA11623@linux-sh.org>
	 <20120517093022.GA14666@arm.com>
	 <20120517095124.GN23420@flint.arm.linux.org.uk>
	 <1337254086.4281.26.camel@twins> <20120517160012.GB18593@arm.com>
	 <1337271884.4281.46.camel@twins>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, 2012-05-17 at 18:24 +0200, Peter Zijlstra wrote:
> On Thu, 2012-05-17 at 17:00 +0100, Catalin Marinas wrote:
>=20
> > BTW, looking at your tlb-unify branch, does tlb_remove_table() call
> > tlb_flush/tlb_flush_mmu before freeing the tables?  I can only see
> > tlb_remove_page() doing this. On ARM, even UP, we need the TLB flushing
> > after clearing the pmd and before freeing the pte page table (and
> > ideally doing it less often than at every pte_free_tlb() call).
>=20
> No I don't think it does, so far the only archs using the RCU stuff are
> ppc,sparc and s390 and none of those needed that (Xen might join them
> soon though). But I will have to look and consider this more carefully.
> I 'lost' most of the ppc/sparc/s390 details from memory to say this with
> any certainty.


Hmm, no, thinking more that does indeed sounds strange, I'll still have
to consider it more carefully, but I think you might have found a bug
there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
