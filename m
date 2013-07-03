Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id B51FE6B0031
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 11:50:52 -0400 (EDT)
Date: Wed, 3 Jul 2013 17:50:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: since-3.10 branch opened for mm git tree
Message-ID: <20130703155051.GA5153@dhcp22.suse.cz>
References: <20130702223405.AF5BB5A4016@corp2gmr1-2.hot.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20130702223405.AF5BB5A4016@corp2gmr1-2.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

Hi,
I have just created since-3.10 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v3.10 tag in Linus tree and mmotm 2013-07-02-15-32.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1  D22D 48E2 09A2 B310 E347)

This also means that since-3.9 branch is no longer updated and all further
mm patches would be pushed only to since-3.10 branch.

The current shortlog says:
Andrew Morton (26):
      mm-remove-compressed-copy-from-zram-in-memory-fix
      mm-remove-compressed-copy-from-zram-in-memory-fix-2-fix
      memory_hotplug-use-pgdat_resize_lock-in-__offline_pages-fix
      include/linux/mm.h: add PAGE_ALIGNED() helper
      vmcore-allocate-buffer-for-elf-headers-on-page-size-alignment-fix
      vmalloc-introduce-remap_vmalloc_range_partial-fix
      vmcore-allocate-elf-note-segment-in-the-2nd-kernel-vmalloc-memory-fix
      vmcore-allow-user-process-to-remap-elf-note-segment-buffer-fix
      vmcore-support-mmap-on-proc-vmcore-fix
      mm-tune-vm_committed_as-percpu_counter-batching-size-fix
      swap-discard-while-swapping-only-if-swap_flag_discard_pages-fix
      mm-use-a-dedicated-lock-to-protect-totalram_pages-and-zone-managed_pages-fix
      mm-correctly-update-zone-managed_pages-fix
      mm-correctly-update-zone-managed_pages-fix-fix-fix
      shrinker-convert-superblock-shrinkers-to-new-api-fix
      xfs-convert-buftarg-lru-to-generic-code-fix
      xfs-convert-dquot-cache-lru-to-list_lru-fix
      fs-convert-fs-shrinkers-to-new-scan-count-api-fix
      drivers-convert-shrinkers-to-new-count-scan-api-fix
      drivers-convert-shrinkers-to-new-count-scan-api-fix-2
      shrinker-convert-remaining-shrinkers-to-count-scan-api-fix
      hugepage-convert-huge-zero-page-shrinker-to-new-shrinker-api-fix
      shrinker-kill-old-shrink-api-fix
      mm-remove-duplicated-call-of-get_pfn_range_for_nid-v2-fix
      memcg-use-css_get-put-when-charging-uncharging-kmem-fix
      include/linux/mmzone.h: cleanups

Artem Savkov (1):
      non-swapcache pages in end_swap_bio_read()

Ben Widawsky (1):
      drm/i915: Rename the gtt_list to global_list

Chen Gang (3):
      mm/vmscan.c: 'lru' may be used without initialized after the patch "3abf380..." in next-20130607 tree
      mm/page_alloc.c: add additional checking and return value for the 'table->data'
      mm/nommu.c: add additional check for vread() just like vwrite() has done

Cody P Schafer (17):
      mm/page_alloc: factor out setting of pcp->high and pcp->batch
      mm/page_alloc: prevent concurrent updaters of pcp ->batch and ->high
      mm/page_alloc: insert memory barriers to allow async update of pcp batch and high
      mm/page_alloc: protect pcp->batch accesses with ACCESS_ONCE
      mm/page_alloc: convert zone_pcp_update() to rely on memory barriers instead of stop_machine()
      mm/page_alloc: when handling percpu_pagelist_fraction, don't unneedly recalulate high
      mm/page_alloc: factor setup_pageset() into pageset_init() and pageset_set_batch()
      mm/page_alloc: relocate comment to be directly above code it refers to.
      mm/page_alloc: factor zone_pageset_init() out of setup_zone_pageset()
      mm/page_alloc: in zone_pcp_update(), uze zone_pageset_init()
      mm/page_alloc: rename setup_pagelist_highmark() to match naming of pageset_set_batch()
      mm/page_alloc: don't re-init pageset in zone_pcp_update()
      mm: fix comment referring to non-existent size_seqlock, change to span_seqlock
      mmzone: note that node_size_lock should be manipulated via pgdat_resize_lock()
      memory_hotplug: use pgdat_resize_lock() in online_pages()
      memory_hotplug: use pgdat_resize_lock() in __offline_pages()
      sparsemem: add BUILD_BUG_ON when sizeof mem_section is non-power-of-2

