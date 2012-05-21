Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 308806B0081
	for <linux-mm@kvack.org>; Mon, 21 May 2012 03:47:20 -0400 (EDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Mon, 21 May 2012 08:47:18 +0100
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4L7lDHc2945050
	for <linux-mm@kvack.org>; Mon, 21 May 2012 08:47:13 +0100
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4L7dWoV023800
	for <linux-mm@kvack.org>; Mon, 21 May 2012 03:39:33 -0400
Date: Mon, 21 May 2012 09:47:09 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [RFC][PATCH 4/6] arm, mm: Convert arm to generic tlb
Message-ID: <20120521094709.6036d868@de.ibm.com>
In-Reply-To: <1337271884.4281.46.camel@twins>
References: <20110302175928.022902359@chello.nl>
	<20110302180259.109909335@chello.nl>
	<20120517030551.GA11623@linux-sh.org>
	<20120517093022.GA14666@arm.com>
	<20120517095124.GN23420@flint.arm.linux.org.uk>
	<1337254086.4281.26.camel@twins>
	<20120517160012.GB18593@arm.com>
	<1337271884.4281.46.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Chris Metcalf <cmetcalf@tilera.com>

On Thu, 17 May 2012 18:24:44 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Thu, 2012-05-17 at 17:00 +0100, Catalin Marinas wrote:
> 
> > BTW, looking at your tlb-unify branch, does tlb_remove_table() call
> > tlb_flush/tlb_flush_mmu before freeing the tables?  I can only see
> > tlb_remove_page() doing this. On ARM, even UP, we need the TLB flushing
> > after clearing the pmd and before freeing the pte page table (and
> > ideally doing it less often than at every pte_free_tlb() call).
> 
> No I don't think it does, so far the only archs using the RCU stuff are
> ppc,sparc and s390 and none of those needed that (Xen might join them
> soon though). But I will have to look and consider this more carefully.
> I 'lost' most of the ppc/sparc/s390 details from memory to say this with
> any certainty.
 
s390 needs a TLB flush for the pgd, pud and pmd tables. See git commit
cd94154cc6a28dd9dc271042c1a59c08d26da886 for the sad details.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
