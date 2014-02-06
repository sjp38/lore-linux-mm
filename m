Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 717316B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 08:21:22 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id y10so1241307wgg.34
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 05:21:21 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bh2si549878wjc.89.2014.02.06.05.21.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 05:21:20 -0800 (PST)
Date: Thu, 6 Feb 2014 14:21:19 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: since-3.13 branch opened for mm git tree (was: Re: mmotm
 2014-02-05-15-56 uploaded)
Message-ID: <20140206132119.GD20269@dhcp22.suse.cz>
References: <20140205235719.A54A231C1DB@corp2gmr1-1.hot.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140205235719.A54A231C1DB@corp2gmr1-1.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

I have just created since-3.12 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v3.12 tag in Linus tree and mmotm-2014-02-05-15-56.

I have pulled some cgroup wide changes from Tejun as well but cgroupfs->kernfs
changes are not there yet.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The current shortlog says:
Alex Williamson (1):
      intel-iommu: fix off-by-one in pagetable freeing

Andi Kleen (1):
      numa: add a sysctl for numa_balancing

Andrea Arcangeli (6):
      mm: hugetlb: use get_page_foll() in follow_hugetlb_page()
      mm: hugetlbfs: move the put/get_page slab and hugetlbfs optimization in a faster path
      mm: thp: optimize compound_trans_huge
      mm: tail page refcounting optimization for slab and hugetlbfs
      mm: hugetlbfs: use __compound_tail_refcounted in __get_page_tail too
      mm/hugetlb.c: defer PageHeadHuge() symbol export

Andreas Sandberg (1):
      mm/hugetlb.c: call MMU notifiers when copying a hugetlb page range

Andrew Morton (5):
      posix_acl: uninlining
      mm/hugetlb.c: simplify PageHeadHuge() and PageHuge()
      mm/swap.c: reorganize put_compound_page()
      mm-hugetlb-improve-page-fault-scalability-fix
      mm-vmstat-fix-up-zone-state-accounting-fix

Axel Lin (2):
      fs/ramfs/file-nommu.c: make ramfs_nommu_get_unmapped_area() and ramfs_nommu_mmap() static
      fs/ramfs: move ramfs_aops to inode.c

Corey Minyard (1):
      fs/read_write.c:compat_readv(): remove bogus area verify

Cyrill Gorcunov (1):
      mm: ignore VM_SOFTDIRTY on VMA merging

Dan Carpenter (1):
      fs/compat_ioctl.c: fix an underflow issue (harmless)

Dan Streetman (1):
      mm/zswap.c: change params from hidden to ro

Dan Williams (1):
      dma-debug: introduce debug_dma_assert_idle()

Dave Hansen (3):
      mm: hugetlbfs: Add some VM_BUG_ON()s to catch non-hugetlbfs pages
      mm: documentation: remove hopelessly out-of-date locking doc
      mm: print more details for bad_page()

David Rientjes (5):
      mm, mempolicy: remove unneeded functions for UMA configs
      mm, page_alloc: warn for non-blockable __GFP_NOFAIL allocation failure
      mm, oom: prefer thread group leaders for display purposes
      mm, compaction: ignore pageblock skip when manually invoking compaction
      mm, hugetlb: mark some bootstrap functions as __init

Davidlohr Bueso (4):
      mm/mmap.c: add mlock_future_check() helper
      mm/mlock: prepare params outside critical region
      mm, hugetlb: fix race in region tracking
      mm, hugetlb: improve page-fault scalability

Fengguang Wu (1):
      mm/rmap: fix coccinelle warnings

Geert Uytterhoeven (2):
      score: remove "select HAVE_GENERIC_HARDIRQS" again
      mm: Make {,set}page_address() static inline if WANT_PAGE_VIRTUAL

Goldwyn Rodrigues (7):
      ocfs2: remove versioning information
      ocfs2: add clustername to cluster connection
      ocfs2: add DLM recovery callbacks
      ocfs2: shift allocation ocfs2_live_connection to user_connect()
      ocfs2: pass ocfs2_cluster_connection to ocfs2_this_node
      ocfs2: framework for version LVB
      ocfs2: use the new DLM operation callbacks while requesting new lockspace

Grygorii Strashko (11):
      mm/memblock: debug: correct displaying of upper memory boundary
      mm/memblock: debug: don't free reserved array if !ARCH_DISCARD_MEMBLOCK
      mm/bootmem: remove duplicated declaration of __free_pages_bootmem()
      mm/memblock: remove unnecessary inclusions of bootmem.h
      mm/memblock: drop WARN and use SMP_CACHE_BYTES as a default alignment
      mm/memblock: reorder parameters of memblock_find_in_range_node
      mm/memblock: switch to use NUMA_NO_NODE instead of MAX_NUMNODES
      mm/hugetlb.c: use memblock apis for early memory allocations
      mm/page_cgroup.c: use memblock apis for early memory allocations
      x86/mm: memblock: switch to use NUMA_NO_NODE
      mm/memblock: use WARN_ONCE when MAX_NUMNODES passed as input parameter