Dan Carpenter (2):
      UBIFS: signedness bug in ubifs_shrink_count()
      mm/vmalloc.c: unbreak __vunmap()

Dave Chinner (18):
      dcache: convert dentry_stat.nr_unused to per-cpu counters
      dentry: move to per-sb LRU locks
      dcache: remove dentries from LRU before putting on dispose list
      mm: new shrinker API
      shrinker: convert superblock shrinkers to new API
      list: add a new LRU list type
      inode: convert inode lru list to generic lru list code.
      dcache: convert to use new lru list infrastructure
      list_lru: per-node list infrastructure
      shrinker: add node awareness
      fs: convert inode and dentry shrinking to be node aware
      xfs: convert buftarg LRU to generic code
      xfs: rework buffer dispose list tracking
      xfs: convert dquot cache lru to list_lru
      fs: convert fs shrinkers to new scan/count API
      drivers: convert shrinkers to new count/scan API
      shrinker: convert remaining shrinkers to count/scan API
      shrinker: Kill old ->shrink API.

David Rientjes (1):
      mm, memcg: don't take task_lock in task_in_mem_cgroup

Fengguang Wu (1):
      swap: swapin_nr_pages() can be static

Glauber Costa (13):
      fs: bump inode and dentry counters to long
      super: fix calculation of shrinkable objects for small numbers
      inode: move inode to a different list inside lock
      list_lru: per-node list infrastructure fix
      list_lru: per-node API
      list_lru: remove special case function list_lru_dispose_all.
      vmscan: per-node deferred work
      i915: bail out earlier when shrinker cannot acquire mutex
      hugepage: convert huge zero page shrinker to new shrinker API
      list_lru: dynamically adjust node arrays
      super: fix for destroy lrus
      memcg: also test for skip accounting at the page allocation level
      memcg: do not account memory used for cache creation

HATAYAMA Daisuke (10):
      vmcore: clean up read_vmcore()
      vmcore: allocate buffer for ELF headers on page-size alignment
      vmcore: treat memory chunks referenced by PT_LOAD program header entries in page-size boundary in vmcore_list
      vmalloc: make find_vm_area check in range
      vmalloc: introduce remap_vmalloc_range_partial
      vmcore: allocate ELF note segment in the 2nd kernel vmalloc memory
      vmcore: allow user process to remap ELF note segment buffer
      vmcore: calculate vmcore file size from buffer size and total size of vmcore objects
      vmcore: support mmap() on /proc/vmcore
      vmcore: disable mmap_vmcore() if CONFIG_MMU is not defined

Haicheng Li (1):
      fs/fs-writeback.c: : make wb_do_writeback() as static

