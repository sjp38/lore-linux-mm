Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A1B9D8D0043
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 12:49:26 -0500 (EST)
Message-Id: <20110307171350.989666626@chello.nl>
Date: Mon, 07 Mar 2011 18:13:50 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 00/15] Unify TLB gather implementations -v2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

This is a series that attempts to unify and fix the current tlb gather
implementations. Only s390 is left unconverted and most aren't event compiled
but other than that its mostly complete (ia64, arm, sh are compile tested).

This second installment doesn't try to change flush_tlb_range() for all
architectures but simply uses a fake vma and fills in VM_EXEC and VM_HUGETLB.

This series depends on the mmu_gather rework -v2 series send last week:
  https://lkml.org/lkml/2011/3/2/323

which is also available (including the anon_vma refcount simplification,
mm preemtibilidy and davem's sparc64 gup_fast implementation) as a git tree
based on next-20110307:
  git://git.kernel.org/pub/scm/linux/kernel/git/peterz/linux-2.6-mmu_gather.git mmu_gather

The whole series, including the depending patches is available through:
  git://git.kernel.org/pub/scm/linux/kernel/git/peterz/linux-2.6-mmu_gather.git mmu_unify

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
