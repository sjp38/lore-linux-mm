Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6A19A6B0253
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 07:23:13 -0500 (EST)
Received: by wmec201 with SMTP id c201so44261074wme.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 04:23:12 -0800 (PST)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id 185si30539793wmx.119.2015.11.11.04.23.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 04:23:11 -0800 (PST)
Received: by wmec201 with SMTP id c201so178967595wme.0
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 04:23:11 -0800 (PST)
Date: Wed, 11 Nov 2015 13:23:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: mmotm git tree since-4.3 branch created (was: Re: mmotm
 2015-11-10-15-53 uploaded)
Message-ID: <20151111122309.GB1432@dhcp22.suse.cz>
References: <564283a0.beR7/+fS68wfuK2o%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <564283a0.beR7/+fS68wfuK2o%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au

I have just created since-4.3 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v4.3 tag in Linus tree and mmotm-mmotm-2015-11-10-15-53.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The shortlog says:
Aaron Tomlin (1):
      thp: remove unused vma parameter from khugepaged_alloc_page

Alexander Kuleshov (13):
      mm/msync: use offset_in_page macro
      mm/nommu: use offset_in_page macro
      mm/mincore: use offset_in_page macro
      mm/early_ioremap: use offset_in_page macro
      mm/percpu: use offset_in_page macro
      mm/util: use offset_in_page macro
      mm/mlock: use offset_in_page macro
      mm/vmalloc: use offset_in_page macro
      mm/mmap: use offset_in_page macro
      mm/mremap: use offset_in_page macro
      mm/memblock: make memblock_remove_range() static
      mm/hugetlb: make node_hstates array static
      lib/halfmd4.c: use rol32 inline function in the ROUND macro

Alexandre Courbot (1):
      drm/nouveau/ttm: convert to DMA API

Alexandru Moise (2):
      mm/slab_common.c: initialize kmem_cache pointer to NULL
      mm/vmscan.c: fix types of some locals

Alexey Klimov (3):
      mm/kmemleak.c: remove unneeded initialization of object to NULL
      mm/mlock.c: reorganize mlockall() return values and remove goto-out label
      mm/zswap.c: remove unneeded initialization to NULL in zswap_entry_find_get()

Andrea Arcangeli (5):
      ksm: add cond_resched() to the rmap_walks
      ksm: don't fail stable tree lookups if walking over stale stable_nodes
      ksm: use the helper method to do the hlist_empty check
      ksm: use find_mergeable_vma in try_to_merge_with_ksm_page
      ksm: unstable_tree_search_insert error checking cleanup

Andrew Morton (12):
      uaccess: reimplement probe_kernel_address() using probe_kernel_read()
      mm/vmstat.c: uninline node_page_state()
      mm/cma.c: suppress warning
      include/linux/mmzone.h: reflow comment
      mm/memcontrol.c: uninline mem_cgroup_usage
      include/linux/compiler-gcc.h: improve __visible documentation
      slub-optimize-bulk-slowpath-free-by-detached-freelist-fix
      mm-fs-obey-gfp_mapping-for-add_to_page_cache-fix
      mm-rework-mapcount-accounting-to-enable-4k-mapping-of-thps-fix
      mm-hwpoison-adjust-for-new-thp-refcounting-fix
      mm-prepare-page_referenced-and-page_idle-to-new-thp-refcounting-checkpatch-fixes
      mm-increase-swap_cluster_max-to-batch-tlb-flushes-fix-fix

Andrey Konovalov (7):
      kasan: update reported bug types for not user nor kernel memory accesses
      kasan: update reported bug types for kernel memory accesses
      kasan: accurately determine the type of the bad access
      kasan: update log messages
      kasan: various fixes in documentation
      kasan: move KASAN_SANITIZE in arch/x86/boot/Makefile
      kasan: update reference to kasan prototype repo

Andrey Ryabinin (2):
      mm, slub, kasan: enable user tracking by default with KASAN=y
      kasan: always taint kernel on report

Andy Shevchenko (5):
      fs/proc/array.c: set overflow flag in case of error
      lib/hexdump.c: truncate output in case of overflow
      fs/seq_file: use seq_* helpers in seq_hex_dump()
      seq_file: reuse string_escape_str()
      lib/string.c: add ULL suffix to the constant definition

