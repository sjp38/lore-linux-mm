Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6656B02F2
	for <linux-mm@kvack.org>; Tue,  2 May 2017 09:16:25 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q4so4285372pga.4
        for <linux-mm@kvack.org>; Tue, 02 May 2017 06:16:25 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id n11si14647337pgd.201.2017.05.02.06.16.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 06:16:24 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id b23so17226263pfc.0
        for <linux-mm@kvack.org>; Tue, 02 May 2017 06:16:24 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/nobootmem: return 0 when start_pfn equals end_pfn
Date: Tue,  2 May 2017 21:11:15 +0800
Message-Id: <20170502131115.6650-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

When start_pfn equals end_pfn, __free_pages_memory() takes no effect and
__free_memory_core() will finally return (end_pfn - start_pfn) = 0.

This patch returns 0 directly when start_pfn equals end_pfn.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/nobootmem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 487dad610731..36454d0f96ee 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -118,7 +118,7 @@ static unsigned long __init __free_memory_core(phys_addr_t start,
 	unsigned long end_pfn = min_t(unsigned long,
 				      PFN_DOWN(end), max_low_pfn);
 
-	if (start_pfn > end_pfn)
+	if (start_pfn >= end_pfn)
 		return 0;
 
 	__free_pages_memory(start_pfn, end_pfn);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
