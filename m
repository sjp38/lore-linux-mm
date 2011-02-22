Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 60E508D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 05:51:33 -0500 (EST)
Received: by iyf13 with SMTP id 13so3691552iyf.14
        for <linux-mm@kvack.org>; Tue, 22 Feb 2011 02:51:31 -0800 (PST)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH] mempolicy: remove redundant check in __mpol_equal()
Date: Tue, 22 Feb 2011 19:51:17 +0900
Message-Id: <1298371877-2906-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Liu <lliubbo@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>

The 'flags' field is already checked, no need to do it again.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
Cc: Bob Liu <lliubbo@gmail.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
---
 mm/mempolicy.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 368fc9d23610..4244e4988e66 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1979,8 +1979,7 @@ int __mpol_equal(struct mempolicy *a, struct mempolicy *b)
 	case MPOL_INTERLEAVE:
 		return nodes_equal(a->v.nodes, b->v.nodes);
 	case MPOL_PREFERRED:
-		return a->v.preferred_node == b->v.preferred_node &&
-			a->flags == b->flags;
+		return a->v.preferred_node == b->v.preferred_node;
 	default:
 		BUG();
 		return 0;
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
