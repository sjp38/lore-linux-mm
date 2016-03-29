Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4E26B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 08:01:20 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id 4so12753424pfd.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 05:01:20 -0700 (PDT)
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com. [209.85.192.171])
        by mx.google.com with ESMTPS id v67si10417423pfa.181.2016.03.29.05.01.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 05:01:18 -0700 (PDT)
Received: by mail-pf0-f171.google.com with SMTP id 4so12752864pfd.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 05:01:18 -0700 (PDT)
Date: Tue, 29 Mar 2016 14:01:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: mmotm git tree since-4.5 branch created (was: mmotm 2016-03-25-15-13
 uploaded)
Message-ID: <20160329120115.GC4466@dhcp22.suse.cz>
References: <56f5b830.Yvs8wbhgxQwqXiSe%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <56f5b830.Yvs8wbhgxQwqXiSe%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

I have just created since-4.5 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v4.5 tag in Linus tree and mmotm-2016-03-25-15-13.
I have pulled cgroup changes and pkeys patches merged via tip tree.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The shortlog says:
Aaro Koskinen (1):
      drivers/firmware/broadcom/bcm47xx_nvram.c: fix incorrect __ioread32_copy

Alexander Kuleshov (1):
      mm/memblock.c: remove unnecessary memblock_type variable

Alexander Potapenko (8):
      kasan: modify kmalloc_large_oob_right(), add kmalloc_pagealloc_oob_right()
      mm, kasan: SLAB support
      mm, kasan: add GFP flags to KASAN API
      arch, ftrace: for KASAN put hard/soft IRQ entries into separate sections
      mm, kasan: stackdepot implementation. Enable stackdepot for SLAB
      kasan: test fix: warn if the UAF could not be detected in kmalloc_uaf2
      mm: kasan: initial memory quarantine implementation
      mm: kasan: Initial memory quarantine implementation

Andrea Arcangeli (2):
      ksm: introduce ksm_max_page_sharing per page deduplication limit
      ksm: validate STABLE_NODE_DUP_HEAD conditional to gcc version

Andreas Ziegler (1):
      mm: fix two typos in comments for to_vmem_altmap()

Andrew Morton (8):
      fs/mpage.c:mpage_readpages(): use lru_to_page() helper
      mm/page_alloc.c: rework code layout in memmap_init_zone()
      sched: add schedule_timeout_idle()
      include-linux-apply-__malloc-attribute-checkpatch-fixes
      include/linux/nodemask.h: create next_node_in() helper
      ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit-fix-2
      mm-oom-rework-oom-detection-checkpatch-fixes
      mm-use-watermak-checks-for-__gfp_repeat-high-order-allocations-checkpatch-fixes

Andrey Ryabinin (4):
      mm/page-writeback: fix dirty_ratelimit calculation
      mm: move max_map_count bits into mm.h
      mm: deduplicate memory overcommitment code
      MAINTAINERS: fill entries for KASAN

Aneesh Kumar K.V (1):
      mm/thp/migration: switch from flush_tlb_range to flush_pmd_tlb_range

Ard Biesheuvel (3):
      x86: kallsyms: disable absolute percpu symbols on !SMP
      kallsyms: don't overload absolute symbol type for percpu symbols
      kallsyms: add support for relative offsets in kallsyms address table

Arnd Bergmann (1):
      cgroup: avoid false positive gcc-6 warning

Borislav Petkov (2):
      x86/cpufeature: Add AMD AVIC bit
      x86/cpufeature: Carve out X86_FEATURE_*

Brian Starkey (2):
      memremap: don't modify flags
      memremap: add MEMREMAP_WC flag

Chen Yucong (1):
      mm, memory hotplug: print debug message in the proper way for online_pages

Christian Borntraeger (4):
      mm/debug_pagealloc: ask users for default setting of debug_pagealloc
      x86: query dynamic DEBUG_PAGEALLOC setting
      s390: query dynamic DEBUG_PAGEALLOC setting
      x86: also use debug_pagealloc_enabled() for free_init_pages

Dan Williams (2):
      mm: exclude ZONE_DEVICE from GFP_ZONE_TABLE
      mm: ZONE_DEVICE depends on SPARSEMEM_VMEMMAP

