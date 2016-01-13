Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7C7828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 08:42:17 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id ho8so97932799pac.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 05:42:17 -0800 (PST)
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com. [209.85.220.53])
        by mx.google.com with ESMTPS id 9si2155434pfa.203.2016.01.13.05.42.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 05:42:15 -0800 (PST)
Received: by mail-pa0-f53.google.com with SMTP id uo6so342719350pac.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 05:42:15 -0800 (PST)
Date: Wed, 13 Jan 2016 14:42:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: mmotm git tree since-4.4 branch created (was: mmotm 2016-01-12-16-44
 uploaded)
Message-ID: <20160113134211.GD28942@dhcp22.suse.cz>
References: <56959f89.w3mPYnkFwRbLPsAK%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56959f89.w3mPYnkFwRbLPsAK%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

I have just created since-4.4 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v4.4 tag in Linus tree and mmotm-2016-01-12-16-44.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The shortlog says:
Alexander Kuleshov (3):
      mm/memblock: remove rgnbase and rgnsize variables
      mm/memblock: introduce for_each_memblock_type()
      mm/page_alloc.c: remove unused struct zone *z variable

Alexey Klimov (1):
      mm/mlock.c: drop unneeded initialization in munlock_vma_pages_range()

Andrea Arcangeli (2):
      ksm: introduce ksm_max_page_sharing per page deduplication limit
      ksm: validate STABLE_NODE_DUP_HEAD conditional to gcc version

Andrew Morton (26):
      account-certain-kmem-allocations-to-memcg-checkpatch-fixes
      include-define-__phys_to_pfn-as-phys_pfn-fix
      mempolicy-convert-the-shared_policy-lock-to-a-rwlock-fix-2
      mm-zonelist-enumerate-zonelists-array-index-checkpatch-fixes
      mm-zonelist-enumerate-zonelists-array-index-fix
      mm-get-rid-of-__alloc_pages_high_priority-checkpatch-fixes
      fs/block_dev.c:bdev_write_page(): use blk_queue_enter(..., GFP_NOIO)
      arm64-mm-support-arch_mmap_rnd_bits-fix
      ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit-fix-2
      mm-fs-obey-gfp_mapping-for-add_to_page_cache-fix
      mm-rework-mapcount-accounting-to-enable-4k-mapping-of-thps-fix
      mm-hwpoison-adjust-for-new-thp-refcounting-fix
      mm-prepare-page_referenced-and-page_idle-to-new-thp-refcounting-checkpatch-fixes
      thp-add-debugfs-handle-to-split-all-huge-pages-fix
      mm-support-madvisemadv_free-fix-2-fix
      arch-uapi-asm-mmanh-let-madv_free-have-same-value-for-all-architectures-fix
      arch-uapi-asm-mmanh-let-madv_free-have-same-value-for-all-architectures-fix-fix-2
      arch-uapi-asm-mmanh-let-madv_free-have-same-value-for-all-architectures-fix-fix-2-fix-3
      mm-oom-rework-oom-detection-checkpatch-fixes
      mm-use-watermak-checks-for-__gfp_repeat-high-order-allocations-checkpatch-fixes
      sched: add schedule_timeout_idle()
      mm-mlockc-change-can_do_mlock-return-value-type-to-boolean-fix
      mm-page_allocc-introduce-kernelcore=mirror-option-fix
      mm/page_alloc.c: rework code layout in memmap_init_zone()
      mm-hugetlbfs-unmap-pages-if-page-fault-raced-with-hole-punch-fix
      mm-soft-offline-exit-with-failure-for-non-anonymous-thp-fix

Arnd Bergmann (3):
      cpuset: Replace all instances of time_t with time64_t
      mm: include linux/pfn.h for PHYS_PFN definition
      ARM: thp: fix unterminated ifdef in header file

