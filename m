Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3618E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 23:50:00 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id ay11so20558960plb.20
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 20:50:00 -0800 (PST)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id i20si42118143pgh.187.2018.12.29.20.49.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Dec 2018 20:49:58 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v4 PATCH 2/2] mm: swap: add comment for swap_vma_readahead
Date: Sun, 30 Dec 2018 12:49:35 +0800
Message-Id: <1546145375-793-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1546145375-793-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1546145375-793-1-git-send-email-yang.shi@linux.alibaba.com>
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
