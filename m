Date: Tue, 25 Nov 2008 21:37:51 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 3/9] swapfile: remove surplus whitespace
In-Reply-To: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
Message-ID: <Pine.LNX.4.64.0811252137080.17555@blonde.site>
References: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Remove trailing whitespace from swapfile.c, and odd swap_show() alignment.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/swapfile.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

--- swapfile2/mm/swapfile.c	2008-11-25 12:41:19.000000000 +0000
+++ swapfile3/mm/swapfile.c	2008-11-25 12:41:24.000000000 +0000
@@ -92,7 +92,7 @@ static inline unsigned long scan_swap_ma
 	unsigned long offset, last_in_cluster;
 	int latency_ration = LATENCY_LIMIT;
 
-	/* 
+	/*
 	 * We try to cluster swap pages by allocating them sequentially
 	 * in swap.  Once we've allocated SWAPFILE_CLUSTER pages this
 	 * way, however, we resort to first-free allocation, starting
@@ -269,7 +269,7 @@ bad_nofile:
 	printk(KERN_ERR "swap_free: %s%08lx\n", Bad_file, entry.val);
 out:
 	return NULL;
-}	
+}
 
 static int swap_entry_free(struct swap_info_struct *p, unsigned long offset)
 {
@@ -736,10 +736,10 @@ static int try_to_unuse(unsigned int typ
 			break;
 		}
 
-		/* 
+		/*
 		 * Get a page for the entry, using the existing swap
 		 * cache page if there is one.  Otherwise, get a clean
-		 * page and read the swap into it. 
+		 * page and read the swap into it.
 		 */
 		swap_map = &si->swap_map[i];
 		entry = swp_entry(type, i);
@@ -1202,7 +1202,7 @@ asmlinkage long sys_swapoff(const char _
 	char * pathname;
 	int i, type, prev;
 	int err;
-	
+
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
@@ -1395,12 +1395,12 @@ static int swap_show(struct seq_file *sw
 	file = ptr->swap_file;
 	len = seq_path(swap, &file->f_path, " \t\n\\");
 	seq_printf(swap, "%*s%s\t%u\t%u\t%d\n",
-		       len < 40 ? 40 - len : 1, " ",
-		       S_ISBLK(file->f_path.dentry->d_inode->i_mode) ?
+			len < 40 ? 40 - len : 1, " ",
+			S_ISBLK(file->f_path.dentry->d_inode->i_mode) ?
 				"partition" : "file\t",
-		       ptr->pages << (PAGE_SHIFT - 10),
-		       ptr->inuse_pages << (PAGE_SHIFT - 10),
-		       ptr->prio);
+			ptr->pages << (PAGE_SHIFT - 10),
+			ptr->inuse_pages << (PAGE_SHIFT - 10),
+			ptr->prio);
 	return 0;
 }
 
@@ -1556,7 +1556,7 @@ asmlinkage long sys_swapon(const char __
 		error = -EINVAL;
 		goto bad_swap;
 	}
-	
+
 	switch (swap_header_version) {
 	case 1:
 		printk(KERN_ERR "version 0 swap is no longer supported. "

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
