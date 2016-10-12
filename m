Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 904956B0069
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 22:24:58 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id k64so53836559itb.5
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 19:24:58 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0009.hostedemail.com. [216.40.44.9])
        by mx.google.com with ESMTPS id w67si22398308itb.10.2016.10.11.19.24.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 19:24:57 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH] mm: page_alloc: Use KERN_CONT where appropriate
Date: Tue, 11 Oct 2016 19:24:55 -0700
Message-Id: <c7df37c8665134654a17aaeb8b9f6ace1d6db58b.1476239034.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Recent changes to printk require KERN_CONT uses to continue logging
messages.  So add KERN_CONT where necessary.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ca423cc20b59..6f8c356140a0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4219,7 +4219,7 @@ static void show_migration_types(unsigned char type)
 	}
 
 	*p = '\0';
-	printk("(%s) ", tmp);
+	printk(KERN_CONT "(%s) ", tmp);
 }
 
 /*
@@ -4330,7 +4330,8 @@ void show_free_areas(unsigned int filter)
 			free_pcp += per_cpu_ptr(zone->pageset, cpu)->pcp.count;
 
 		show_node(zone);
-		printk("%s"
+		printk(KERN_CONT
+		        "%s"
 			" free:%lukB"
 			" min:%lukB"
 			" low:%lukB"
@@ -4377,8 +4378,8 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_FREE_CMA_PAGES)));
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
-			printk(" %ld", zone->lowmem_reserve[i]);
-		printk("\n");
+			printk(KERN_CONT " %ld", zone->lowmem_reserve[i]);
+		printk(KERN_CONT "\n");
 	}
 
 	for_each_populated_zone(zone) {
@@ -4389,7 +4390,7 @@ void show_free_areas(unsigned int filter)
 		if (skip_free_areas_node(filter, zone_to_nid(zone)))
 			continue;
 		show_node(zone);
-		printk("%s: ", zone->name);
+		printk(KERN_CONT "%s: ", zone->name);
 
 		spin_lock_irqsave(&zone->lock, flags);
 		for (order = 0; order < MAX_ORDER; order++) {
@@ -4407,11 +4408,12 @@ void show_free_areas(unsigned int filter)
 		}
 		spin_unlock_irqrestore(&zone->lock, flags);
 		for (order = 0; order < MAX_ORDER; order++) {
-			printk("%lu*%lukB ", nr[order], K(1UL) << order);
+			printk(KERN_CONT "%lu*%lukB ",
+			       nr[order], K(1UL) << order);
 			if (nr[order])
 				show_migration_types(types[order]);
 		}
-		printk("= %lukB\n", K(total));
+		printk(KERN_CONT "= %lukB\n", K(total));
 	}
 
 	hugetlb_show_meminfo();
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
