Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E5C546B015F
	for <linux-mm@kvack.org>; Sat, 13 Mar 2010 00:02:15 -0500 (EST)
Received: by pxi34 with SMTP id 34so972553pxi.22
        for <linux-mm@kvack.org>; Fri, 12 Mar 2010 21:02:13 -0800 (PST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] mempolicy: remove redundant code
Date: Sat, 13 Mar 2010 13:01:54 +0800
Message-Id: <1268456515-8557-1-git-send-email-user@bob-laptop>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

From: Bob Liu <lliubbo@gmail.com>

1. In funtion is_valid_nodemask(), varibable k will be inited to 0 in
the following loop, needn't init to policy_zone anymore.

2. (MPOL_F_STATIC_NODES | MPOL_F_RELATIVE_NODES) has already defined
to MPOL_MODE_FLAGS in mempolicy.h.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mempolicy.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/mempolicy.c b/mempolicy.c
index bda230e..b6fbcbd 100644
--- a/mempolicy.c
+++ b/mempolicy.c
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
