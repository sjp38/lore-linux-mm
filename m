Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9824A6B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 03:42:21 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id fp1so4532439pdb.9
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 00:42:21 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id pb4si12065931pac.482.2014.04.29.00.42.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 00:42:20 -0700 (PDT)
Received: by mail-pd0-f174.google.com with SMTP id z10so5833099pdj.5
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 00:42:20 -0700 (PDT)
Message-ID: <535F57D5.7030606@gmail.com>
Date: Tue, 29 Apr 2014 15:42:13 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] bootmem: trivial cleanup the comment for BOOTMEM_ flags
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org


Use BOOTMEM_DEFAULT instead of 0 in the comment.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 include/linux/bootmem.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index db51fe4..4e2bd4c 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -58,9 +58,9 @@ extern void free_bootmem_late(unsigned long physaddr, unsigned long size);
  * Flags for reserve_bootmem (also if CONFIG_HAVE_ARCH_BOOTMEM_NODE,
  * the architecture-specific code should honor this).
  *
- * If flags is 0, then the return value is always 0 (success). If
- * flags contains BOOTMEM_EXCLUSIVE, then -EBUSY is returned if the
- * memory already was reserved.
+ * If flags is BOOTMEM_DEFAULT, then the return value is always 0 (success).
+ * If flags contains BOOTMEM_EXCLUSIVE, then -EBUSY is returned if the memory
+ * already was reserved.
  */
 #define BOOTMEM_DEFAULT                0
 #define BOOTMEM_EXCLUSIVE      (1<<0)
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
