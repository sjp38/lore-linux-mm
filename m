Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B11446B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 04:56:30 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w37so13492850wrc.0
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 01:56:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b141si5766809wma.133.2017.02.23.01.56.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Feb 2017 01:56:28 -0800 (PST)
Date: Thu, 23 Feb 2017 10:56:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: mmotm git tree since-4.10 branch created (was: mmotm
 2017-02-22-16-28 uploaded)
Message-ID: <20170223095625.d7sfk22jfra2e7kv@dhcp22.suse.cz>
References: <58ae2cf1.5/S/liO1BdKf+3qG%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58ae2cf1.5/S/liO1BdKf+3qG%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

I have just created since-4.10 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v4.10 tag in Linus tree and mmotm-2017-02-22-16-28.
I have pulled also Tejun's cgroup for-4.11 branch because he has
reorganized the cgroup directory structure and this might cause
pointless conflicts.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The shortlog says:
Adygzhy Ondar (1):
      mm/bootmem.c: cosmetic improvement of code readability

Andrea Arcangeli (19):
      userfaultfd: document _IOR/_IOW
      userfaultfd: correct comment about UFFD_FEATURE_PAGEFAULT_FLAG_WP
      userfaultfd: convert BUG() to WARN_ON_ONCE()
      userfaultfd: use vma_is_anonymous
      userfaultfd: non-cooperative: report all available features to userland
      userfaultfd: non-cooperative: optimize mremap_userfaultfd_complete()
      userfaultfd: non-cooperative: avoid MADV_DONTNEED race condition
      userfaultfd: non-cooperative: wake userfaults after UFFDIO_UNREGISTER
      userfaultfd: hugetlbfs: gup: support VM_FAULT_RETRY
      userfaultfd: hugetlbfs: UFFD_FEATURE_MISSING_HUGETLBFS
      userfaultfd: shmem: add tlbflush.h header for microblaze
      userfaultfd: shmem: lock the page before adding it to pagecache
      userfaultfd: shmem: avoid a lockup resulting from corrupted page->flags
      userfaultfd: shmem: avoid leaking blocks and used blocks in UFFDIO_COPY
      userfaultfd: hugetlbfs: UFFD_FEATURE_MISSING_SHMEM
      userfaultfd: selftest: test UFFDIO_ZEROPAGE on all memory types
      mm: mprotect: use pmd_trans_unstable instead of taking the pmd_lock
      userfaultfd-mcopy_atomic-return-enoent-when-no-compatible-vma-found-fix-2
      userfaultfd-mcopy_atomic-return-enoent-when-no-compatible-vma-found-fix-2-fix-fix

Andrew Morton (6):
      mm-ksm-improve-deduplication-of-zero-pages-with-colouring-fix
      mm/memory_hotplug.c: unexport __remove_pages()
      z3fold-add-kref-refcounting-checkpatch-fixes
      mm-convert-remove_migration_pte-to-use-page_vma_mapped_walk-checkpatch-fixes
      userfaultfd-mcopy_atomic-return-enoent-when-no-compatible-vma-found-fix-2-fix
      mm-autonuma-dont-use-set_pte_at-when-updating-protnone-ptes-fix

Aneesh Kumar K.V (8):
      mm/autonuma: don't use set_pte_at when updating protnone ptes
      mm/autonuma: let architecture override how the write bit should be stashed in a protnone pte.
      mm-autonuma-let-architecture-override-how-the-write-bit-should-be-stashed-in-a-protnone-pte-v3
      mm/ksm: Handle protnone saved writes when making page write protect
      powerpc/mm/autonuma: switch ppc64 to its own implementation of saved write
      powerpc-mm-autonuma-switch-ppc64-to-its-own-implementeation-of-saved-write-v3
      mm/gup: check for protnone only if it is a PTE entry
      mm/thp/autonuma: use TNF flag instead of vm fault

Arnd Bergmann (2):
      fixup! mm, fs: reduce fault, page_mkwrite, and pfn_mkwrite to take only vmf
      userfaultfd-non-cooperative-add-event-for-memory-unmaps-fix-2

Borislav Petkov (1):
      mm/slub: add a dump_stack() to the unexpected GFP check

Claudio Imbrenda (2):
      mm/ksm: improve deduplication of zero pages with colouring
      mm/ksm: documentation for coloured zero pages deduplication

Cong Wang (1):
      9p: fix a potential acl leak

Dan Streetman (3):
      zswap: allow initialization at boot without pool
      zswap: clear compressor or zpool param if invalid at init
      zswap: don't param_set_charp while holding spinlock

