Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA0A96B0339
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 05:05:36 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id i131so1489891wma.1
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 02:05:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 26si1103832wrx.524.2017.09.12.02.05.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Sep 2017 02:05:34 -0700 (PDT)
Date: Tue, 12 Sep 2017 11:05:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: mmotm git tree since-4.13 branch created (was: mmotm
 2017-09-08-16-48 uploaded)
Message-ID: <20170912090531.fwqzs2nhvmqw3eia@dhcp22.suse.cz>
References: <59b32c8e.2kl6QUdusEmEtnCx%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <59b32c8e.2kl6QUdusEmEtnCx%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

I have just created since-4.13 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v4.13 tag in Linus tree and mmotm-2017-09-08-16-48 plus I
have merged tip/x86/mm which contains 5-level page table stuff plus PCID
changes and cgroup core changes in case there will be some later changes
regarding memcg which would depend on those. Let me know if some other
changes should be merged as well for an easier development on top of
this tree.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The shortlog says:
Aaron Lu (1):
      swap: choose swap device according to numa node

Alexander Popov (1):
      mm/slub.c: add a naive detection of double free or corruption

Alexander Potapenko (1):
      slub: tidy up initialization ordering

Alexey Dobriyan (3):
      proc: uninline proc_create()
      treewide: make "nr_cpu_ids" unsigned
      cpumask: make cpumask_next() out-of-line

Alexey Perevalov (1):
      userfaultfd: provide pid in userfault msg

Andrea Arcangeli (6):
      userfaultfd: selftest: exercise UFFDIO_COPY/ZEROPAGE -EEXIST
      userfaultfd: selftest: explicit failure if the SIGBUS test failed
      userfaultfd: call userfaultfd_unmap_prep only if __split_vma succeeds
      userfaultfd: provide pid in userfault msg - add feat union
      mm: oom: let oom_reap_task and exit_mmap run concurrently
      userfaultfd: non-cooperative: closing the uffd without triggering SIGBUS

Andrew Morton (2):
      treewide-remove-gfp_temporary-allocation-flag-fix
      treewide-remove-gfp_temporary-allocation-flag-checkpatch-fixes

Andy Shevchenko (1):
      lib/hexdump.c: return -EINVAL in case of error in hex2bin()

Anshuman Khandual (2):
      mm/memory.c: remove reduntant check for write access
      mm/mempolicy.c: remove BUG_ON() checks for VMA inside mpol_misplaced()

Arnd Bergmann (2):
      fscache: fix fscache_objlist_show format processing
      IB/mlx4: fix sprintf format warning

Arvind Yadav (5):
      mm/ksm.c: constify attribute_group structures
      mm/slub.c: constify attribute_group structures
      mm/page_idle.c: constify attribute_group structures
      mm/huge_memory.c: constify attribute_group structures
      mm/hugetlb.c: constify attribute_group structures

Babu Moger (3):
      arch: define CPU_BIG_ENDIAN for all fixed big endian archs
      arch/microblaze: add choice for endianness and update Makefile
      include: warn for inconsistent endian config definition

Baoquan He (1):
      lib/cmdline.c: remove meaningless comment

Byungchul Park (1):
      mm/vmalloc.c: don't reinvent the wheel but use existing llist API

Chris Wilson (2):
      mm: track actual nr_scanned during shrink_slab()
      drm/i915: wire up shrinkctl->nr_scanned

Cyrill Gorcunov (1):
      tools/testing/selftests/kcmp/kcmp_test.c: add KCMP_EPOLL_TFD testing

Dan Carpenter (1):
      lib/string.c: check for kmalloc() failure

Dan Williams (1):
      mm, devm_memremap_pages: use multi-order radix for ZONE_DEVICE lookups

Daniel Colascione (1):
      mm: add /proc/pid/smaps_rollup

Daniel Micay (1):
      init/main.c: extract early boot entropy from the passed cmdline

Darrick J. Wong (1):
      mm: kvfree the swap cluster info if the swap file is unsatisfactory

David Rientjes (5):
      mm/swapfile.c: fix swapon frontswap_map memory leak on error
      fs, proc: unconditional cond_resched when reading smaps
      mm, compaction: kcompactd should not ignore pageblock skip
      mm, compaction: persistently skip hugetlbfs pageblocks
      mm, compaction: persistently skip hugetlbfs pageblocks fix

