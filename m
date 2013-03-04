Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id B1C466B0002
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 05:46:31 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id e53so3662097eek.26
        for <linux-mm@kvack.org>; Mon, 04 Mar 2013 02:46:30 -0800 (PST)
From: Claudiu Ghioc <claudiughioc@gmail.com>
Subject: [PATCH] hugetlb: fix sparse warning for hugetlb_register_node
Date: Mon,  4 Mar 2013 12:46:15 +0200
Message-Id: <1362393975-22533-1-git-send-email-claudiu.ghioc@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, dhillf@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Claudiu Ghioc <claudiu.ghioc@gmail.com>

Removed the following sparse warnings:
*  mm/hugetlb.c:1764:6: warning: symbol
    'hugetlb_unregister_node' was not declared.
    Should it be static?
*   mm/hugetlb.c:1808:6: warning: symbol
    'hugetlb_register_node' was not declared.
    Should it be static?

Signed-off-by: Claudiu Ghioc <claudiu.ghioc@gmail.com>
---
 mm/hugetlb.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 0a0be33..c65a8a5 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1761,7 +1761,7 @@ static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
  * Unregister hstate attributes from a single node device.
  * No-op if no hstate attributes attached.
  */
-void hugetlb_unregister_node(struct node *node)
+static void hugetlb_unregister_node(struct node *node)
 {
 	struct hstate *h;
 	struct node_hstate *nhs = &node_hstates[node->dev.id];
@@ -1805,7 +1805,7 @@ static void hugetlb_unregister_all_nodes(void)
  * Register hstate attributes for a single node device.
  * No-op if attributes already registered.
  */
-void hugetlb_register_node(struct node *node)
+static void hugetlb_register_node(struct node *node)
 {
 	struct hstate *h;
 	struct node_hstate *nhs = &node_hstates[node->dev.id];
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