Chen Gang (3):
      mm/mmap.c: remove redundant local variables for may_expand_vm()
      mm: add PHYS_PFN, use it in __phys_to_pfn()
      arch/*/include/uapi/asm/mman.h: : let MADV_FREE have same value for all architectures

Christoph Lameter (2):
      vmstat: make vmstat_updater deferrable again and shut down on idle
      vmstat-make-vmstat_updater-deferrable-again-and-shut-down-on-idle-fix

Dan Carpenter (1):
      mm/huge_memory: add a missing tab

Dan Williams (28):
      pmem, dax: clean up clear_pmem()
      dax: increase granularity of dax_clear_blocks() operations
      dax: guarantee page aligned results from bdev_direct_access()
      dax: fix lifetime of in-kernel dax mappings with dax_map_atomic()
      dax-fix-lifetime-of-in-kernel-dax-mappings-with-dax_map_atomic-v3
      um: kill pfn_t
      kvm: rename pfn_t to kvm_pfn_t
      mm, dax, pmem: introduce pfn_t
      mm: skip memory block registration for ZONE_DEVICE
      mm: introduce find_dev_pagemap()
      x86, mm: introduce vmem_altmap to augment vmemmap_populate()
      libnvdimm, pfn, pmem: allocate memmap array in persistent memory
      avr32: convert to asm-generic/memory_model.h
      hugetlb: fix compile error on tile
      frv: fix compiler warning from definition of __pmd()
      x86, mm: introduce _PAGE_DEVMAP
      mm, dax, gpu: convert vm_insert_mixed to pfn_t
      mm, dax: convert vmf_insert_pfn_pmd() to pfn_t
      libnvdimm, pmem: move request_queue allocation earlier in probe
      mm, dax, pmem: introduce {get|put}_dev_pagemap() for dax-gup
      list, perf: fix list_force_poison() build regression
      mm, dax: dax-pmd vs thp-pmd vs hugetlbfs-pmd
      mm, dax: dax-pmd vs thp-pmd vs hugetlbfs-pmd v5
      mm: fix pmd_devmap compile error
      mm, x86: get_user_pages() for dax mappings
      mm, x86: get_user_pages() for dax mappings
      dax: provide diagnostics for pmd mapping failures
      dax: re-enable dax pmd mappings

Daniel Cashman (8):
      mm: mmap: add new /proc tunable for mmap_base ASLR
      arm: mm: support ARCH_MMAP_RND_BITS
      arm: mm: support ARCH_MMAP_RND_BITS
      arm64: mm: support ARCH_MMAP_RND_BITS
      arm64-mm-support-arch_mmap_rnd_bits-v6
      arm64-mm-support-arch_mmap_rnd_bits-v7
      x86: mm: support ARCH_MMAP_RND_BITS
      x86-mm-support-arch_mmap_rnd_bits-v7.txt

David Rientjes (1):
      mm, vmalloc: remove VM_VPAGES

Dominik Dingel (2):
      mm: bring in additional flag for fixup_user_fault to signal unlock
      s390/mm: enable fixup_user_fault retrying

Ebru Akagunduz (3):
      mm: add tracepoint for scanning pages
      mm: make optimistic check for swapin readahead
      mm: make swapin readahead to improve thp collapse rate

Florian Fainelli (1):
      include/linux/memblock.h: fix ordering of 'flags' argument in comments

Geliang Tang (13):
      mm/slab.c use list_first_entry_or_null()
      mm/slab.c: use list_for_each_entry in cache_flusharray
      mm/slab.c: add a helper function get_first_slab
      mm/vmalloc.c: use list_{next,first}_entry
      mm, thp: use list_first_entry_or_null()
      mm/page_alloc.c: use list_{first,last}_entry instead of list_entry
      mm/page_alloc.c: use list_for_each_entry in mark_free_pages()
      mm/swapfile.c: use list_{next,first}_entry
      mm/readahead.c, mm/vmscan.c: use lru_to_page instead of list_to_page
      mm/ksm.c: use list_for_each_entry_safe
      mm/swapfile.c: use list_for_each_entry_safe in free_swap_count_continuations
      mm: move lru_to_page to mm_inline.h
      mm/zbud.c: use list_last_entry() instead of list_tail_entry()

Guenter Roeck (1):
      mn10300: Declare __pfn_to_phys() to fix build error

Hugh Dickins (2):
      memcg: avoid vmpressure oops when memcg disabled
      mm: make swapoff more robust against soft dirty

Jerome Marchand (2):
      mm, shmem: add internal shmem resident memory accounting
      mm, procfs: breakdown RSS for anon, shmem and file in /proc/pid/status

Johannes Weiner (20):
      cgroup: clean up the kernel configuration menu nomenclature
      cgroup: put controller Kconfig options in meaningful order
      mm: page_alloc: generalize the dirty balance reserve
      proc: meminfo: estimate available memory more conservatively
      mm: memcontrol: export root_mem_cgroup
      net: tcp_memcontrol: properly detect ancestor socket pressure
      net: tcp_memcontrol: remove bogus hierarchy pressure propagation
      net: tcp_memcontrol: protect all tcp_memcontrol calls by jump-label
      net: tcp_memcontrol: remove dead per-memcg count of allocated sockets
      net: tcp_memcontrol: simplify the per-memcg limit access
      net: tcp_memcontrol: sanitize tcp memory accounting callbacks
      net: tcp_memcontrol: simplify linkage between socket and page counter
      net-tcp_memcontrol-simplify-linkage-between-socket-and-page-counter
      mm: memcontrol: generalize the socket accounting jump label
      mm: memcontrol: do not account memory+swap on unified hierarchy
      mm: memcontrol: move socket code for unified hierarchy accounting
      mm: memcontrol: account socket memory in unified hierarchy memory controller
      mm: memcontrol: hook up vmpressure to socket pressure
      mm: memcontrol: switch to the updated jump-label API
      mm/oom_kill.c: don't ignore oom score on exiting tasks

John Allen (1):
      drivers/base/memory.c: fix kernel warning during memory hotplug on ppc64

Joonsoo Kim (5):
      mm/page_isolation.c: return last tested pfn rather than failure indicator
      mm/page_isolation.c: add new tracepoint, test_pages_isolated
      mm/cma: always check which page caused allocation failure
      mm/cma: always check which page cause allocation failure
      mm/compaction.c: __compact_pgdat() code cleanuup

Joshua Clayton (1):
      mm: fix noisy sparse warning in LIBCFS_ALLOC_PRE()

Juergen Gross (1):
      x86/paravirt: Remove paravirt ops pmd_update[_defer] and pte_update_defer

Kirill A. Shutemov (86):
      mm: make sure isolate_lru_page() is never called for tail page
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
      page-flags: drop __TestClearPage*() helpers
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
      thp: fix leak due split_huge_page() vs. exit race
      migrate_pages: try to split pages on queuing
      mempolicy: add missed spin_unlock in queue_pages_pte_range
      thp: introduce deferred_split_huge_page()
      thp: fix split_huge_page vs. deferred_split_scan race
      mm: re-enable THP
      thp: update documentation
      thp: allow mlocked THP again
      mm: stop __munlock_pagevec_fill() if THP encountered
      mm, thp: clear PG_mlocked when last mapping gone
      mm: prepare page_referenced() and page_idle to new THP refcounting
      mm-prepare-page_referenced-and-page_idle-to-new-thp-refcounting-fix
      mm: uninline slowpath of page_mapcount()
      mm: fix __page_mapcount()
      thp: add debugfs handle to split all huge pages
      thp: increase split_huge_page() success rate
      thp-increase-split_huge_page-success-rate-fix
      mm-add-page_check_address_transhuge-helper-fix-fix
      thp: fix regression in handling mlocked pages in __split_huge_pmd()
      memblock: fix section mismatch
      mm: fix locking order in mm_take_all_locks()

Konstantin Khlebnikov (1):
      mm: rework virtual memory accounting

Kyeongdon Kim (1):
      zram: try vmalloc() after kmalloc()

Laura Abbott (1):
      dma-debug: switch check from _text to _stext

Liang Chen (1):
      mm: mempolicy: skip non-migratable VMAs when setting MPOL_MF_LAZY

Mel Gorman (1):
      mm/page_alloc.c: remove unnecessary parameter from __rmqueue

Michal Hocko (15):
      Merge remote-tracking branch 'tj-cgroups/for-4.5' into mmotm-4.4
      mm/page_alloc.c: get rid of __alloc_pages_high_priority()
      mm/page_alloc.c: do not loop over ALLOC_NO_WATERMARKS without triggering reclaim
      mm, vmscan: consider isolated pages in zone_reclaimable_pages
      mm: allow GFP_{FS,IO} for page_cache_read page cache allocation
      mm, oom: give __GFP_NOFAIL allocations access to memory reserves
      memcg: ignore partial THP when moving task
      mm-rework-mapcount-accounting-to-enable-4k-mapping-of-thps-fix-5-fix
      mm, oom: rework oom detection
      mm: throttle on IO only when there are too many dirty and writeback pages
      mm: use watermark checks for __GFP_REPEAT high order allocations
      mm, oom: introduce oom reaper
      mm-oom-introduce-oom-reaper-v4
      oom reaper: handle anonymous mlocked pages
      oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space

Mike Kravetz (2):
      fs/hugetlbfs/inode.c: fix bugs in hugetlb_vmtruncate_list()
      mm/hugetlbfs: unmap pages if page fault raced with hole punch

Minchan Kim (14):
      zram: pass gfp from zcomp frontend to backend
      mm: support madvise(MADV_FREE)
      mm-support-madvisemadv_free-fix
      mm: account pglazyfreed exactly
      mm: define MADV_FREE for some arches
      mm/madvise.c: free swp_entry in madvise_free
      mm: move lazily freed pages to inactive list
      mm/ksm.c: mark stable page dirty
      arch/x86/include/asm/pgtable.h: add pmd_[dirty|mkclean] for THP
      arch/sparc/include/asm/pgtable_64.h: add pmd_[dirty|mkclean] for THP
      arch/powerpc/include/asm/pgtable-ppc64.h: add pmd_[dirty|mkclean] for THP
      arch/arm/include/asm/pgtable-3level.h: add pmd_mkclean for THP
      arch/arm64/include/asm/pgtable.h: add pmd_mkclean for THP
      mm/huge_memory.c: don't split THP page when MADV_FREE syscall is called

Naoya Horiguchi (8):
      mm/page_alloc.c: fix warning in comparing enumerator
      mm-zonelist-enumerate-zonelists-array-index-fix-fix-fix
      mm/page_isolation: use macro to judge the alignment
      mm: fix mapcount mismatch in hugepage migration
      mm: soft-offline: check return value in second __get_any_page() call
      mm: hwpoison: adjust for new thp refcounting
      mm: soft-offline: clean up soft_offline_page()
      mm: soft-offline: exit with failure for non anonymous thp

Nathan Zimmer (1):
      mm/mempolicy.c: convert the shared_policy lock to a rwlock

Oleg Nesterov (2):
      cgroup: kill cgrp_ss_priv[CGROUP_CANFORK_COUNT] and friends
      mm: /proc/pid/clear_refs: no need to clear VM_SOFTDIRTY in clear_soft_dirty_pmd()

Paul Gortmaker (1):
      hugetlb: make mm and fs code explicitly non-modular

Piotr Kwapulinski (1):
      mm/mmap.c: remove incorrect MAP_FIXED flag comparison from mmap_region

Rami Rosen (2):
      cgroup_pids: fix a typo.
      cgroup: fix a typo.

Rodrigo Freire (1):
      Documentation/filesystems: describe the shared memory usage/accounting

Ross Zwisler (2):
      cgroup: Fix uninitialized variable warning
      mm, dax: fix livelock, allow dax pmd mappings to become writeable

Sergey Senozhatsky (2):
      zram/zcomp: use GFP_NOIO to allocate streams
      zram/zcomp: do not zero out zcomp private pages

Seth Jennings (2):
      drivers/base/memory.c: clean up section counting
      drivers/base/memory.c: rename remove_memory_block() to remove_memory_section()

Sudip Mukherjee (3):
      m32r: fix m32104ut_defconfig build fail
      arch/*/include/uapi/asm/mman.h: correct uniform value of MADV_FREE
      m68k: provide __phys_to_pfn() and __pfn_to_phys()

