Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8062E6B0038
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 08:39:21 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so61002004wic.1
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 05:39:21 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id fi7si487658wib.108.2015.09.11.05.39.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Sep 2015 05:39:19 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so61403357wic.0
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 05:39:19 -0700 (PDT)
Date: Fri, 11 Sep 2015 14:39:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mmotm 2015-09-10-16-30 uploaded
Message-ID: <20150911123917.GI3417@dhcp22.suse.cz>
References: <55f212ae.jOhLy+/WerFdt/xh%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55f212ae.jOhLy+/WerFdt/xh%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au

I have just created since-4.2 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v4.2 tag in Linus tree and mmotm-2015-09-10-16-30.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The shortlog says:
Aleksa Sarai (4):
      cgroup: allow a cgroup subsystem to reject a fork
      cgroup: implement the PIDs subsystem
      cgroup: add documentation for the PIDs controller
      cgroup: pids: fix invalid get/put usage

Alexander Kuleshov (3):
      mm/memblock.c: rename local variable of memblock_type to 'type'
      mm/memblock.c: fiy typos in comments
      mm/memblock.c: fix comment in __next_mem_range()

Andrea Arcangeli (26):
      userfaultfd: linux/Documentation/vm/userfaultfd.txt
      userfaultfd: waitqueue: add nr wake parameter to __wake_up_locked_key
      userfaultfd: uAPI
      userfaultfd: linux/userfaultfd_k.h
      userfaultfd: add vm_userfaultfd_ctx to the vm_area_struct
      userfaultfd: add VM_UFFD_MISSING and VM_UFFD_WP
      userfaultfd: call handle_userfault() for userfaultfd_missing() faults
      userfaultfd: teach vma_merge to merge across vma->vm_userfaultfd_ctx
      userfaultfd: prevent khugepaged to merge if userfaultfd is armed
      userfaultfd: add new syscall to provide memory externalization
      userfaultfd: change the read API to return a uffd_msg
      userfaultfd: wake pending userfaults
      userfaultfd: optimize read() and poll() to be O(1)
      userfaultfd: allocate the userfaultfd_ctx cacheline aligned
      userfaultfd: solve the race between UFFDIO_COPY|ZEROPAGE and read
      userfaultfd: buildsystem activation
      userfaultfd: activate syscall
      userfaultfd: UFFDIO_COPY|UFFDIO_ZEROPAGE uAPI
      userfaultfd: mcopy_atomic|mfill_zeropage: UFFDIO_COPY|UFFDIO_ZEROPAGE preparation
      userfaultfd: avoid mmap_sem read recursion in mcopy_atomic
      userfaultfd: UFFDIO_COPY and UFFDIO_ZEROPAGE
      userfaultfd: require UFFDIO_API before other ioctls
      userfaultfd: allow signals to interrupt a userfault
      userfaultfd: propagate the full address in THP faults
      userfaultfd: avoid missing wakeups during refile in userfaultfd_read
      userfaultfd: selftest

Andrew Morton (10):
      kernel/kthread.c:kthread_create_on_node(): clarify documentation
      dax: revert userfaultfd change
      mm-srcu-ify-shrinkers-fix-fix
      page-flags-introduce-page-flags-policies-wrt-compound-pages-fix
      include/linux/page-flags.h: rename macros to avoid collisions
      x86-add-pmd_-for-thp-fix
      sparc-add-pmd_-for-thp-fix
      mm-support-madvisemadv_free-fix-2
      mm-dont-split-thp-page-when-syscall-is-called-fix-3
      mm-move-lazy-free-pages-to-inactive-list-fix-fix

Ard Biesheuvel (1):
      mm/early_ioremap: add explicit #include of asm/early_ioremap.h

Aristeu Rozanski (1):
      mm/mempolicy.c: get rid of duplicated check for vma(VM_PFNMAP) in queue_pages_range()

Calvin Owens (1):
      procfs: always expose /proc/<pid>/map_files/ and make it readable

Chen Gang (2):
      mm/mmap.c: simplify the failure return working flow
      mm/mmap.c:insert_vm_struct(): check for failure before setting values

Chris Metcalf (1):
      bootmem: avoid freeing to bootmem after bootmem is done

