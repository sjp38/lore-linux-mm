Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 88BE86B0005
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 11:41:51 -0500 (EST)
Date: Wed, 20 Feb 2013 17:41:48 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: since-3.8 branch opened for mm git tree (was: mmotm 2013-02-19-17-20
 uploaded)
Message-ID: <20130220164148.GA5170@dhcp22.suse.cz>
References: <20130220012122.870BB31C11E@corp2gmr1-1.hot.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130220012122.870BB31C11E@corp2gmr1-1.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

As this mmotm tree is based on the fresh new 3.8 I have created
since-3.8 branch for the mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary).

Same as before this branch contains all mm patches based on v3.8 tag and
it will track the next mmot[ms] trees without any rebases. since-3.7
branch is now obsolete.

As usual mmotm trees are tagged with signed tag 
(finger print BB43 1E25 7FB8 660F F2F1  D22D 48E2 09A2 B310 E347).

The current shortlog says (I have squashed all -fix patches into their
base patches):
Andrew Morton (7):
      mm/memcontrol.c: convert printk(KERN_FOO) to pr_foo()
      mm/hugetlb.c: convert to pr_foo()
      mm/page_alloc.c:__alloc_contig_migrate_range(): cleanup
      mm/page_alloc.c:__setup_per_zone_wmarks: make min_pages unsigned long
      mm/vmscan.c:__zone_reclaim(): replace max_t() with max()
      mm: compaction: make __compact_pgdat() and compact_pgdat() return void
      include/linux/mmzone.h: cleanups

Cliff Wickman (1):
      mm: export mmu notifier invalidates

Cody P Schafer (9):
      mm: add SECTION_IN_PAGE_FLAGS
      mm: add & use zone_end_pfn() and zone_spans_pfn()
      mm: add zone_is_empty() and zone_is_initialized()
      mm/page_alloc: add a VM_BUG in __free_one_page() if the zone is uninitialized.
      mmzone: add pgdat_{end_pfn,is_empty}() helpers & consolidate.
      mm/page_alloc: add informative debugging message in page_outside_zone_boundaries()
      mm: add helper ensure_zone_is_initialized()
      mm/memory_hotplug: use ensure_zone_is_initialized()
      mm/memory_hotplug: use pgdat_end_pfn() instead of open coding the same.

Dan Carpenter (1):
      compat: return -EFAULT on error in waitid()

Dave Hansen (4):
      x86, mm: Make DEBUG_VIRTUAL work earlier in boot
      x86, mm: Pagetable level size/shift/mask helpers
      x86, mm: Use new pagetable helpers in try_preserve_large_page()
      x86, mm: Create slow_virt_to_phys()

David Rientjes (1):
      mm: use NUMA_NO_NODE

Davidlohr Bueso (1):
      x86/srat: Simplify memory affinity init error handling

Glauber Costa (8):
      memcg: reduce the size of struct memcg 244-fold.
      memcg: prevent changes to move_charge_at_immigrate during task attach
      memcg: split part of memcg creation to css_online
      memcg: fast hierarchy-aware child test
      memcg: replace cgroup_lock with memcg specific memcg_lock
      memcg: increment static branch right after limit set
      memcg: avoid dangling reference count in creation failure.
      memcg: debugging facility to access dangling memcgs

Hugh Dickins (11):
      mm: numa: Cleanup flow of transhuge page migration
      ksm: trivial tidyups
      ksm: reorganize ksm_check_stable_tree
      ksm: get_ksm_page locked
      ksm: remove old stable nodes more thoroughly
      ksm: make KSM page migration possible
      ksm: make !merge_across_nodes migration safe
      ksm: enable KSM page migration
      mm: remove offlining arg to migrate_pages
      ksm: stop hotremove lockdep warning
      memcg: stop warning on memcg_propagate_kmem

Jiang Liu (3):
      mm: use zone->present_pages instead of zone->managed_pages where appropriate
      mm: set zone->present_pages to number of existing pages in the zone
      mm: increase totalram_pages when free pages allocated by bootmem allocator

Jim Somerville (1):
      inotify: remove broken mask checks causing unmount to be EINVAL

Johannes Weiner (10):
      mm: memcg: only evict file pages when we have plenty
      mm: vmscan: save work scanning (almost) empty LRU lists
      mm: vmscan: clarify how swappiness, highest priority, memcg interact
      mm: vmscan: improve comment on low-page cache handling
      mm: vmscan: clean up get_scan_count()
      mm: vmscan: compaction works against zones, not lruvecs
      mm: reduce rmap overhead for ex-KSM page copies created on swap faults
      mm: shmem: use new radix tree iterator
      mm: refactor inactive_file_is_low() to use get_lru_size()
      mm/mlock.c: document scary-looking stack expansion mlock chain

