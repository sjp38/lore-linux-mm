Received: by wf-out-1314.google.com with SMTP id 28so2907773wfc.11
        for <linux-mm@kvack.org>; Mon, 12 May 2008 03:32:27 -0700 (PDT)
From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 4/4] [MM/NOMMU]: Export two symbols in nommu.c for mmap test
Date: Mon, 12 May 2008 18:32:05 +0800
Message-Id: <1210588325-11027-5-git-send-email-cooloney@kernel.org>
In-Reply-To: <1210588325-11027-1-git-send-email-cooloney@kernel.org>
References: <1210588325-11027-1-git-send-email-cooloney@kernel.org>
Sender: owner-linux-mm@kvack.org
From: Vivi Li <vivi.li@analog.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dwmw2@infradead.org
Cc: Vivi Li <vivi.li@analog.com>, Bryan Wu <cooloney@kernel.org>
List-ID: <linux-mm.kvack.org>

http://blackfin.uclinux.org/gf/project/uclinux-dist/tracker/?action=TrackerItemEdit&tracker_item_id=2312

Signed-off-by: Vivi Li <vivi.li@analog.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 mm/nommu.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index 56bb447..cef9d75 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -47,6 +47,8 @@ int heap_stack_gap = 0;
 
 EXPORT_SYMBOL(mem_map);
 EXPORT_SYMBOL(num_physpages);
+EXPORT_SYMBOL(high_memory);
+EXPORT_SYMBOL(max_mapnr);
 
 /* list of shareable VMAs */
 struct rb_root nommu_vma_tree = RB_ROOT;
-- 
1.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
