Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3578E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 10:15:34 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 2-v6so10072153plc.11
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 07:15:34 -0700 (PDT)
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id h23-v6si15708874pgv.356.2018.09.10.07.15.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 07:15:33 -0700 (PDT)
From: zhong jiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: Use BUG_ON directly instead of a if condition followed by BUG
Date: Mon, 10 Sep 2018 22:03:17 +0800
Message-ID: <1536588197-22115-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, pasha.tatashin@oracle.com, dan.j.williams@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The if condition can be removed if we use BUG_ON directly.
The issule is detected with the help of Coccinelle.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/memory_hotplug.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 38d94b7..280b26c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1888,8 +1888,7 @@ void __ref remove_memory(int nid, u64 start, u64 size)
 	 */
 	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
 				check_memblock_offlined_cb);
-	if (ret)
-		BUG();
+	BUG(ret);
 
 	/* remove memmap entry */
 	firmware_map_remove(start, start + size, "System RAM");
-- 
1.7.12.4