Aneesh Kumar K.V (4):
      mm/kasan: rename kasan_enabled() to kasan_report_enabled()
      mm/kasan: MODULE_VADDR is not available on all archs
      mm/kasan: don't use kasan shadow pointer in generic functions
      mm/kasan: prevent deadlock in kasan reporting

Arnd Bergmann (1):
      ARM: thp: fix unterminated ifdef in header file

Ben Segall (1):
      pidns: fix set/getpriority and ioprio_set/get in PRIO_USER mode

Catalin Marinas (1):
      mm: slab: only move management objects off-slab for sizes larger than KMALLOC_MIN_SIZE

Chen Gang (4):
      mm/mmap.c: remove useless statement "vma = NULL" in find_vma()
      mm/mmap.c: remove redundant statement "error = -ENOMEM"
      mm/mmap.c: do not initialize retval in mmap_pgoff()
      mm/mmap.c: change __install_special_mapping() args order

Christoph Hellwig (12):
      pcnet32: use pci_set_dma_mask insted of pci_dma_supported
      tw68-core: use pci_set_dma_mask insted of pci_dma_supported
      saa7164: use pci_set_dma_mask insted of pci_dma_supported
      saa7134: use pci_set_dma_mask insted of pci_dma_supported
      cx88: use pci_set_dma_mask insted of pci_dma_supported
      cx25821: use pci_set_dma_mask insted of pci_dma_supported
      cx23885: use pci_set_dma_mask insted of pci_dma_supported
      netup_unidvb: use pci_set_dma_mask insted of pci_dma_supported
      sfc: don't call dma_supported
      kaweth: remove ifdefed out call to dma_supported
      usbnet: remove ifdefed out call to dma_supported
      pci: remove pci_dma_supported

Christoph Lameter (2):
      slub: create new ___slab_alloc function that can be called with irqs disabled
      slub: avoid irqoff/on in bulk allocation

Cody P Schafer (1):
      rbtree: clarify documentation of rbtree_postorder_for_each_entry_safe()

Dan Carpenter (1):
      mm/huge_memory: add a missing tab

Dan Streetman (3):
      module: export param_free_charp()
      zswap: use charp for zswap param strings
      zpool: remove redundant zpool->type string, const-ify zpool_get_type

Dan Williams (1):
      block: generic request_queue reference counting

Daniel Baluta (1):
      configfs: allow dynamic group creation

Dave Hansen (2):
      mm, hugetlb: use memory policy when available
      mm, hugetlbfs: optimize when NUMA=n

David Rientjes (2):
      mm, oom: remove task_lock protecting comm printing
      mm, oom: add comment for why oom_adj exists

Davidlohr Bueso (1):
      mm/vmacache: inline vmacache_valid_mm()

Denis Kirjanov (1):
      slab: convert slab_is_available() to boolean

Dmitry Vyukov (1):
      lib/llist.c: fix data race in llist_del_first

Ebru Akagunduz (4):
      Documentation/vm/transhuge.txt: add information about max_ptes_swap
      mm: add tracepoint for scanning pages
      mm: make optimistic check for swapin readahead
      mm: make swapin readahead to improve thp collapse rate

Eric B Munson (5):
      mm: mlock: refactor mlock, munlock, and munlockall code
      mm: mlock: add new mlock system call
      mm: introduce VM_LOCKONFAULT
      mm: mlock: add mlock flags to enable VM_LOCKONFAULT usage
      selftests: vm: add tests for lock on fault

Geert Uytterhoeven (2):
      selftests/mlock2: add missing #define _GNU_SOURCE
      selftests/mlock2: add ULL suffix to 64-bit constants

Geliang Tang (2):
      mm/nommu.c: drop unlikely inside BUG_ON()
      zram: make is_partial_io/valid_io_request/page_zero_filled return boolean

Greg Thelen (1):
      fs, seqfile: always allow oom killer