Christoph Hellwig (5):
      dma-mapping: consolidate dma_{alloc,free}_{attrs,coherent}
      dma-mapping: consolidate dma_{alloc,free}_noncoherent
      dma-mapping: cosolidate dma_mapping_error
      dma-mapping: consolidate dma_supported
      dma-mapping: consolidate dma_set_mask

Christoph Lameter (1):
      slab: infrastructure for bulk object allocation and freeing

Dan Streetman (5):
      zpool: remove no-op module init/exit
      zpool: add zpool_has_pool()
      zswap: dynamic pool creation
      zswap: change zpool/compressor at runtime
      zswap: update docs for runtime-changeable attributes

Daniel Borkmann (1):
      mm/slab.h: fix argument order in cache_from_obj's error message

Dave Hansen (1):
      fs: do not prefault sys_write() user buffer pages

David Rientjes (6):
      mm: improve __GFP_NORETRY comment based on implementation
      mm, oom: organize oom context into struct
      mm, oom: pass an oom order of -1 when triggered by sysrq
      mm, oom: do not panic for oom kills triggered from sysrq
      mm, oom: add description of struct oom_control
      mm, oom: remove unnecessary variable

Davidlohr Bueso (2):
      mm: srcu-ify shrinkers
      mm-srcu-ify-shrinkers-fix

Dmitry Safonov (1):
      mm: swap: zswap: maybe_preload & refactoring

Eric B Munson (10):
      mm: mlock: refactor mlock, munlock, and munlockall code
      mm-mlock-refactor-mlock-munlock-and-munlockall-code-v7
      mm: mlock: add new mlock system call
      mm-mlock-add-new-mlock-system-call-v7
      mm: introduce VM_LOCKONFAULT
      mm-introduce-vm_lockonfault-v7
      mm: mlock: add mlock flags to enable VM_LOCKONFAULT usage
      mm-mlock-add-mlock-flags-to-enable-vm_lockonfault-usage-v7
      selftests: vm: add tests for lock on fault
      mips: add entry for new mlock2 syscall

Frederic Weisbecker (3):
      smpboot: fix memory leak on error handling
      smpboot: make cleanup to mirror setup
      smpboot: allow passing the cpumask on per-cpu thread registration

Geert Uytterhoeven (1):
      selftests/userfaultfd: fix compiler warnings on 32-bit

Hugh Dickins (1):
      mm, vmscan: unlock page while waiting on writeback

Jaewon Kim (1):
      vmscan: fix increasing nr_isolated incurred by putback unevictable pages

James Custer (1):
      mm: fix invalid use of pfn_valid_within in test_pages_in_a_zone

Jeff Layton (1):
      list_lru: don't call list_lru_from_kmem if the list_head is empty

Jesper Dangaard Brouer (5):
      slub: fix spelling succedd to succeed
      slub bulk alloc: extract objects from the per cpu slab
      slub: improve bulk alloc strategy
      slub: initial bulk free implementation
      slub: add support for kmem_cache_debug in bulk calls

Joonsoo Kim (2):
      mm/slub: don't wait for high-order page allocation
      mm/compaction: correct to flush migrated pages if pageblock skip happens

Kees Cook (2):
      fs: create and use seq_show_option for escaping
      cgroup: fix seq_show_option merge with legacy_name

Kirill A. Shutemov (28):
      mm: fix status code which move_pages() returns for zero page
      mm: make GUP handle pfn mapping unless FOLL_GET is requested
      thp: vma_adjust_trans_huge(): adjust file-backed VMA too
      thp: decrement refcount on huge zero page if it is split
      thp: fix zap_huge_pmd() for DAX
      dax: don't use set_huge_zero_page()
      mm: take i_mmap_lock in unmap_mapping_range() for DAX
      mm, dax: use i_mmap_unlock_write() in do_cow_fault()
      mm: drop __nocast from vm_flags_t definition
      mm: mark most vm_operations_struct const
      mm: make sure all file VMAs have ->vm_ops set
      mm: use vma_is_anonymous() in create_huge_pmd() and wp_huge_pmd()
      page-flags: trivial cleanup for PageTrans* helpers
      page-flags: introduce page flags policies wrt compound pages
      page-flags: define PG_locked behavior on compound pages
      page-flags: define behavior of FS/IO-related flags on compound pages
      page-flags: define behavior of LRU-related flags on compound pages
      page-flags: define behavior SL*B-related flags on compound pages
      page-flags: define behavior of Xen-related flags on compound pages
      page-flags: define PG_reserved behavior on compound pages
      page-flags: define PG_swapbacked behavior on compound pages
      page-flags: define PG_swapcache behavior on compound pages
      page-flags: define PG_mlocked behavior on compound pages
      page-flags: define PG_uncached behavior on compound pages
      page-flags: define PG_uptodate behavior on compound pages
      page-flags: look at head page if the flag is encoded in page->mapping
      mm: sanitize page->mapping for tail pages
      mm, madvise: use vma_is_anonymous() to check for anon VMA

