Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8ECAE6B0005
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 11:29:38 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v2-v6so7229730wrr.10
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 08:29:38 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e17-v6sor3961802wri.46.2018.08.10.08.29.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Aug 2018 08:29:36 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH 2/3] mm/memory_hotplug: Drop unneeded check from unregister_mem_sect_under_nodes
Date: Fri, 10 Aug 2018 17:29:30 +0200
Message-Id: <20180810152931.23004-3-osalvador@techadventures.net>
In-Reply-To: <20180810152931.23004-1-osalvador@techadventures.net>
References: <20180810152931.23004-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, david@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

Before calling to unregister_mem_sect_under_nodes(),
remove_memory_section() already checks if we got a valid
memory_block.

No need to check that again in unregister_mem_sect_under_nodes().

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 drivers/base/node.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 1ac4c36e13bb..dd3bdab230b2 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -455,10 +455,6 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
 
-	if (!mem_blk) {
-		NODEMASK_FREE(unlinked_nodes);
-		return -EFAULT;
-	}
 	if (!unlinked_nodes)
 		return -ENOMEM;
 	nodes_clear(*unlinked_nodes);
-- 
2.13.6