Davidlohr Bueso (19):
      rbtree: cache leftmost node internally
      rbtree: optimize root-check during rebalancing loop
      rbtree: add some additional comments for rebalancing cases
      lib/rbtree_test.c: make input module parameters
      lib/rbtree_test.c: add (inorder) traversal test
      lib/rbtree_test.c: support rb_root_cached
      sched/fair: replace cfs_rq->rb_leftmost
      sched/deadline: replace earliest dl and rq leftmost caching
      locking/rtmutex: replace top-waiter and pi_waiters leftmost caching
      block/cfq: replace cfq_rb_root leftmost caching
      lib/interval_tree: fast overlap detection
      lib/interval-tree: correct comment wrt generic flavor
      procfs: use faster rb_first_cached()
      fs/epoll: use faster rb_first_cached()
      mem/memcg: cache rightmost node
      block/cfq: cache rightmost rb_node
      lib/rhashtable: fix comment on locks_mul default value
      ipc/sem: drop sem_checkid helper
      ipc/sem: play nicer with large nsops allocations

Dmitry Vyukov (1):
      kcov: support compat processes

Dou Liyang (1):
      metag/numa: remove the unused parent_node() macro

Elena Reshetova (3):
      ipc: convert ipc_namespace.count from atomic_t to refcount_t
      ipc: convert sem_undo_list.refcnt from atomic_t to refcount_t
      ipc: convert kern_ipc_perm.refcount from atomic_t to refcount_t

Eric Dumazet (1):
      radix-tree: must check __radix_tree_preload() return value

Florian Fainelli (1):
      lib: add test module for CONFIG_DEBUG_VIRTUAL

Guillaume Knispel (1):
      ipc: optimize semget/shmget/msgget for lots of keys

Helge Deller (1):
      parisc: Add MADV_HWPOISON and MADV_SOFT_OFFLINE

Huang Ying (18):
      mm, THP, swap: support to clear swap cache flag for THP swapped out
      mm, THP, swap: support to reclaim swap space for THP swapped out
      mm, THP, swap: make reuse_swap_page() works for THP swapped out
      mm, THP, swap: don't allocate huge cluster for file backed swap device
      block, THP: make block_device_operations.rw_page support THP
      mm: test code to write THP to swap device as a whole
      mm, THP, swap: support splitting THP for THP swap out
      memcg, THP, swap: support move mem cgroup charge for THP swapped out
      memcg, THP, swap: avoid to duplicated charge THP in swap cache
      memcg, THP, swap: make mem_cgroup_swapout() support THP
      mm, THP, swap: delay splitting THP after swapped out
      mm, THP, swap: add THP swapping out fallback counting
      mm, swap: add swap readahead hit statistics
      mm, swap: fix swap readahead marking
      mm, swap: VMA based swap readahead
      mm, swap: add sysfs interface for VMA based swap readahead
      mm, swap: don't use VMA based swap readahead if HDD is used as swap
      mm: hugetlb: clear target sub-page last when clearing huge page

Hui Zhu (1):
      zsmalloc: zs_page_migrate: skip unnecessary loops but not return -EBUSY if zspage is not inuse

Jan Kara (10):
      fscache: remove unused ->now_uncached callback
      mm: make pagevec_lookup() update index
      mm: implement find_get_pages_range()
      fs: fix performance regression in clean_bdev_aliases()
      ext4: use pagevec_lookup_range() in ext4_find_unwritten_pgoff()
      ext4: use pagevec_lookup_range() in writeback code
      hugetlbfs: use pagevec_lookup_range() in remove_inode_hugepages()
      fs: use pagevec_lookup_range() in page_cache_seek_hole_data()
      mm: use find_get_pages_range() in filemap_range_has_page()
      mm: remove nr_pages argument from pagevec_lookup{,_range}()

Jeff Layton (2):
      fs/sync.c: remove unnecessary NULL f_mapping check in sync_file_range
      include/linux/fs.h: remove unneeded forward definition of mm_struct

Joonsoo Kim (4):
      mm/mlock.c: use page_zone() instead of page_zone_id()
      mm/cma: manage the memory of the CMA area by using the ZONE_MOVABLE
      mm/cma: remove ALLOC_CMA
      ARM: CMA: avoid double mapping to the CMA area if CONFIG_HIGHMEM=y

