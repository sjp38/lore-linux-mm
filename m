Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3DF8A6B0135
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 05:24:17 -0500 (EST)
Received: by pzk10 with SMTP id 10so693960pzk.11
        for <linux-mm@kvack.org>; Fri, 12 Mar 2010 02:24:07 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 12 Mar 2010 05:24:06 -0500
Message-ID: <cf18f8341003120224k243ff3fdq6d4a7acfe15dccc8@mail.gmail.com>
Subject: [Patch] mempolicy: remove redundant code
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org
List-ID: <linux-mm.kvack.org>

1. In funtion is_valid_nodemask(), varibable k will be inited to 0 in
the following loop, needn't init to policy_zone anymore.

2. (MPOL_F_STATIC_NODES | MPOL_F_RELATIVE_NODES) has already defined
to MPOL_MODE_FLAGS in mempolicy.h.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
 ---
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index bda230e..66d71f4 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -128,9 +128,6 @@ static int is_valid_nodemask(const nodemask_t *nodemask)
 {
        int nd, k;

-       /* Check that there is something useful in this mask */
-       k = policy_zone;
-
        for_each_node_mask(nd, *nodemask) {
                struct zone *z;

@@ -146,7 +143,7 @@ static int is_valid_nodemask(const nodemask_t *nodemask)

 static inline int mpol_store_user_nodemask(const struct mempolicy *pol)
 {
-       return pol->flags & (MPOL_F_STATIC_NODES | MPOL_F_RELATIVE_NODES);
+    return pol->flags & MPOL_MODE_FLAGS;
 }

 static void mpol_relative_nodemask(nodemask_t *ret, const nodemask_t *orig,
--
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
