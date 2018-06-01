Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 75C2F6B000C
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 08:54:14 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id l17-v6so13699565wrm.3
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 05:54:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c3-v6sor20640075wrd.32.2018.06.01.05.54.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Jun 2018 05:54:13 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH 4/4] mm/memory_hotplug: Drop unnecessary checks from register_mem_sect_under_node
Date: Fri,  1 Jun 2018 14:53:21 +0200
Message-Id: <20180601125321.30652-5-osalvador@techadventures.net>
In-Reply-To: <20180601125321.30652-1-osalvador@techadventures.net>
References: <20180601125321.30652-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

Callers of register_mem_sect_under_node() are always passing a valid
memory_block (not NULL), so we can safely drop the check for NULL.

In the same way, register_mem_sect_under_node() is only called in case
the node is online, so we can safely remove that check as well.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 drivers/base/node.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 248c712e8de5..681be04351bc 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -415,12 +415,7 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid,
 	int ret;
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
 
-	if (!mem_blk)
-		return -EFAULT;
-
 	mem_blk->nid = nid;
-	if (!node_online(nid))
-		return 0;
 
 	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
 	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
-- 
2.13.6
