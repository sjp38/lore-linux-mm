Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3E5D36B0177
	for <linux-mm@kvack.org>; Sun, 14 Mar 2010 07:50:42 -0400 (EDT)
Received: by pwj9 with SMTP id 9so1365518pwj.14
        for <linux-mm@kvack.org>; Sun, 14 Mar 2010 04:50:40 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] mempolicy: remove redundant code
Date: Sun, 14 Mar 2010 19:50:18 +0800
Message-Id: <1268567418-8700-1-git-send-email-user@bob-laptop>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

From: Bob Liu <lliubbo@gmail.com>

1. In funtion is_valid_nodemask(), varibable k will be inited to 0 in
the following loop, needn't init to policy_zone anymore.

2. (MPOL_F_STATIC_NODES | MPOL_F_RELATIVE_NODES) has already defined
to MPOL_MODE_FLAGS in mempolicy.h.
---
 mempolicy.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index bda230e..b6fbcbd 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -128,9 +128,6 @@ static int is_valid_nodemask(const nodemask_t *nodemask)
 {
 	int nd, k;
 
-	/* Check that there is something useful in this mask */
-	k = policy_zone;
-
 	for_each_node_mask(nd, *nodemask) {
 		struct zone *z;
 
@@ -146,7 +143,7 @@ static int is_valid_nodemask(const nodemask_t *nodemask)
 
 static inline int mpol_store_user_nodemask(const struct mempolicy *pol)
 {
-	return pol->flags & (MPOL_F_STATIC_NODES | MPOL_F_RELATIVE_NODES);
+	return pol->flags & MPOL_MODE_FLAGS;
 }
 
 static void mpol_relative_nodemask(nodemask_t *ret, const nodemask_t *orig,
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
