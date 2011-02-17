Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 22B928D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 12:10:39 -0500 (EST)
Message-Id: <20110217162327.434629380@chello.nl>
Date: Thu, 17 Feb 2011 17:23:27 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/17] mm: mmu_gather rework
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

Rework the existing mmu_gather infrastructure.

The direct purpose of these patches was to allow preemptible mmu_gather,
but even without that I think these patches provide an improvement to the
status quo.

The first patch is a fix to the tile architecture, the subsequent 9 patches
rework the mmu_gather infrastructure. For review purpose I've split them
into generic and per-arch patches with the last of those a generic cleanup.

For the final commit I would provide a roll-up of these patches so as not
to wreck bisectability of non generic archs.

The next patch provides generic RCU page-table freeing, and the follow up
is a patch converting s390 to use this. I've also got 4 patches from
DaveM lined up (not included in this series) that uses this to implement
gup_fast() for sparc64.

Then there is one patch that extends the generic mmu_gather batching.

Finally there are 4 patches that convert various architectures over
to asm-generic/tlb.h, these are compile tested only and basically RFC.

After this only um and s390 are left -- um should be straight forward,
s390 wants a bit more, but more on that in another email.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
