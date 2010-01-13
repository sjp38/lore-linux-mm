Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0A0AF6B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 20:00:57 -0500 (EST)
Message-Id: <20100113004938.715904356@suse.com>
Date: Tue, 12 Jan 2010 19:48:57 -0500
From: Jeff Mahoney <jeffm@suse.com>
Subject: [patch 2/6] hugetlb: Fix section mismatches
References: <20100113004855.550486769@suse.com>
Content-Disposition: inline; filename=patches.rpmify/hugetlbfs-fix-section-mismatches
Sender: owner-linux-mm@kvack.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

 hugetlb_register_node calls hugetlb_sysfs_add_hstate, which is marked with
 __init. Since hugetlb_register_node is only called by
 hugetlb_register_all_nodes, which in turn is only called by hugetlb_init,
 it's safe to mark both of them as __init.

Signed-off-by: Jeff Mahoney <jeffm@suse.com>
---
 mm/hugetlb.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1630,7 +1630,7 @@ void hugetlb_unregister_node(struct node
  * hugetlb module exit:  unregister hstate attributes from node sysdevs
  * that have them.
  */
-static void hugetlb_unregister_all_nodes(void)
+static void __init hugetlb_unregister_all_nodes(void)
 {
 	int nid;
 
@@ -1650,7 +1650,7 @@ static void hugetlb_unregister_all_nodes
  * Register hstate attributes for a single node sysdev.
  * No-op if attributes already registered.
  */
-void hugetlb_register_node(struct node *node)
+void __init hugetlb_register_node(struct node *node)
 {
 	struct hstate *h;
 	struct node_hstate *nhs = &node_hstates[node->sysdev.id];


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