Hugh Dickins (15):
      mm Documentation: undoc non-linear vmas
      mm: rmap use pte lock not mmap_sem to set PageMlocked
      mm: page migration fix PageMlocked on migrated pages
      mm: rename mem_cgroup_migrate to mem_cgroup_replace_page
      mm: correct a couple of page migration comments
      mm: page migration use the put_new_page whenever necessary
      mm: page migration trylock newpage at same level as oldpage
      mm: page migration remove_migration_ptes at lock+unlock level
      mm: simplify page migration's anon_vma comment and flow
      mm: page migration use migration entry for swapcache too
      mm: page migration avoid touching newpage until no going back
      mm: migrate dirty page without clear_page_dirty_for_io etc
      tmpfs: avoid a little creat and stat slowdown
      Documentation/filesystems/proc.txt: a little tidying
      osd fs: __r4w_get_page rely on PageUptodate for uptodate

Hui Zhu (3):
      zsmalloc: add comments for ->inuse to zspage
      zsmalloc: fix obj_to_head use page_private(page) as value but not pointer
      mm/zsmalloc.c: remove useless line in obj_free()

Jan Kara (1):
      fs/sync.c: make sync_file_range(2) use WB_SYNC_NONE writeback

Jerome Marchand (1):
      mm/memcontrol.c: fix order calculation in try_charge()

Jesper Dangaard Brouer (4):
      slub: mark the dangling ifdef #else of CONFIG_SLUB_DEBUG
      slab: implement bulking for SLAB allocator
      slub: support for bulk free with SLUB freelists
      slub: optimize bulk slowpath free by detached freelist

Johannes Weiner (3):
      mm: memcontrol: eliminate root memory.current
      mm: page_counter: let page_counter_try_charge() return bool
      mm: vmpressure: fix scan window after SWAP_CLUSTER_MAX increase

Jonathan Corbet (1):
      mm: fix docbook comment for get_vaddr_frames()

Junichi Nomura (1):
      mm/filemap.c: make global sync not clear error status of individual inodes

Kirill A. Shutemov (78):
      mm: drop page->slab_page
      slab, slub: use page->rcu_head instead of page->lru plus cast
      zsmalloc: use page->private instead of page->first_page
      mm: pack compound_dtor and compound_order into one word in struct page
      mm: make compound_head() robust
      mm: use 'unsigned int' for page order
      mm: use 'unsigned int' for compound_dtor/compound_order on 64BIT
      khugepaged: avoid usage of uninitialized variable 'isolated'
      mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix
      khugepaged: __collapse_huge_page_swapin(): drop unused 'pte' parameter
      thp: do not hold anon_vma lock during swap in
      page-flags: trivial cleanup for PageTrans* helpers
      page-flags: move code around
      page-flags: introduce page flags policies wrt compound pages
      page-flags: do not corrupt caller 'page' in PF_NO_TAIL
      page-flags: add documentation for policies
      page-flags: hide PF_* validation check under separate config option
      page-flags: define PG_locked behavior on compound pages
      page-flags: define behavior of FS/IO-related flags on compound pages
      page-flags: define behavior of LRU-related flags on compound pages
      page-flags: define behavior SL*B-related flags on compound pages
      page-flags: define behavior of Xen-related flags on compound pages
      page-flags: define PG_reserved behavior on compound pages
      hugetlb: clear PG_reserved before setting PG_head on gigantic pages
      page-flags: define PG_swapbacked behavior on compound pages
      page-flags: define PG_swapcache behavior on compound pages
      page-flags: define PG_mlocked behavior on compound pages
      page-flags: define PG_uncached behavior on compound pages
      page-flags: define PG_uptodate behavior on compound pages
      page-flags: look at head page if the flag is encoded in page->mapping
      mm: sanitize page->mapping for tail pages
      mm, proc: adjust PSS calculation
      rmap: add argument to charge compound page
      memcg: adjust to support new THP refcounting
      mm, thp: adjust conditions when we can reuse the page on WP fault
      mm: adjust FOLL_SPLIT for new refcounting
      mm: handle PTE-mapped tail pages in gerneric fast gup implementaiton
      thp, mlock: do not allow huge pages in mlocked area
      khugepaged: ignore pmd tables with THP mapped with ptes
      thp: rename split_huge_page_pmd() to split_huge_pmd()
      mm, vmstats: new THP splitting event
      mm: temporally mark THP broken
      thp: drop all split_huge_page()-related code
      mm: drop tail page refcounting
      futex, thp: remove special case for THP in get_futex_key
      futex-thp-remove-special-case-for-thp-in-get_futex_key-fix
      ksm: prepare to new THP semantics
      mm, thp: remove compound_lock()
      arm64, thp: remove infrastructure for handling splitting PMDs
      arm, thp: remove infrastructure for handling splitting PMDs
      mips, thp: remove infrastructure for handling splitting PMDs
      powerpc, thp: remove infrastructure for handling splitting PMDs
      s390, thp: remove infrastructure for handling splitting PMDs
      sparc, thp: remove infrastructure for handling splitting PMDs
      tile, thp: remove infrastructure for handling splitting PMDs
      x86, thp: remove infrastructure for handling splitting PMDs
      mm, thp: remove infrastructure for handling splitting PMDs
      mm-thp-remove-infrastructure-for-handling-splitting-pmds-fix
      mm: rework mapcount accounting to enable 4k mapping of THPs
      mm: do not crash on PageDoubleMap() for non-head pages
      mm: duplicate rmap reference for hugetlb pages as compound
      mm-rework-mapcount-accounting-to-enable-4k-mapping-of-thps-fix-4
      mm: differentiate page_mapped() from page_mapcount() for compound pages
      mm, numa: skip PTE-mapped THP on numa fault
      thp: implement split_huge_pmd()
      thp: add option to setup migration entries during PMD split
      thp, mm: split_huge_page(): caller need to lock page
      thp: reintroduce split_huge_page()
      thp-reintroduce-split_huge_page-fix-2
      thp: fix split vs. unmap race
      migrate_pages: try to split pages on queuing
      thp: introduce deferred_split_huge_page()
      mm: re-enable THP
      thp: update documentation
      thp: allow mlocked THP again
      mm: prepare page_referenced() and page_idle to new THP refcounting
      mm-prepare-page_referenced-and-page_idle-to-new-thp-refcounting-fix
      mm: uninline slowpath of page_mapcount()

