Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PFqZTb003472
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 11:52:35 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PFqVDU109058
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 09:52:33 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PFqUQ8028976
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 09:52:31 -0600
Subject: [PATCH 1/2] Fix migratetype_names[] and make it available
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 08:55:59 -0700
Message-Id: <1193327759.9894.6.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, haveblue@us.ibm.com
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Add "Isolate" to migratetype_names for completeness and make it
available for use outside vmstat.c

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com> 
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/pageblock-flags.h |    1 +
 mm/vmstat.c                     |    3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

Index: linux-2.6.23/include/linux/pageblock-flags.h
===================================================================
--- linux-2.6.23.orig/include/linux/pageblock-flags.h	2007-10-23 13:04:46.000000000 -0700
+++ linux-2.6.23/include/linux/pageblock-flags.h	2007-10-23 13:06:08.000000000 -0700
@@ -72,4 +72,5 @@ void set_pageblock_flags_group(struct pa
 #define set_pageblock_flags(page) \
 			set_pageblock_flags_group(page, 0, NR_PAGEBLOCK_BITS-1)
 
+extern char *migratetype_names[];
 #endif	/* PAGEBLOCK_FLAGS_H */
Index: linux-2.6.23/mm/vmstat.c
===================================================================
--- linux-2.6.23.orig/mm/vmstat.c	2007-10-23 13:05:03.000000000 -0700
+++ linux-2.6.23/mm/vmstat.c	2007-10-23 13:06:36.000000000 -0700
@@ -382,11 +382,12 @@ void zone_statistics(struct zonelist *zo
 
 #include <linux/seq_file.h>
 
-static char * const migratetype_names[MIGRATE_TYPES] = {
+char * const migratetype_names[MIGRATE_TYPES] = {
 	"Unmovable",
 	"Reclaimable",
 	"Movable",
 	"Reserve",
+	"Isolate",
 };
 
 static void *frag_start(struct seq_file *m, loff_t *pos)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
