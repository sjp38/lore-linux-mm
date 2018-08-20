Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F84D6B16E9
	for <linux-mm@kvack.org>; Sun, 19 Aug 2018 23:22:10 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u22-v6so13773170qkk.10
        for <linux-mm@kvack.org>; Sun, 19 Aug 2018 20:22:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b3-v6si3056046qva.64.2018.08.19.20.22.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Aug 2018 20:22:09 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/2] mm: thp: consolidate policy_nodemask call
Date: Sun, 19 Aug 2018 23:22:03 -0400
Message-Id: <20180820032204.9591-2-aarcange@redhat.com>
In-Reply-To: <20180820032204.9591-1-aarcange@redhat.com>
References: <20180820032204.9591-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

Just a minor cleanup.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/mempolicy.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 01f1a14facc4..d6512ef28cde 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2026,6 +2026,8 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		goto out;
 	}
 
+	nmask = policy_nodemask(gfp, pol);
+
 	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage)) {
 		int hpage_node = node;
 
@@ -2043,7 +2045,6 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 						!(pol->flags & MPOL_F_LOCAL))
 			hpage_node = pol->v.preferred_node;
 
-		nmask = policy_nodemask(gfp, pol);
 		if (!nmask || node_isset(hpage_node, *nmask)) {
 			mpol_cond_put(pol);
 			page = __alloc_pages_node(hpage_node,
@@ -2052,7 +2053,6 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		}
 	}
 
-	nmask = policy_nodemask(gfp, pol);
 	preferred_nid = policy_node(gfp, pol, node);
 	page = __alloc_pages_nodemask(gfp, order, preferred_nid, nmask);
 	mpol_cond_put(pol);
