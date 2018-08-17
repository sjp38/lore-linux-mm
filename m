Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 150B06B074F
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 05:00:26 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q26-v6so687743wmc.0
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 02:00:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 68-v6sor752708wmj.38.2018.08.17.02.00.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Aug 2018 02:00:24 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH v4 4/4] mm/memory_hotplug: Drop node_online check in unregister_mem_sect_under_nodes
Date: Fri, 17 Aug 2018 11:00:17 +0200
Message-Id: <20180817090017.17610-5-osalvador@techadventures.net>
In-Reply-To: <20180817090017.17610-1-osalvador@techadventures.net>
References: <20180817090017.17610-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

We are getting the nid from the pages that are not yet removed,
but a node can only be offline when its memory/cpu's have been removed.
Therefore, we know that the node is still online.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Reviewed-by: David Hildenbrand <david@redhat.com>
Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
---
 drivers/base/node.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 6b8c9b4537c9..01e9190be010 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -464,8 +464,6 @@ void unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 
 		if (nid < 0)
 			continue;
-		if (!node_online(nid))
-			continue;
 		if (node_test_and_set(nid, unlinked_nodes))
 			continue;
 
-- 
2.13.6
