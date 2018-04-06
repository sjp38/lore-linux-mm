Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 679756B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 05:01:40 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f137so460027wme.5
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 02:01:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w199si5784039wmw.196.2018.04.06.02.01.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Apr 2018 02:01:38 -0700 (PDT)
Date: Fri, 6 Apr 2018 11:01:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: mmotm git tree since-4.16 branch created (was: mmotm
 2018-04-05-16-59 uploaded)
Message-ID: <20180406090136.GI8286@dhcp22.suse.cz>
References: <20180406000009.l1ebV%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180406000009.l1ebV%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: broonie@kernel.org, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

I have just created since-4.16 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v2018-04-05-16-59 tag in Linus tree and mmotm-2018-04-05-16-59.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The shortlog says:
AKASHI Takahiro (1):
      kernel/kexec_file.c: add walk_system_ram_res_rev()

Aaron Lu (3):
      mm/free_pcppages_bulk: update pcp->count inside
      mm/free_pcppages_bulk: do not hold lock when picking pages to free
      mm/free_pcppages_bulk: prefetch buddy while not holding lock

Alexey Dobriyan (26):
      mm/slab_common.c: mark kmalloc machinery as __ro_after_init
      slab: fixup calculate_alignment() argument type
      slab: make kmalloc_index() return "unsigned int"
      slab: make kmalloc_size() return "unsigned int"
      slab: make create_kmalloc_cache() work with 32-bit sizes
      slab: make create_boot_cache() work with 32-bit sizes
      slab: make kmem_cache_create() work with 32-bit sizes
      slab: make size_index[] array u8
      slab: make size_index_elem() unsigned int
      slub: make ->remote_node_defrag_ratio unsigned int
      slub: make ->max_attr_size unsigned int
      slub: make ->red_left_pad unsigned int
      slub: make ->reserved unsigned int
      slub: make ->align unsigned int
      slub: make ->inuse unsigned int
      slub: make ->cpu_partial unsigned int
      slub: make ->offset unsigned int
      slub: make ->object_size unsigned int
      slub: make ->size unsigned int
      slab: make kmem_cache_flags accept 32-bit object size
      kasan: make kasan_cache_create() work with 32-bit slab cache sizes
      slab: make usercopy region 32-bit
      slub: make slab_index() return unsigned int
      slub: make struct kmem_cache_order_objects::x unsigned int
      slub: make size_from_object() return unsigned int
      slab: use 32-bit arithmetic in freelist_randomize()

Andi Kleen (1):
      drivers/media/platform/sti/delta/delta-ipc.c: fix read buffer overflow

Andrew Morton (5):
      z3fold-fix-memory-leak-fix
      list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix
      mm-oom-cgroup-aware-oom-killer-fix
      mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix-2-fix
      fs-fsnotify-account-fsnotify-metadata-to-kmemcg-fix

Andrey Konovalov (4):
      kasan, slub: fix handling of kasan_slab_free hook
      kasan-slub-fix-handling-of-kasan_slab_free-hook-v2
      kasan: fix invalid-free test crashing the kernel
      kasan: prevent compiler from optimizing away memset in tests

Andrey Ryabinin (5):
      mm/vmscan: update stale comments
      mm/vmscan: remove redundant current_may_throttle() check
      mm/vmscan: don't change pgdat state on base of a single LRU list state
      mm/vmscan: don't mess with pgdat->flags in memcg reclaim
      mm/kasan: don't vfree() nonexistent vm_area

Andy Shevchenko (1):
      mm: reuse DEFINE_SHOW_ATTRIBUTE() macro

Anshuman Khandual (1):
      mm/migrate: rename migration reason MR_CMA to MR_CONTIG_RANGE

Arnd Bergmann (1):
      mm/hmm: fix header file if/else/endif maze, again

Baoquan He (4):
      mm/sparse.c: add a static variable nr_present_sections
      mm/sparsemem.c: defer the ms->section_mem_map clearing
      mm/sparse.c: add a new parameter 'data_unit_size' for alloc_usemap_and_memmap
      kernel/kexec_file.c: load kernel at top of system RAM if required

Changbin Du (1):
      scripts/faddr2line: show the code context

Chintan Pandya (1):
      mm/slub.c: use jitter-free reference while printing age

Claudio Imbrenda (2):
      mm/ksm: fix interaction with THP
      mm/ksm.c: fix inconsistent accounting of zero pages

Colin Ian King (3):
      mm/ksm.c: make stable_node_dup() static
      mm/swap_state.c: make bool enable_vma_readahead and swap_vma_readahead() static
      mm/swapfile.c: make pointer swap_avail_heads static

Dan Williams (3):
      mm, powerpc: use vma_kernel_pagesize() in vma_mmu_pagesize()
      mm, hugetlbfs: introduce ->pagesize() to vm_operations_struct
      device-dax: implement ->pagesize() for smaps to report MMUPageSize

