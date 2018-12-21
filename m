Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 392578E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 16:47:00 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b8so6145742pfe.10
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 13:47:00 -0800 (PST)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id d23si22376637pgm.559.2018.12.21.13.46.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 13:46:58 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v3 PATCH 2/2] mm: swap: add comment for swap_vma_readahead
Date: Sat, 22 Dec 2018 05:40:20 +0800
Message-Id: <1545428420-126557-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1545428420-126557-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1545428420-126557-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ying.huang@intel.com, tim.c.chen@intel.com, minchan@kernel.org, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

swap_vma_readahead()'s comment is missed, just add it.

Cc: Huang Ying <ying.huang@intel.com>
Cc: Tim Chen <tim.c.chen@intel.com>
Cc: Minchan Kim <minchan@kernel.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/swap_state.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 78d500e..dd8f698 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -698,6 +698,23 @@ static void swap_ra_info(struct vm_fault *vmf,
 	pte_unmap(orig_pte);
 }
 
+/**
+ * swap_vm_readahead - swap in pages in hope we need them soon
+ * @entry: swap entry of this memory
+ * @gfp_mask: memory allocation flags
+ * @vmf: fault information
+ *
+ * Returns the struct page for entry and addr, after queueing swapin.
+ *
+ * Primitive swap readahead code. We simply read in a few pages whoes
+ * virtual addresses are around the fault address in the same vma.
+ *
+ * This has been extended to use the NUMA policies from the mm triggering
+ * the readahead.
+ *
+ * Caller must hold down_read on the vma->vm_mm if vmf->vma is not NULL.
+ *
+ */
 static struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 				       struct vm_fault *vmf)
 {
-- 
1.8.3.1
