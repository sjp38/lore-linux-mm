Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 464AC6B0006
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 11:48:58 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c188so1600016wma.7
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 08:48:58 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id d19si1578934wmh.18.2018.02.23.08.48.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Feb 2018 08:48:57 -0800 (PST)
From: Colin King <colin.king@canonical.com>
Subject: [PATCH][mm-next] mm, swap: make bool enable_vma_readahead and function swap_vma_readahead static
Date: Fri, 23 Feb 2018 16:48:52 +0000
Message-Id: <20180223164852.5159-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The bool enable_vma_readahead and function swap_vma_readahead are local
to the source and do not need to be in global scope, so make them static.

Cleans up sparse warnings:
mm/swap_state.c:41:6: warning: symbol 'enable_vma_readahead' was not
declared. Should it be static?
mm/swap_state.c:742:13: warning: symbol 'swap_vma_readahead' was not
declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 mm/swap_state.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 8dde719e973c..f3952138f01d 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -38,7 +38,7 @@ static const struct address_space_operations swap_aops = {
 
 struct address_space *swapper_spaces[MAX_SWAPFILES] __read_mostly;
 static unsigned int nr_swapper_spaces[MAX_SWAPFILES] __read_mostly;
-bool enable_vma_readahead __read_mostly = true;
+static bool enable_vma_readahead __read_mostly = true;
 
 #define SWAP_RA_WIN_SHIFT	(PAGE_SHIFT / 2)
 #define SWAP_RA_HITS_MASK	((1UL << SWAP_RA_WIN_SHIFT) - 1)
@@ -739,8 +739,8 @@ static void swap_ra_info(struct vm_fault *vmf,
 	pte_unmap(orig_pte);
 }
 
-struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
-				    struct vm_fault *vmf)
+static struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
+				       struct vm_fault *vmf)
 {
 	struct blk_plug plug;
 	struct vm_area_struct *vma = vmf->vma;
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
