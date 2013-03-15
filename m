Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 128D66B0037
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 12:52:00 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 3/9] mmu_notifier: use DEFINE_STATIC_SRCU() to define srcu struct
Date: Sat, 16 Mar 2013 00:50:51 +0800
Message-Id: <1363366257-4886-4-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1363366257-4886-1-git-send-email-laijs@cn.fujitsu.com>
References: <1363366257-4886-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Robin Holt <holt@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Gavin Shan <shangw@linux.vnet.ibm.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

DEFINE_STATIC_SRCU() defines srcu struct and do init at build time.
also remove unneeded mmu_notifier_init().

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 mm/mmu_notifier.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index be04122..aa7c785 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -20,7 +20,7 @@
 #include <linux/slab.h>
 
 /* global SRCU for all MMs */
-static struct srcu_struct srcu;
+DEFINE_STATIC_SRCU(srcu);
 
 /*
  * This function can't run concurrently against mmu_notifier_register
@@ -326,9 +326,3 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
 
-static int __init mmu_notifier_init(void)
-{
-	return init_srcu_struct(&srcu);
-}
-
-module_init(mmu_notifier_init);
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
