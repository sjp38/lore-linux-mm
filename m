Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 19B8D6B0092
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:23:51 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id y13so9924116pdi.3
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:23:50 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ch4si34365547pdb.68.2014.12.24.04.23.29
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:30 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 03/38] mm: drop vm_ops->remap_pages and generic_file_remap_pages() stub
Date: Wed, 24 Dec 2014 14:22:11 +0200
Message-Id: <1419423766-114457-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Nobody uses it anymore.

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
index 5594505e6e73..b40133796b87 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -831,7 +831,6 @@ static const struct vm_operations_struct v9fs_file_vm_ops = {
 	.fault = filemap_fault,
 	.map_pages = filemap_map_pages,
 	.page_mkwrite = v9fs_vm_page_mkwrite,
-	.remap_pages = generic_file_remap_pages,
 };
 
 static const struct vm_operations_struct v9fs_mmap_file_vm_ops = {
@@ -839,7 +838,6 @@ static const struct vm_operations_struct v9fs_mmap_file_vm_ops = {
 	.fault = filemap_fault,
 	.map_pages = filemap_map_pages,
 	.page_mkwrite = v9fs_vm_page_mkwrite,
-	.remap_pages = generic_file_remap_pages,
 };
 
 
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index e4090259569b..a606ab551296 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -2081,7 +2081,6 @@ static const struct vm_operations_struct btrfs_file_vm_ops = {
 	.fault		= filemap_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= btrfs_page_mkwrite,
-	.remap_pages	= generic_file_remap_pages,
 };
 
 static int btrfs_file_mmap(struct file	*filp, struct vm_area_struct *vma)
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index f5013d92a7e6..4f68d0189d01 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -1569,7 +1569,6 @@ out:
 static struct vm_operations_struct ceph_vmops = {
 	.fault		= ceph_filemap_fault,
 	.page_mkwrite	= ceph_page_mkwrite,
-	.remap_pages	= generic_file_remap_pages,
 };
 
 int ceph_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 96b7e9b7706d..9f4d03954ecd 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -3244,7 +3244,6 @@ static struct vm_operations_struct cifs_file_vm_ops = {
 	.fault = filemap_fault,
 	.map_pages = filemap_map_pages,
 	.page_mkwrite = cifs_page_mkwrite,
-	.remap_pages = generic_file_remap_pages,
 };
 
 int cifs_file_strict_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 513c12cf444c..fa19f6b26532 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -195,7 +195,6 @@ static const struct vm_operations_struct ext4_file_vm_ops = {
 	.fault		= filemap_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite   = ext4_page_mkwrite,
-	.remap_pages	= generic_file_remap_pages,
 };
 
 static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 3c27e0ecb3bc..5674ba13102b 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -92,7 +92,6 @@ static const struct vm_operations_struct f2fs_file_vm_ops = {
 	.fault		= filemap_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= f2fs_vm_page_mkwrite,
-	.remap_pages	= generic_file_remap_pages,
 };
 
 static int get_parent_ino(struct inode *inode, nid_t *pino)
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 760b2c552197..d769e594855b 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -2062,7 +2062,6 @@ static const struct vm_operations_struct fuse_file_vm_ops = {
 	.fault		= filemap_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= fuse_page_mkwrite,
-	.remap_pages	= generic_file_remap_pages,
 };
 
 static int fuse_file_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index 6e600abf694a..ec9c2d33477a 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -498,7 +498,6 @@ static const struct vm_operations_struct gfs2_vm_ops = {
 	.fault = filemap_fault,
 	.map_pages = filemap_map_pages,
 	.page_mkwrite = gfs2_page_mkwrite,
-	.remap_pages = generic_file_remap_pages,
 };
 
 /**
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 2ab6f00dba5b..94712fc781fa 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -646,7 +646,6 @@ static const struct vm_operations_struct nfs_file_vm_ops = {
 	.fault = filemap_fault,
 	.map_pages = filemap_map_pages,
 	.page_mkwrite = nfs_vm_page_mkwrite,
-	.remap_pages = generic_file_remap_pages,
 };
 
 static int nfs_need_sync_write(struct file *filp, struct inode *inode)
diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
index 3a03e0aea1fb..a8c728acb7a8 100644
--- a/fs/nilfs2/file.c
+++ b/fs/nilfs2/file.c
@@ -128,7 +128,6 @@ static const struct vm_operations_struct nilfs_file_vm_ops = {
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
index 538519ee37d9..035e51011444 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1536,7 +1536,6 @@ static const struct vm_operations_struct ubifs_file_vm_ops = {
 	.fault        = filemap_fault,
 	.map_pages = filemap_map_pages,
 	.page_mkwrite = ubifs_vm_page_mkwrite,
-	.remap_pages = generic_file_remap_pages,
 };
 
 static int ubifs_file_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 13e974e6a889..ac7f1e8f92b3 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1384,5 +1384,4 @@ static const struct vm_operations_struct xfs_file_vm_ops = {
 	.fault		= filemap_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= xfs_vm_page_mkwrite,
-	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 86397708b7ab..84b661f7a5ba 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2481,12 +2481,6 @@ extern int sb_min_blocksize(struct super_block *, int);
 
 extern int generic_file_mmap(struct file *, struct vm_area_struct *);
 extern int generic_file_readonly_mmap(struct file *, struct vm_area_struct *);
-static inline int generic_file_remap_pages(struct vm_area_struct *vma,
-		unsigned long addr, unsigned long size, pgoff_t pgoff)
-{
-	BUG();
-	return 0;
-}
 int generic_write_checks(struct file *file, loff_t *pos, size_t *count, int isblk);
 extern ssize_t generic_file_read_iter(struct kiocb *, struct iov_iter *);
 extern ssize_t __generic_file_write_iter(struct kiocb *, struct iov_iter *);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7c7761536f5f..c6338ab35dc6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -285,9 +285,6 @@ struct vm_operations_struct {
 	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
 					unsigned long addr);
 #endif
-	/* called by sys_remap_file_pages() to populate non-linear mapping */
-	int (*remap_pages)(struct vm_area_struct *vma, unsigned long addr,
-			   unsigned long size, pgoff_t pgoff);
 };
 
 struct mmu_gather;
diff --git a/mm/filemap.c b/mm/filemap.c
index bd8543c6508f..e50fa993e5f5 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2091,7 +2091,6 @@ const struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= filemap_page_mkwrite,
-	.remap_pages	= generic_file_remap_pages,
 };
 
 /* This is used for a general mmap of a disk file */
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index 0d105aeff82f..70c09da1a419 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -301,7 +301,6 @@ out:
 static const struct vm_operations_struct xip_file_vm_ops = {
 	.fault	= xip_file_fault,
 	.page_mkwrite	= filemap_page_mkwrite,
-	.remap_pages = generic_file_remap_pages,
 };
 
 int xip_file_mmap(struct file * file, struct vm_area_struct * vma)
diff --git a/mm/shmem.c b/mm/shmem.c
index 73ba1df7c8ba..05a2d70a9244 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3201,7 +3201,6 @@ static const struct vm_operations_struct shmem_vm_ops = {
 	.set_policy     = shmem_set_policy,
 	.get_policy     = shmem_get_policy,
 #endif
-	.remap_pages	= generic_file_remap_pages,
 };
 
 static struct dentry *shmem_mount(struct file_system_type *fs_type,
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
