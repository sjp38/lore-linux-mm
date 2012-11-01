Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id F1E7B6B00AC
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 17:48:14 -0400 (EDT)
Message-Id: <0000013abdf22407-d3ab65ab-ace9-4118-8b0e-574ea3e1c802-000000@email.amazonses.com>
Date: Thu, 1 Nov 2012 21:48:13 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK5 [15/18] stat: Use size_t for sizes instead of unsigned
References: <20121101214538.971500204@linux.com>
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
--- linux.orig/fs/proc/stat.c	2012-11-01 10:09:46.221403795 -0500
+++ linux/fs/proc/stat.c	2012-11-01 11:19:37.164785019 -0500
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