Dan Williams (4):
      mm, devm_memremap_pages: hold device_hotplug lock over mem_hotplug_{begin, done}
      mm, devm_memremap_pages: hold device_hotplug lock over mem_hotplug_{begin, done}
      mm: validate device_hotplug is held for memory hotplug
      mm: fix get_user_pages() vs device-dax pud mappings

Daniel Thompson (1):
      tools/vm: add missing Makefile rules

Dave Jiang (9):
      mm, dax: make pmd_fault() and friends be the same as fault()
      mm, dax: change pmd_fault() to take only vmf parameter
      mm, fs: reduce fault, page_mkwrite, and pfn_mkwrite to take only vmf
      mm,fs,dax: change ->pmd_fault to ->huge_fault
      mm, dax: clear PMD or PUD size flags when in fall through path
      mm,x86: native_pud_clear missing on i386 build
      mm,x86: fix SMP x86 32bit build for native_pud_clear()
      dax: support for transparent PUD pages for device DAX
      mm: replace FAULT_FLAG_SIZE with parameter to huge_fault

David Dillow (1):
      scatterlist: don't overflow length field

David Rientjes (6):
      mm, compaction: add vmstats for kcompactd work
      mm, thp: add new defer+madvise defrag option
      mm, page_alloc: warn_alloc nodemask is NULL when cpusets are disabled
      mm, oom: header nodemask is NULL when cpusets are disabled
      mm, oom: header nodemask is NULL when cpusets are disabled fix
      mm, madvise: fail with ENOMEM when splitting vma will hit max_map_count

Davidlohr Bueso (4):
      m32r: use generic current.h
      score: remove asm/current.h
      parisc: use generic current.h
      mm,compaction: serialize waitqueue_active() checks

Denys Vlasenko (1):
      powerpc: do not make the entire heap executable

Eric Ren (2):
      ocfs2/dlmglue: prepare tracking logic to avoid recursive cluster lock
      ocfs2: fix deadlock issue when taking inode lock at vfs entry points

Fabian Frederick (1):
      fs: add i_blocksize()

Gavin Shan (1):
      mm/page_alloc: fix nodes for reclaim in fast path

Geliang Tang (6):
      cgroup: fix a comment typo
      mm/vmalloc.c: use rb_entry_safe
      mm/backing-dev.c: use rb_entry()
      truncate: use i_blocksize()
      nilfs2: use nilfs_btree_node_size()
      nilfs2: use i_blocksize()

Greg Thelen (2):
      kasan: drain quarantine of memcg slab objects
      kasan: add memcg kmem_cache test

Grygorii Maistrenko (1):
      slub: do not merge cache if slub_debug contains a never-merge flag

Hans Ragas (1):
      cgroup: Add missing cgroup-v2 PID controller documentation.

Heiko Carstens (3):
      memblock: let memblock_type_name know about physmem type
      memblock: also dump physmem list within __memblock_dump_all
      memblock: embed memblock type name within struct memblock_type

Huang Ying (1):
      mm/swap: skip readahead only when swap slot cache is enabled

Huang, Ying (3):
      mm/swap: fix kernel message in swap_info_get()
      mm/swap: add cluster lock
      mm/swap: split swap cache into 64MB trunks

Hugh Dickins (2):
      tmpfs: change shmem_mapping() to test shmem_aops
      mm: remove shmem_mapping() shmem_zero_setup() duplicates

Jaewon Kim (1):
      mm: cma: print allocation failure reason and bitmap status

Johannes Weiner (7):
      mm: vmscan: scan dirty pages even in laptop mode
      mm: vmscan: kick flushers when we encounter dirty pages on the LRU
      mm: vmscan: kick flushers when we encounter dirty pages on the LRU fix
      mm: vmscan: remove old flusher wakeup from direct reclaim path
      mm: vmscan: only write dirty pages that the scanner has seen twice
      mm: vmscan: move dirty pages out of the way until they're flushed
      mm: vmscan: move dirty pages out of the way until they're flushed fix

Kani, Toshimitsu (1):
      mm-fix-a-overflow-in-test_pages_in_a_zone-fix

