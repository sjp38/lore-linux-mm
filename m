Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 95D9C8E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 14:29:53 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 82so35459991pfs.20
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 11:29:53 -0800 (PST)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id o6si3864554plh.23.2019.01.03.11.29.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 11:29:52 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v5 PATCH 2/2] mm: swap: add comment for swap_vma_readahead
Date: Fri,  4 Jan 2019 03:27:53 +0800
Message-Id: <1546543673-108536-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1546543673-108536-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1546543673-108536-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ying.huang@intel.com, tim.c.chen@intel.com, minchan@kernel.org, daniel.m.jordan@oracle.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

swap_vma_readahead()'s comment is missed, just add it.

Cc: Huang Ying <ying.huang@intel.com>
Cc: Tim Chen <tim.c.chen@intel.com>
Cc: Minchan Kim <minchan@kernel.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
v5: Fixed the comments per Ying Huang

 mm/swap_state.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 78d500e..c8730d7 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -523,7 +523,7 @@ static unsigned long swapin_nr_pages(unsigned long offset)
  * This has been extended to use the NUMA policies from the mm triggering
  * the readahead.
  *
- * Caller must hold down_read on the vma->vm_mm if vmf->vma is not NULL.
+ * Caller must hold read mmap_sem if vmf->vma is not NULL.
  */
 struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
 				struct vm_fault *vmf)
@@ -698,6 +698,20 @@ static void swap_ra_info(struct vm_fault *vmf,
 	pte_unmap(orig_pte);
 }
 
+/**
+ * swap_vma_readahead - swap in pages in hope we need them soon
+ * @entry: swap entry of this memory
+ * @gfp_mask: memory allocation flags
+ * @vmf: fault information
+ *
+ * Returns the struct page for entry and addr, after queueing swapin.
+ *
+ * Primitive swap readahead code. We simply read in a few pages whoes
+ * virtual addresses are around the fault address in the same vma.
+ *
+ * Caller must hold read mmap_sem if vmf->vma is not NULL.
+ *
+ */
 static struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 				       struct vm_fault *vmf)
 {
-- 
1.8.3.1