Jiang Liu (74):
      mm: change signature of free_reserved_area() to fix building warnings
      mm: enhance free_reserved_area() to support poisoning memory with zero
      mm/ARM64: kill poison_init_mem()
      mm/x86: use free_reserved_area() to simplify code
      mm/tile: use common help functions to free reserved pages
      mm: fix some trivial typos in comments
      mm: use managed_pages to calculate default zonelist order
      mm: accurately calculate zone->managed_pages for highmem zones
      mm: use a dedicated lock to protect totalram_pages and zone->managed_pages
      mm: make __free_pages_bootmem() only available at boot time
      mm: correctly update zone->managed_pages
      mm-correctly-update-zone-managed_pages-fix-fix
      mm: concentrate modification of totalram_pages into the mm core
      mm: report available pages as "MemTotal" for each NUMA node
      vmlinux.lds: add comments for global variables and clean up useless declarations
      avr32: normalize global variables exported by vmlinux.lds
      c6x: normalize global variables exported by vmlinux.lds
      h8300: normalize global variables exported by vmlinux.lds
      score: normalize global variables exported by vmlinux.lds
      tile: normalize global variables exported by vmlinux.lds
      UML: normalize global variables exported by vmlinux.lds
      mm: introduce helper function mem_init_print_info() to simplify mem_init()
      mm: use totalram_pages instead of num_physpages at runtime
      mm/hotplug: prepare for removing num_physpages
      mm/alpha: prepare for removing num_physpages and simplify mem_init()
      mm/ARC: prepare for removing num_physpages and simplify mem_init()
      mm/ARM: prepare for removing num_physpages and simplify mem_init()
      mm/ARM64: prepare for removing num_physpages and simplify mem_init()
      mm/AVR32: prepare for removing num_physpages and simplify mem_init()
      mm/blackfin: prepare for removing num_physpages and simplify mem_init()
      mm/c6x: prepare for removing num_physpages and simplify mem_init()
      mm/cris: prepare for removing num_physpages and simplify mem_init()
      mm/frv: prepare for removing num_physpages and simplify mem_init()
      mm/h8300: prepare for removing num_physpages and simplify mem_init()
      mm/hexagon: prepare for removing num_physpages and simplify mem_init()
      mm/IA64: prepare for removing num_physpages and simplify mem_init()
      mm/m32r: prepare for removing num_physpages and simplify mem_init()
      mm/m68k: prepare for removing num_physpages and simplify mem_init()
      mm/metag: prepare for removing num_physpages and simplify mem_init()
      mm/microblaze: prepare for removing num_physpages and simplify mem_init()
      mm, arch: fix two errors in calling mem_init_print_info()
      mm/MIPS: prepare for removing num_physpages and simplify mem_init()
      mm/mn10300: prepare for removing num_physpages and simplify mem_init()
      mm/openrisc: prepare for removing num_physpages and simplify mem_init()
      mm/PARISC: prepare for removing num_physpages and simplify mem_init()
      mm/ppc: prepare for removing num_physpages and simplify mem_init()
      mm/s390: prepare for removing num_physpages and simplify mem_init()
      mm/score: prepare for removing num_physpages and simplify mem_init()
      mm/SH: prepare for removing num_physpages and simplify mem_init()
      mm/SPARC: prepare for removing num_physpages and simplify mem_init()
      mm/tile: prepare for removing num_physpages and simplify mem_init()
      mm/um: prepare for removing num_physpages and simplify mem_init()
      mm/unicore32: prepare for removing num_physpages and simplify mem_init()
      mm/x86: prepare for removing num_physpages and simplify mem_init()
      mm/xtensa: prepare for removing num_physpages and simplify mem_init()
      mm: kill global variable num_physpages
      mm: introduce helper function set_max_mapnr()
      mm/AVR32: prepare for killing free_all_bootmem_node()
      mm/IA64: prepare for killing free_all_bootmem_node()
      mm/m32r: prepare for killing free_all_bootmem_node()
      mm/m68k: prepare for killing free_all_bootmem_node()
      mm/metag: prepare for killing free_all_bootmem_node()
      mm/MIPS: prepare for killing free_all_bootmem_node()
      mm/PARISC: prepare for killing free_all_bootmem_node()
      mm/PPC: prepare for killing free_all_bootmem_node()
      mm/SH: prepare for killing free_all_bootmem_node()
      mm: kill free_all_bootmem_node()
      mm/alpha: unify mem_init() for both UMA and NUMA architectures
      mm/m68k: fix build warning of unused variable
      mm/ALPHA: clean up unused VALID_PAGE()
      mm/ARM: fix stale comment about VALID_PAGE()
      mm/CRIS: clean up unused VALID_PAGE()
      mm/microblaze: clean up unused VALID_PAGE()
      mm/unicore32: fix stale comment about VALID_PAGE()

