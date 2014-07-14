Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id B7E226B0035
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 03:52:41 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so4562430pab.30
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 00:52:41 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id j1si8533624pbw.214.2014.07.14.00.52.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 00:52:40 -0700 (PDT)
Received: by mail-pd0-f176.google.com with SMTP id y10so436834pdj.7
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 00:52:40 -0700 (PDT)
Message-ID: <53C38C3A.3090903@gmail.com>
Date: Mon, 14 Jul 2014 15:52:26 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: trivial code style fix to shmem_statfs
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org


Should read the super_block fields, even if current implementation uses
the same constants.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 mm/shmem.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 1140f49..368523b 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1874,10 +1874,11 @@ out:

 static int shmem_statfs(struct dentry *dentry, struct kstatfs *buf)
 {
-       struct shmem_sb_info *sbinfo = SHMEM_SB(dentry->d_sb);
+       struct super_block *sb = dentry->d_sb;
+       struct shmem_sb_info *sbinfo = SHMEM_SB(sb);

-       buf->f_type = TMPFS_MAGIC;
-       buf->f_bsize = PAGE_CACHE_SIZE;
+       buf->f_type = sb->s_magic;
+       buf->f_bsize = sb->s_blocksize;
        buf->f_namelen = NAME_MAX;
        if (sbinfo->max_blocks) {
                buf->f_blocks = sbinfo->max_blocks;
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
