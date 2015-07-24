Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7226B0255
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 10:46:03 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so31112511wib.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 07:46:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i7si4611850wiz.121.2015.07.24.07.45.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 07:45:56 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC v2 3/4] mm: use numa_mem_id in alloc_pages_node()
Date: Fri, 24 Jul 2015 16:45:25 +0200
Message-Id: <1437749126-25867-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1437749126-25867-1-git-send-email-vbabka@suse.cz>
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>

numa_mem_id() is able to handle allocation from CPU's on memory-less nodes,
so it's a more robust fallback than the currently used numa_node_id().

Suggested-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/gfp.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 54c3ee7..531c72d 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -322,7 +322,7 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 {
 	/* Unknown node is current (or closest) node */
 	if (nid == NUMA_NO_NODE)
-		nid = numa_node_id();
+		nid = numa_mem_id();
 
 	return __alloc_pages_node(nid, gfp_mask, order);
 }
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