Han Pingtian (2):
      mm: prevent setting of a value less than 0 to min_free_kbytes
      mm: show message when updating min_free_kbytes in thp

Hugh Dickins (3):
      cgroup: remove stray references to css_id
      mm/memcg: fix last_dead_count memory wastage
      mm/memcg: iteration skip memcgs not yet fully initialized

Jamie Liu (1):
      mm/swapfile.c: do not skip lowest_bit in scan_swap_map() scan loop

Jan Kara (4):
      inotify: provide function for name length rounding
      fsnotify: do not share events between notification groups
      fsnotify: remove .should_send_event callback
      fsnotify: remove pointless NULL initializers

Jerome Marchand (1):
      mm: add overcommit_kbytes sysctl variable

Jianguo Wu (1):
      mm: do_mincore() cleanup

Jianyu Zhan (1):
      mm/vmalloc: interchage the implementation of vmalloc_to_{pfn,page}

Jie Liu (3):
      ocfs2: return EOPNOTSUPP if the device does not support discard
      ocfs2: return EINVAL if the given range to discard is less than block size
      ocfs2: adjust minlen with discard_granularity in the FITRIM ioctl

Johannes Weiner (10):
      mm: vmstat: fix UP zone state accounting
      fs: cachefiles: use add_to_page_cache_lru()
      lib: radix-tree: add radix_tree_delete_item()
      mm: shmem: save one radix tree lookup when truncating swapped pages
      mm: filemap: move radix tree hole searching here
      mm + fs: prepare for non-page entries in page cache radix trees
      mm + fs: store shadow entries in page cache
      mm: thrash detection-based file cache sizing
      lib: radix_tree: tree node interface
      mm: keep page cache radix tree nodes in check

Joonsoo Kim (16):
      mm/rmap: recompute pgoff for huge page
      mm/rmap: factor nonlinear handling out of try_to_unmap_file()
      mm/rmap: factor lock function out of rmap_walk_anon()
      mm/rmap: make rmap_walk to get the rmap_walk_control argument
      mm/rmap: extend rmap_walk_xxx() to cope with different cases
      mm/rmap: use rmap_walk() in try_to_unmap()
      mm/rmap: use rmap_walk() in try_to_munlock()
      mm/rmap: use rmap_walk() in page_referenced()
      mm/rmap: use rmap_walk() in page_mkclean()
      mm/migrate: correct failure handling if !hugepage_migration_support()
      mm/migrate: remove putback_lru_pages, fix comment on putback_movable_pages
      mm/migrate: remove unused function, fail_migrate_page()
      mm, hugetlb: unify region structure handling
      mm, hugetlb: improve, cleanup resv_map parameters
      mm, hugetlb: remove resv_map_put
      mm, hugetlb: use vma_resv_map() map types

KOSAKI Motohiro (2):
      mm: __set_page_dirty_nobuffers() uses spin_lock_irqsave() instead of spin_lock_irq()
      mm: __set_page_dirty uses spin_lock_irqsave instead of spin_lock_irq

Kirill A. Shutemov (1):
      mm: create a separate slab for page->ptl allocation

Mark Salter (10):
      add generic fixmap.h
      x86: use generic fixmap.h
      hexagon: use generic fixmap.h
      metag: use generic fixmap.h
      microblaze: use generic fixmap.h
      mips: use generic fixmap.h
      powerpc: use generic fixmap.h
      sh: use generic fixmap.h
      tile: use generic fixmap.h
      um: use generic fixmap.h

Masanari Iida (1):
      doc: cgroups: Fix typo in doc/cgroups

Mel Gorman (9):
      mm, show_mem: remove SHOW_MEM_FILTER_PAGE_COUNT
      mm: numa: make NUMA-migrate related functions static
      mm: numa: limit scope of lock for NUMA migrate rate limiting
      mm: numa: trace tasks that fail migration due to rate limiting
      mm: numa: do not automatically migrate KSM pages
      sched: add tracepoints related to NUMA task migration
      mm: compaction: trace compaction begin and end
      mm: improve documentation of page_order
      mm: optimize put_mems_allowed() usage