Kirill A. Shutemov (16):
      mm: drop zap_details::ignore_dirty
      mm: drop zap_details::check_swap_entries
      mm: drop unused argument of zap_page_range()
      oom-reaper: use madvise_dontneed() logic to decide if unmap the VMA
      uprobes: split THPs before trying to replace them
      mm: introduce page_vma_mapped_walk()
      mm: fix handling PTE-mapped THPs in page_referenced()
      mm: fix handling PTE-mapped THPs in page_idle_clear_pte_refs()
      mm, rmap: check all VMAs that PTE-mapped THP can be part of
      mm: convert page_mkclean_one() to use page_vma_mapped_walk()
      mm: convert try_to_unmap_one() to use page_vma_mapped_walk()
      mm, ksm: convert write_protect_page() to use page_vma_mapped_walk()
      mm, uprobes: convert __replace_page() to use page_vma_mapped_walk()
      mm: convert page_mapped_in_vma() to use page_vma_mapped_walk()
      mm: drop page_check_address{,_transhuge}
      mm: convert remove_migration_pte() to use page_vma_mapped_walk()

Lucas Stach (3):
      mm: alloc_contig_range: allow to specify GFP mask
      mm: cma_alloc: allow to specify GFP mask
      mm: wire up GFP flag passing in dma_alloc_from_contiguous

Masanari Iida (1):
      mm/page_alloc.c: remove duplicate inclusion of page_ext.h

Matthew Wilcox (1):
      mm, x86: add support for PUD-sized transparent hugepages

Mel Gorman (8):
      mm, page_alloc: split buffered_rmqueue()
      mm, page_alloc: split buffered_rmqueue -fix
      mm, page_alloc: split alloc_pages_nodemask()
      mm, page_alloc: drain per-cpu pages from workqueue context
      mm, page_alloc: only use per-cpu allocator for irq-safe requests
      mm, page_alloc: only use per-cpu allocator for irq-safe requests -fix
      mm, page_alloc: use static global work_struct for draining per-cpu pages
      mm, vmscan: clear PGDAT_WRITEBACK when zone is balanced

Michal Hocko (27):
      mm: throttle show_mem() from warn_alloc()
      mm, trace: extract COMPACTION_STATUS and ZONE_TYPE to a common header
      oom, trace: add oom detection tracepoints
      oom, trace: add compaction retry tracepoint
      mm, vmscan: remove unused mm_vmscan_memcg_isolate
      mm, vmscan: add active list aging tracepoint
      mm, vmscan: show the number of skipped pages in mm_vmscan_lru_isolate
      mm, vmscan: show LRU name in mm_vmscan_lru_isolate tracepoint
      mm, vmscan: extract shrink_page_list reclaim counters into a struct
      mm, vmscan: enhance mm_vmscan_lru_shrink_inactive tracepoint
      mm, vmscan: add mm_vmscan_inactive_list_is_low tracepoint
      trace-vmscan-postprocess: sync with tracepoints updates
      mm, vmscan: do not count freed pages as PGDEACTIVATE
      mm, vmscan: cleanup lru size claculations
      mm, vmscan: consider eligible zones in get_scan_count
      Revert "mm: bail out in shrink_inactive_list()"
      mm, page_alloc: do not report all nodes in show_mem
      mm, page_alloc: warn_alloc print nodemask
      arch, mm: remove arch specific show_mem
      lib/show_mem.c: teach show_mem to work with the given nodemask
      mm: consolidate GFP_NOFAIL checks in the allocator slowpath
      mm, oom: do not enforce OOM killer for __GFP_NOFAIL automatically
      mm: help __GFP_NOFAIL allocations which do not trigger OOM killer
      mm, page_alloc: do not depend on cpu hotplug locks inside the allocator
      userfaultfd-non-cooperative-add-event-for-memory-unmaps-fix
      vmalloc: back off when the current task is killed
      Merge remote-tracking branch 'tj-cgroups/for-4.11' into mmotm-since-4.10

Mike Kravetz (10):
      userfaultfd: hugetlbfs: add copy_huge_page_from_user for hugetlb userfaultfd support
      userfaultfd: hugetlbfs: add hugetlb_mcopy_atomic_pte for userfaultfd support
      userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb for huge page UFFDIO_COPY
      userfaultfd: hugetlbfs: fix __mcopy_atomic_hugetlb retry/error processing
      userfaultfd: hugetlbfs: add userfaultfd hugetlb hook
      userfaultfd: hugetlbfs: allow registration of ranges containing huge pages
      userfaultfd: hugetlbfs: add userfaultfd_hugetlb test
      userfaultfd: hugetlbfs: userfaultfd_huge_must_wait for hugepmd ranges
      userfaultfd: hugetlbfs: reserve count on error in __mcopy_atomic_hugetlb
      userfaultfd: hugetlbfs: add UFFDIO_COPY support for shared mappings

