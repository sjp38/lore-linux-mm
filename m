Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id E03DD6B0078
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 11:06:29 -0400 (EDT)
Message-Id: <0000013a934f6bae-920b99f6-68fe-419c-bd5e-f94bcdf582e9-000000@email.amazonses.com>
Date: Wed, 24 Oct 2012 15:06:26 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK4 [14/15] stat: Use size_t for sizes instead of unsigned
References: <20121024150518.156629201@linux.com>
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
--- linux.orig/fs/proc/stat.c	2012-10-24 09:22:24.176503765 -0500
+++ linux/fs/proc/stat.c	2012-10-24 09:23:34.717510721 -0500
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