Joe Perches (1):
      mm: remove unused VM_<READfoo> macros and expand other in-place

Joern Engel (1):
      hugetlb: properly account rss

Johannes Weiner (3):
      mm: memcontrol: factor out reclaim iterator loading and updating
      memcg: clean up memcg->nodeinfo
      mm: invoke oom-killer from remaining unconverted page fault handlers

Jorn Engel (1):
      mmap: allow MAP_HUGETLB for hugetlbfs files v2

Li Zefan (8):
      memcg: update TODO list in Documentation
      memcg: use css_get() in sock_update_memcg()
      memcg: don't use mem_cgroup_get() when creating a kmemcg cache
      memcg: use css_get/put when charging/uncharging kmem
      memcg: use css_get/put for swap memcg
      memcg: don't need to get a reference to the parent
      memcg: kill memcg refcnt
      memcg: don't need to free memcg via RCU or workqueue

Libin (3):
      mm: use vma_pages() to replace (vm_end - vm_start) >> PAGE_SHIFT
      ncpfs: use vma_pages() to replace (vm_end - vm_start) >> PAGE_SHIFT
      uio: use vma_pages() to replace (vm_end - vm_start) >> PAGE_SHIFT

Mel Gorman (28):
      mm: vmscan: limit the number of pages kswapd reclaims at each priority
      mm: vmscan: obey proportional scanning requirements for kswapd
      mm: vmscan: flatten kswapd priority loop
      mm: vmscan: decide whether to compact the pgdat based on reclaim progress
      mm: vmscan: do not allow kswapd to scan at maximum priority
      mm: vmscan: have kswapd writeback pages based on dirty pages encountered, not priority
      mm: vmscan: block kswapd if it is encountering pages under writeback
      mm-vmscan-block-kswapd-if-it-is-encountering-pages-under-writeback-fix
      mm-vmscan-block-kswapd-if-it-is-encountering-pages-under-writeback-fix-2
      mm: vmscan: check if kswapd should writepage once per pgdat scan
      mm: vmscan: move logic from balance_pgdat() to kswapd_shrink_zone()
      mm: vmscan: stall page reclaim and writeback pages based on dirty/writepage pages encountered
      mm: vmscan: stall page reclaim after a list of pages have been processed
      mm: vmscan: set zone flags before blocking
      mm: vmscan: move direct reclaim wait_iff_congested into shrink_list
      mm: vmscan: treat pages marked for immediate reclaim as zone congestion
      mm: vmscan: take page buffers dirty and locked state into account
      fs: nfs: inform the VM about pages being committed or unstable
      mm: add tracepoints for LRU activation and insertions
      mm: pagevec: defer deciding which LRU to add a page to until pagevec drain time
      mm: activate !PageLRU pages on mark_page_accessed if page is on local pagevec
      mm: remove lru parameter from __pagevec_lru_add and remove parts of pagevec API
      mm: remove lru parameter from __lru_cache_add and lru_cache_add_lru
      mm: Clear page active before releasing pages
      documentation: update address_space_operations
      documentation: document the is_dirty_writeback aops callback
      mm: vmscan: do not continue scanning if reclaim was aborted for compaction
      mm: vmscan: do not scale writeback pages when deciding whether to set ZONE_WRITEBACK

Michal Hocko (4):
      mm-memory-hotplug-fix-lowmem-count-overflow-when-offline-pages-fix
      Revert "memcg: avoid dangling reference count in creation failure"
      memcg, kmem: fix reference count handling on the error path
      drop_caches: add some documentation and info message

Michel Lespinasse (1):
      mm: remove free_area_cache

Mike Yoknis (1):
      mm: memmap_init_zone() performance improvement

Minchan Kim (1):
      mm: remove compressed copy from zram in-memory

Naoya Horiguchi (1):
      mm/memory-failure.c: fix memory leak in successful soft offlining

Oleg Nesterov (1):
      vfree: don't schedule free_work() if llist_add() returns false

