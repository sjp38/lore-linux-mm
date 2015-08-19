Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C97186B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 05:21:54 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so153766308pab.0
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 02:21:54 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id c11si97425pat.225.2015.08.19.02.21.53
        for <linux-mm@kvack.org>;
        Wed, 19 Aug 2015 02:21:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 1/5] mm: drop page->slab_page
Date: Wed, 19 Aug 2015 12:21:42 +0300
Message-Id: <1439976106-137226-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andi Kleen <ak@linux.intel.com>

Since 8456a648cf44 ("slab: use struct page for slab management") nobody
uses slab_page field in struct page.

Let's drop it.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andi Kleen <ak@linux.intel.com>
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