Laura Abbott (1):
      mm: Don't offset memmap for flatmem

Laurent Dufour (2):
      mm: clear pte in clear_soft_dirty()
      mm: clear_soft_dirty_pmd() requires THP

Luis Henriques (1):
      zram: introduce comp algorithm fallback functionality

Martin Schwidefsky (2):
      mm: add architecture primitives for software dirty bit clearing
      s390/mm: implement soft-dirty bits for user memory change tracking

Mel Gorman (13):
      mm, page_alloc: remove unnecessary parameter from zone_watermark_ok_safe
      mm, page_alloc: remove unnecessary recalculations for dirty zone balancing
      mm, page_alloc: remove unnecessary taking of a seqlock when cpusets are disabled
      mm, page_alloc: use masks and shifts when converting GFP flags to migrate types
      mm, page_alloc: distinguish between being unable to sleep, unwilling to sleep and avoiding waking kswapd
      mm: page_alloc: remove GFP_IOFS
      mm, page_alloc: rename __GFP_WAIT to __GFP_RECLAIM
      mm, page_alloc: delete the zonelist_cache
      mm, page_alloc: remove MIGRATE_RESERVE
      mm, page_alloc: reserve pageblocks for high-order atomic allocations on demand
      mm, page_alloc: only enforce watermarks for order-0 allocations
      mm: page_alloc: hide some GFP internals and document the bits and flag combinations
      mm: increase SWAP_CLUSTER_MAX to batch TLB flushes

Michal Hocko (3):
      Merge remote-tracking branch 'tj-cgroups/for-4.4' into mmotm-4.3
      memcg: fix thresholds for 32b architectures.
      mm, fs: introduce mapping_gfp_constraint()

Mike Kravetz (1):
      mm/hugetlbfs fix bugs in fallocate hole punch of areas with holes

Mike Rapoport (3):
      staging: lustre: replace OBD_SLAB_ALLOC_PTR_GFP with kmem_cache_alloc
      staging: lustre: replace OBD_SLAB_ALLOC_GFP with kmem_cache_alloc
      staging: lustre: replace OBD_SLAB_FREE with kmem_cache_free

Minfei Huang (1):
      kexec: use file name as the output message prefix

