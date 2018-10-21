Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 678036B000D
	for <linux-mm@kvack.org>; Sat, 20 Oct 2018 22:39:51 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id j9-v6so24039628plt.3
        for <linux-mm@kvack.org>; Sat, 20 Oct 2018 19:39:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e192-v6sor16621497pgc.33.2018.10.20.19.39.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Oct 2018 19:39:50 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm: remove reset of pcp->counter in pageset_init()
Date: Sun, 21 Oct 2018 10:39:20 +0800
Message-Id: <20181021023920.5501-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

per_cpu_pageset is cleared by memset, it is not necessary to reset it
again.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/page_alloc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 15ea511fb41c..730fadd9b639 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5647,7 +5647,6 @@ static void pageset_init(struct per_cpu_pageset *p)
 	memset(p, 0, sizeof(*p));
 
 	pcp = &p->pcp;
-	pcp->count = 0;
 	for (migratetype = 0; migratetype < MIGRATE_PCPTYPES; migratetype++)
 		INIT_LIST_HEAD(&pcp->lists[migratetype]);
 }
-- 
2.15.1
