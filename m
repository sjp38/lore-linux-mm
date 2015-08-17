Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id AF92C6B0254
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 11:09:14 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so57404073pdr.0
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 08:09:14 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id yb5si25030888pab.209.2015.08.17.08.09.13
        for <linux-mm@kvack.org>;
        Mon, 17 Aug 2015 08:09:13 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 1/4] mm: drop page->slab_page
Date: Mon, 17 Aug 2015 18:09:02 +0300
Message-Id: <1439824145-25397-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1439824145-25397-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1439824145-25397-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andi Kleen <ak@linux.intel.com>, Christoph Lameter <cl@linux.com>

Since 8456a648cf44 ("slab: use struct page for slab management") nobody
uses slab_page field in struct page.

Let's drop it.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Christoph Lameter <cl@linux.com>
---
 include/linux/mm_types.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 0038ac7466fd..58620ac7f15c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -140,7 +140,6 @@ struct page {
 #endif
 		};
 
-		struct slab *slab_page; /* slab fields */
 		struct rcu_head rcu_head;	/* Used by SLAB
 						 * when destroying via RCU
 						 */
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