Kirill A. Shutemov (1):
      mm: remove unused memclear_highpage_flush()

Konstantin Khlebnikov (1):
      mm/rmap: rename anon_vma_unlock() => anon_vma_unlock_write()

Lai Jiangshan (1):
      mempolicy: fix is_valid_nodemask()

Lin Feng (2):
      memory-hotplug: introduce CONFIG_HAVE_BOOTMEM_INFO_NODE and revert register_page_bootmem_info_node() when platform not support
      memory-hotplug: mm/Kconfig: move auto selects from MEMORY_HOTPLUG to MEMORY_HOTREMOVE as needed

Maxim Patlasov (1):
      proc: avoid extra pde_put() in proc_fill_super()

Mel Gorman (8):
      mm: compaction: do not accidentally skip pageblocks in the migrate scanner
      mm: numa: fix minor typo in numa_next_scan
      mm: numa: take THP into account when migrating pages for NUMA balancing
      mm: numa: handle side-effects in count_vm_numa_events() for !CONFIG_NUMA_BALANCING
      mm: uninline page_xchg_last_nid()
      mm: init: report on last-nid information stored in page->flags
      mm: rename page struct field helpers
      mm/fadvise.c: drain all pagevecs if POSIX_FADV_DONTNEED fails to discard all pages

Michal Hocko (9):
      memcg,vmscan: do not break out targeted reclaim without reclaimed pages
      memory-hotplug: cleanup: removing the arch specific functions without any implementation
      x86-32, mm: Remove reference to alloc_remap()
      memcg: do not create memsw files if swap accounting is disabled
      memcg: clean up swap accounting initialization code
      memcg: move mem_cgroup_soft_limit_tree_init to mem_cgroup_init
      memcg: move memcg_stock initialization to mem_cgroup_init
      memcg: cleanup mem_cgroup_init comment
      drop_caches: add some documentation and info message

Michel Lespinasse (13):
      mm: remap_file_pages() fixes
      mm: introduce mm_populate() for populating new vmas
      mm: use mm_populate() for blocking remap_file_pages()
      mm: use mm_populate() when adjusting brk with MCL_FUTURE in effect
      mm: use mm_populate() for mremap() of VM_LOCKED vmas
      mm: remove flags argument to mmap_region
      mm: directly use __mlock_vma_pages_range() in find_extend_vma()
      mm: introduce VM_POPULATE flag to better deal with racy userspace programs
      mm: make do_mmap_pgoff return populate as a size in bytes, not as a bool
      mm: remove free_area_cache
      mm: use long type for page counts in mm_populate() and get_user_pages()
      mm: accelerate mm_populate() treatment of THP pages
      mm: accelerate munlock() treatment of THP pages

Mike Yoknis (1):
      mm: memmap_init_zone() performance improvement

Minchan Kim (3):
      mm: remove MIGRATE_ISOLATE check in hotpath
      mm: Get rid of lockdep whinge on sys_swapon
      mm: use up free swap space before reaching OOM kill

Ming Lei (6):
      mm: teach mm by current context info to not do I/O during memory allocation
      pm / runtime: introduce pm_runtime_set_memalloc_noio()
      block/genhd.c: apply pm_runtime_set_memalloc_noio on block devices
      net/core: apply pm_runtime_set_memalloc_noio on network devices
      pm / runtime: force memory allocation with no I/O during Runtime PM callbcack
      usb: forbid memory allocation with I/O during bus reset

Naoya Horiguchi (4):
      mm/memory-failure.c: clean up soft_offline_page()
      mm/memory-failure.c: fix wrong num_poisoned_pages in handling memory error on thp
      HWPOISON: fix misjudgement of page_action() for errors on mlocked pages
      HWPOISON: change order of error_states[]'s elements

Paul Szabo (1):
      page-writeback.c: subtract min_free_kbytes from dirtyable memory

Peter Zijlstra (2):
      mm: move page flags layout to separate header
      mm: Fold page->_last_nid into page->flags where possible

Petr Holasek (2):
      ksm: allow trees per NUMA node
      ksm: add sysfs ABI Documentation

Rafael Aquini (1):
      mm: add vm event counters for balloon pages compaction

Robin Holt (1):
      mmu_notifier_unregister NULL Pointer deref and multiple ->release() callouts

Sasha Levin (4):
      mm/huge_memory.c: use new hashtable implementation
      mm/ksm.c: use new hashtable implementation
      mm: fix BUG on madvise early failure
      mm: memory_hotplug: no need to check res twice in add_memory

Sha Zhengju (1):
      memcg, oom: provide more precise dump info while memcg oom happening