Jerome Glisse (20):
      hmm: heterogeneous memory management documentation
      mm/hmm: heterogeneous memory management (HMM for short)
      mm/hmm/mirror: mirror process address space on device with HMM helpers
      mm/hmm/mirror: helper to snapshot CPU page table
      mm/hmm/mirror: device page fault handler
      mm/ZONE_DEVICE: new type of ZONE_DEVICE for unaddressable memory
      mm/ZONE_DEVICE: special case put_page() for device private pages
      mm/memcontrol: allow to uncharge page without using page->lru field
      mm/memcontrol: support MEMORY_DEVICE_PRIVATE
      mm/hmm/devmem: device memory hotplug using ZONE_DEVICE
      mm/hmm/devmem: dummy HMM device for ZONE_DEVICE memory
      mm/migrate: new migrate mode MIGRATE_SYNC_NO_COPY
      mm/migrate: new memory migration helper for use with device memory
      mm/migrate: migrate_vma() unmap page from vma while collecting pages
      mm/migrate: support un-addressable ZONE_DEVICE page in migration
      mm/migrate: allow migrate_vma() to alloc new page on empty entry
      mm/device-public-memory: device memory cache coherent with CPU
      mm/hmm: add new helper to hotplug CDM memory region
      mm/hmm: avoid bloating arch that do not make use of HMM
      mm/hmm: fix build when HMM is disabled

Kees Cook (1):
      mm: add SLUB free list pointer obfuscation

Kemi Wang (3):
      mm: change the call sites of numa statistics items
      mm: update NUMA counter threshold size
      mm: consider the number in local CPUs when reading NUMA stats

Laura Abbott (1):
      init: move stack canary initialization after setup_arch

Laurent Dufour (3):
      mm: remove useless vma parameter to offset_il_node
      mm/memory.c: fix mem_cgroup_oom_disable() call missing
      mm: skip HWPoisoned pages when onlining pages

Markus Elfring (1):
      binfmt_flat: delete two error messages for a failed memory allocation in decompress_exec()

Masahiro Yamada (1):
      linux/kernel.h: move DIV_ROUND_DOWN_ULL() macro

Matthew Wilcox (7):
      lib/string.c: add multibyte memset functions
      lib/string.c: add testcases for memset16/32/64
      x86: implement memset16, memset32 & memset64
      ARM: implement memset32 & memset64
      alpha: add support for memset16
      drivers/block/zram/zram_drv.c: convert to using memset_l
      drivers/scsi/sym53c8xx_2/sym_hipd.c: convert to use memset32

Matthias Kaehlcke (3):
      mm: memcontrol: use int for event/state parameter in several functions
      mm/zsmalloc.c: change stat type parameter to int
      bitops: avoid integer overflow in GENMASK(_ULL)

Mel Gorman (1):
      mm: always flush VMA ranges affected by zap_page_range

Michal Hocko (23):
      Merge remote-tracking branch 'tip/x86/mm' into mmotm-4.13
      Merge remote-tracking branch 'tj-cgroups/for-4.14' into mmotm-4.13
      mm, memory_hotplug: display allowed zones in the preferred ordering
      mm, memory_hotplug: remove zone restrictions
      mm, page_alloc: rip out ZONELIST_ORDER_ZONE
      mm, page_alloc: remove boot pageset initialization from memory hotplug
      mm, page_alloc: do not set_cpu_numa_mem on empty nodes initialization
      mm, memory_hotplug: drop zone from build_all_zonelists
      mm, memory_hotplug: remove explicit build_all_zonelists from try_online_node
      mm, page_alloc: simplify zonelist initialization
      mm, page_alloc: remove stop_machine from build_all_zonelists
      mm, memory_hotplug: get rid of zonelists_mutex
      mm, sparse, page_ext: drop ugly N_HIGH_MEMORY branches for allocations
      mm, vmscan: do not loop on too_many_isolated for ever
      mm: rename global_page_state to global_zone_page_state
      mm, hugetlb: do not allocate non-migrateable gigantic pages from movable zones
      mm, oom: do not rely on TIF_MEMDIE for memory reserves access
      mm: replace TIF_MEMDIE checks by tsk_is_oom_victim
      mm/memory_hotplug: introduce add_pages
      mm/sparse.c: fix typo in online_mem_sections
      fs, proc: remove priv argument from is_stack
      mm, memory_hotplug: do not back off draining pcp free pages from kworker context
      mm: treewide: remove GFP_TEMPORARY allocation flag

Mike Kravetz (6):
      mm/mremap: fail map duplication attempts for private mappings
      mm: hugetlb: define system call hugetlb size encodings in single file
      mm: arch: consolidate mmap hugetlb size encodings
      mm: shm: use new hugetlb size encoding definitions
      mm/shmem: add hugetlbfs support to memfd_create()
      selftests/memfd: add memfd_create hugetlbfs selftest

