Date: Mon, 29 Jul 2002 14:23:03 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] remove unused /proc/sys/vm/kswapd and swapctl.h
Message-ID: <20020729142303.A32475@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.512, 2002-07-29 15:17:43+02:00, hch@sb.bsdonline.org
  VM: remove unused /proc/sys/vm/kswapd and swapctl.h
  
  These were totally unused for a long time.  It's interesting how
  many files include swapctl.h, though..


 b/Documentation/sysctl/vm.txt |   33 ---------------------------------
 b/arch/arm/mm/init.c          |    1 -
 b/arch/mips/mm/init.c         |    1 -
 b/arch/mips64/mm/init.c       |    1 -
 b/arch/sparc/mm/init.c        |    1 -
 b/arch/sparc64/mm/init.c      |    1 -
 b/fs/coda/sysctl.c            |    1 -
 b/fs/intermezzo/sysctl.c      |    1 -
 b/include/linux/sysctl.h      |   10 +++++-----
 b/kernel/suspend.c            |    1 -
 b/kernel/sysctl.c             |    3 ---
 b/mm/bootmem.c                |    1 -
 b/mm/memory.c                 |    1 -
 b/mm/mmap.c                   |    1 -
 b/mm/oom_kill.c               |    1 -
 b/mm/swap.c                   |    7 -------
 b/mm/swap_state.c             |    1 -
 b/mm/swapfile.c               |    1 -
 b/mm/vmscan.c                 |    1 -
 include/linux/swapctl.h       |   13 -------------
 20 files changed, 5 insertions, 76 deletions


diff -Nru a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
--- a/Documentation/sysctl/vm.txt	Mon Jul 29 15:19:51 2002
+++ b/Documentation/sysctl/vm.txt	Mon Jul 29 15:19:51 2002
@@ -16,7 +16,6 @@
 files can be found in mm/swap.c.
 
 Currently, these files are in /proc/sys/vm:
-- kswapd
 - overcommit_memory
 - page-cluster
 - dirty_async_ratio
@@ -31,39 +30,6 @@
 dirty_sync_ratio dirty_writeback_centisecs:
 
 See Documentation/filesystems/proc.txt
-
-==============================================================
-
-kswapd:
-
-Kswapd is the kernel swapout daemon. That is, kswapd is that
-piece of the kernel that frees memory when it gets fragmented
-or full. Since every system is different, you'll probably want
-some control over this piece of the system.
-
-The numbers in this page correspond to the numbers in the
-struct pager_daemon {tries_base, tries_min, swap_cluster
-}; The tries_base and swap_cluster probably have the
-largest influence on system performance.
-
-tries_base	The maximum number of pages kswapd tries to
-		free in one round is calculated from this
-		number. Usually this number will be divided
-		by 4 or 8 (see mm/vmscan.c), so it isn't as
-		big as it looks.
-		When you need to increase the bandwidth to/from
-		swap, you'll want to increase this number.
-tries_min	This is the minimum number of times kswapd
-		tries to free a page each time it is called.
-		Basically it's just there to make sure that
-		kswapd frees some pages even when it's being
-		called with minimum priority.
-swap_cluster	This is the number of pages kswapd writes in
-		one turn. You want this large so that kswapd
-		does it's I/O in large chunks and the disk
-		doesn't have to seek often, but you don't want
-		it to be too large since that would flood the
-		request queue.
 
 ==============================================================
 
diff -Nru a/arch/arm/mm/init.c b/arch/arm/mm/init.c
--- a/arch/arm/mm/init.c	Mon Jul 29 15:19:51 2002
+++ b/arch/arm/mm/init.c	Mon Jul 29 15:19:51 2002
@@ -18,7 +18,6 @@
 #include <linux/mman.h>
 #include <linux/mm.h>
 #include <linux/swap.h>
-#include <linux/swapctl.h>
 #include <linux/smp.h>
 #include <linux/init.h>
 #include <linux/bootmem.h>
diff -Nru a/arch/mips/mm/init.c b/arch/mips/mm/init.c
--- a/arch/mips/mm/init.c	Mon Jul 29 15:19:51 2002
+++ b/arch/mips/mm/init.c	Mon Jul 29 15:19:51 2002
@@ -24,7 +24,6 @@
 #include <linux/bootmem.h>
 #include <linux/highmem.h>
 #include <linux/swap.h>
-#include <linux/swapctl.h>
 #ifdef CONFIG_BLK_DEV_INITRD
 #include <linux/blk.h>
 #endif
diff -Nru a/arch/mips64/mm/init.c b/arch/mips64/mm/init.c
--- a/arch/mips64/mm/init.c	Mon Jul 29 15:19:51 2002
+++ b/arch/mips64/mm/init.c	Mon Jul 29 15:19:51 2002
@@ -21,7 +21,6 @@
 #include <linux/bootmem.h>
 #include <linux/highmem.h>
 #include <linux/swap.h>
-#include <linux/swapctl.h>
 #ifdef CONFIG_BLK_DEV_INITRD
 #include <linux/blk.h>
 #endif
