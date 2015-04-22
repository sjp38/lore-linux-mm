Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id A105A6B006C
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 04:52:58 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so267984277pdb.1
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 01:52:58 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id es10si6759403pac.102.2015.04.22.01.52.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 01:52:56 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NN700418A5GAW40@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Apr 2015 09:56:04 +0100 (BST)
From: Marcin Jabrzyk <m.jabrzyk@samsung.com>
Subject: [PATCH v2 2/2] zsmalloc: remove obsolete ZSMALLOC_DEBUG
Date: Wed, 22 Apr 2015 10:52:36 +0200
Message-id: <1429692756-15197-3-git-send-email-m.jabrzyk@samsung.com>
In-reply-to: <1429692756-15197-1-git-send-email-m.jabrzyk@samsung.com>
References: <1429615220-20676-1-git-send-email-m.jabrzyk@samsung.com>
 <1429692756-15197-1-git-send-email-m.jabrzyk@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kyungmin.park@samsung.com, Marcin Jabrzyk <m.jabrzyk@samsung.com>

The DEBUG define in zsmalloc is useless, there
is no usage of it at all.

Signed-off-by: Marcin Jabrzyk <m.jabrzyk@samsung.com>
---
 mm/zsmalloc.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 08bd7a3d464a..33d512646379 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -45,10 +45,6 @@
  *
  */
 
-#ifdef CONFIG_ZSMALLOC_DEBUG
-#define DEBUG
-#endif
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
