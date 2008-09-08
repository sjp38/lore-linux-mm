Date: Mon, 8 Sep 2008 19:46:34 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] hugetlbfs: add llseek method
Message-ID: <20080908174634.GC19912@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugetlbfs currently doesn't set a llseek method for regular files, which
means it will fall back to default_llseek.  This means no one can seek
beyond 2 Gigabytes.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c	2008-09-08 19:44:33.000000000 +0200
+++ linux-2.6/fs/hugetlbfs/inode.c	2008-09-08 19:44:58.000000000 +0200
@@ -717,6 +717,7 @@ const struct file_operations hugetlbfs_f
 	.mmap			= hugetlbfs_file_mmap,
 	.fsync			= simple_sync_file,
 	.get_unmapped_area	= hugetlb_get_unmapped_area,
+	.llseek			= generic_file_llseek,
 };
 
 static const struct inode_operations hugetlbfs_dir_inode_operations = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