diff -Nru a/arch/sparc/mm/init.c b/arch/sparc/mm/init.c
--- a/arch/sparc/mm/init.c	Mon Jul 29 15:19:51 2002
+++ b/arch/sparc/mm/init.c	Mon Jul 29 15:19:51 2002
@@ -18,7 +18,6 @@
 #include <linux/mman.h>
 #include <linux/mm.h>
 #include <linux/swap.h>
-#include <linux/swapctl.h>
 #ifdef CONFIG_BLK_DEV_INITRD
 #include <linux/blk.h>
 #endif
diff -Nru a/arch/sparc64/mm/init.c b/arch/sparc64/mm/init.c
--- a/arch/sparc64/mm/init.c	Mon Jul 29 15:19:51 2002
+++ b/arch/sparc64/mm/init.c	Mon Jul 29 15:19:51 2002
@@ -15,7 +15,6 @@
 #include <linux/slab.h>
 #include <linux/blk.h>
 #include <linux/swap.h>
-#include <linux/swapctl.h>
 #include <linux/pagemap.h>
 #include <linux/fs.h>
 #include <linux/seq_file.h>
diff -Nru a/fs/coda/sysctl.c b/fs/coda/sysctl.c
--- a/fs/coda/sysctl.c	Mon Jul 29 15:19:51 2002
+++ b/fs/coda/sysctl.c	Mon Jul 29 15:19:51 2002
@@ -15,7 +15,6 @@
 #include <linux/time.h>
 #include <linux/mm.h>
 #include <linux/sysctl.h>
-#include <linux/swapctl.h>
 #include <linux/proc_fs.h>
 #include <linux/slab.h>
 #include <linux/stat.h>
diff -Nru a/fs/intermezzo/sysctl.c b/fs/intermezzo/sysctl.c
--- a/fs/intermezzo/sysctl.c	Mon Jul 29 15:19:51 2002
+++ b/fs/intermezzo/sysctl.c	Mon Jul 29 15:19:51 2002
@@ -8,7 +8,6 @@
 #include <linux/time.h>
 #include <linux/mm.h>
 #include <linux/sysctl.h>
-#include <linux/swapctl.h>
 #include <linux/proc_fs.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
diff -Nru a/include/linux/swapctl.h b/include/linux/swapctl.h
--- a/include/linux/swapctl.h	Mon Jul 29 15:19:51 2002
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,13 +0,0 @@
-#ifndef _LINUX_SWAPCTL_H
-#define _LINUX_SWAPCTL_H
-
-typedef struct pager_daemon_v1
-{
-	unsigned int	tries_base;
-	unsigned int	tries_min;
-	unsigned int	swap_cluster;
-} pager_daemon_v1;
-typedef pager_daemon_v1 pager_daemon_t;
-extern pager_daemon_t pager_daemon;
-
-#endif /* _LINUX_SWAPCTL_H */
diff -Nru a/include/linux/sysctl.h b/include/linux/sysctl.h
--- a/include/linux/sysctl.h	Mon Jul 29 15:19:51 2002
+++ b/include/linux/sysctl.h	Mon Jul 29 15:19:51 2002
@@ -136,12 +136,12 @@
 	VM_UNUSED1=1,		/* was: struct: Set vm swapping control */
 	VM_UNUSED2=2,		/* was; int: Linear or sqrt() swapout for hogs */
 	VM_UNUSED3=3,		/* was: struct: Set free page thresholds */
-	VM_BDFLUSH_UNUSED=4,	/* Spare */
+	VM_UNUSED4=4,		/* Spare */
 	VM_OVERCOMMIT_MEMORY=5,	/* Turn off the virtual memory safety limit */
-	VM_UNUSED4=6,		/* was: struct: Set buffer memory thresholds */
-	VM_UNUSED5=7,		/* was: struct: Set cache memory thresholds */
-	VM_PAGERDAEMON=8,	/* struct: Control kswapd behaviour */
-	VM_UNUSED6=9,		/* was: struct: Set page table cache parameters */
+	VM_UNUSED5=6,		/* was: struct: Set buffer memory thresholds */
+	VM_UNUSED7=7,		/* was: struct: Set cache memory thresholds */
+	VM_UNUSED8=8,		/* was: struct: Control kswapd behaviour */
+	VM_UNUSED9=9,		/* was: struct: Set page table cache parameters */
 	VM_PAGE_CLUSTER=10,	/* int: set number of pages to swap together */
 	VM_DIRTY_BACKGROUND=11,	/* dirty_background_ratio */
 	VM_DIRTY_ASYNC=12,	/* dirty_async_ratio */
diff -Nru a/kernel/suspend.c b/kernel/suspend.c
--- a/kernel/suspend.c	Mon Jul 29 15:19:51 2002
+++ b/kernel/suspend.c	Mon Jul 29 15:19:51 2002
@@ -36,7 +36,6 @@
 
 #include <linux/module.h>
 #include <linux/mm.h>
-#include <linux/swapctl.h>
 #include <linux/suspend.h>
 #include <linux/smp_lock.h>
 #include <linux/file.h>
