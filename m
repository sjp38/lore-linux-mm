Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id A219A6B009D
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 10:32:21 -0400 (EDT)
Message-Id: <0000013a797066fe-be951901-f108-4705-95bb-e0d6a2b2af85-000000@email.amazonses.com>
Date: Fri, 19 Oct 2012 14:32:20 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK2 [14/15] stat: Use size_t for sizes instead of unsigned
References: <20121019142254.724806786@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On some platforms (such as IA64) the large page size may results in
slab allocations to be allowed of numbers that do not fit in 32 bit.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/fs/proc/stat.c
===================================================================
--- linux.orig/fs/proc/stat.c	2012-10-05 13:26:55.711476247 -0500
+++ linux/fs/proc/stat.c	2012-10-15 16:12:38.136811230 -0500
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