Naoya Horiguchi (5):
      mm: hugetlb: proc: add hugetlb-related fields to /proc/PID/smaps
      mm: hugetlb: proc: add HugetlbPages field to /proc/PID/status
      mm: hwpoison: ratelimit messages from unpoison_memory()
      hugetlb: trivial comment fix
      mm: hwpoison: adjust for new thp refcounting

Oleg Nesterov (13):
      mm: fix the racy mm->locked_vm change in
      mm: add the "struct mm_struct *mm" local into
      mm/oom_kill: remove the wrong fatal_signal_pending() check in oom_kill_process()
      mm/oom_kill: cleanup the "kill sharing same memory" loop
      mm/oom_kill: fix the wrong task->mm == mm checks in oom_kill_process()
      proc: actually make proc_fd_permission() thread-friendly
      lib/is_single_threaded.c: change current_is_single_threaded() to use for_each_thread()
      signals: kill block_all_signals() and unblock_all_signals()
      signal: turn dequeue_signal_lock() into kernel_dequeue_signal()
      signal: introduce kernel_signal_stop() to fix jffs2_garbage_collect_thread()
      signal: remove jffs2_garbage_collect_thread()->allow_signal(SIGCONT)
      coredump: ensure all coredumping tasks have SIGNAL_GROUP_COREDUMP
      coredump: change zap_threads() and zap_process() to use for_each_thread()

Raghavendra K T (2):
      mm/list_lru.c: replace nr_node_ids for loop with for_each_node()
      arch/powerpc/mm/numa.c: do not allocate bootmem memory for non existing nodes

Rasmus Villemoes (6):
      compiler.h: add support for function attribute assume_aligned
      include/linux/compiler-gcc.h: hide assume_aligned attribute from sparse
      mm/maccess.c: actually return -EFAULT from strncpy_from_unsafe
      lib/kasprintf.c: introduce kvasprintf_const
      lib/kobject.c: use kvasprintf_const for formatting ->name
      slab.h: sprinkle __assume_aligned attributes

Robin Murphy (2):
      dma-mapping: tidy up dma_parms default handling
      dma-debug: check nents in dma_sync_sg*

Roman Gushchin (1):
      mm: use only per-device readahead limit

Sergey SENOZHATSKY (2):
      zram: keep the exact overcommited value in mem_used_max
      mm: zsmalloc: constify struct zs_pool name

Sergey Senozhatsky (12):
      tools/vm/slabinfo: use getopt no_argument/optional_argument
      tools/vm/slabinfo: limit the number of reported slabs
      tools/vm/slabinfo: sort slabs by loss
      tools/vm/slabinfo: fix alternate opts names
      tools/vm/slabinfo: introduce extended totals mode
      tools/vm/slabinfo: output sizes in bytes
      tools/vm/slabinfo: cosmetic globals cleanup
      tools/vm/slabinfo: gnuplot slabifo extended stat
      Doc/slub: document slabinfo-gnuplot.sh script
      zsmalloc: use preempt.h for in_interrupt()
      zsmalloc: don't test shrinker_enabled in zs_shrinker_count()
      zsmalloc: reduce size_class memory usage