Mike Rapoport (22):
      userfaultfd: non-cooperative: dup_userfaultfd: use mm_count instead of mm_users
      userfaultfd: introduce vma_can_userfault
      userfaultfd: shmem: add shmem_mcopy_atomic_pte for userfaultfd support
      userfaultfd: shmem: introduce vma_is_shmem
      userfaultfd: shmem: use shmem_mcopy_atomic_pte for shared memory
      userfaultfd: shmem: add userfaultfd hook for shared memory faults
      userfaultfd: shmem: allow registration of shared memory ranges
      userfaultfd: shmem: add userfaultfd_shmem test
      userfaultfd: non-cooperative: selftest: introduce userfaultfd_open
      userfaultfd: non-cooperative: selftest: add ufd parameter to copy_page
      userfaultfd: non-cooperative: selftest: add test for FORK, MADVDONTNEED and REMAP events
      userfaultfd: non-cooperative: rename *EVENT_MADVDONTNEED to *EVENT_REMOVE
      userfaultfd: non-cooperative: add madvise() event for MADV_REMOVE request
      userfaultfd: non-cooperative: selftest: enable REMOVE event test for shmem
      mm: call vm_munmap in munmap syscall instead of using open coded version
      userfaultfd: non-cooperative: add event for memory unmaps
      userfaultfd: non-cooperative: add event for exit() notification
      userfaultfd-non-cooperative-add-event-for-exit-notification-fix
      userfaultfd: mcopy_atomic: return -ENOENT when no compatible VMA found
      userfaultfd: mcopy_atomic: update cases returning -ENOENT
      userfaultfd_copy: return -ENOSPC in case mm has gone
      userfaultfd: documentation update

Miles Chen (3):
      dma-debug: add comment for failed to check map error
      mm/memblock.c: remove unnecessary log and clean up
      mm: cleanups for printing phys_addr_t and dma_addr_t

Minchan Kim (3):
      zram: remove waitqueue for IO done
      zram: do not free same element pages in zram_meta_free
      mm: do not access page->mapping directly on page_endio

Nicholas Piggin (2):
      nfs: no PG_private waiters remain, remove waker
      mm: un-export wake_up_page functions

Parav Pandit (4):
      rdmacg: Added rdma cgroup controller
      IB/core: added support to use rdma cgroup controller
      rdmacg: Added documentation for rdmacg
      rdmacg: Fixed uninitialized current resource usage

Paul Burton (1):
      mm: page_alloc: skip over regions of invalid pfns where possible

Pavel Emelyanov (5):
      userfaultfd: non-cooperative: Split the find_userfault() routine
      userfaultfd: non-cooperative: add ability to report non-PF events from uffd descriptor
      userfaultfd: non-cooperative: Add fork() event
      userfaultfd: non-cooperative: add mremap() event
      userfaultfd: non-cooperative: add madvise() event for MADV_DONTNEED request

Prarit Bhargava (1):
      kernel/watchdog.c: do not hardcode CPU 0 as the initial thread

Randy Dunlap (2):
      mm: fix filemap.c kernel-doc warnings
      mm: fix <linux/pagemap.h> stray kernel-doc notation

Ross Zwisler (7):
      tracing: add __print_flags_u64()
      dax: add tracepoint infrastructure, PMD tracing
      dax: update MAINTAINERS entries for FS DAX
      dax: add tracepoints to dax_pmd_load_hole()
      dax: add tracepoints to dax_pmd_insert_mapping()
      ext4: Remove unused function ext4_dax_huge_fault()
      drm: remove unnecessary fault wrappers

Sergey Senozhatsky (1):
      zram: remove obsolete sysfs attrs

Steven Rostedt (1):
      mm/mmzone.c: swap likely to unlikely as code logic is different for next_zones_zonelist()

Steven Rostedt (VMware) (2):
      mm/shmem.c: fix unlikely() test of info->seals to test only for WRITE and GROW
      mm/page-writeback.c: place "not" inside of unlikely() statement in wb_domain_writeout_inc()

Sudip Mukherjee (1):
      m32r: fix build warning

