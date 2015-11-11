Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DF6846B0253
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 08:07:10 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so30764234pac.3
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 05:07:10 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id nc3si12719738pbc.24.2015.11.11.05.07.10
        for <linux-mm@kvack.org>;
        Wed, 11 Nov 2015 05:07:10 -0800 (PST)
Received: from nauris.fi.intel.com (nauris.localdomain [192.168.240.2])
	by paasikivi.fi.intel.com (Postfix) with ESMTP id 3C13D2022B
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 15:07:08 +0200 (EET)
From: Sakari Ailus <sakari.ailus@linux.intel.com>
Subject: [PATCH 1/1] mm: EXPORT_SYMBOL_GPL(find_vm_area);
Date: Wed, 11 Nov 2015 15:06:24 +0200
Message-Id: <1447247184-27939-1-git-send-email-sakari.ailus@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

find_vm_area() is needed in implementing the DMA mapping API as a module.
Device specific IOMMUs with associated DMA mapping implementations should be
buildable as modules.

Signed-off-by: Sakari Ailus <sakari.ailus@linux.intel.com>
---
 mm/vmalloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 2faaa29..d06db45 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1416,6 +1416,7 @@ struct vm_struct *find_vm_area(const void *addr)
 
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(find_vm_area);
 
 /**
  *	remove_vm_area  -  find and remove a continuous kernel virtual area
-- 
2.1.0.231.g7484e3b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
