Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 074E56B003D
	for <linux-mm@kvack.org>; Sun, 10 May 2009 15:33:58 -0400 (EDT)
Message-ID: <4A072CB5.2050801@oracle.com>
Date: Sun, 10 May 2009 12:36:21 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: [PATCH -mmotm] slqbinfo: eliminate warnings
References: <200905082241.n48Mfpdh022249@imap1.linux-foundation.org>
In-Reply-To: <200905082241.n48Mfpdh022249@imap1.linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Eliminate build warnings:

Documentation/vm/slqbinfo.c:386: warning: unused variable 'total'
Documentation/vm/slqbinfo.c:512: warning: format '%5d' expects type 'int', but argument 9 has type 'long unsigned int'
Documentation/vm/slqbinfo.c:520: warning: format '%4ld' expects type 'long int', but argument 9 has type 'int'
Documentation/vm/slqbinfo.c:646: warning: unused variable 'total_partial'
Documentation/vm/slqbinfo.c:646: warning: unused variable 'avg_partial'
Documentation/vm/slqbinfo.c:645: warning: unused variable 'max_partial'
Documentation/vm/slqbinfo.c:645: warning: unused variable 'min_partial'
Documentation/vm/slqbinfo.c:860: warning: unused variable 'count'
Documentation/vm/slqbinfo.c:858: warning: unused variable 'p'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 Documentation/vm/slqbinfo.c |   11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

--- mmotm-2009-0508-1522.orig/Documentation/vm/slqbinfo.c
+++ mmotm-2009-0508-1522/Documentation/vm/slqbinfo.c
@@ -383,7 +383,6 @@ void slab_stats(struct slabinfo *s)
 {
 	unsigned long total_alloc;
 	unsigned long total_free;
-	unsigned long total;
 
 	total_alloc = s->alloc;
 	total_free = s->free;
@@ -501,7 +500,7 @@ void slabcache(struct slabinfo *s)
 		total_alloc = s->alloc;
 		total_free = s->free;
 
-		printf("%-21s %8ld %10ld %10ld %5ld %5ld %7ld %5d %7ld %8d\n",
+		printf("%-21s %8ld %10ld %10ld %5ld %5ld %7ld %5ld %7ld %8d\n",
 			s->name, s->objects,
 			total_alloc, total_free,
 			total_alloc ? (s->alloc_slab_fill * 100 / total_alloc) : 0,
@@ -512,7 +511,7 @@ void slabcache(struct slabinfo *s)
 			s->order);
 	}
 	else
-		printf("%-21s %8ld %7d %8s %4d %1d %3ld %4ld %s\n",
+		printf("%-21s %8ld %7d %8s %4d %1d %3ld %4d %s\n",
 			s->name, s->objects, s->object_size, size_str,
 			s->objs_per_slab, s->order,
 			s->slabs ? (s->objects * s->object_size * 100) /
@@ -641,10 +640,6 @@ void totals(void)
 	/* Object size */
 	unsigned long long min_objsize = max, max_objsize = 0, avg_objsize;
 
-	/* Number of partial slabs in a slabcache */
-	unsigned long long min_partial = max, max_partial = 0,
-				avg_partial, total_partial = 0;
-
 	/* Number of slabs in a slab cache */
 	unsigned long long min_slabs = max, max_slabs = 0,
 				avg_slabs, total_slabs = 0;
@@ -855,9 +850,7 @@ void read_slab_dir(void)
 	DIR *dir;
 	struct dirent *de;
 	struct slabinfo *slab = slabinfo;
-	char *p;
 	char *t;
-	int count;
 
 	if (chdir("/sys/kernel/slab") && chdir("/sys/slab"))
 		fatal("SYSFS support for SLUB not active\n");




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
