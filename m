Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 2E4E76B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 08:02:06 -0400 (EDT)
Message-ID: <1340884801.20977.84.camel@pasglop>
Subject: Re: [PATCH 02/20] mm: Add optional TLB flush to generic RCU
 page-table freeing
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 28 Jun 2012 22:00:01 +1000
In-Reply-To: <1340881511.28750.19.camel@twins>
References: <20120627211540.459910855@chello.nl>
	 <20120627212830.693232452@chello.nl>
	 <CA+55aFwa41fzvx8EZG_gODvw7hSpr+iP+w5fXp6jUcQh-4nFgQ@mail.gmail.com>
	 <1340838106.10063.85.camel@twins> <1340867364.20977.65.camel@pasglop>
	 <1340881511.28750.19.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A.
 Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Thu, 2012-06-28 at 13:05 +0200, Peter Zijlstra wrote:
> 
> > Some embedded ppc's know about the lowest level (SW loaded PMD) but
> > that's not an issue here. We flush these special TLB entries
> > specifically and synchronously in __pte_free_tlb().
> 
> OK, I missed that.. is that
> arch/powerpc/mm/tlb_nohash.c:tlb_flush_pgtable() ?

Yup.

> > > So even if the hardware did do speculative tlb fills, it would do
> them
> > > from the hash-table, but that's already cleared out.
> > 
> > Right,
> 
> Phew at least I got the important thing right ;-)

Yeah as long as we have that hash :-) The day we move on (if ever) it
will be as bad as ARM :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
