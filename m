Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2DAE882963
	for <linux-mm@kvack.org>; Tue,  6 May 2014 10:38:09 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y13so7272714pdi.7
        for <linux-mm@kvack.org>; Tue, 06 May 2014 07:38:08 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id xy8si12104947pab.324.2014.05.06.07.38.07
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 07:38:08 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/8] mm: kill vm_operations_struct->remap_pages
Date: Tue,  6 May 2014 17:37:26 +0300
Message-Id: <1399387052-31660-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

There's no users anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/9p/vfs_file.c   | 2 --
 fs/btrfs/file.c    | 1 -
 fs/ceph/addr.c     | 1 -
 fs/cifs/file.c     | 1 -
 fs/ext4/file.c     | 1 -
 fs/f2fs/file.c     | 1 -
 fs/fuse/file.c     | 1 -
 fs/gfs2/file.c     | 1 -
 fs/nfs/file.c      | 1 -
 fs/nilfs2/file.c   | 1 -
 fs/ocfs2/mmap.c    | 1 -
 fs/ubifs/file.c    | 1 -
 fs/xfs/xfs_file.c  | 1 -
 include/linux/fs.h | 6 ------
 include/linux/mm.h | 3 ---
 mm/filemap.c       | 1 -
 mm/filemap_xip.c   | 1 -
 mm/shmem.c         | 1 -
 18 files changed, 26 deletions(-)

diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
index d8223209d4b1..4cc2eed453a7 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -834,7 +834,6 @@ static const struct vm_operations_struct v9fs_file_vm_ops = {
 	.fault = filemap_fault,
 	.map_pages = filemap_map_pages,
 	.page_mkwrite = v9fs_vm_page_mkwrite,
-	.remap_pages = generic_file_remap_pages,
 };
 
 static const struct vm_operations_struct v9fs_mmap_file_vm_ops = {
@@ -842,7 +841,6 @@ static const struct vm_operations_struct v9fs_mmap_file_vm_ops = {
 	.fault = filemap_fault,
 	.map_pages = filemap_map_pages,
 	.page_mkwrite = v9fs_vm_page_mkwrite,
-	.remap_pages = generic_file_remap_pages,
 };
 
 
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index ae6af072b635..1238b42e53d6 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -2024,7 +2024,6 @@ static const struct vm_operations_struct btrfs_file_vm_ops = {
 	.fault		= filemap_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= btrfs_page_mkwrite,
-	.remap_pages	= generic_file_remap_pages,
 };
 
 static int btrfs_file_mmap(struct file	*filp, struct vm_area_struct *vma)
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index b53278c9fd97..ac6146d48647 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -1330,7 +1330,6 @@ out:
 static struct vm_operations_struct ceph_vmops = {
 	.fault		= ceph_filemap_fault,
 	.page_mkwrite	= ceph_page_mkwrite,
-	.remap_pages	= generic_file_remap_pages,
 };
 
 int ceph_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 5ed03e0b8b40..b153aaa5da11 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -3101,7 +3101,6 @@ static struct vm_operations_struct cifs_file_vm_ops = {
 	.fault = filemap_fault,
 	.map_pages = filemap_map_pages,
 	.page_mkwrite = cifs_page_mkwrite,
-	.remap_pages = generic_file_remap_pages,
 };
 
 int cifs_file_strict_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 063fc1538355..fee8a59b3e64 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -202,7 +202,6 @@ static const struct vm_operations_struct ext4_file_vm_ops = {
 	.fault		= filemap_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite   = ext4_page_mkwrite,
-	.remap_pages	= generic_file_remap_pages,
 };
 
 static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 60e7d5448a1d..c5908e5b621c 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -86,7 +86,6 @@ static const struct vm_operations_struct f2fs_file_vm_ops = {
 	.fault		= filemap_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= f2fs_vm_page_mkwrite,
-	.remap_pages	= generic_file_remap_pages,
 };
 
 static int get_parent_ino(struct inode *inode, nid_t *pino)
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 13f8bdec5110..a743711ef28b 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -2116,7 +2116,6 @@ static const struct vm_operations_struct fuse_file_vm_ops = {
 	.fault		= filemap_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= fuse_page_mkwrite,
-	.remap_pages	= generic_file_remap_pages,
 };
 
 static int fuse_file_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index 80d67253623c..2fec9c78fc6b 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -496,7 +496,6 @@ static const struct vm_operations_struct gfs2_vm_ops = {
 	.fault = filemap_fault,
 	.map_pages = filemap_map_pages,
 	.page_mkwrite = gfs2_page_mkwrite,
-	.remap_pages = generic_file_remap_pages,
 };
 
 /**
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 284ca901fe16..18f50bb4d887 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -619,7 +619,6 @@ static const struct vm_operations_struct nfs_file_vm_ops = {
 	.fault = filemap_fault,
 	.map_pages = filemap_map_pages,
 	.page_mkwrite = nfs_vm_page_mkwrite,
-	.remap_pages = generic_file_remap_pages,
 };
 
 static int nfs_need_sync_write(struct file *filp, struct inode *inode)
diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
index f3a82fbcae02..e0c458b8a168 100644
--- a/fs/nilfs2/file.c
+++ b/fs/nilfs2/file.c
@@ -136,7 +136,6 @@ static const struct vm_operations_struct nilfs_file_vm_ops = {
 	.fault		= filemap_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= nilfs_page_mkwrite,
-	.remap_pages	= generic_file_remap_pages,
 };
 
 static int nilfs_file_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/ocfs2/mmap.c b/fs/ocfs2/mmap.c
index 10d66c75cecb..9581d190f6e1 100644
--- a/fs/ocfs2/mmap.c
+++ b/fs/ocfs2/mmap.c
@@ -173,7 +173,6 @@ out:
 static const struct vm_operations_struct ocfs2_file_vm_ops = {
 	.fault		= ocfs2_fault,
 	.page_mkwrite	= ocfs2_page_mkwrite,
-	.remap_pages	= generic_file_remap_pages,
 };
 
 int ocfs2_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 4f34dbae823d..63c550489b1c 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1540,7 +1540,6 @@ static const struct vm_operations_struct ubifs_file_vm_ops = {
 	.fault        = filemap_fault,
 	.map_pages = filemap_map_pages,
 	.page_mkwrite = ubifs_vm_page_mkwrite,
-	.remap_pages = generic_file_remap_pages,
 };
 
 static int ubifs_file_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 951a2321ee01..b315608c5b57 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1494,5 +1494,4 @@ static const struct vm_operations_struct xfs_file_vm_ops = {
 	.fault		= filemap_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= xfs_vm_page_mkwrite,
-	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b7cda7d95ea0..14abfc355726 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2401,12 +2401,6 @@ extern int sb_min_blocksize(struct super_block *, int);
 
 extern int generic_file_mmap(struct file *, struct vm_area_struct *);
 extern int generic_file_readonly_mmap(struct file *, struct vm_area_struct *);
-static inline int generic_file_remap_pages(struct vm_area_struct *vma,
-		unsigned long addr, unsigned long size, pgoff_t pgoff)
-{
-	BUG();
-	return 0;
-}
 int generic_write_checks(struct file *file, loff_t *pos, size_t *count, int isblk);
 extern ssize_t generic_file_aio_read(struct kiocb *, const struct iovec *, unsigned long, loff_t);
 extern ssize_t __generic_file_aio_write(struct kiocb *, const struct iovec *, unsigned long);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index bf9811e1321a..3e7b88ff15d6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -264,9 +264,6 @@ struct vm_operations_struct {
 	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,
 		const nodemask_t *to, unsigned long flags);
 #endif
-	/* called by sys_remap_file_pages() to populate non-linear mapping */
-	int (*remap_pages)(struct vm_area_struct *vma, unsigned long addr,
-			   unsigned long size, pgoff_t pgoff);
 };
 
 struct mmu_gather;
diff --git a/mm/filemap.c b/mm/filemap.c
index 5020b280a771..3fda0bfee2d2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2106,7 +2106,6 @@ const struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= filemap_page_mkwrite,
-	.remap_pages	= generic_file_remap_pages,
 };
 
 /* This is used for a general mmap of a disk file */
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index d8d9fe3f685c..e609c215c5d2 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -306,7 +306,6 @@ out:
 static const struct vm_operations_struct xip_file_vm_ops = {
 	.fault	= xip_file_fault,
 	.page_mkwrite	= filemap_page_mkwrite,
-	.remap_pages = generic_file_remap_pages,
 };
 
 int xip_file_mmap(struct file * file, struct vm_area_struct * vma)
diff --git a/mm/shmem.c b/mm/shmem.c
index 9f70e02111c6..335c8ea62ded 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2705,7 +2705,6 @@ static const struct vm_operations_struct shmem_vm_ops = {
 	.set_policy     = shmem_set_policy,
 	.get_policy     = shmem_get_policy,
 #endif
-	.remap_pages	= generic_file_remap_pages,
 };
 
 static struct dentry *shmem_mount(struct file_system_type *fs_type,
-- 
2.0.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