Tejun Heo (44):
      sched, cgroup: replace signal_struct->group_rwsem with a global percpu_rwsem
      cgroup: simplify threadgroup locking
      jump_label: make static_key_enabled() work on static_key_true/false types too
      cgroup: implement static_key based cgroup_subsys_enabled() and cgroup_subsys_on_dfl()
      cgroup: replace cgroup_subsys->disabled tests with cgroup_subsys_enabled()
      cgroup: replace cgroup_on_dfl() tests in controllers with cgroup_subsys_on_dfl()
      cgroup: replace "cgroup.populated" with "cgroup.events"
      cgroup: replace cftype->mode with CFTYPE_WORLD_WRITABLE
      cgroup: relocate cgroup_populate_dir()
      cgroup: make cgroup_addrm_files() clean up after itself on failures
      cgroup: cosmetic updates to rebind_subsystems()
      cgroup: restructure file creation / removal handling
      cgroup: generalize obtaining the handles of and notifying cgroup files
      memcg: generate file modified notifications on "memory.events"
      cpuset: migrate memory only for threadgroup leaders
      cgroup, memcg, cpuset: implement cgroup_taskset_for_each_leader()
      cgroup: reorder cgroup_migrate()'s parameters
      cgroup: separate out taskset operations from cgroup_migrate()
      cgroup: make cgroup_update_dfl_csses() migrate all target processes atomically
      cgroup: Merge branch 'for-4.3-fixes' into for-4.4
      cgroup: fix too early usage of static_branch_disable()
      cgroup: remove an unused parameter from cgroup_task_migrate()
      cgroup: make cgroup->nr_populated count the number of populated css_sets
      cgroup: replace cgroup_has_tasks() with cgroup_is_populated()
      cgroup: move check_for_release() invocation
      cgroup: relocate cgroup_[try]get/put()
      cgroup: make css_sets pin the associated cgroups
      cgroup: make cgroup_destroy_locked() test cgroup_is_populated()
      cgroup: keep css_set and task lists in chronological order
      cgroup: factor out css_set_move_task()
      cgroup: reorganize css_task_iter functions
      cgroup: don't hold css_set_rwsem across css task iteration
      cgroup: make css_set_rwsem a spinlock and rename it to css_set_lock
      cgroup: keep zombies associated with their original cgroups
      cgroup: add cgroup_subsys->free() method and use it to fix pids controller
      cgroup: replace error handling in cgroup_init() with WARN_ON()s
      cgroup: drop cgroup__DEVEL__legacy_files_on_dfl
      blkcg: don't create "io.stat" on the root cgroup
      cgroup: fix race condition around termination check in css_task_iter_next()
      memcg: flatten task_struct->memcg_oom
      memcg: punt high overage reclaim to return-to-userland path
      memcg: collect kmem bypass conditions into __memcg_kmem_bypass()
      memcg: ratify and consolidate over-charge handling
      memcg: drop unnecessary cold-path tests from __memcg_kmem_bypass()

Tetsuo Handa (4):
      mm/oom_kill.c: reverse the order of setting TIF_MEMDIE and sending SIGKILL
      mm/oom_kill.c: fix potentially killing unrelated process
      mm/oom_kill.c: suppress unnecessary "sharing same memory" message
      mm: remove refresh_cpu_vm_stats() definition for !SMP kernel

Vineet Gupta (1):
      mm: optimize PageHighMem() check

Vitaly Kuznetsov (2):
      lib/test-string_helpers.c: add string_get_size() tests
      panic: release stale console lock to always get the logbuf printed out

Vladimir Davydov (8):
      mm/slab_common.c: rename cache create/destroy helpers
      mm/slab_common.c: clear pointers to per memcg caches on destroy
      mm/slab_common.c: do not warn that cache is busy on destroy more than once
      memcg: simplify charging kmem pages
      memcg: unify slab and other kmem pages charging
      memcg: simplify and inline __mem_cgroup_from_kmem
      mm: do not inc NR_PAGETABLE if ptlock_init failed
      mm/khugepaged: fix scan not aborted on SCAN_EXCEED_SWAP_PTE

Vlastimil Babka (4):
      mm, migrate: count pages failing all retries in vmstat and tracepoint
      mm, compaction: export tracepoints status strings to userspace
      mm, compaction: export tracepoints zone names to userspace
      mm, compaction: distinguish contended status in tracepoints

Wang Long (2):
      lib: test_kasan: add some testcases
      kasan: Fix a type conversion error

Wei Yang (3):
      mm/slub: correct the comment in calculate_order()
      mm/slub: use get_order() instead of fls()
      mm/slub: calculate start order with reserved in consideration

Xishi Qiu (3):
      mm: fix overflow in find_zone_movable_pfns_for_nodes()
      mm/page_alloc.c: skip ZONE_MOVABLE if required_kernelcore is larger than totalpages
      kasan: use IS_ALIGNED in memory_is_poisoned_8()

Yaowei Bai (6):
      mm/page_alloc: remove unused parameter in init_currently_empty_zone()
      mm/vmscan: make inactive_anon_is_low_global return directly
      mm/compaction.c: add an is_via_compact_memory() helper
      mm/vmscan: make inactive_anon/file_is_low return bool
      mm/memcontrol: make mem_cgroup_inactive_anon_is_low() return bool
      mm/oom_kill.c: introduce is_sysrq_oom helper

yalin wang (1):
      include/linux/vm_event_item.h: change HIGHMEM_ZONE macro definition

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