Dave Hansen (38):
      mm/gup: Introduce get_user_pages_remote()
      mm/gup: Overload get_user_pages() functions
      mm/gup: Switch all callers of get_user_pages() to not pass tsk/mm
      x86/fpu: Add placeholder for 'Processor Trace' XSAVE state
      x86/mm/pkeys: Add Kconfig option
      x86/cpufeature, x86/mm/pkeys: Add protection keys related CPUID definitions
      x86/cpu, x86/mm/pkeys: Define new CR4 bit
      x86/fpu, x86/mm/pkeys: Add PKRU xsave fields and data structures
      x86/mm/pkeys: Add PTE bits for storing protection key
      x86/mm/pkeys: Add new 'PF_PK' page fault error code bit
      mm/core, x86/mm/pkeys: Store protection bits in high VMA flags
      x86/mm/pkeys: Add arch-specific VMA protection bits
      x86/mm/pkeys: Pass VMA down in to fault signal generation code
      signals, ia64, mips: Update arch-specific siginfos with pkeys field
      signals, pkeys: Notify userspace about protection key faults
      x86/mm/pkeys: Fill in pkey field in siginfo
      x86/mm/pkeys: Add functions to fetch PKRU
      mm/gup: Factor out VMA fault permission checking
      x86/mm/gup: Simplify get_user_pages() PTE bit handling
      mm/gup, x86/mm/pkeys: Check VMAs and PTEs for protection keys
      um, pkeys: Add UML arch_*_access_permitted() methods
      mm/core: Do not enforce PKEY permissions on remote mm access
      x86/mm/pkeys: Optimize fault handling in access_error()
      mm/core, x86/mm/pkeys: Differentiate instruction fetches
      x86/mm/pkeys: Dump PKRU with other kernel registers
      x86/mm/pkeys: Dump pkey from VMA in /proc/pid/smaps
      x86/mm/pkeys: Add Kconfig prompt to existing config option
      x86/mm/pkeys: Actually enable Memory Protection Keys in the CPU
      mm/core, arch, powerpc: Pass a protection key in to calc_vm_flag_bits()
      mm/core, x86/mm/pkeys: Add arch_validate_pkey()
      x86/mm: Factor out LDT init from context init
      x86/fpu: Allow setting of XSAVE state
      x86/mm/pkeys: Allow kernel to modify user pkey rights register
      x86/mm/pkeys: Create an x86 arch_calc_vm_prot_bits() for VMA flags
      mm/core, x86/mm/pkeys: Add execute-only protection keys support
      x86/mm/pkeys: Fix access_error() denial of writes to write-only VMA
      mm/pkeys: Fix siginfo ABI breakage caused by new u64 field
      x86/mm/pkeys: Fix mismerge of protection keys CPUID bits

David Rientjes (1):
      mm, mempool: only set __GFP_NOMEMALLOC if there are free elements

Davidlohr Bueso (1):
      ipc/sem: make semctl setting sempid consistent

Denys Vlasenko (5):
      bufferhead: force inlining of buffer head flag operations
      include/linux/page-flags.h: force inlining of selected page flag modifications
      include/asm-generic/atomic-long.h: force inlining of some atomic_long operations
      include/uapi/linux/byteorder, swab: force inlining of some byteswap operations
      include/linux/unaligned: force inlining of byteswap operations

Ebru Akagunduz (2):
      mm: make optimistic check for swapin readahead
      mm: make swapin readahead to improve thp collapse rate

Eric Biggers (1):
      cpumask: remove incorrect information from comment

Haosdent Huang (1):
      cgroup: remove stale item in cgroup-v1 document INDEX file.

Igor Redko (2):
      mm/page_alloc.c: calculate 'available' memory in a separate function
      virtio_balloon: export 'available' memory to balloon statistics

Jan Kara (1):
      mm: remove VM_FAULT_MINOR

Jesper Dangaard Brouer (11):
      slub: clean up code for kmem cgroup support to kmem_cache_free_bulk
      mm/slab: move SLUB alloc hooks to common mm/slab.h
      mm: fault-inject take over bootstrap kmem_cache check
      slab: use slab_pre_alloc_hook in SLAB allocator shared with SLUB
      mm: kmemcheck skip object if slab allocation failed
      slab: use slab_post_alloc_hook in SLAB allocator shared with SLUB
      slab: implement bulk alloc in SLAB allocator
      slab: avoid running debug SLAB code with IRQs disabled for alloc_bulk
      slab: implement bulk free in SLAB allocator
      mm: new API kfree_bulk() for SLAB+SLUB allocators
      mm: fix some spelling