Mike Rapoport (7):
      shmem: shmem_charge: verify max_block is not exceeded before inode update
      shmem: introduce shmem_inode_acct_block
      userfaultfd: shmem: add shmem_mfill_zeropage_pte for userfaultfd support
      userfaultfd: mcopy_atomic: introduce mfill_atomic_pte helper
      userfaultfd: shmem: wire up shmem_mfill_zeropage_pte
      userfaultfd: report UFFDIO_ZEROPAGE as available for shmem VMAs
      userfaultfd: selftest: enable testing of UFFDIO_ZEROPAGE for shmem

Minchan Kim (9):
      zram: clean up duplicated codes in __zram_bvec_write
      zram: inline zram_compress
      zram: rename zram_decompress_page to __zram_bvec_read
      zram: add interface to specif backing device
      zram: add free space management in backing device
      zram: identify asynchronous IO's return value
      zram: write incompressible pages to backing device
      zram: read page from backing device
      zram: add config and doc file for writeback feature

Naoya Horiguchi (8):
      mm: mempolicy: add queue_pages_required()
      mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7 to bit 1
      mm: thp: introduce separate TTU flag for thp freezing
      mm: thp: introduce CONFIG_ARCH_ENABLE_THP_MIGRATION
      mm: soft-dirty: keep soft-dirty bits over thp migration
      mm: mempolicy: mbind and migrate_pages support thp migration
      mm: migrate: move_pages() supports thp migration
      mm: memory_hotplug: memory hotremove supports thp migration

Nicolas Iooss (1):
      dax: initialize variable pfn before using it

Oliver O'Halloran (1):
      mm/gup: make __gup_device_* require THP

Pavel Tatashin (1):
      sparc64: NG4 memset 32 bits overflow

Prakash Gupta (1):
      mm, page_owner: skip unnecessary stack_trace entries

Prakash Sangappa (2):
      mm: userfaultfd: add feature to request for a signal delivery
      userfaultfd: selftest: add tests for UFFD_FEATURE_SIGBUS feature

Punit Agrawal (1):
      mm/hugetlb.c: make huge_pte_offset() consistent and document behaviour

Rik van Riel (2):
      x86,mpx: make mpx depend on x86-64 to free up VMA flag
      mm,fork: introduce MADV_WIPEONFORK

Roman Gushchin (3):
      mm, memcg: reset memory.low during memcg offlining
      cgroup: revert fa06235b8eb0 ("cgroup: reset css on destruction")
      mm: memcontrol: use per-cpu stocks for socket memory uncharging

Ross Zwisler (7):
      mm: add vm_insert_mixed_mkwrite()
      dax: relocate some dax functions
      dax: use common 4k zero page for dax mmap reads
      dax: remove DAX code from page_cache_tree_insert()
      dax: move all DAX radix tree defs to fs/dax.c
      dax: explain how read(2)/write(2) addresses are validated
      dax: use PG_PMD_COLOUR instead of open coding

SeongJae Park (1):
      mm/vmstat.c: fix wrong comment

Shakeel Butt (1):
      mm: fadvise: avoid fadvise for fs without backing device

Tetsuo Handa (1):
      mm/page_alloc.c: apply gfp_allowed_mask before the first allocation attempt

Vinayak Menon (1):
      mm: vmscan: do not pass reclaimed slab to vmpressure

Vitaly Wool (1):
      z3fold: use per-cpu unbuddied lists

Vlastimil Babka (3):
      mm, page_owner: make init_pages_in_zone() faster
      mm, page_ext: periodically reschedule during page_ext_init()
      mm, page_owner: don't grab zone->lock for init_pages_in_zone()

Wei Yang (3):
      mm/memory_hotplug: just build zonelist for newly added node
      mm/vmalloc.c: halve the number of comparisons performed in pcpu_get_vm_areas()
      mm/page_alloc: return 0 in case this node has no page within the zone

Wen Yang (1):
      mm/vmstat: fix divide error at __fragmentation_index

Yury Norov (3):
      lib/bitmap.c: make bitmap_parselist() thread-safe and much faster
      lib/test_bitmap.c: add test for bitmap_parselist()
      bitmap: introduce BITMAP_FROM_U64()

Zi Yan (2):
      mm: thp: enable thp migration in generic path
      mm: thp: check pmd migration entry in common path

zhong jiang (2):
      mm/page_owner: align with pageblock_nr pages
      mm/vmstat.c: walk the zone in pageblock_nr_pages steps

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
