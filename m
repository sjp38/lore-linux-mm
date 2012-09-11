Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 7ECD46B00C3
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 07:20:44 -0400 (EDT)
Received: by eeke49 with SMTP id e49so362205eek.14
        for <linux-mm@kvack.org>; Tue, 11 Sep 2012 04:20:43 -0700 (PDT)
Message-ID: <504F1E81.40002@gmail.com>
Date: Tue, 11 Sep 2012 13:20:33 +0200
From: Michael Kerrisk <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: [patch] memcg: trivial fixes for Documentation/cgroups/memory.txt
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

While reading through Documentation/cgroups/memory.txt, I found a number
of minor wordos and typos. The patch below is a conservative
handling of some of these: it provides just a number of "obviously
correct" fixes to the English that improve the readability
of the document somewhat. Obviously some more significant
fixes need to be made to the document, but some of those 
may not be in the "obvious correct" category.

Please apply.

Signed-off-by: Michael Kerrisk <mtk.manpages@gmail.com>


diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 4372e6b..c07f7b4 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -18,16 +18,16 @@ from the rest of the system. The article on LWN [12] mentions some probable
 uses of the memory controller. The memory controller can be used to
 
 a. Isolate an application or a group of applications
-   Memory hungry applications can be isolated and limited to a smaller
+   Memory-hungry applications can be isolated and limited to a smaller
    amount of memory.
-b. Create a cgroup with limited amount of memory, this can be used
+b. Create a cgroup with a limited amount of memory; this can be used
    as a good alternative to booting with mem=XXXX.
 c. Virtualization solutions can control the amount of memory they want
    to assign to a virtual machine instance.
 d. A CD/DVD burner could control the amount of memory used by the
    rest of the system to ensure that burning does not fail due to lack
    of available memory.
-e. There are several other use cases, find one or use the controller just
+e. There are several other use cases; find one or use the controller just
    for fun (to learn and hack on the VM subsystem).
 
 Current Status: linux-2.6.34-mmotm(development version of 2010/April)
@@ -38,12 +38,12 @@ Features:
  - optionally, memory+swap usage can be accounted and limited.
  - hierarchical accounting
  - soft limit
- - moving(recharging) account at moving a task is selectable.
+ - moving (recharging) account at moving a task is selectable.
  - usage threshold notifier
  - oom-killer disable knob and oom-notifier
  - Root cgroup has no limit controls.
 
- Kernel memory support is work in progress, and the current version provides
+ Kernel memory support is a work in progress, and the current version provides
  basically functionality. (See Section 2.7)
 
 Brief summary of control files.
@@ -144,9 +144,9 @@ Figure 1 shows the important aspects of the controller
 3. Each page has a pointer to the page_cgroup, which in turn knows the
    cgroup it belongs to
 
-The accounting is done as follows: mem_cgroup_charge() is invoked to setup
+The accounting is done as follows: mem_cgroup_charge() is invoked to set up
 the necessary data structures and check if the cgroup that is being charged
-is over its limit. If it is then reclaim is invoked on the cgroup.
+is over its limit. If it is, then reclaim is invoked on the cgroup.
 More details can be found in the reclaim section of this document.
 If everything goes well, a page meta-data-structure called page_cgroup is
 updated. page_cgroup has its own LRU on cgroup.
@@ -163,13 +163,13 @@ for earlier. A file page will be accounted for as Page Cache when it's
 inserted into inode (radix-tree). While it's mapped into the page tables of
 processes, duplicate accounting is carefully avoided.
 
-A RSS page is unaccounted when it's fully unmapped. A PageCache page is
+An RSS page is unaccounted when it's fully unmapped. A PageCache page is
 unaccounted when it's removed from radix-tree. Even if RSS pages are fully
 unmapped (by kswapd), they may exist as SwapCache in the system until they
-are really freed. Such SwapCaches also also accounted.
+are really freed. Such SwapCaches are also accounted.
 A swapped-in page is not accounted until it's mapped.
 
-Note: The kernel does swapin-readahead and read multiple swaps at once.
+Note: The kernel does swapin-readahead and reads multiple swaps at once.
 This means swapped-in pages may contain pages for other tasks than a task
 causing page fault. So, we avoid accounting at swap-in I/O.
 
@@ -209,7 +209,7 @@ memsw.limit_in_bytes.
 Example: Assume a system with 4G of swap. A task which allocates 6G of memory
 (by mistake) under 2G memory limitation will use all swap.
 In this case, setting memsw.limit_in_bytes=3G will prevent bad use of swap.
-By using memsw limit, you can avoid system OOM which can be caused by swap
+By using the memsw limit, you can avoid system OOM which can be caused by swap
 shortage.
 
 * why 'memory+swap' rather than swap.
