Received: from debian from [209.144.230.137] by mail3.iadfw.net
	(/\##/\ Smail3.1.30.16 #30.61) with esmtp for <linux-mm@kvack.org> sender: <ahaas@neosoft.com>
	id <mT/17Xidr-0039Q9T@mail3.iadfw.net>; Thu, 25 Jul 2002 08:26:55 -0500 (CDT)
Date: Thu, 25 Jul 2002 08:25:39 -0500
From: Art Haas <ahaas@neosoft.com>
Subject: [PATCH] designated initializer changes for mm/*
Message-ID: <20020725132539.GB1035@debian>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bCsyhTFzCvuiizWE"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: trivial@rustcorp.com.au
List-ID: <linux-mm.kvack.org>

--bCsyhTFzCvuiizWE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi.

Here's a set of small patches that convert the code to using
the ISO C99 designated initializer syntax. The patches are all
against 2.5.28.

Art Haas

-- 
They that can give up essential liberty to obtain a little temporary
safety deserve neither liberty nor safety.
 -- Benjamin Franklin, Historical Review of Pennsylvania, 1759

--bCsyhTFzCvuiizWE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="filemap.c.diff"

--- linux-2.5.28/mm/filemap.c.old	2002-07-20 21:58:57.000000000 -0500
+++ linux-2.5.28/mm/filemap.c	2002-07-24 20:05:37.000000000 -0500
@@ -1442,7 +1442,7 @@
 }
 
 static struct vm_operations_struct generic_file_vm_ops = {
-	nopage:		filemap_nopage,
+	.nopage		= filemap_nopage,
 };
 
 /* This is used for a general mmap of a disk file */

--bCsyhTFzCvuiizWE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="numa.c.diff"

--- linux-2.5.28/mm/numa.c.old	2002-07-05 18:42:20.000000000 -0500
+++ linux-2.5.28/mm/numa.c	2002-07-24 20:05:37.000000000 -0500
@@ -12,7 +12,7 @@
 int numnodes = 1;	/* Initialized for UMA platforms */
 
 static bootmem_data_t contig_bootmem_data;
-pg_data_t contig_page_data = { bdata: &contig_bootmem_data };
+pg_data_t contig_page_data = { .bdata = &contig_bootmem_data };
 
 #ifndef CONFIG_DISCONTIGMEM
 

--bCsyhTFzCvuiizWE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="page_io.c.diff"

--- linux-2.5.28/mm/page_io.c.old	2002-07-20 21:58:57.000000000 -0500
+++ linux-2.5.28/mm/page_io.c	2002-07-24 20:05:37.000000000 -0500
@@ -132,11 +132,11 @@
 }
 
 struct address_space_operations swap_aops = {
-	vm_writeback:	swap_vm_writeback,
-	writepage:	swap_writepage,
-	readpage:	swap_readpage,
-	sync_page:	block_sync_page,
-	set_page_dirty:	__set_page_dirty_nobuffers,
+	.vm_writeback	= swap_vm_writeback,
+	.writepage	= swap_writepage,
+	.readpage	= swap_readpage,
+	.sync_page	= block_sync_page,
+	.set_page_dirty	= __set_page_dirty_nobuffers,
 };
 
 /*

--bCsyhTFzCvuiizWE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="readahead.c.diff"

--- linux-2.5.28/mm/readahead.c.old	2002-07-20 21:58:57.000000000 -0500
+++ linux-2.5.28/mm/readahead.c	2002-07-24 20:05:37.000000000 -0500
@@ -14,8 +14,8 @@
 #include <linux/backing-dev.h>
 
 struct backing_dev_info default_backing_dev_info = {
-	ra_pages:	(VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE,
-	state:		0,
+	.ra_pages	= (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE,
+	.state		= 0,
 };
 
 /*

--bCsyhTFzCvuiizWE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="shmem.c.diff"

--- linux-2.5.28/mm/shmem.c.old	2002-07-24 19:42:41.000000000 -0500
+++ linux-2.5.28/mm/shmem.c	2002-07-24 20:05:38.000000000 -0500
@@ -1254,14 +1254,14 @@
 }
 
 static struct inode_operations shmem_symlink_inline_operations = {
-	readlink:	shmem_readlink_inline,
-	follow_link:	shmem_follow_link_inline,
+	.readlink	= shmem_readlink_inline,
+	.follow_link	= shmem_follow_link_inline,
 };
 
 static struct inode_operations shmem_symlink_inode_operations = {
-	truncate:	shmem_truncate,
-	readlink:	shmem_readlink,
-	follow_link:	shmem_follow_link,
+	.truncate	= shmem_truncate,
+	.readlink	= shmem_readlink,
+	.follow_link	= shmem_follow_link,
 };
 
 static int shmem_parse_options(char *options, int *mode, uid_t *uid, gid_t *gid, unsigned long * blocks, unsigned long *inodes)
@@ -1462,51 +1462,51 @@
 }
 
 static struct address_space_operations shmem_aops = {
-	writepage:	shmem_writepage,
-	set_page_dirty:	__set_page_dirty_nobuffers,
+	.writepage	= shmem_writepage,
+	.set_page_dirty	= __set_page_dirty_nobuffers,
 };
 
 static struct file_operations shmem_file_operations = {
-	mmap:	shmem_mmap,
+	.mmap	= shmem_mmap,
 #ifdef CONFIG_TMPFS
-	read:	shmem_file_read,
-	write:	shmem_file_write,
-	fsync:	shmem_sync_file,
+	.read	= shmem_file_read,
+	.write	= shmem_file_write,
+	.fsync	= shmem_sync_file,
 #endif
 };
 
 static struct inode_operations shmem_inode_operations = {
-	truncate:	shmem_truncate,
+	.truncate	= shmem_truncate,
 };
 
 static struct inode_operations shmem_dir_inode_operations = {
 #ifdef CONFIG_TMPFS
-	create:		shmem_create,
-	lookup:		simple_lookup,
-	link:		shmem_link,
-	unlink:		shmem_unlink,
-	symlink:	shmem_symlink,
-	mkdir:		shmem_mkdir,
-	rmdir:		shmem_rmdir,
-	mknod:		shmem_mknod,
-	rename:		shmem_rename,
+	.create		= shmem_create,
+	.lookup		= simple_lookup,
+	.link		= shmem_link,
+	.unlink		= shmem_unlink,
+	.symlink	= shmem_symlink,
+	.mkdir		= shmem_mkdir,
+	.rmdir		= shmem_rmdir,
+	.mknod		= shmem_mknod,
+	.rename		= shmem_rename,
 #endif
 };
 
 static struct super_operations shmem_ops = {
-	alloc_inode:	shmem_alloc_inode,
-	destroy_inode:	shmem_destroy_inode,
+	.alloc_inode	= shmem_alloc_inode,
+	.destroy_inode	= shmem_destroy_inode,
 #ifdef CONFIG_TMPFS
-	statfs:		shmem_statfs,
-	remount_fs:	shmem_remount_fs,
+	.statfs		= shmem_statfs,
+	.remount_fs	= shmem_remount_fs,
 #endif
-	delete_inode:	shmem_delete_inode,
-	drop_inode:	generic_delete_inode,
-	put_super:	shmem_put_super,
+	.delete_inode	= shmem_delete_inode,
+	.drop_inode	= generic_delete_inode,
+	.put_super	= shmem_put_super,
 };
 
 static struct vm_operations_struct shmem_vm_ops = {
-	nopage:	shmem_nopage,
+	.nopage	= shmem_nopage,
 };
 
 static struct super_block *shmem_get_sb(struct file_system_type *fs_type,
@@ -1518,17 +1518,17 @@
 #ifdef CONFIG_TMPFS
 /* type "shm" will be tagged obsolete in 2.5 */
 static struct file_system_type shmem_fs_type = {
-	owner:		THIS_MODULE,
-	name:		"shmem",
-	get_sb:		shmem_get_sb,
-	kill_sb:	kill_litter_super,
+	.owner		= THIS_MODULE,
+	.name		= "shmem",
+	.get_sb		= shmem_get_sb,
+	.kill_sb	= kill_litter_super,
 };
 #endif
 static struct file_system_type tmpfs_fs_type = {
-	owner:		THIS_MODULE,
-	name:		"tmpfs",
-	get_sb:		shmem_get_sb,
-	kill_sb:	kill_litter_super,
+	.owner		= THIS_MODULE,
+	.name		= "tmpfs",
+	.get_sb		= shmem_get_sb,
+	.kill_sb	= kill_litter_super,
 };
 static struct vfsmount *shm_mnt;
 

