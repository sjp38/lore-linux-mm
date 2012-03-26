Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 4845E6B00E8
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:18:46 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 36/39] autonuma: link mm/autonuma.o and kernel/sched/numa.o
Date: Mon, 26 Mar 2012 19:46:23 +0200
Message-Id: <1332783986-24195-37-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

Link the AutoNUMA core and scheduler object files in the kernel if
CONFIG_AUTONUMA=y.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 kernel/sched/Makefile |    3 +--
 mm/Makefile           |    1 +
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/sched/Makefile b/kernel/sched/Makefile
index 9a7dd35..783a840 100644
--- a/kernel/sched/Makefile
+++ b/kernel/sched/Makefile
@@ -16,5 +16,4 @@ obj-$(CONFIG_SMP) += cpupri.o
 obj-$(CONFIG_SCHED_AUTOGROUP) += auto_group.o
 obj-$(CONFIG_SCHEDSTATS) += stats.o
 obj-$(CONFIG_SCHED_DEBUG) += debug.o
-
-
+obj-$(CONFIG_AUTONUMA) += numa.o
diff --git a/mm/Makefile b/mm/Makefile
index 50ec00e..67c77bd 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -29,6 +29,7 @@ obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
 obj-$(CONFIG_HAS_DMA)	+= dmapool.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
+obj-$(CONFIG_AUTONUMA) 	+= autonuma.o
 obj-$(CONFIG_SPARSEMEM)	+= sparse.o
 obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