Taku Izumi (2):
      mm/page_alloc.c: calculate zone_start_pfn at zone_spanned_pages_in_node()
      mm/page_alloc.c: introduce kernelcore=mirror option

Tejun Heo (11):
      cgroup: replace __DEVEL__sane_behavior with cgroup2 fs type
      cgroup: rename Documentation/cgroups/ to Documentation/cgroup-legacy/
      cgroup: replace unified-hierarchy.txt with a proper cgroup v2 documentation
      cgroup: record ancestor IDs and reimplement cgroup_is_descendant() using it
      kernfs: implement kernfs_walk_and_get()
      cgroup: implement cgroup_get_from_path() and expose cgroup_put()
      Merge branch 'for-4.4-fixes' into for-4.5
      Merge branch 'for-4.5-ancestor-test' of git://git.kernel.org/.../tj/cgroup into for-4.5
      cgroup: demote subsystem init messages to KERN_DEBUG
      cgroup: rename cgroup documentations
      cgroup, memcg, writeback: drop spurious rcu locking around mem_cgroup_css_from_page()

Tetsuo Handa (1):
      tree wide: use kvfree() than conditional kfree()/vfree()

Toshi Kani (3):
      x86/mm/pat: Add untrack_pfn_moved for mremap
      x86/mm/pat: Change free_memtype() to support shrinking case
      dax: Split pmd map when fallback on COW