--bCsyhTFzCvuiizWE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="slab.c.diff"

--- linux-2.5.28/mm/slab.c.old	2002-07-24 19:42:41.000000000 -0500
+++ linux-2.5.28/mm/slab.c	2002-07-24 20:05:38.000000000 -0500
@@ -384,14 +384,14 @@
 
 /* internal cache of cache description objs */
 static kmem_cache_t cache_cache = {
-	slabs_full:	LIST_HEAD_INIT(cache_cache.slabs_full),
-	slabs_partial:	LIST_HEAD_INIT(cache_cache.slabs_partial),
-	slabs_free:	LIST_HEAD_INIT(cache_cache.slabs_free),
-	objsize:	sizeof(kmem_cache_t),
-	flags:		SLAB_NO_REAP,
-	spinlock:	SPIN_LOCK_UNLOCKED,
-	colour_off:	L1_CACHE_BYTES,
-	name:		"kmem_cache",
+	.slabs_full	= LIST_HEAD_INIT(cache_cache.slabs_full),
+	.slabs_partial	= LIST_HEAD_INIT(cache_cache.slabs_partial),
+	.slabs_free	= LIST_HEAD_INIT(cache_cache.slabs_free),
+	.objsize	= sizeof(kmem_cache_t),
+	.flags		= SLAB_NO_REAP,
+	.spinlock	= SPIN_LOCK_UNLOCKED,
+	.colour_off	= L1_CACHE_BYTES,
+	.name		= "kmem_cache",
 };
 
 /* Guard access to the cache-chain. */
