Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 0EDC76B0069
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 05:22:38 -0400 (EDT)
Received: by weys10 with SMTP id s10so4064210wey.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 02:22:36 -0700 (PDT)
From: Luis Gonzalez Fernandez <luisgf@gmail.com>
Subject: [PATCH 1/1] mm: Fix unused function warnings in vmstat.c
Date: Tue,  4 Sep 2012 11:22:25 +0200
Message-Id: <1346750545-2094-1-git-send-email-luisgf@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: Luis Gonzalez Fernandez <luisgf@gmail.com>

frag_start(), frag_next(), frag_stop(), walk_zones_in_node() throws
compilation warnings (-Wunused-function) even when are currently used.

This patchs fix the compilation warnings in vmstat.c

Signed-off-by: Luis Gonzalez Fernandez <luisgf@gmail.com>
---
 mm/vmstat.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index df7a674..e8f7dbd 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -619,7 +619,8 @@ static char * const migratetype_names[MIGRATE_TYPES] = {
 	"Isolate",
 };
 
-static void *frag_start(struct seq_file *m, loff_t *pos)
+static void __attribute__((unused)) *frag_start(struct seq_file *m,
+							loff_t *pos)
 {
 	pg_data_t *pgdat;
 	loff_t node = *pos;
@@ -631,7 +632,8 @@ static void *frag_start(struct seq_file *m, loff_t *pos)
 	return pgdat;
 }
 
-static void *frag_next(struct seq_file *m, void *arg, loff_t *pos)
+static void __attribute__((unused)) *frag_next(struct seq_file *m,
+						void *arg, loff_t *pos)
 {
 	pg_data_t *pgdat = (pg_data_t *)arg;
 
@@ -639,12 +641,13 @@ static void *frag_next(struct seq_file *m, void *arg, loff_t *pos)
 	return next_online_pgdat(pgdat);
 }
 
-static void frag_stop(struct seq_file *m, void *arg)
+static void __attribute__((unused)) frag_stop(struct seq_file *m, void *arg)
 {
 }
 
 /* Walk all the zones in a node and print using a callback */
-static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
+static void __attribute__((unused)) walk_zones_in_node(struct seq_file *m,
+							pg_data_t *pgdat,
 		void (*print)(struct seq_file *m, pg_data_t *, struct zone *))
 {
 	struct zone *zone;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
