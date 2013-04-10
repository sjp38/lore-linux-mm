Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 5BC9A6B0039
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 15:35:20 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] mm: Print the correct method to disable automatic numa migration
Date: Wed, 10 Apr 2013 12:35:14 -0700
Message-Id: <1365622514-26614-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, mgorman@suse.de

From: Andi Kleen <ak@linux.intel.com>

When the "default y" CONFIG_NUMA_BALANCING_DEFAULT_ENABLED is enabled,
the message it prints refers to a sysctl to disable it again.
But that sysctl doesn't exist.

Document the correct (highly obscure method) through debugfs.

This should be also in Documentation/* but isn't.

Also fix the checkpatch problems.

BTW I think the "default y" is highly dubious for such a
experimential feature.

Cc: mgorman@suse.de
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/mempolicy.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 7431001..8a4dc29 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2530,8 +2530,8 @@ static void __init check_numabalancing_enable(void)
 		numabalancing_default = true;
 
 	if (nr_node_ids > 1 && !numabalancing_override) {
-		printk(KERN_INFO "Enabling automatic NUMA balancing. "
-			"Configure with numa_balancing= or sysctl");
+		pr_info("Enabling automatic NUMA balancing.\n");
+		pr_info("Change with numa_balancing= or echo -NUMA >/sys/kernel/debug/sched_features\n");
 		set_numabalancing_state(numabalancing_default);
 	}
 }
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