@@ -2044,10 +2044,10 @@
  */
 
 struct seq_operations slabinfo_op = {
-	start:	s_start,
-	next:	s_next,
-	stop:	s_stop,
-	show:	s_show
+	.start	= s_start,
+	.next	= s_next,
+	.stop	= s_stop,
+	.show	= s_show
 };
 
 #define MAX_SLABINFO_WRITE 128

--bCsyhTFzCvuiizWE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="swap_state.c.diff"

--- linux-2.5.28/mm/swap_state.c.old	2002-07-20 21:58:57.000000000 -0500
+++ linux-2.5.28/mm/swap_state.c	2002-07-24 20:05:38.000000000 -0500
@@ -23,23 +23,23 @@
  * avoid some special-casing in other parts of the kernel.
  */
 static struct inode swapper_inode = {
-	i_mapping:	&swapper_space,
+	.i_mapping	= &swapper_space,
 };
 
 extern struct address_space_operations swap_aops;
 
 struct address_space swapper_space = {
-	page_tree:	RADIX_TREE_INIT(GFP_ATOMIC),
-	page_lock:	RW_LOCK_UNLOCKED,
-	clean_pages:	LIST_HEAD_INIT(swapper_space.clean_pages),
-	dirty_pages:	LIST_HEAD_INIT(swapper_space.dirty_pages),
-	io_pages:	LIST_HEAD_INIT(swapper_space.io_pages),
-	locked_pages:	LIST_HEAD_INIT(swapper_space.locked_pages),
-	host:		&swapper_inode,
-	a_ops:		&swap_aops,
-	i_shared_lock:	SPIN_LOCK_UNLOCKED,
-	private_lock:	SPIN_LOCK_UNLOCKED,
-	private_list:	LIST_HEAD_INIT(swapper_space.private_list),
+	.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC),
+	.page_lock	= RW_LOCK_UNLOCKED,
+	.clean_pages	= LIST_HEAD_INIT(swapper_space.clean_pages),
+	.dirty_pages	= LIST_HEAD_INIT(swapper_space.dirty_pages),
+	.io_pages	= LIST_HEAD_INIT(swapper_space.io_pages),
+	.locked_pages	= LIST_HEAD_INIT(swapper_space.locked_pages),
+	.host		= &swapper_inode,
+	.a_ops		= &swap_aops,
+	.i_shared_lock	= SPIN_LOCK_UNLOCKED,
+	.private_lock	= SPIN_LOCK_UNLOCKED,
+	.private_list	= LIST_HEAD_INIT(swapper_space.private_list),
 };
 
 #ifdef SWAP_CACHE_INFO

--bCsyhTFzCvuiizWE--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