Konstantin Khlebnikov (7):
      mm/slub: fix slab double-free in case of duplicate sysfs filename
      pagemap: check permissions and capabilities at open time
      pagemap: switch to the new format and do some cleanup
      pagemap: rework hugetlb and thp report
      pagemap: hide physical addresses from non-privileged users
      pagemap: add mmap-exclusive bit for marking pages mapped only here
      pagemap: update documentation

Krzysztof Kozlowski (2):
      mm: zpool: constify the zpool_ops
      mm: zbud: constify the zbud_ops

Liuhailong (1):
      slab: fix unexpected index mapping result of kmalloc_size(INDEX_NODE + 1)

Lorenzo Nava (1):
      ARM: 8398/1: arm DMA: Fix allocation from CMA for coherent DMA

Mark Salter (3):
      mm: add utility for early copy from unmapped ram
      arm64: support initrd outside kernel linear map
      x86: use generic early mem copy

Matthew Wilcox (17):
      dax: move DAX-related functions to a new header
      thp: prepare for DAX huge pages
      mm: add a pmd_fault handler
      mm: export various functions for the benefit of DAX
      mm: add vmf_insert_pfn_pmd()
      dax: add huge page fault support
      ext2: huge page fault support
      ext4: huge page fault support
      xfs: huge page fault support
      ext4: use ext4_get_block_write() for DAX
      thp: change insert_pfn's return type to void
      dax: improve comment about truncate race
      ext4: add ext4_get_block_dax()
      ext4: start transaction before calling into DAX
      dax: fix race between simultaneous faults
      dax: ensure that zero pages are removed from other processes
      dax: use linear_page_index()

Max Filippov (1):
      xtensa: reimplement DMA API using common helpers

Mel Gorman (5):
      x86, mm: trace when an IPI is about to be sent
      mm: send one IPI per CPU to TLB flush all entries after unmapping pages
      mm: defer flush of writable TLB entries
      Documentation/features/vm: add feature description and arch support status for batched TLB flush after unmap
      mm: increase SWAP_CLUSTER_MAX to batch TLB flushes

Michal Hocko (7):
      Merge remote-tracking branch 'tj-cgroups/for-4.3' into mmotm-since-4.2-base
      sparc32: do not include swap.h from pgtable_32.h
      memcg: export struct mem_cgroup
      memcg: get rid of mem_cgroup_root_css for !CONFIG_MEMCG
      memcg: get rid of extern for functions in memcontrol.h
      memcg, tcp_kmem: check for cg_proto in sock_update_memcg
      memcg: move memcg_proto_active from sock.h

Mike Kravetz (13):
      mm/hugetlb: add cache of descriptors to resv_map for region_add
      mm/hugetlb: add region_del() to delete a specific range of entries
      mm/hugetlb: expose hugetlb fault mutex for use by fallocate
      hugetlbfs: hugetlb_vmtruncate_list() needs to take a range to delete
      hugetlbfs: truncate_hugepages() takes a range of pages
      mm/hugetlb: vma_has_reserves() needs to handle fallocate hole punch
      mm/hugetlb: alloc_huge_page handle areas hole punched by fallocate
      hugetlbfs: New huge_add_to_page_cache helper routine
      hugetlbfs: add hugetlbfs_fallocate()
      mm: madvise allow remove operation for hugetlbfs
      Revert "selftests: add hugetlbfstest"
      selftests:vm: point to libhugetlbfs for regression testing
      Documentation: update libhugetlbfs location and use for testing