Pavel Emelyanov (7):
      clear_refs: sanitize accepted commands declaration
      clear_refs: introduce private struct for mm_walk
      pagemap: introduce pagemap_entry_t without pmshift bits
      pagemap-introduce-pagemap_entry_t-without-pmshift-bits-v4
      mm: soft-dirty bits for user memory changes tracking
      soft-dirty: call mmu notifiers when write-protecting ptes
      pagemap: prepare to reuse constant bits with page-shift

Rafael Aquini (2):
      swap: discard while swapping only if SWAP_FLAG_DISCARD_PAGES
      mm: add vm event counters for balloon pages compaction

Rasmus Villemoes (1):
      mm: mremap: validate input before taking lock

Sergey Dyasly (1):
      memcg: Kconfig info update

Seth Jennings (7):
      zbud: add to mm/
      zswap: init under_reclaim
      debugfs: add get/set for atomic types
      zswap: add to mm/
      zswap: fix Kconfig to depend on CRYPTO=y
      zswap: add documentation
      MAINTAINERS: add zswap and zbud maintainer

Shaohua Li (1):
      swap: add a simple detector for inappropriate swapin readahead

Tang Chen (3):
      page migration: fix wrong comment in address_space_operations.migratepage()
      mm/memblock.c: fix wrong comment in __next_free_mem_range()
      mm/memory_hotplug.c: fix a comment typo in register_page_bootmem_info_node()

Tim Chen (1):
      mm: tune vm_committed_as percpu_counter batching size

Toshi Kani (1):
      mm/memory_hotplug.c: change normal message to use pr_debug

Vineet Gupta (1):
      mm: Fix the TLB range flushed when __tlb_remove_page() runs out of slots

Wanpeng Li (10):
      mm/memory-hotplug: fix lowmem count overflow when offline pages
      mm/pageblock: remove get/set_pageblock_flags
      mm/hugetlb: remove hugetlb_prefault
      mm/hugetlb: use already existing interface huge_page_shift
      mm/writeback: remove wb_reason_name
      mm/writeback: don't check force_wait to handle bdi->work_list
      mm/writeback: commit reason of WB_REASON_FORKER_THREAD mismatch name
      mm/page_alloc: fix doc for numa_zonelist_order
      mm/thp: fix doc for transparent huge zero page
      mm/pgtable: don't accumulate addr during pgd prepopulate pmd

Xi Wang (2):
      drivers/usb/gadget/amd5536udc.c: avoid calling dma_pool_create() with NULL dev
      mm/dmapool.c: fix null dev in dma_pool_create()

Zhang Yanfei (19):
      mm, vmalloc: only call setup_vmalloc_vm() only in __get_vm_area_node()
      mm, vmalloc: call setup_vmalloc_vm() instead of insert_vmalloc_vm()
      mm, vmalloc: remove insert_vmalloc_vm()
      mm, vmalloc: use clamp() to simplify code
      mm: remove duplicated call of get_pfn_range_for_nid
      mm-remove-duplicated-call-of-get_pfn_range_for_nid-v2
      mm/vmalloc.c: remove dead code in vb_alloc
      mm/vmalloc.c: remove unused purge_fragmented_blocks_thiscpu
      mm/vmalloc.c: remove alloc_map from vmap_block
      mm/vmalloc.c: emit the failure message before return
      mm/vmalloc.c: rename VM_UNLIST to VM_UNINITIALIZED
      mm/vmalloc.c: check VM_UNINITIALIZED flag in s_show instead of show_numa_info
      include/linux/gfp.h: fix the comment for GFP_ZONE_TABLE
      mm/page_alloc.c: remove zone_type argument of build_zonelists_node
      mm: remove unused functions is_{normal_idx, normal, dma32, dma}
      mm/page_alloc.c: remove unlikely() from the current_order test
      mm: remove unused __put_page()
      mm/sparse.c: put clear_hwpoisoned_pages within CONFIG_MEMORY_HOTREMOVE
      mm/vmalloc.c: fix an overflow bug in alloc_vmap_area()

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
