Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 7932D6B00EA
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:18:49 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 05/39] autonuma: generic pte_numa() and pmd_numa()
Date: Mon, 26 Mar 2012 19:45:52 +0200
Message-Id: <1332783986-24195-6-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

Implement generic version of the methods. They're used when
CONFIG_AUTONUMA=n, and they're a noop.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/asm-generic/pgtable.h |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 125c54e..d22552b 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -503,6 +503,18 @@ static inline int pmd_trans_unstable(pmd_t *pmd)
 #endif
 }
 
+#ifndef CONFIG_AUTONUMA
+static inline int pte_numa(pte_t pte)
+{
+	return 0;
+}
+
+static inline int pmd_numa(pmd_t pmd)
+{
+	return 0;
+}
+#endif /* CONFIG_AUTONUMA */
+
 #endif /* CONFIG_MMU */
 
 #endif /* !__ASSEMBLY__ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