Michal Hocko (4):
      memcg, oom: lock mem_cgroup_print_oom_info
      mm: new_vma_page() cannot see NULL vma for hugetlb pages
      memcg: fix endless loop caused by mem_cgroup_iter
      memcg: fix css reference leak and endless loop in mem_cgroup_iter

Mike Frysinger (1):
      uapi: convert u64 to __u64 in exported headers

Naoya Horiguchi (3):
      mm/migrate: add comment about permanent failure path
      fs/proc/page.c: add PageAnon check to surely detect thp
      mm/memory-failure.c: shift page lock from head page to tail page after thp split

Nathan Zimmer (1):
      mm/memory_hotplug.c: move register_memory_resource out of the lock_memory_hotplug

Oleg Nesterov (6):
      mm: thp: __get_page_tail_foll() can use get_huge_page_tail()
      mm: thp: turn compound_head() into BUG_ON(!PageTail) in get_huge_page_tail()
      introduce for_each_thread() to replace the buggy while_each_thread()
      oom_kill: change oom_kill.c to use for_each_thread()
      oom_kill: has_intersects_mems_allowed() needs rcu_read_lock()
      oom_kill: add rcu_read_lock() into find_lock_task_mm()

Paul Gortmaker (3):
      fs/ramfs: don't use module_init for non-modular core code
      mm/mm_init.c: make creation of the mm_kobj happen earlier than device_initcall
      mm: audit/fix non-modular users of module_init in core code

Philipp Hachtmann (3):
      mm/nobootmem.c: add return value check in __alloc_memory_core_early()
      mm: free memblock.memory in free_all_bootmem
      mm/nobootmem: free_all_bootmem again

Randy Dunlap (1):
      Documentation/kernel-parameters.txt: fix memmap= language

Rik van Riel (1):
      /proc/meminfo: provide estimated available memory

Santosh Shilimkar (15):
      x86: memblock: set current limit to max low memory address
      mm/memblock: add memblock memory allocation apis
      init/main.c: use memblock apis for early memory allocations
      kernel/printk/printk.c: use memblock apis for early memory allocations
      mm/page_alloc.c: use memblock apis for early memory allocations
      kernel/power/snapshot.c: use memblock apis for early memory allocations
      lib/swiotlb.c: use memblock apis for early memory allocations
      lib/cpumask.c: use memblock apis for early memory allocations
      mm/sparse: use memblock apis for early memory allocations
      mm/percpu.c: use memblock apis for early memory allocations
      mm/memory_hotplug.c: use memblock apis for early memory allocations
      drivers/firmware/memmap.c: use memblock apis for early memory allocations
      arch/arm/kernel/: use memblock apis for early memory allocations
      arch/arm/mm/init.c: use memblock apis for early memory allocations
      arch/arm/mach-omap2/omap_hwmod.c: use memblock apis for early memory allocations

Sasha Levin (1):
      mm: dump page when hitting a VM_BUG_ON using VM_BUG_ON_PAGE

SeongJae Park (1):
      cgroup: trivial style updates

Shaohua Li (1):
      swap: add a simple detector for inappropriate swapin readahead

Shawn Guo (1):
      include/linux/genalloc.h: spinlock_t needs spinlock_types.h

Tang Chen (7):
      memblock, numa: introduce flags field into memblock
      memblock, mem_hotplug: introduce MEMBLOCK_HOTPLUG flag to mark hotpluggable regions
      memblock: make memblock_set_node() support different memblock_type
      acpi, numa, mem_hotplug: mark hotpluggable memory in memblock
      acpi, numa, mem_hotplug: mark all nodes the kernel resides un-hotpluggable
      memblock, mem_hotplug: make memblock skip hotpluggable regions if needed
      x86, numa, acpi, memory-hotplug: make movable_node have higher priority

Tariq Saeed (1):
      ocfs2: punch hole should return EINVAL if the length argument in ioctl is negative