diff -Nru a/kernel/sysctl.c b/kernel/sysctl.c
--- a/kernel/sysctl.c	Mon Jul 29 15:19:51 2002
+++ b/kernel/sysctl.c	Mon Jul 29 15:19:51 2002
@@ -22,7 +22,6 @@
 #include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/sysctl.h>
-#include <linux/swapctl.h>
 #include <linux/proc_fs.h>
 #include <linux/ctype.h>
 #include <linux/utsname.h>
@@ -272,8 +271,6 @@
 	{VM_OVERCOMMIT_RATIO, "overcommit_ratio",
 	 &sysctl_overcommit_ratio, sizeof(sysctl_overcommit_ratio), 0644,
 	 NULL, &proc_dointvec},
-	{VM_PAGERDAEMON, "kswapd",
-	 &pager_daemon, sizeof(pager_daemon_t), 0644, NULL, &proc_dointvec},
 	{VM_PAGE_CLUSTER, "page-cluster", 
 	 &page_cluster, sizeof(int), 0644, NULL, &proc_dointvec},
 	{VM_DIRTY_BACKGROUND, "dirty_background_ratio",
diff -Nru a/mm/bootmem.c b/mm/bootmem.c
--- a/mm/bootmem.c	Mon Jul 29 15:19:51 2002
+++ b/mm/bootmem.c	Mon Jul 29 15:19:51 2002
@@ -12,7 +12,6 @@
 #include <linux/mm.h>
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
-#include <linux/swapctl.h>
 #include <linux/interrupt.h>
 #include <linux/init.h>
 #include <linux/bootmem.h>
diff -Nru a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c	Mon Jul 29 15:19:51 2002
+++ b/mm/memory.c	Mon Jul 29 15:19:51 2002
@@ -41,7 +41,6 @@
 #include <linux/mman.h>
 #include <linux/swap.h>
 #include <linux/smp_lock.h>
-#include <linux/swapctl.h>
 #include <linux/iobuf.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
diff -Nru a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c	Mon Jul 29 15:19:51 2002
+++ b/mm/mmap.c	Mon Jul 29 15:19:51 2002
@@ -11,7 +11,6 @@
 #include <linux/mman.h>
 #include <linux/pagemap.h>
 #include <linux/swap.h>
-#include <linux/swapctl.h>
 #include <linux/smp_lock.h>
 #include <linux/init.h>
 #include <linux/file.h>
diff -Nru a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c	Mon Jul 29 15:19:51 2002
+++ b/mm/oom_kill.c	Mon Jul 29 15:19:51 2002
@@ -18,7 +18,6 @@
 #include <linux/mm.h>
 #include <linux/sched.h>
 #include <linux/swap.h>
-#include <linux/swapctl.h>
 #include <linux/timex.h>
 
 /* #define DEBUG */
diff -Nru a/mm/swap.c b/mm/swap.c
--- a/mm/swap.c	Mon Jul 29 15:19:51 2002
+++ b/mm/swap.c	Mon Jul 29 15:19:51 2002
@@ -16,7 +16,6 @@
 #include <linux/mm.h>
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
-#include <linux/swapctl.h>
 #include <linux/pagemap.h>
 #include <linux/init.h>
 
@@ -26,12 +25,6 @@
 
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
-
-pager_daemon_t pager_daemon = {
-	512,	/* base number for calculating the number of tries */
-	SWAP_CLUSTER_MAX,	/* minimum number of tries */
-	8,	/* do swap I/O in clusters of this size */
-};
 
 /*
  * Move an inactive page to the active list.
diff -Nru a/mm/swap_state.c b/mm/swap_state.c
--- a/mm/swap_state.c	Mon Jul 29 15:19:51 2002
+++ b/mm/swap_state.c	Mon Jul 29 15:19:51 2002
@@ -10,7 +10,6 @@
 #include <linux/mm.h>
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
-#include <linux/swapctl.h>
 #include <linux/init.h>
 #include <linux/pagemap.h>
 #include <linux/smp_lock.h>
diff -Nru a/mm/swapfile.c b/mm/swapfile.c
--- a/mm/swapfile.c	Mon Jul 29 15:19:51 2002
+++ b/mm/swapfile.c	Mon Jul 29 15:19:51 2002
@@ -10,7 +10,6 @@
 #include <linux/smp_lock.h>
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
-#include <linux/swapctl.h>
 #include <linux/vmalloc.h>
 #include <linux/pagemap.h>
 #include <linux/namei.h>
diff -Nru a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	Mon Jul 29 15:19:51 2002
+++ b/mm/vmscan.c	Mon Jul 29 15:19:51 2002
@@ -15,7 +15,6 @@
 #include <linux/slab.h>
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
-#include <linux/swapctl.h>
 #include <linux/smp_lock.h>
 #include <linux/pagemap.h>
 #include <linux/init.h>

===================================================================


This BitKeeper patch contains the following changesets:
1.512
## Wrapped with gzip_uu ##


begin 664 bkpatch9069
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
J9OC[!KG41P:;7-;C.[_)M_Z?$E#8NKML&5\%08`#3M7@OUC_AWZ4,0``
`
end

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