Minchan Kim (16):
      mm: /proc/pid/smaps:: show proportional swap share of the mapping
      zsmalloc: consider ZS_ALMOST_FULL as migrate source
      zsmalloc: use class->pages_per_zspage
      x86: add pmd_[dirty|mkclean] for THP
      sparc: add pmd_[dirty|mkclean] for THP
      powerpc: add pmd_[dirty|mkclean] for THP
      arm: add pmd_mkclean for THP
      arm64: add pmd_[dirty|mkclean] for THP
      mm: support madvise(MADV_FREE)
      mm: define MADV_FREE for some arches
      mm: don't split THP page when syscall is called
      mm: remove lock validation check for MADV_FREE
      mm: free swp_entry in madvise_free
      mm: move lazily freed pages to inactive list
      mm: document deactivate_page
      mm: lru_deactivate_fn should clear PG_referenced

Naoya Horiguchi (7):
      mm, page_isolation: make set/unset_migratetype_isolate() file-local
      mm/hwpoison: introduce num_poisoned_pages wrappers
      mm/hwpoison: don't try to unpoison containment-failed pages
      mm: hugetlb: proc: add HugetlbPages field to /proc/PID/smaps
      Documentation/filesystems/proc.txt: give additional comment about hugetlb usage
      mm: hugetlb: proc: add HugetlbPages field to /proc/PID/status
      mm-hugetlb-proc-add-hugetlbpages-field-to-proc-pid-status-v5

Nicholas Krause (6):
      mm/hugetlb.c: make vma_shareable() return bool
      mm/dmapool.c: change is_page_busy() return from int to bool
      mm/memory.c: make tlb_next_batch() return bool
      mm/madvise.c: make madvise_behaviour_valid() return bool
      mm/hugetlb.c: make vma_has_reserves() return bool
      mm: make set_recommended_min_free_kbytes() return void

Oleg Nesterov (9):
      mremap: don't leak new_vma if f_op->mremap() fails
      mm: move ->mremap() from file_operations to vm_operations_struct
      mremap: don't do mm_populate(new_addr) on failure
      mremap: don't do uneccesary checks if new_len == old_len
      mremap: simplify the "overlap" check in mremap_to()
      mm: introduce vma_is_anonymous(vma) helper
      mmap: fix the usage of ->vm_pgoff in special_mapping paths
      mremap: fix the wrong !vma->vm_file check in copy_vma()
      mm, mpx: add "vm_flags_t vm_flags" arg to do_mmap_pgoff()

Paul Bolle (1):
      mm: Fix comment typo "CONFIG_TRANSPARNTE_HUGE"

Pavel Emelyanov (1):
      userfaultfd: Rename uffd_api.bits into .features

Petr Mladek (1):
      mm/khugepaged: allow interruption of allocation sleep again

Roman Pen (1):
      fs/mpage.c: forgotten WRITE_SYNC in case of data integrity write

SF Markus Elfring (1):
      ntfs: delete unnecessary checks before calling iput()

Sean O. Stalley (4):
      mm: add support for __GFP_ZERO flag to dma_pool_alloc()
      mm: add dma_pool_zalloc() call to DMA API
      pci: mm: add pci_pool_zalloc() call
      coccinelle: mm: scripts/coccinelle/api/alloc/pool_zalloc-simple.cocci

Sebastian Andrzej Siewior (1):
      mm: memcontrol: bring back the VM_BUG_ON() in mem_cgroup_swapout()

