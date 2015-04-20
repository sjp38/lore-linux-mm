Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 552BC6B0032
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 14:09:56 -0400 (EDT)
Received: by paboj16 with SMTP id oj16so214122774pab.0
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 11:09:56 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id td4si29167695pbc.224.2015.04.20.11.09.55
        for <linux-mm@kvack.org>;
        Mon, 20 Apr 2015 11:09:55 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] mm, hwpoison: Remove obsolete "Notebook" todo list
Date: Mon, 20 Apr 2015 11:09:43 -0700
Message-Id: <1429553383-11466-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

All the items mentioned here have been either addressed, or were
not really needed. So just remove the comment.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/memory-failure.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index d487f8d..25c2054 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -28,13 +28,6 @@
  * are rare we hope to get away with this. This avoids impacting the core 
  * VM.
  */
-
-/*
- * Notebook:
- * - hugetlb needs more code
- * - kcore/oldmem/vmcore/mem/kmem check for hwpoison pages
- * - pass bad pages to kdump next kernel
- */
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/page-flags.h>
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
