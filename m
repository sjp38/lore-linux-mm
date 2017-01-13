Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8626C6B0260
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 02:15:11 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id d9so49839392itc.4
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 23:15:11 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id l24si11813390pgn.200.2017.01.12.23.15.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 23:15:10 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id b22so7077385pfd.3
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 23:15:10 -0800 (PST)
From: js1304@gmail.com
Subject: [RFC PATCH 2/5] mm/vmstat: rename variables/functions about buddyinfo
Date: Fri, 13 Jan 2017 16:14:30 +0900
Message-Id: <1484291673-2239-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Following patch will introduce interface about fragmentation information
and "frag" prefix would be more suitable for it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/vmstat.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index e1ca5eb..cd0c331 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1138,7 +1138,7 @@ static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
 #endif
 
 #ifdef CONFIG_PROC_FS
-static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
+static void buddyinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 						struct zone *zone)
 {
 	int order;
@@ -1152,10 +1152,10 @@ static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
 /*
  * This walks the free areas for each zone.
  */
-static int frag_show(struct seq_file *m, void *arg)
+static int buddyinfo_show(struct seq_file *m, void *arg)
 {
 	pg_data_t *pgdat = (pg_data_t *)arg;
-	walk_zones_in_node(m, pgdat, frag_show_print);
+	walk_zones_in_node(m, pgdat, buddyinfo_show_print);
 	return 0;
 }
 
@@ -1300,20 +1300,20 @@ static int pagetypeinfo_show(struct seq_file *m, void *arg)
 	return 0;
 }
 
-static const struct seq_operations fragmentation_op = {
+static const struct seq_operations buddyinfo_op = {
 	.start	= frag_start,
 	.next	= frag_next,
 	.stop	= frag_stop,
-	.show	= frag_show,
+	.show	= buddyinfo_show,
 };
 
-static int fragmentation_open(struct inode *inode, struct file *file)
+static int buddyinfo_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &fragmentation_op);
+	return seq_open(file, &buddyinfo_op);
 }
 
-static const struct file_operations fragmentation_file_operations = {
-	.open		= fragmentation_open,
+static const struct file_operations buddyinfo_file_operations = {
+	.open		= buddyinfo_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
 	.release	= seq_release,
@@ -1781,7 +1781,7 @@ static int __init setup_vmstat(void)
 	start_shepherd_timer();
 #endif
 #ifdef CONFIG_PROC_FS
-	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);
+	proc_create("buddyinfo", S_IRUGO, NULL, &buddyinfo_file_operations);
 	proc_create("pagetypeinfo", S_IRUGO, NULL, &pagetypeinfo_file_ops);
 	proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
 	proc_create("zoneinfo", S_IRUGO, NULL, &proc_zoneinfo_file_operations);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