Vitaly Kuznetsov (2):
      memory-hotplug: don't BUG() in register_memory_resource()
      memory-hotplug-dont-bug-in-register_memory_resource-v2

Vladimir Davydov (12):
      Revert "kernfs: do not account ino_ida allocations to memcg"
      Revert "gfp: add __GFP_NOACCOUNT"
      memcg: only account kmem allocations marked as __GFP_ACCOUNT
      slab: add SLAB_ACCOUNT flag
      vmalloc: allow to account vmalloc to memcg
      kmemcg: account certain kmem allocations to memcg
      vmscan: do not force-scan file lru if its absolute size is small
      vmscan-do-not-force-scan-file-lru-if-its-absolute-size-is-small-v2
      memcg: do not allow to disable tcp accounting after limit is set
      mm/khugepaged: fix scan not aborted on SCAN_EXCEED_SWAP_PTE
      mm: add page_check_address_transhuge() helper
      mm-add-page_check_address_transhuge-helper-fix

Vlastimil Babka (4):
      mm, documentation: clarify /proc/pid/status VmSwap limitations for shmem
      mm, proc: account for shmem swap in /proc/pid/smaps
      mm, proc: reduce cost of /proc/pid/smaps for shmem mappings
      mm, proc: reduce cost of /proc/pid/smaps for unpopulated shmem mappings