Joe Perches (4):
      mm: convert pr_warning to pr_warn
      mm: coalesce split strings
      mm: convert printk(KERN_<LEVEL> to pr_<level>
      mm: percpu: use pr_fmt to prefix output

Johannes Weiner (17):
      cgroup: provide cgroup_nov1= to disable controllers in v1 mounts
      cgroup: document cgroup_no_v1=
      mm: memcontrol: generalize locking for the page->mem_cgroup binding
      mm: workingset: #define radix entry eviction mask
      mm: workingset: separate shadow unpacking and refault calculation
      mm: workingset: eviction buckets for bigmem/lowbit machines
      mm: workingset: per-cgroup cache thrash detection
      mm: migrate: do not touch page->mem_cgroup of live pages
      mm: simplify lock_page_memcg()
      mm: remove unnecessary uses of lock_page_memcg()
      mm: migrate: consolidate mem_cgroup_migrate() calls
      mm: memcontrol: drop unnecessary lru locking from mem_cgroup_migrate()
      mm: oom_kill: don't ignore oom score on exiting tasks
      mm: scale kswapd watermarks in proportion to memory
      mm: memcontrol: reclaim when shrinking memory.high below usage
      mm: memcontrol: reclaim and OOM kill when shrinking memory.max below usage
      mm: memcontrol: clarify the uncharge_list() loop

Joonsoo Kim (29):
      mm/slab: fix stale code comment
      mm/slab: remove useless structure define
      mm/slab: remove the checks for slab implementation bug
      mm/slab: activate debug_pagealloc in SLAB when it is actually enabled
      mm/slab: use more appropriate condition check for debug_pagealloc
      mm/slab: clean up DEBUG_PAGEALLOC processing code
      mm/slab: alternative implementation for DEBUG_SLAB_LEAK
      mm/slab: remove object status buffer for DEBUG_SLAB_LEAK
      mm/slab: put the freelist at the end of slab page
      mm/slab: align cache size first before determination of OFF_SLAB candidate
      mm/slab: clean up cache type determination
      mm/slab: do not change cache size if debug pagealloc isn't possible
      mm/slab: make criteria for off slab determination robust and simple
      mm/slab: factor out slab list fixup code
      mm/slab: factor out debugging initialization in cache_init_objs()
      mm/slab: introduce new slab management type, OBJFREELIST_SLAB
      mm/slab: avoid returning values by reference
      mm/slab: re-implement pfmemalloc support
      mm/slub: support left redzone
      mm/compaction: fix invalid free_pfn and compact_cached_free_pfn
      mm/compaction: pass only pageblock aligned range to pageblock_pfn_to_page
      mm/compaction: speed up pageblock_pfn_to_page() when zone is contiguous
      mm/vmalloc: query dynamic DEBUG_PAGEALLOC setting
      mm/slub: query dynamic DEBUG_PAGEALLOC setting
      sound: query dynamic DEBUG_PAGEALLOC setting
      powerpc: query dynamic DEBUG_PAGEALLOC setting
      tile: query dynamic DEBUG_PAGEALLOC setting
      mm: introduce page reference manipulation functions
      mm/page_ref: add tracepoint to track down page reference manipulation

Kirill A. Shutemov (13):
      thp: cleanup split_huge_page()
      thp, vmstats: count deferred split events
      mm, tracing: refresh __def_vmaflag_names
      mm: cleanup *pte_alloc* interfaces
      rmap: introduce rmap_walk_locked()
      rmap: extend try_to_unmap() to be usable by split_huge_page()
      mm: make remove_migration_ptes() beyond mm/migration.c
      thp: rewrite freeze_page()/unfreeze_page() with generic rmap walkers
      thp: fix deadlock in split_huge_pmd()
      thp: fix typo in khugepaged_scan_pmd()
      mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix
      khugepaged: __collapse_huge_page_swapin(): drop unused 'pte' parameter
      thp: do not hold anon_vma lock during swap in

Konstantin Khlebnikov (3):
      tools/vm/page-types.c: add memory cgroup dumping and filtering
      radix-tree tests: add regression3 test
      radix-tree tests: add test for radix_tree_iter_next

Laura Abbott (6):
      slub: drop lock at the end of free_debug_processing
      slub: fix/clean free_debug_processing return paths
      slub: convert SLAB_DEBUG_FREE to SLAB_CONSISTENCY_CHECKS
      slub: relax CMPXCHG consistency restrictions
      mm/page_poison.c: enable PAGE_POISONING as a separate option
      mm/page_poisoning.c: allow for zero poisoning

Li Bin (1):
      kernel/Makefile: remove the useless CFLAGS_REMOVE_cgroup-debug.o

Li Zhang (2):
      mm: meminit: initialise more memory for inode/dentry hash tables in early boot
      powerpc/mm: enable page parallel initialisation

Liang Chen (1):
      mm/mempolicy.c: skip VM_HUGETLB and VM_MIXEDMAP VMA for lazy mbind

Luis R. Rodriguez (1):
      ia64: define ioremap_uc()

Matthew Wilcox (10):
      mm: use linear_page_index() in do_fault()
      radix-tree: add an explicit include of bitops.h
      radix tree test harness
      radix_tree: tag all internal tree nodes as indirect pointers
      radix_tree: loop based on shift count, not height
      radix_tree: add support for multi-order entries
      radix_tree: add radix_tree_dump
      btrfs: use radix_tree_iter_retry()
      mm: use radix_tree_iter_retry()
      radix-tree,shmem: introduce radix_tree_iter_next()

Mel Gorman (3):
      mm: filemap: remove redundant code in do_read_cache_page
      mm: filemap: avoid unnecessary calls to lock_page when waiting for IO to complete during a read
      mm: thp: set THP defrag by default to madvise and add a stall-free defrag option

Michal Hocko (12):
      Merge remote-tracking branch 'tj-cgroups/for-4.6' into mmotm-since-4.5-cgroups
      mm, vmscan: make zone_reclaimable_pages more precise
      mm: remove __GFP_NOFAIL is deprecated comment
      mm, oom: introduce oom reaper
      oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space
      mm, oom_reaper: report success/failure
      mm, oom_reaper: implement OOM victims queuing
      oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task
      oom: make oom_reaper freezable
      mm, oom: rework oom detection
      mm: throttle on IO only when there are too many dirty and writeback pages
      mm: use watermark checks for __GFP_REPEAT high order allocations

Mika Penttila (1):
      mm/memory.c: make apply_to_page_range() more robust

Minchan Kim (1):
      zram: revive swap_slot_free_notify

Naoya Horiguchi (6):
      mm/madvise: pass return code of memory_failure() to userspace
      mm/madvise: update comment on sys_madvise()
      /proc/kpageflags: return KPF_BUDDY for "tail" buddy pages
      /proc/kpageflags: return KPF_SLAB for slab tail pages
      tools/vm/page-types.c: support swap entry
      tools/vm/page-types.c: avoid memset() in walk_pfn() when count == 1

Nicolai Stange (1):
      mm/filemap: generic_file_read_iter(): check for zero reads unconditionally

Parav Pandit (2):
      cgroup: Trivial correction to reflect controller.
      Documentation: cgroup v2: Trivial heading correction.

Piotr Kwapulinski (1):
      mm/mprotect.c: don't imply PROT_EXEC on non-exec fs

Rasmus Villemoes (2):
      compiler.h: add support for malloc attribute
      include/linux: apply __malloc attribute

Satoru Takeuchi (1):
      mm: remove unnecessary description about a non-exist gfp flag

Sergey Senozhatsky (1):
      mm/zsmalloc: add `freeable' column to pool stat

Shawn Lin (1):
      mm/vmalloc: use PAGE_ALIGNED() to check PAGE_SIZE alignment

Sudip Mukherjee (1):
      blackfin: define dummy pgprot_writecombine for !MMU

Taku Izumi (2):
      mm/page_alloc.c: calculate zone_start_pfn at zone_spanned_pages_in_node()
      mm/page_alloc.c: introduce kernelcore=mirror option

Tejun Heo (35):
      cgroup: fix error return value of cgroup_addrm_files()
      Revert "cgroup: add cgroup_subsys->css_e_css_changed()"
      cgroup: s/child_subsys_mask/subtree_ss_mask/
      cgroup: convert for_each_subsys_which() to do-while style
      cgroup: use do_each_subsys_mask() where applicable
      cgroup: make cgroup subsystem masks u16
      cgroup: s/cgrp_dfl_root_/cgrp_dfl_/
      cgroup: convert cgroup_subsys flag fields to bool bitfields
      cgroup: make css_tryget_online_from_dir() also recognize cgroup2 fs
      cgroup: use ->subtree_control when testing no internal process rule
      cgroup: re-hash init_css_set after subsystems are initialized
      cgroup: suppress spurious de-populated events
      cgroup: separate out interface file creation from css creation
      cgroup: explicitly track whether a cgroup_subsys_state is visible to userland
      cgroup: reorder operations in cgroup_mkdir()
      cgroup: factor out cgroup_create() out of cgroup_mkdir()
      cgroup: introduce cgroup_control() and cgroup_ss_mask()
      cgroup: factor out cgroup_drain_offline() from cgroup_subtree_control_write()
      cgroup: factor out cgroup_apply_control_disable() from cgroup_subtree_control_write()
      cgroup: factor out cgroup_apply_control_enable() from cgroup_subtree_control_write()
      cgroup: make cgroup_drain_offline() and cgroup_apply_control_{disable|enable}() recursive
      cgroup: introduce cgroup_{save|propagate|restore}_control()
      cgroup: factor out cgroup_{apply|finalize}_control() from cgroup_subtree_control_write()
      cgroup: combine cgroup_mutex locking and offline css draining
      cgroup: use cgroup_apply_enable_control() in cgroup creation path
      cgroup: reimplement rebind_subsystems() using cgroup_apply_control() and friends
      cgroup: make cgroup_calc_subtree_ss_mask() take @this_ss_mask
      cgroup: allocate 2x cgrp_cset_links when setting up a new root
      cgroup: update css iteration in cgroup_update_dfl_csses()
      cgroup: fix incorrect destination cgroup in cgroup_update_dfl_csses()
      cgroup: move migration destination verification out of cgroup_migrate_prepare_dst()
      cgroup: make cgroup[_taskset]_migrate() take cgroup_root instead of cgroup
      cgroup: use css_set->mg_dst_cgrp for the migration target cgroup
      cgroup: implement cgroup_subsys->implicit_on_dfl
      cgroup: ignore css_sets associated with dead cgroups during migration

Tetsuo Handa (4):
      mm,oom: make oom_killer_disable() killable
      mm,oom: do not loop !__GFP_FS allocation if the OOM killer is disabled
      oom, oom_reaper: protect oom_reaper_list using simpler way
      include/linux/oom.h: remove undefined oom_kills_count()/note_oom_kill()

Vineet Gupta (1):
      ARC, thp: remove infrastructure for handling splitting PMDs

Vitaly Kuznetsov (2):
      memory-hotplug: add automatic onlining policy for the newly added memory
      xen_balloon: support memory auto onlining policy

Vladimir Davydov (16):
      cgroup: reset css on destruction
      mm: vmscan: do not clear SHRINKER_NUMA_AWARE if nr_node_ids == 1
      mm: memcontrol: do not bypass slab charge if memcg is offline
      mm: memcontrol: make tree_{stat,events} fetch all stats
      mm: memcontrol: report slab usage in cgroup2 memory.stat
      mm: memcontrol: report kernel stack usage in cgroup2 memory.stat
      mm: memcontrol: enable kmem accounting for all cgroups in the legacy hierarchy
      mm: vmscan: pass root_mem_cgroup instead of NULL to memcg aware shrinker
      mm: memcontrol: zap memcg_kmem_online helper
      radix-tree: account radix_tree_node to memory cgroup
      mm: workingset: size shadow nodes lru basing on file cache size
      mm: workingset: make shadow node shrinker memcg aware
      mm: memcontrol: cleanup css_reset callback
      mm: memcontrol: zap oom_info_lock
      oom: make oom_reaper_list single linked
      mm/khugepaged: fix scan not aborted on SCAN_EXCEED_SWAP_PTE

Vlastimil Babka (20):
      tracepoints: move trace_print_flags definitions to tracepoint-defs.h
      mm, tracing: make show_gfp_flags() up to date
      tools, perf: make gfp_compact_table up to date
      mm, tracing: unify mm flags handling in tracepoints and printk
      mm, printk: introduce new format string for flags
      mm, debug: replace dump_flags() with the new printk formats
      mm, page_alloc: print symbolic gfp_flags on allocation failure
      mm, oom: print symbolic gfp_flags in oom warning
      mm, page_owner: print migratetype of page and pageblock, symbolic flags
      mm, page_owner: convert page_owner_inited to static key
      mm, page_owner: copy page owner info during migration
      mm, page_owner: track and print last migrate reason
      mm, page_owner: dump page owner info from dump_page()
      mm, debug: move bad flags printing to bad_page()
      mm, sl[au]b: print gfp_flags as strings in slab_out_of_memory()
      mm, kswapd: remove bogus check of balance_classzone_idx
      mm, compaction: introduce kcompactd
      mm, memory hotplug: small cleanup in online_pages()
      mm, kswapd: replace kswapd compaction with waking up kcompactd
      mm/page_alloc: prevent merging between isolated and other pageblocks

Wang Xiaoqiang (1):
      mm/memory-failure.c: remove useless "undef"s

Xishi Qiu (1):
      mm: fix invalid node in alloc_migrate_target()

Xiubo Li (1):
      cgroup: fix a mistake in warning message

Yang Shi (1):
      mm/Kconfig: remove redundant arch depend for memory hotplug

YiPing Xu (1):
      zsmalloc: drop unused member 'mapping_area->huge'

nimisolo (1):
      mm/memblock.c:memblock_add_range(): if nr_new is 0 just return

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