Tejun Heo (35):
      cgroup, memcg: move cgroup_event implementation to memcg
      memcg: cgroup_write_event_control() now knows @css is for memcg
      cgroup, memcg: move cgroup->event_list[_lock] and event callbacks into memcg
      memcg: remove cgroup_event->cft
      memcg: make cgroup_event deal with mem_cgroup instead of cgroup_subsys_state
      memcg: rename cgroup_event to mem_cgroup_event
      cgroup: unexport cgroup_css() and remove __file_cft()
      cgroup: don't skip seq_open on write only opens on pidlist files
      cgroup: remove cftype->release()
      cgroup: implement delayed destruction for cgroup_pidlist
      cgroup: introduce struct cgroup_pidlist_open_file
      cgroup: refactor cgroup_pidlist_find()
      cgroup: remove cgroup_pidlist->rwsem
      cgroup: load and release pidlists from seq_file start and stop respectively
      cgroup: remove cgroup_pidlist->use_count
      cgroup: don't guarantee cgroup.procs is sorted if sane_behavior
      cgroup, sched: convert away from cftype->read_map()
      cpuset: convert away from cftype->read()
      memcg: convert away from cftype->read() and ->read_map()
      netprio_cgroup: convert away from cftype->read_map()
      hugetlb_cgroup: convert away from cftype->read()
      cgroup: remove cftype->read(), ->read_map() and ->write()
      cgroup: unify cgroup_write_X64() and cgroup_write_string()
      cgroup: unify read path so that seq_file is always used
      cgroup: generalize cgroup_pidlist_open_file
      cgroup: attach cgroup_open_file to all cgroup files
      cgroup: replace cftype->read_seq_string() with cftype->seq_show()
      cgroup: unify pidlist and other file handling
      cgroup: css iterations and css_from_dir() are safe under cgroup_mutex
      cgroup: make for_each_subsys() useable under cgroup_root_mutex
      cgroup: reorder operations in cgroup_create()
      cgroup: combine css handling loops in cgroup_create()
      cgroup: factor out cgroup_subsys_state creation into create_css()
      cgroup: implement for_each_css()
      cgroup: remove for_each_root_subsys()

Vinayak Menon (1):
      Documentation/trace/postprocess/trace-vmscan-postprocess.pl: fix the traceevent regex

Vladimir Davydov (23):
      fs/super.c: fix WARN on alloc_super() fail path
      memcg: fix kmem_account_flags check in memcg_can_account_kmem()
      memcg: make memcg_update_cache_sizes() static
      cgroup: fix fail path in cgroup_load_subsys()
      memcg: do not use vmalloc for mem_cgroup allocations
      slab: clean up kmem_cache_create_memcg() error handling
      memcg, slab: kmem_cache_create_memcg(): fix memleak on fail path
      memcg, slab: clean up memcg cache initialization/destruction
      memcg, slab: fix barrier usage when accessing memcg_caches
      memcg: fix possible NULL deref while traversing memcg_slab_caches list
      memcg, slab: fix races in per-memcg cache creation/destruction
      memcg: get rid of kmem_cache_dup()
      slab: do not panic if we fail to create memcg cache
      memcg, slab: RCU protect memcg_params for root caches
      memcg: remove KMEM_ACCOUNTED_ACTIVATED flag
      memcg: rework memcg_update_kmem_limit synchronization
      mm: vmscan: shrink all slab objects if tight on memory
      mm: vmscan: call NUMA-unaware shrinkers irrespective of nodemask
      memcg: remove unused code from kmem_cache_destroy_work_func
      mm: vmscan: respect NUMA policy mask when shrinking slab on direct reclaim
      mm: vmscan: move call to shrink_slab() to shrink_zones()
      mm: vmscan: remove shrink_control arg from do_try_to_free_pages()
      mm: vmscan: shrink_slab: rename max_pass -> freeable

Vlastimil Babka (6):
      mm: compaction: encapsulate defer reset logic
      mm: compaction: reset cached scanner pfn's before reading them
      mm: compaction: detect when scanners meet in isolate_freepages
      mm: compaction: do not mark unmovable pageblocks as skipped in async compaction
      mm: compaction: reset scanner positions immediately when they meet
      mm: munlock: fix potential race with THP page split

Wanlong Gao (1):
      arch/sh/kernel/kgdb.c: add missing #include <linux/sched.h>

Wanpeng Li (2):
      mm/hwpoison: add '#' to hwpoison_inject
      sched/numa: fix setting of cpupid on page migration twice

Wei Yongjun (2):
      ocfs2: fix sparse non static symbol warning
      cgroup: fix missing unlock on error in cgroup_load_subsys()

Weijie Yang (1):
      mm/swap: fix race on swap_info reuse between swapoff and swapon

Xishi Qiu (2):
      lib/show_mem.c: show num_poisoned_pages when oom
      doc/kmemcheck: add kmemcheck to kernel-parameters

Yasuaki Ishimatsu (1):
      mm: get rid of unnecessary pageblock scanning in setup_zone_migrate_reserve

Yiwen Jiang (1):
      ocfs2: fix NULL pointer dereference when dismount and ocfs2rec simultaneously

Younger Liu (1):
      ocfs2: remove redundant ocfs2_alloc_dinode_update_counts() and ocfs2_block_group_set_bits()

Zhi Yong Wu (1):
      mm, memory-failure: fix typo in me_pagecache_dirty()

Zongxun Wang (1):
      ocfs2: free allocated clusters if error occurs after ocfs2_claim_clusters
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
