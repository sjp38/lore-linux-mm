Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3ECB06B026E
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:27:50 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id z13-v6so3725255wrq.3
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:27:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 132-v6sor1359887wmd.20.2018.07.19.06.27.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 06:27:49 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH v2 5/5] mm/page_alloc: Only call pgdat_set_deferred_range when the system boots
Date: Thu, 19 Jul 2018 15:27:40 +0200
Message-Id: <20180719132740.32743-6-osalvador@techadventures.net>
In-Reply-To: <20180719132740.32743-1-osalvador@techadventures.net>
References: <20180719132740.32743-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: pasha.tatashin@oracle.com, mhocko@suse.com, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

We should only care about deferred initialization when booting.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d77bc2a7ec2c..5911b64a88ab 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6419,7 +6419,8 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 				  zones_size, zholes_size);
 
 	alloc_node_mem_map(pgdat);
-	pgdat_set_deferred_range(pgdat);
+	if (system_state == SYSTEM_BOOTING)
+		pgdat_set_deferred_range(pgdat);
 
 	free_area_init_core(pgdat);
 }
-- 
2.13.6