Shaohua Li (4):
      mm: make madvise(MADV_WILLNEED) support swap file prefetch
      mm: don't inline page_mapping()
      swap: make each swap partition have one address_space
      swap: add per-partition lock for swapfile

Srinivas Pandruvada (1):
      CMA: make putback_lru_pages() call conditional

Tang Chen (28):
      Bug fix: Hold spinlock across find|remove /sys/firmware/memmap/X operation.
      Bug fix: Fix the wrong comments of map_entries.
      Bug fix: Reuse the storage of /sys/firmware/memmap/X/ allocated by bootmem.
      Bug fix: Fix section mismatch problem of release_firmware_map_entry().
      Bug fix: Fix the doc format in drivers/firmware/memmap.c
      memory-hotplug: move pgdat_resize_lock into sparse_remove_one_section()
      Bug fix: Do not calculate direct mapping pages when freeing vmemmap pagetables.
      Bug fix: Do not free direct mapping pages twice.
      Bug fix: Do not free page split from hugepage one by one.
      Bug fix: Do not split pages when freeing pagetable pages.
      memory-hotplug: remove page table of x86_64 architecture
      memory-hotplug: remove memmap of sparse-vmemmap
      memory-hotplug: integrated __remove_section() of CONFIG_SPARSEMEM_VMEMMAP.
      memory-hotplug: remove sysfs file of node
      memory-hotplug: do not allocate pgdat if it was not freed when offline.
      sched: do not use cpu_to_node() to find an offlined cpu's node.
      page_alloc: add movable_memmap kernel parameter
      Rename movablecore_map to movablemem_map.
      page_alloc: introduce zone_movable_limit[] to keep movable limit for nodes
      Bug fix: Remove the unused sanitize_zone_movable_limit() definition.
      page_alloc: make movablemem_map have higher priority
      page_alloc: bootmem limit with movablecore_map
      acpi, memory-hotplug: parse SRAT before memblock is ready
      acpi, movablemem_map: Do not zero numa_meminfo in numa_init().
      acpi, memory-hotplug: extend movablemem_map ranges to the end of node
      acpi, memory-hotplug: support getting hotplug info from SRAT
      acpi, movablemem_map: Set numa_nodes_hotplug nodemask when using SRAT info.
      mm/memblock.c: use CONFIG_HAVE_MEMBLOCK_NODE_MAP to protect movablecore_map in memblock_overlaps_region().

Wen Congyang (10):
      memory-hotplug: try to offline the memory twice to avoid dependence
      memory-hotplug: remove redundant codes
      memory-hotplug: introduce new arch_remove_memory() for removing page table
      memory-hotplug: common APIs to support page tables hot-remove
      memory-hotplug: free node_data when a node is offlined
      memory-hotplug: consider compound pages when free memmap
      cpu_hotplug: clear apicid to node when the cpu is hotremoved
      memory-hotplug: export the function try_offline_node()
      cpu-hotplug, memory-hotplug: try offlining the node when hotremoving a cpu
      cpu-hotplug,memory-hotplug: clear cpu_to_node() when offlining the node

Xi Wang (2):
      drivers/usb/gadget/amd5536udc.c: avoid calling dma_pool_create() with NULL dev
      mm/dmapool.c: fix null dev in dma_pool_create()

Xishi Qiu (3):
      memory-failure: fix an error of mce_bad_pages statistics
      memory-failure: do code refactor of soft_offline_page()
      memory-failure: use num_poisoned_pages instead of mce_bad_pages

Yasuaki Ishimatsu (5):
      memory-hotplug: check whether all memory blocks are offlined or not when removing memory
      memory-hotplug: remove /sys/firmware/memmap/X sysfs
      memory-hotplug: implement register_page_bootmem_info_section of sparse-vmemmap
      memory_hotplug: clear zone when removing the memory
      x86: get pg_data_t's memory from other node

Yinghai Lu (1):
      x86, 64bit: Don't set max_pfn_mapped wrong value early on native path

Zhang Yanfei (7):
      mm: fix return type for functions nr_free_*_pages
      ia64: use %ld to print pages calculated in nr_free_buffer_pages
      fs/buffer.c: change type of max_buffer_heads to unsigned long
      fs/nfsd: change type of max_delegations, nfsd_drc_max_mem and nfsd_drc_mem_used
      vmscan: change type of vm_total_pages to unsigned long
      net: change type of virtio_chan->p9_max_pages
      mm: accurately document nr_free_*_pages functions with code comments

Zlatko Calusic (2):
      mm: avoid calling pgdat_balanced() needlessly
      mm: don't wait on congested zones in balance_pgdat()
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
