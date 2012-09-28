Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 4B3A06B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 15:39:23 -0400 (EDT)
Message-Id: <0000013a0e63f1cc-816dfb68-cf2a-40a1-b5fe-7a9e5c354c53-000000@email.amazonses.com>
Date: Fri, 28 Sep 2012 19:39:21 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK2 [13/15] stat: Use size_t for sizes instead of unsigned
References: <20120928191715.368450474@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On some platforms (such as IA64) the large page size may results in
slab allocations to be allowed of numbers that do not fit in 32 bit.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/fs/proc/stat.c
===================================================================
--- linux.orig/fs/proc/stat.c	2012-09-18 12:21:56.301459334 -0500
+++ linux/fs/proc/stat.c	2012-09-28 12:33:29.428759019 -0500
@@ -178,7 +178,7 @@ static int show_stat(struct seq_file *p,
 
 static int stat_open(struct inode *inode, struct file *file)
 {
-	unsigned size = 1024 + 128 * num_possible_cpus();
+	size_t size = 1024 + 128 * num_possible_cpus();
 	char *buf;
 	struct seq_file *m;
 	int res;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