David Rientjes (6):
      mm, page_alloc: extend kernelcore and movablecore for percent
      mm, page_alloc: move mirrored_kernelcore to __meminitdata
      mm, compaction: drain pcps for zone when kcompactd fails
      mm, page_alloc: wakeup kcompactd even if kswapd cannot free more memory
      mm, oom: remove 3% bonus for CAP_SYS_ADMIN processes
      mm: memcg: remote memcg charging for kmem allocations fix

David Woodhouse (1):
      mm: always print RLIMIT_DATA warning

Dou Liyang (3):
      mm/kmemleak.c: make kmemleak_boot_config() __init
      mm/page_owner.c: make early_page_owner_param() __init
      mm/page_poison.c: make early_page_poison_param() __init

Guenter Roeck (1):
      include/linux/mm.h: provide consistent declaration for num_poisoned_pages

Howard McLauchlan (1):
      mm: make should_failslab always available for fault injection

Huacai Chen (1):
      zboot: fix stack protector in compressed boot phase

Huang Ying (5):
      mm: fix races between address_space dereference and free in page_evicatable
      mm: fix races between swapoff and flush dcache
      mm, swap: fix race between swapoff and some swap operations
      mm, swap: fix race between swapoff and some swap operations
      mm: Fix race between swapoff and mincore

Jan Kara (2):
      fanotify: Avoid lost events due to ENOMEM for unlimited queues
      fsnotify: Let userspace know about lost events due to ENOMEM

Jeff Moyer (1):
      block_invalidatepage(): only release page if the full page was invalidated

Johannes Weiner (1):
      mm: memcg: make sure memory.events is uptodate when waking pollers

Joonsoo Kim (5):
      mm/page_alloc: don't reserve ZONE_HIGHMEM for ZONE_MOVABLE request
      mm/cma: manage the memory of the CMA area by using the ZONE_MOVABLE
      mm/cma: remove ALLOC_CMA
      ARM: CMA: avoid double mapping to the CMA area if CONFIG_HIGHMEM=y
      mm/thp: don't count ZONE_MOVABLE as the target for freepage reserving

Jerome Glisse (13):
      mm/hmm: fix header file if/else/endif maze
      mm/hmm: unregister mmu_notifier when last HMM client quit
      mm/hmm: hmm_pfns_bad() was accessing wrong struct
      mm/hmm: use struct for hmm_vma_fault(), hmm_vma_get_pfns() parameters
      mm/hmm: remove HMM_PFN_READ flag and ignore peculiar architecture
      mm/hmm: use uint64_t for HMM pfn instead of defining hmm_pfn_t to ulong
      mm/hmm: cleanup special vma handling (VM_SPECIAL)
      mm/hmm: do not differentiate between empty entry or missing directory
      mm/hmm: rename HMM_PFN_DEVICE_UNADDRESSABLE to HMM_PFN_DEVICE_PRIVATE
      mm/hmm: move hmm_pfns_clear() closer to where it is used
      mm/hmm: factor out pte and pmd handling to simplify hmm_vma_walk_pmd()
      mm/hmm: change hmm_vma_fault() to allow write fault on page basis
      mm/hmm: use device driver encoding for HMM pfn

Khalid Aziz (1):
      mm, swap: Add infrastructure for saving page metadata on swap

Kirill Tkhai (1):
      mm: make counting of list_lru_one::nr_items lockless

Konstantin Khlebnikov (2):
      mm/page_ref: use atomic_set_release in page_ref_unfreeze
      mm/huge_memory.c: reorder operations in __split_huge_page_tail()

Marc-Andre Lureau (1):
      mm/page_owner: align with pageblock_nr_pages

Mario Leinweber (1):
      mm/gup.c: fix coding style issues.

Mark Rutland (1):
      kernel/fork.c: detect early free of a live mm

Masahiro Yamada (3):
      linux/const.h: prefix include guard of uapi/linux/const.h with _UAPI
      linux/const.h: move UL() macro to include/linux/const.h
      linux/const.h: refactor _BITUL and _BITULL a bit

Matthew Wilcox (8):
      radix tree: use GFP_ZONEMASK bits of gfp_t for flags
      arm64: turn flush_dcache_mmap_lock into a no-op
      unicore32: turn flush_dcache_mmap_lock into a no-op
      export __set_page_dirty
      fscache: use appropriate radix tree accessors
      xarray: add the xa_lock to the radix_tree_root
      page cache: use xa_lock
      btrfs: Use filemap_range_has_page()

Maxim Patlasov (1):
      mm: add strictlimit knob

Mel Gorman (1):
      sched/numa: avoid trapping faults and attempting migration of file-backed dirty pages

Michal Hocko (9):
      include/linux/mmdebug.h: make VM_WARN* non-rvals
      memcg, thp: do not invoke oom killer on thp charges
      oom, memcg: clarify root memcg oom accounting
      mm, numa: rework do_pages_move
      mm, migrate: remove reason argument from new_page_t
      mm: unclutter THP migration
      mm: introduce MAP_FIXED_NOREPLACE
      fs, elf: drop MAP_FIXED usage from elf_map
      elf: enforce MAP_FIXED on overlaying elf segments

