Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 94C7A6B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 03:39:34 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c4so204726430pfb.7
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 00:39:34 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id d30si25567667plj.183.2016.11.28.00.39.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 00:39:33 -0800 (PST)
Date: Mon, 28 Nov 2016 16:39:31 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH 1/2] tlb: export tlb_flush_mmu_tlbonly
Message-ID: <20161128083931.GB21738@aaronlu.sh.intel.com>
References: <026b73f6-ca1d-e7bb-766c-4aaeb7071ce6@intel.com>
 <CA+55aFzHfpZckv8ck19fZSFK+3TmR5eF=BsDzhwVGKrbyEBjEw@mail.gmail.com>
 <c160bc18-7c1b-2d54-8af1-7c5bfcbcefe8@intel.com>
 <20161128083715.GA21738@aaronlu.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161128083715.GA21738@aaronlu.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org

The mmu gather logic for tlb flush will be used in mremap case so export
this function.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 include/asm-generic/tlb.h | 1 +
 mm/memory.c               | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index c6d667187608..0f1861db935c 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -119,6 +119,7 @@ struct mmu_gather {
 
 void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start, unsigned long end);
 void tlb_flush_mmu(struct mmu_gather *tlb);
+void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb);
 void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start,
 							unsigned long end);
 extern bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page,
diff --git a/mm/memory.c b/mm/memory.c
index e18c57bdc75c..130d82f7d8a2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -238,7 +238,7 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long
 	__tlb_reset_range(tlb);
 }
 
-static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
+void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 {
 	if (!tlb->end)
 		return;
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
