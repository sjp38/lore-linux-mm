Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 110466B039C
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 21:43:49 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id y136so41719929iof.3
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 18:43:49 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0148.hostedemail.com. [216.40.44.148])
        by mx.google.com with ESMTPS id a203si2008392itg.7.2017.03.15.18.43.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 18:43:48 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/3] mm: page_alloc: Break up a long single-line printk
Date: Wed, 15 Mar 2017 18:43:15 -0700
Message-Id: <3ceb85654e0cfe5168cc36f96a6e09822cf7139e.1489628459.git.joe@perches.com>
In-Reply-To: <cover.1489628459.git.joe@perches.com>
References: <cover.1489628459.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Blocked multiple line output is easier to read than an
extremely long single line.

Miscellanea:

o Add "Node" prefix to each new line of the block

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6816bb167394..2d3c10734874 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4540,20 +4540,23 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		       " inactive_anon:%lukB"
 		       " active_file:%lukB"
 		       " inactive_file:%lukB"
-		       " unevictable:%lukB",
+		       " unevictable:%lukB"
+		       "\n",
 		       pgdat->node_id,
 		       K(node_page_state(pgdat, NR_ACTIVE_ANON)),
 		       K(node_page_state(pgdat, NR_INACTIVE_ANON)),
 		       K(node_page_state(pgdat, NR_ACTIVE_FILE)),
 		       K(node_page_state(pgdat, NR_INACTIVE_FILE)),
 		       K(node_page_state(pgdat, NR_UNEVICTABLE)));
-		printk(KERN_CONT
+		printk("Node %d"
 		       " isolated(anon):%lukB"
 		       " isolated(file):%lukB"
 		       " mapped:%lukB"
 		       " dirty:%lukB"
 		       " writeback:%lukB"
-		       " shmem:%lukB",
+		       " shmem:%lukB"
+		       "\n",
+		       pgdat->node_id,
 		       K(node_page_state(pgdat, NR_ISOLATED_ANON)),
 		       K(node_page_state(pgdat, NR_ISOLATED_FILE)),
 		       K(node_page_state(pgdat, NR_FILE_MAPPED)),
@@ -4561,20 +4564,23 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		       K(node_page_state(pgdat, NR_WRITEBACK)),
 		       K(node_page_state(pgdat, NR_SHMEM)));
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		printk(KERN_CONT
+		printk("Node %d"
 		       " shmem_thp: %lukB"
 		       " shmem_pmdmapped: %lukB"
-		       " anon_thp: %lukB",
+		       " anon_thp: %lukB"
+		       "\n",
+		       pgdat->node_id,
 		       K(node_page_state(pgdat, NR_SHMEM_THPS) * HPAGE_PMD_NR),
 		       K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED)
 			 * HPAGE_PMD_NR),
 		       K(node_page_state(pgdat, NR_ANON_THPS) * HPAGE_PMD_NR));
 #endif
-		printk(KERN_CONT
+		printk("Node %d"
 		       " writeback_tmp:%lukB"
 		       " unstable:%lukB"
 		       " all_unreclaimable? %s"
 		       "\n",
+		       pgdat->node_id,
 		       K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
 		       K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
 		       pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES ?
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
