Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f178.google.com (mail-gg0-f178.google.com [209.85.161.178])
	by kanga.kvack.org (Postfix) with ESMTP id D5B2E6B0035
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 06:26:06 -0500 (EST)
Received: by mail-gg0-f178.google.com with SMTP id n5so2768706ggj.9
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 03:26:06 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id s23si29067087yhf.3.2014.01.02.03.26.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Jan 2014 03:26:05 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id bj1so14455680pad.30
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 03:26:04 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Subject: [PATCH] mm: page_alloc: use enum instead of number for migratetype
Date: Thu,  2 Jan 2014 20:25:22 +0900
Message-Id: <1388661922-10957-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, SeongJae Park <sj38.park@gmail.com>

Using enum instead of number for migratetype everywhere would be better
for reading and understanding.

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
---
 mm/page_alloc.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5bcbca5..08f6ed7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -646,7 +646,7 @@ static inline int free_pages_check(struct page *page)
 static void free_pcppages_bulk(struct zone *zone, int count,
 					struct per_cpu_pages *pcp)
 {
-	int migratetype = 0;
+	int migratetype = MIGRATE_UNMOVABLE;
 	int batch_free = 0;
 	int to_free = count;
 
@@ -667,7 +667,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 		do {
 			batch_free++;
 			if (++migratetype == MIGRATE_PCPTYPES)
-				migratetype = 0;
+				migratetype = MIGRATE_UNMOVABLE;
 			list = &pcp->lists[migratetype];
 		} while (list_empty(list));
 
@@ -4158,7 +4158,9 @@ static void pageset_init(struct per_cpu_pageset *p)
 
 	pcp = &p->pcp;
 	pcp->count = 0;
-	for (migratetype = 0; migratetype < MIGRATE_PCPTYPES; migratetype++)
+
+	for (migratetype = MIGRATE_UNMOVABLE; migratetype < MIGRATE_PCPTYPES;
+						migratetype++)
 		INIT_LIST_HEAD(&pcp->lists[migratetype]);
 }
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
