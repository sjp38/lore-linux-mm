Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 42CAA6B005A
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 14:14:19 -0500 (EST)
Message-Id: <0000013c25e25ed1-b8a9491d-3454-42a5-a844-a57ff13074c3-000000@email.amazonses.com>
Date: Thu, 10 Jan 2013 19:14:17 +0000
From: Christoph Lameter <cl@linux.com>
Subject: REN2 [10/13] stat: Use size_t for sizes instead of unsigned
References: <20130110190027.780479755@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On some platforms (such as IA64) the large page size may results in
slab allocations to be allowed of numbers that do not fit in 32 bit.

Acked-by: Glauber Costa <glommer@parallels.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/fs/proc/stat.c
===================================================================
--- linux.orig/fs/proc/stat.c	2012-12-19 10:25:05.227152297 -0600
+++ linux/fs/proc/stat.c	2013-01-10 09:43:51.721622972 -0600
@@ -184,7 +184,7 @@ static int show_stat(struct seq_file *p,
 
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
