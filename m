Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 291596B000A
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 00:25:34 -0500 (EST)
Received: by mail-qe0-f49.google.com with SMTP id 1so1122586qec.22
        for <linux-mm@kvack.org>; Wed, 27 Feb 2013 21:25:33 -0800 (PST)
From: kosaki.motohiro@gmail.com
Subject: [PATCH 2/2] mempolicy: fix typo
Date: Thu, 28 Feb 2013 00:25:07 -0500
Message-Id: <1362029107-3908-2-git-send-email-kosaki.motohiro@gmail.com>
In-Reply-To: <CAJd=RBBxTutPsF+XPZGt44eT1f0uPAQfCvQj_UmwdDg82J=F+A@mail.gmail.com>
References: <CAJd=RBBxTutPsF+XPZGt44eT1f0uPAQfCvQj_UmwdDg82J=F+A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, Hillf Danton <dhillf@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Currently, n_new is wrongly initialized. start and end parameter
are inverted. Let's fix it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/mempolicy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 868d08f..7431001 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2390,7 +2390,7 @@ static int shared_policy_replace(struct shared_policy *sp, unsigned long start,
 
 				*mpol_new = *n->policy;
 				atomic_set(&mpol_new->refcnt, 1);
-				sp_node_init(n_new, n->end, end, mpol_new);
+				sp_node_init(n_new, end, n->end, mpol_new);
 				n->end = start;
 				sp_insert(sp, n_new);
 				n_new = NULL;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