Sergey Senozhatsky (14):
      mm/slab_common: allow NULL cache pointer in kmem_cache_destroy()
      mm/mempool: allow NULL `pool' pointer in mempool_destroy()
      mm/dmapool: allow NULL `pool' pointer in dma_pool_destroy()
      zsmalloc: drop unused variable `nr_to_migrate'
      zsmalloc: always keep per-class stats
      zsmalloc: introduce zs_can_compact() function
      zsmalloc: cosmetic compaction code adjustments
      zsmalloc/zram: introduce zs_pool_stats api
      zsmalloc: account the number of compacted pages
      zsmalloc: use shrinker to trigger auto-compaction
      zsmalloc: partial page ordering within a fullness_list
      zsmalloc: do not take class lock in zs_shrinker_count()
      zsmalloc: remove null check from destroy_handle_cache()
      zram: unify error reporting

Tang Chen (3):
      memory-hotplug: add hot-added memory ranges to memblock before allocate node_data for a node.
      mm/memblock.c: make memblock_overlaps_region() return bool.
      mem-hotplug: handle node hole when initializing numa_meminfo.

Tejun Heo (7):
      cgroup: define controller file conventions
      cgroup: export cgrp_dfl_root
      cgroup: make cftype->private a unsigned long
      cgroup: don't print subsystems for the default hierarchy
      cgroup: introduce cgroup_subsys->legacy_name
      Merge branch 'for-4.3-unified-base' into for-4.3
      memcg: restructure mem_cgroup_can_attach()

Thierry Reding (4):
      selftests: vm: pick up sanitized kernel headers
      selftests: vm: Fix mlock2-tests for 32-bit architectures
      selftests: vm: ensure the mlock2 syscall number can be found
      selftests: vm: use the right arguments for main()

Thomas Gleixner (1):
      mm/slub: move slab initialization into irq enabled region

Valentin Rothberg (1):
      fs/dax.c: fix typo in #endif comment

Vasily Kulikov (2):
      include/linux/poison.h: fix LIST_POISON{1,2} offset
      include/linux/poison.h: remove not-used poison pointer macros

Vinayak Menon (1):
      mm: vmscan: fix the page state calculation in too_many_isolated

Vineet Gupta (1):
      mm: remove put_page_unless_one()

Vishnu Pratap Singh (1):
      lib/show_mem.c: correct reserved memory calculation

Vitaly Kuznetsov (1):
      lib/string_helpers.c: fix infinite loop in string_get_size()

Vladimir Davydov (10):
      cgroup: fix idr_preload usage
      mm: vmscan: never isolate more pages than necessary
      memcg: add page_cgroup_ino helper
      hwpoison: use page_cgroup_ino for filtering by memcg
      memcg: zap try_get_mem_cgroup_from_page
      proc: add kpagecgroup file
      mmu-notifier: add clear_young callback
      mm: introduce idle page tracking
      proc: export idle flag via kpageflags
      proc: add cond_resched to /proc/kpage* read/write loop

Vladimir Murzin (3):
      memtest: use kstrtouint instead of simple_strtoul
      memtest: cleanup log messages
      memtest: remove unused header files

Vladimir Zapolskiy (2):
      genalloc: add name arg to gen_pool_get() and devm_gen_pool_create()
      genalloc: add support of multiple gen_pools per device

Vlastimil Babka (10):
      mm, page_isolation: remove bogus tests for isolated pages
      mm: rename and move get/set_freepage_migratetype
      mm, compaction: more robust check for scanners meeting
      mm, compaction: simplify handling restart position in free pages scanner
      mm, compaction: encapsulate resetting cached scanner positions
      mm, compaction: always skip all compound pages by order in migrate scanner
      mm, compaction: skip compound pages by order in free scanner
      mm: rename alloc_pages_exact_node() to __alloc_pages_node()
      mm: unify checks in alloc_pages_node() and __alloc_pages_node()
      mm: use numa_mem_id() in alloc_pages_node()

Waiman Long (1):
      proc: change proc_subdir_lock to a rwlock

Wang Kai (1):
      kmemleak: record accurate early log buffer count and report when exceeded

Wanpeng Li (6):
      mm/hwpoison: fix failure to split thp w/ refcount held
      mm/hwpoison: fix PageHWPoison test/set race
      mm/hwpoison: introduce put_hwpoison_page to put refcount for memory error handling
      mm/hwpoison: fix refcount of THP head page in no-injection case
      mm/hwpoison: replace most of put_page in memory error handling by put_hwpoison_page
      mm/hwpoison: fix race between soft_offline_page and unpoison_memory

Wei Yang (4):
      mm/memblock: WARN_ON when nid differs from overlap region
      mm/page_alloc.c: refine the calculation of highest possible node id
      mm/page_alloc.c: remove unused variable in free_area_init_core()
      mm/memblock.c: WARN_ON when flags differs from overlap region

Weijie Yang (1):
      mm: page_isolation: check pfn validity before access

Xishi Qiu (1):
      memory-hotplug: fix comments in zone_spanned_pages_in_node() and zone_spanned_pages_in_node()

Yaowei Bai (2):
      mm/page_alloc.c: fix a misleading comment
      mm/page_alloc.c: change sysctl_lower_zone_reserve_ratio to sysctl_lowmem_reserve_ratio in comments

Yinghai Lu (1):
      mm: check if section present during memory block registering

Yu Zhao (1):
      shmem: recalculate file inode when fstat

Zhen Lei (1):
      mm/page_alloc.c: fix type information of memoryless node

minkyung88.kim (1):
      mm: remove struct node_active_region

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