@@ -217,7 +217,7 @@ The global LRU(kswapd) can swap out arbitrary pages. Swap-out means
 to move account from memory to swap...there is no change in usage of
 memory+swap. In other words, when we want to limit the usage of swap without
 affecting global LRU, memory+swap limit is better than just limiting swap from
-OS point of view.
+an OS point of view.
 
 * What happens when a cgroup hits memory.memsw.limit_in_bytes
 When a cgroup hits memory.memsw.limit_in_bytes, it's useless to do swap-out
@@ -236,7 +236,7 @@ an OOM routine is invoked to select and kill the bulkiest task in the
 cgroup. (See 10. OOM Control below.)
 
 The reclaim algorithm has not been modified for cgroups, except that
-pages that are selected for reclaiming come from the per cgroup LRU
+pages that are selected for reclaiming come from the per-cgroup LRU
 list.
 
 NOTE: Reclaim does not work for the root cgroup, since we cannot set any
@@ -316,7 +316,7 @@ We can check the usage:
 # cat /sys/fs/cgroup/memory/0/memory.usage_in_bytes
 1216512
 
-A successful write to this file does not guarantee a successful set of
+A successful write to this file does not guarantee a successful setting of
 this limit to the value written into the file. This can be due to a
 number of factors, such as rounding up to page boundaries or the total
 availability of memory on the system. The user is required to re-read
@@ -350,7 +350,7 @@ Trying usual test under memory controller is always helpful.
 4.1 Troubleshooting
 
 Sometimes a user might find that the application under a cgroup is
-terminated by OOM killer. There are several causes for this:
+terminated by the OOM killer. There are several causes for this:
 
 1. The cgroup limit is too low (just too low to do anything useful)
 2. The user is using anonymous memory and swap is turned off or too low
@@ -358,7 +358,7 @@ terminated by OOM killer. There are several causes for this:
 A sync followed by echo 1 > /proc/sys/vm/drop_caches will help get rid of
 some of the pages cached in the cgroup (page cache pages).
 
-To know what happens, disable OOM_Kill by 10. OOM Control(see below) and
+To know what happens, disabling OOM_Kill as per "10. OOM Control" (below) and
 seeing what happens will be helpful.
 
 4.2 Task migration
@@ -399,10 +399,10 @@ About use_hierarchy, see Section 6.
 
   Almost all pages tracked by this memory cgroup will be unmapped and freed.
   Some pages cannot be freed because they are locked or in-use. Such pages are
-  moved to parent(if use_hierarchy==1) or root (if use_hierarchy==0) and this
+  moved to parent (if use_hierarchy==1) or root (if use_hierarchy==0) and this
   cgroup will be empty.
 
-  Typical use case of this interface is that calling this before rmdir().
+  The typical use case for this interface is before calling rmdir().
   Because rmdir() moves all pages to parent, some out-of-use page caches can be
   moved to the parent. If you want to avoid that, force_empty will be useful.
 
@@ -486,7 +486,7 @@ You can reset failcnt by writing 0 to failcnt file.
 
 For efficiency, as other kernel components, memory cgroup uses some optimization
 to avoid unnecessary cacheline false sharing. usage_in_bytes is affected by the