Mike Kravetz (5):
      hugetlbfs: fix bug in pgoff overflow checking
      mm: hugetlbfs: move HUGETLBFS_I outside #ifdef CONFIG_HUGETLBFS
      mm: memfd: split out memfd for use by multiple filesystems
      mm: memfd: remove memfd code from shmem files and use new memfd files
      mm/page_isolation.c: make start_isolate_page_range() fail if already isolated

Mike Rapoport (3):
      mm/nommu: remove description of alloc_vm_area
      mm/swap.c: remove @cold parameter description for release_pages()
      mm: kernel-doc: add missing parameter descriptions

Mikulas Patocka (1):
      mm/slab_common.c: remove test if cache name is accessible

Minchan Kim (2):
      mm: swap: clean up swap readahead
      mm: swap: unify cluster-based and vma-based swap readahead

Naoya Horiguchi (1):
      mm: hwpoison: disable memory error handling on 1GB hugepage

Nikolay Borisov (2):
      fs/direct-io.c: minor cleanups in do_blockdev_direct_IO
      fs/dcache.c: add cond_resched() in shrink_dentry_list()

Pavel Tatashin (10):
      mm: disable interrupts while initializing deferred pages
      mm: initialize pages on demand during boot
      mm/memory_hotplug: enforce block size aligned range check
      x86/mm/memory_hotplug: determine block size based on the end of boot memory
      mm: uninitialized struct page poisoning sanity checking
      mm/memory_hotplug: optimize probe routine
      mm/memory_hotplug: don't read nid from struct page during hotplug
      mm/memory_hotplug: optimize memory hotplug
      xen, mm: allow deferred page initialization for xen pv domains
      sparc64: NG4 memset 32 bits overflow

Ralph Campbell (5):
      mm/hmm: documentation editorial update to HMM documentation
      mm/hmm: HMM should have a callback before MM is destroyed
      mm/hmm: do not ignore specific pte fault flag in hmm_vma_fault()
      mm/hmm: clarify fault logic for device private memory
      mm/migrate: properly preserve write attribute in special migrate entry

Randy Dunlap (2):
      mm/swap_slots.c: use conditional compilation
      headers: untangle kmemleak.h from mm.h

Roman Gushchin (15):
      mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES
      mm: treat indirectly reclaimable memory as available in MemAvailable
      dcache: account external names as indirectly reclaimable memory
      dcache: fix indirectly reclaimable memory accounting for CONFIG_SLOB
      dcache: fix indirectly reclaimable memory accounting
      mm: treat indirectly reclaimable memory as free in overcommit logic
      mm, oom: refactor oom_kill_process()
      mm: implement mem_cgroup_scan_tasks() for the root memory cgroup
      mm, oom: cgroup-aware OOM killer
      mm, oom: introduce memory.oom_group
      mm, oom: return error on access to memory.oom_group if groupoom is disabled
      mm, oom: add cgroup v2 mount option for cgroup-aware OOM killer
      mm, oom, docs: describe the cgroup-aware OOM killer
      mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix
      cgroup: list groupoom in cgroup features

Sergey Senozhatsky (2):
      zsmalloc: introduce zs_huge_class_size()
      zram: drop max_zpage_size and use zs_huge_class_size()

Shakeel Butt (4):
      slab, slub: remove size disparity on debug kernel
      slab, slub: skip unnecessary kasan_cache_shutdown()
      mm: memcg: remote memcg charging for kmem allocations
      fs: fsnotify: account fsnotify metadata to kmemcg

Souptick Joarder (1):
      mm: change return type to vm_fault_t

Stefan Agner (1):
      mm/memblock.c: cast constant ULLONG_MAX to phys_addr_t

Steven Rostedt (1):
      mm, vmscan, tracing: use pointer to reclaim_stat struct in trace event

Tejun Heo (1):
      mm/hmm.c: remove superfluous RCU protection around radix tree lookup

Tetsuo Handa (3):
      mm,vmscan: don't pretend forward progress upon shrinker_rwsem contention
      mm,oom_reaper: check for MMF_OOM_SKIP before complaining
      mm,vmscan: mark register_shrinker() as __must_check

Valentin Vidic (1):
      include/linux/kfifo.h: fix comment

Vitaly Wool (1):
      z3fold: limit use of stale list for allocation

Waiman Long (1):
      mm/list_lru.c: prefetch neighboring list entries before acquiring lock

Wei Yang (1):
      mm: check __highest_present_section_nr directly in memory_dev_init()

Xidong Wang (1):
      z3fold: fix memory leak

Yang Shi (1):
      mm: thp: fix potential clearing to referenced flag in page_idle_clear_pte_refs_one()

Yu Zhao (1):
      mm: don't expose page to fast gup before it's ready

Yury Norov (1):
      lib: fix stall in __bitmap_parselist()

shunki-fujita (1):
      fs: don't flush pagecache when expanding block device

zhong jiang (1):
      mm/page_owner: align with pageblock_nr pages
-- 
Michal Hocko
SUSE Labs