Wang Xiaoqiang (3):
      mm/page_isolation: do some cleanup in "undo_isolate_page_range"
      mm/vmalloc.c: use macro IS_ALIGNED to judge the aligment
      mm/mlock.c: change can_do_mlock return value type to boolean

Weijie Yang (1):
      zsmalloc: reorganize struct size_class to pack 4 bytes hole

Yaowei Bai (6):
      include/linux/hugetlb.h: is_file_hugepages() can be boolean
      mm/memblock.c: memblock_is_memory()/reserved() can be boolean
      include/linux/mmzone.h: remove unused is_unevictable_lru()
      mm/zonelist: enumerate zonelists array index
      mm/mmzone.c: memmap_valid_within() can be boolean
      mm/compaction: improve comment for compact_memory tunable knob handler

Yuan Sun (2):
      Subject: cgroup: Fix incomplete dd command in blkio documentation
      cgroup: Remove resource_counter.txt in Documentation/cgroup-legacy/00-INDEX.

nimisolo (1):
      mm/memblock.c:memblock_add_range(): if nr_new is 0 just return

yalin wang (3):
      mm/vmscan.c: change trace_mm_vmscan_writepage() proto type
      mm: change mm_vmscan_lru_shrink_inactive() proto types
      mm: fix kernel crash in khugepaged thread

zhong jiang (1):
      arm64: fix add kasan bug

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