-method and doesn't show 'exact' value of memory(and swap) usage, it's an fuzz
+method and doesn't show 'exact' value of memory (and swap) usage, it's a fuzz
 value for efficient access. (Of course, when necessary, it's synchronized.)
 If you want to know more exact memory usage, you should use RSS+CACHE(+SWAP)
 value in memory.stat(see 5.2).
@@ -496,8 +496,8 @@ value in memory.stat(see 5.2).
 This is similar to numa_maps but operates on a per-memcg basis.  This is
 useful for providing visibility into the numa locality information within
 an memcg since the pages are allowed to be allocated from any physical
-node.  One of the usecases is evaluating application performance by
-combining this information with the application's cpu allocation.
+node.  One of the use cases is evaluating application performance by
+combining this information with the application's CPU allocation.
 
 We export "total", "file", "anon" and "unevictable" pages per-node for
 each memcg.  The ouput format of memory.numa_stat is:
@@ -561,10 +561,10 @@ are pushed back to their soft limits. If the soft limit of each control
 group is very high, they are pushed back as much as possible to make
 sure that one control group does not starve the others of memory.
 
-Please note that soft limits is a best effort feature, it comes with
+Please note that soft limits is a best-effort feature; it comes with
 no guarantees, but it does its best to make sure that when memory is
 heavily contended for, memory is allocated based on the soft limit
-hints/setup. Currently soft limit based reclaim is setup such that
+hints/setup. Currently soft limit based reclaim is set up such that
 it gets invoked from balance_pgdat (kswapd).
 
 7.1 Interface
@@ -592,7 +592,7 @@ page tables.
 
 8.1 Interface
 
-This feature is disabled by default. It can be enabled(and disabled again) by
+This feature is disabled by default. It can be enabledi (and disabled again) by
 writing to memory.move_charge_at_immigrate of the destination cgroup.
 
 If you want to enable it:
@@ -601,8 +601,8 @@ If you want to enable it:
 
 Note: Each bits of move_charge_at_immigrate has its own meaning about what type
       of charges should be moved. See 8.2 for details.
-Note: Charges are moved only when you move mm->owner, IOW, a leader of a thread
-      group.
+Note: Charges are moved only when you move mm->owner, in other words,
+      a leader of a thread group.
 Note: If we cannot find enough space for the task in the destination cgroup, we
       try to make space by reclaiming memory. Task migration may fail if we
       cannot make enough space.
@@ -612,25 +612,25 @@ And if you want disable it again:
 
 # echo 0 > memory.move_charge_at_immigrate
 
-8.2 Type of charges which can be move
+8.2 Type of charges which can be moved
 
-Each bits of move_charge_at_immigrate has its own meaning about what type of
-charges should be moved. But in any cases, it must be noted that an account of
-a page or a swap can be moved only when it is charged to the task's current(old)
-memory cgroup.
+Each bit in move_charge_at_immigrate has its own meaning about what type of
+charges should be moved. But in any case, it must be noted that an account of
+a page or a swap can be moved only when it is charged to the task's current
+(old) memory cgroup.
 
   bit | what type of charges would be moved ?
  -----+------------------------------------------------------------------------
-   0  | A charge of an anonymous page(or swap of it) used by the target task.
-      | You must enable Swap Extension(see 2.4) to enable move of swap charges.
+   0  | A charge of an anonymous page (or swap of it) used by the target task.
+      | You must enable Swap Extension (see 2.4) to enable move of swap charges.
  -----+------------------------------------------------------------------------
-   1  | A charge of file pages(normal file, tmpfs file(e.g. ipc shared memory)
+   1  | A charge of file pages (normal file, tmpfs file (e.g. ipc shared memory)
       | and swaps of tmpfs file) mmapped by the target task. Unlike the case of
-      | anonymous pages, file pages(and swaps) in the range mmapped by the task
+      | anonymous pages, file pages (and swaps) in the range mmapped by the task
       | will be moved even if the task hasn't done page fault, i.e. they might
       | not be the task's "RSS", but other task's "RSS" that maps the same file.
-      | And mapcount of the page is ignored(the page can be moved even if
-      | page_mapcount(page) > 1). You must enable Swap Extension(see 2.4) to
+      | And mapcount of the page is ignored (the page can be moved even if
+      | page_mapcount(page) > 1). You must enable Swap Extension (see 2.4) to
       | enable move of swap charges.
 
 8.3 TODO
@@ -640,11 +640,11 @@ memory cgroup.
 
 9. Memory thresholds
 
-Memory cgroup implements memory thresholds using cgroups notification
+Memory cgroup implements memory thresholds using the cgroups notification
 API (see cgroups.txt). It allows to register multiple memory and memsw
 thresholds and gets notifications when it crosses.
 
-To register a threshold application need:
+To register a threshold, an application must:
 - create an eventfd using eventfd(2);
 - open memory.usage_in_bytes or memory.memsw.usage_in_bytes;
 - write string like "<event_fd> <fd of memory.usage_in_bytes> <threshold>" to
@@ -659,24 +659,24 @@ It's applicable for root and non-root cgroup.
 
 memory.oom_control file is for OOM notification and other controls.
 
-Memory cgroup implements OOM notifier using cgroup notification
+Memory cgroup implements OOM notifier using the cgroup notification
 API (See cgroups.txt). It allows to register multiple OOM notification
 delivery and gets notification when OOM happens.
 
-To register a notifier, application need:
+To register a notifier, an application must:
  - create an eventfd using eventfd(2)
  - open memory.oom_control file
  - write string like "<event_fd> <fd of memory.oom_control>" to
    cgroup.event_control
 
-Application will be notified through eventfd when OOM happens.
-OOM notification doesn't work for root cgroup.
+The application will be notified through eventfd when OOM happens.
+OOM notification doesn't work for the root cgroup.
 
-You can disable OOM-killer by writing "1" to memory.oom_control file, as:
+You can disable the OOM-killer by writing "1" to memory.oom_control file, as:
 
 	#echo 1 > memory.oom_control
 
-This operation is only allowed to the top cgroup of sub-hierarchy.
+This operation is only allowed to the top cgroup of a sub-hierarchy.
 If OOM-killer is disabled, tasks under cgroup will hang/sleep
 in memory cgroup's OOM-waitqueue when they request accountable memory.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