Tejun Heo (34):
      kernfs: make kernfs_open_file->mmapped a bitfield
      kernfs: add kernfs_ops->open/release() callbacks
      cgroup add cftype->open/release() callbacks
      cgroup: reimplement reading "cgroup.procs" on cgroup v2
      cgroup: remove cgroup_pid_fry() and friends
      cgroup: reorder css_set fields
      cgroup: move cgroup files under kernel/cgroup/
      cgroup: move cgroup v1 specific code to kernel/cgroup/cgroup-v1.c
      cgroup: refactor mount path and clearly distinguish v1 and v2 paths
      cgroup: separate out cgroup1_kf_syscall_ops
      cgroup: move v1 mount functions to kernel/cgroup/cgroup-v1.c
      cgroup: rename functions for consistency
      cgroup: move namespace code to kernel/cgroup/namespace.c
      cgroup: fix RCU related sparse warnings
      cgroup: cosmetic update to cgroup_taskset_add()
      cgroup: track migration context in cgroup_mgctx
      cgroup: call subsys->*attach() only for subsystems which are actually affected by migration
      Merge branch 'for-4.10-fixes' into for-4.11
      cgroup: misc cleanups
      cgroup, perf_event: make perf_event controller work on cgroup2 hierarchy
      cgroup: drop the matching uid requirement on migration for cgroup v2
      Merge branch 'cgroup/for-4.11-rdmacg' into cgroup/for-4.11
      kernfs: fix locking around kernfs_ops->release() callback
      Revert "slub: move synchronize_sched out of slab_mutex on shrink"
      slub: separate out sysfs_slab_release() from sysfs_slab_remove()
      slab: remove synchronous rcu_barrier() call in memcg cache release path
      slab: reorganize memcg_cache_params
      slab: link memcg kmem_caches on their associated memory cgroup
      slab: implement slab_root_caches list
      slab: introduce __kmemcg_cache_deactivate()
      slab: remove synchronous synchronize_sched() from memcg cache deactivation path
      slab: remove slub sysfs interface files early for empty memcg caches
      slab: use memcg_kmem_cache_wq for slab destruction operations
      slub: make sysfs directories for memcg sub-caches optional

Tetsuo Handa (1):
      block: use for_each_thread() in sys_ioprio_set()/sys_ioprio_get()

Tim Chen (5):
      mm/swap: skip readahead for unreferenced swap slots
      mm/swap: allocate swap slots in batches
      mm/swap: free swap slots in batch
      mm/swap: add cache for swap slots allocation
      mm/swap: enable swap slots cache usage

Tobin C Harding (2):
      mm/memory.c: use NULL instead of literal 0
      mm: codgin-style fixes

Vegard Nossum (4):
      mm: add new mmgrab() helper
      mm: add new mmget() helper
      mm: use mmget_not_zero() helper
      mm: clarify mm_struct.mm_{users,count} documentation

Vinayak Menon (2):
      mm: vmpressure: fix sending wrong events on underflow
      mm: vmscan: do not pass reclaimed slab to vmpressure

Vitaly Wool (5):
      z3fold: make pages_nr atomic
      z3fold: fix header size related issues
      z3fold: extend compaction function
      z3fold: use per-page spinlock
      z3fold: add kref refcounting

Vlastimil Babka (5):
      mm, slab: rename kmalloc-node cache to kmalloc-<size>
      mm, page_alloc: don't convert pfn to idx when merging
      mm, page_alloc: avoid page_to_pfn() when merging buddies
      mm, page_alloc: remove redundant checks from alloc fastpath
      mm, page_alloc: don't check cpuset allowed twice in fast-path

Wei Yang (4):
      mm/memblock.c: trivial code refine in memblock_is_region_memory()
      mm/memblock.c: check return value of memblock_reserve() in memblock_virt_alloc_internal()
      mm/page_alloc: return 0 in case this node has no page within the zone
      mm/page_alloc.c: remove redundant init code for ZONE_MOVABLE

Xishi Qiu (1):
      mm: fix some typos in mm/zsmalloc.c

Yasuaki Ishimatsu (2):
      mm/sparse: use page_private() to get page->private value
      mm/memory_hotplug: set magic number to page->freelist instead of page->lru.next

Yisheng Xie (7):
      mm/migration: make isolate_movable_page() return int type
      mm/migration: make isolate_movable_page() return int type
      mm/migration: make isolate_movable_page always defined
      HWPOISON: soft offlining for non-lru movable page
      mm/hotplug: enable memory hotplug for non-lru movable pages
      mm/zsmalloc: remove redundant SetPagePrivate2 in create_page_chain
      mm/zsmalloc: fix comment in zsmalloc

seokhoon.yoon (1):
      mm: fix comments for mmap_init()

zhong jiang (4):
      mm/z3fold.c: limit first_num to the actual range of possible buddy indexes
      mm/memory_hotplug.c: fix overflow in test_pages_in_a_zone()
      mm/page_owner: align with pageblock_nr pages
      mm/vmstat.c: walk the zone in pageblock_nr_pages steps

zhouxianrong (1):
      zram: extend zero pages to same element pages


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
