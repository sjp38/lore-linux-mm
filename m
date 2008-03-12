Date: Wed, 12 Mar 2008 15:16:50 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -mmotm] mm/shmem and tiny-shmem: fix some kernel-doc
Message-Id: <20080312151650.fba006e2.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Randy Dunlap <randy.dunlap@oracle.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Convert tiny-shmem.c function comments to kernel-doc.
Add parameters and convert/fix other kernel-doc in shmem.c.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/shmem.c      |   25 ++++++++++---------------
 mm/tiny-shmem.c |    8 +++-----
 2 files changed, 13 insertions(+), 20 deletions(-)

--- lin2625-rc5-mmotm.orig/mm/shmem.c
+++ lin2625-rc5-mmotm/mm/shmem.c
@@ -244,9 +244,8 @@ static void shmem_free_inode(struct supe
 	}
 }
 
-/*
+/**
  * shmem_recalc_inode - recalculate the size of an inode
- *
  * @inode: inode to recalc
  *
  * We have to calculate the free blocks since the mm can drop
@@ -270,9 +269,8 @@ static void shmem_recalc_inode(struct in
 	}
 }
 
-/*
+/**
  * shmem_swp_entry - find the swap vector position in the info structure
- *
  * @info:  info structure for the inode
  * @index: index of the page to find
  * @page:  optional page to add to the structure. Has to be preset to
@@ -374,13 +372,13 @@ static void shmem_swp_set(struct shmem_i
 	}
 }
 
-/*
+/**
  * shmem_swp_alloc - get the position of the swap entry for the page.
- *                   If it does not exist allocate the entry.
- *
  * @info:	info structure for the inode
  * @index:	index of the page to find
  * @sgp:	check and recheck i_size? skip allocation?
+ *
+ * If the entry does not exist, allocate it.
  */
 static swp_entry_t *shmem_swp_alloc(struct shmem_inode_info *info, unsigned long index, enum sgp_type sgp)
 {
@@ -440,9 +438,8 @@ static swp_entry_t *shmem_swp_alloc(stru
 	return entry;
 }
 
-/*
+/**
  * shmem_free_swp - free some swap entries in a directory
- *
  * @dir:        pointer to the directory
  * @edir:       pointer after last entry of the directory
  * @punch_lock: pointer to spinlock when needed for the holepunch case
@@ -2036,7 +2033,7 @@ static const struct inode_operations shm
 };
 
 #ifdef CONFIG_TMPFS_POSIX_ACL
-/**
+/*
  * Superblocks without xattr inode operations will get security.* xattr
  * support from the VFS "for free". As soon as we have any other xattrs
  * like ACLs, we also need to implement the security.* handlers at
@@ -2578,12 +2575,11 @@ out4:
 }
 module_init(init_tmpfs)
 
-/*
+/**
  * shmem_file_setup - get an unlinked file living in tmpfs
- *
  * @name: name for dentry (to be seen in /proc/<pid>/maps
  * @size: size to be set for the file
- *
+ * @flags: vm_flags
  */
 struct file *shmem_file_setup(char *name, loff_t size, unsigned long flags)
 {
@@ -2638,9 +2634,8 @@ put_memory:
 	return ERR_PTR(error);
 }
 
-/*
+/**
  * shmem_zero_setup - setup a shared anonymous mapping
- *
  * @vma: the vma to be mmapped is prepared by do_mmap_pgoff
  */
 int shmem_zero_setup(struct vm_area_struct *vma)
--- lin2625-rc5-mmotm.orig/mm/tiny-shmem.c
+++ lin2625-rc5-mmotm/mm/tiny-shmem.c
@@ -39,12 +39,11 @@ static int __init init_tmpfs(void)
 }
 module_init(init_tmpfs)
 
-/*
+/**
  * shmem_file_setup - get an unlinked file living in tmpfs
- *
  * @name: name for dentry (to be seen in /proc/<pid>/maps
  * @size: size to be set for the file
- *
+ * @flags: vm_flags
  */
 struct file *shmem_file_setup(char *name, loff_t size, unsigned long flags)
 {
@@ -95,9 +94,8 @@ put_memory:
 	return ERR_PTR(error);
 }
 
-/*
+/**
  * shmem_zero_setup - setup a shared anonymous mapping
- *
  * @vma: the vma to be mmapped is prepared by do_mmap_pgoff
  */
 int shmem_zero_setup(struct vm_area_struct *vma)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
