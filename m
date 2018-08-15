Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id B1EAB6B000E
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 10:42:33 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id p12-v6so1018918wro.7
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 07:42:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h6-v6sor8279655wre.67.2018.08.15.07.42.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Aug 2018 07:42:32 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH v3 4/4] mm/memory_hotplug: Drop node_online check in unregister_mem_sect_under_nodes
Date: Wed, 15 Aug 2018 16:42:19 +0200
Message-Id: <20180815144219.6014-5-osalvador@techadventures.net>
In-Reply-To: <20180815144219.6014-1-osalvador@techadventures.net>
References: <20180815144219.6014-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

We are getting the nid from the pages that are not yet removed,
but a node can only be offline when its memory/cpu's have been removed.
Therefore, we know that the node is still online.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 drivers/base/node.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 81b27b5b1f15..b23769e4fcbb 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -465,8 +465,6 @@ void unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 
 		if (nid < 0)
 			continue;
-		if (!node_online(nid))
-			continue;
 		/*
 		 * It is possible that NODEMASK_ALLOC fails due to memory
 		 * pressure.
-- 
2.13.6
