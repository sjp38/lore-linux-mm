Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 58D996B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 09:43:33 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e4so77382506pfg.4
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 06:43:33 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id i19si5749466pgk.288.2017.01.23.06.43.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 06:43:32 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id 75so13905111pgf.3
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 06:43:32 -0800 (PST)
From: "seokhoon.yoon" <iamyooon@gmail.com>
Subject: [PATCH 1/1] mm: fix comments for mmap_init()
Date: Mon, 23 Jan 2017 23:43:21 +0900
Message-Id: <1485182601-9294-1-git-send-email-iamyooon@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

mmap_init() is no longer associated with VMA slab. so fix it.

Signed-off-by: seokhoon.yoon <iamyooon@gmail.com>
---
 mm/mmap.c  | 2 +-
 mm/nommu.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index dc4291d..3794ada 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3433,7 +3433,7 @@ void mm_drop_all_locks(struct mm_struct *mm)
 }
 
 /*
- * initialise the VMA slab
+ * initialise the percpu counter for VM
  */
 void __init mmap_init(void)
 {
diff --git a/mm/nommu.c b/mm/nommu.c
index 24f9f5f..fd6b50a 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -517,7 +517,7 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 }
 
 /*
- * initialise the VMA and region record slabs
+ * initialise the percpu counter for VM and region record slabs
  */
 void __init mmap_init(void)
 {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
