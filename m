Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id CF3C96B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 04:00:08 -0500 (EST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Tue, 14 Feb 2012 08:55:12 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1E8xppv1495072
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 19:59:51 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1E8xp8T007595
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 19:59:51 +1100
Message-ID: <4F3A2285.7060700@linux.vnet.ibm.com>
Date: Tue, 14 Feb 2012 16:59:49 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 1/4] prio_tree: remove unnecessary code in prio_tree_replace
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Remove the code since 'node' has already been initialized in the
begin of the function

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 lib/prio_tree.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/prio_tree.c b/lib/prio_tree.c
index ccfd850..423eba8 100644
--- a/lib/prio_tree.c
+++ b/lib/prio_tree.c
@@ -151,7 +151,6 @@ struct prio_tree_node *prio_tree_replace(struct prio_tree_root *root,
 		 * We can reduce root->index_bits here. However, it is complex
 		 * and does not help much to improve performance (IMO).
 		 */
-		node->parent = node;
 		root->prio_tree_node = node;
 	} else {
 		node->parent = old->parent;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
