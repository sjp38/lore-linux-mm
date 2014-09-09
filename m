Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 645226B0036
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 22:09:10 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kq14so1336511pab.39
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 19:09:10 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id zi3si20300800pbb.217.2014.09.08.19.09.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 08 Sep 2014 19:09:09 -0700 (PDT)
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
Subject: [PATCH] memory-hotplug: fix below build warning
Date: Tue, 9 Sep 2014 10:11:43 +0800
Message-ID: <1410228703-2496-1-git-send-email-zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, wangnan0@huawei.com

drivers/base/memory.c: In function 'show_valid_zones':
drivers/base/memory.c:384:22: warning: unused variable 'zone_prev' [-Wunused-variable]
  struct zone *zone, *zone_prev;
                      ^

Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
---
 drivers/base/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index efd456c..7c5d871 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -381,7 +381,7 @@ static ssize_t show_valid_zones(struct device *dev,
 	unsigned long start_pfn, end_pfn;
 	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
 	struct page *first_page;
-	struct zone *zone, *zone_prev;
+	struct zone *zone;
 
 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
 	end_pfn = start_pfn + nr_pages;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
