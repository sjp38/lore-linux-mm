Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F36F46B010C
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 08:46:30 -0400 (EDT)
Received: by pxi34 with SMTP id 34so1509674pxi.22
        for <linux-mm@kvack.org>; Thu, 18 Mar 2010 05:46:28 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 1/2] mempolicy:del case MPOL_INTERLEAVE in policy_zonelist()
Date: Thu, 18 Mar 2010 20:46:16 +0800
Message-Id: <1268916376-8695-1-git-send-email-user@bob-laptop>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

From: Bob Liu <lliubbo@gmail.com>

In policy_zonelist() mode MPOL_INTERLEAVE shouldn't happen,
so fall through to BUG() instead of break to return.I also fix
the comment.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/mempolicy.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 643f66e..b88e914 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1441,15 +1441,13 @@ static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy)
 		/*
 		 * Normally, MPOL_BIND allocations are node-local within the
 		 * allowed nodemask.  However, if __GFP_THISNODE is set and the
-		 * current node is part of the mask, we use the zonelist for
+		 * current node isn't part of the mask, we use the zonelist for
 		 * the first node in the mask instead.
 		 */
 		if (unlikely(gfp & __GFP_THISNODE) &&
 				unlikely(!node_isset(nd, policy->v.nodes)))
 			nd = first_node(policy->v.nodes);
 		break;
-	case MPOL_INTERLEAVE: /* should not happen */
-		break;
 	default:
 		BUG();
 	}
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
