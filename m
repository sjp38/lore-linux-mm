Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 493A96B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 20:20:46 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id hb4so957321pac.3
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 17:20:46 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id n10si6357421pay.80.2016.04.18.17.20.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 17:20:45 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id 184so361516pff.0
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 17:20:45 -0700 (PDT)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH] mm: thp: simplify the implementation of mk_huge_pmd
Date: Mon, 18 Apr 2016 16:55:00 -0700
Message-Id: <1461023700-5851-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, hughd@google.com, mgorman@suse.de
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

The implementation of mk_huge_pmd looks verbose, it could be just simplified
to one line code.

Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 mm/huge_memory.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 8adf3c2..fecbbc5 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -764,10 +764,7 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
 
 static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
 {
-	pmd_t entry;
-	entry = mk_pmd(page, prot);
-	entry = pmd_mkhuge(entry);
-	return entry;
+	return pmd_mkhuge(mk_pmd(page, prot));
 }
 
 static inline struct list_head *page_deferred_list(struct page *page)
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
