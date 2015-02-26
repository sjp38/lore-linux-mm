Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id EEB466B006C
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 08:20:13 -0500 (EST)
Received: by wevm14 with SMTP id m14so10603273wev.8
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 05:20:13 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x13si3347811wib.7.2015.02.26.05.20.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Feb 2015 05:20:09 -0800 (PST)
Date: Thu, 26 Feb 2015 14:20:06 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: since-3.19 branch opened for mm git tree (was: Re: mmotm
 2015-02-25-21-19 uploaded)
Message-ID: <20150226132006.GA14878@dhcp22.suse.cz>
References: <54eeaceb.gWfyhW4BeYkMh+Bz%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54eeaceb.gWfyhW4BeYkMh+Bz%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au

I have just created since-3.19 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v3.19 tag in Linus tree and mmotm-2015-02-25-21-19.

I have pulled some cgroup wide changes from Tejun.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The current shortlog says:
Alexander Kuleshov (1):
      fs: proc: use PDE() to get proc_dir_entry

Andrea Arcangeli (6):
      mm: gup: add get_user_pages_locked and get_user_pages_unlocked
      mm: gup: add __get_user_pages_unlocked to customize gup_flags
      mm: gup: use get_user_pages_unlocked within get_user_pages_fast
      mm: gup: use get_user_pages_unlocked
      mm: gup: kvm use get_user_pages_unlocked
      mm: incorporate zero pages into transparent huge pages fix

Andrew Morton (9):
      mm/vmstat.c: fix/cleanup ifdefs
      mm/page_alloc.c:__alloc_pages_nodemask(): don't alter arg gfp_mask
      mm-cma-release-trigger-checkpatch-fixes
      mm-cma-allocation-trigger-fix
      mm-compaction-enhance-compaction-finish-condition-fix
      page_writeback-cleanup-mess-around-cancel_dirty_page-checkpatch-fixes
      mm-hide-per-cpu-lists-in-output-of-show_mem-fix
      x86-add-pmd_-for-thp-fix
      sparc-add-pmd_-for-thp-fix

Andrey Ryabinin (2):
      mm, hugetlb: remove unnecessary lower bound on sysctl handlers"?
      mm: hugetlb: fix type of hugetlb_treat_as_movable variable

Andrey Skvortsov (1):
      gitignore: ignore tar-install build directory

Andy Lutomirski (1):
      all arches, signal: move restart_block to struct task_struct

Andy Shevchenko (1):
      fs/proc/array.c: convert to use string_escape_str()

Aneesh Kumar K.V (1):
      mm/thp: allocate transparent hugepages on local node

Baoquan He (2):
      mm: fix typo of MIGRATE_RESERVE in comment
      mm/memblock.c: rename local variable of memblock_type to `type'

Christoph Hellwig (1):
      fs: export inode_to_bdi and use it in favor of mapping->backing_dev_info

Christoph Lameter (1):
      vmstat: Reduce time interval to stat update on idle cpu

Cyril Bur (2):
      kernel/sched/clock.c: add another clock for use with the soft lockup watchdog
      powerpc: add running_clock for powerpc to prevent spurious softlockup warnings

Cyrill Gorcunov (1):
      Documentation/filesystems/proc.txt: describe /proc/<pid>/map_files

David Rientjes (1):
      mm, hotplug: fix concurrent memory hot-add deadlock

Ebru Akagunduz (2):
      mm: incorporate read-only pages into transparent huge pages
      mm: incorporate zero pages into transparent huge pages

Ganesh Mahendran (3):
      zram: free meta table in zram_meta_free
      mm/zpool: add name argument to create zpool
      mm/zsmalloc: add statistics support

Geert Uytterhoeven (1):
      linux/types.h: Always use unsigned long for pgoff_t

George G. Davis (1):
      mm: cma: fix totalcma_pages to include DT defined CMA regions

Grazvydas Ignotas (1):
      mm/memory.c: actually remap enough memory

Greg Thelen (1):
      memcg: add BUILD_BUG_ON() for string tables

Henrik Austad (1):
      Update of Documentation/cgroups/00-INDEX

Hugh Dickins (1):
      mm: fix negative nr_isolated counts

James Custer (1):
      mm: fix invalid use of pfn_valid_within in test_pages_in_a_zone

Joe Perches (1):
      printk: correct timeout comment, neaten MODULE_PARM_DESC

Johannes Weiner (12):
      mm: memory: remove ->vm_file check on shared writable vmas
      mm: memory: merge shared-writable dirtying branches in do_wp_page()
      mm: memcontrol: track move_lock state internally
      mm: page_counter: pull "-1" handling out of page_counter_memparse()
      mm: memcontrol: default hierarchy interface for memory
      mm: memcontrol: fold move_anon() and move_file()
      mm: memcontrol: simplify soft limit tree init code
      mm: memcontrol: consolidate memory controller initialization
      mm: memcontrol: consolidate swap controller code
      mm: memcontrol: use "max" instead of "infinity" in control knobs
      mm: page_alloc: revert inadvertent !__GFP_FS retry behavior change
      mm: memcontrol: update copyright notice

Joonsoo Kim (14):
      mm/slub: optimize alloc/free fastpath by removing preemption on/off
      mm: don't use compound_head() in virt_to_head_page()
      mm/compaction: change tracepoint format from decimal to hexadecimal
      mm/compaction: enhance tracepoint output for compaction begin/end
      mm/compaction: print current range where compaction work
      mm/compaction: more trace to understand when/why compaction start/finish
      mm/compaction: add tracepoint to observe behaviour of compaction defer
      mm/compaction: fix wrong order check in compact_finished()
      mm/compaction: stop the isolation when we isolate enough freepage
      mm/nommu: fix memory leak
      zram: use proper type to update max_used_pages
      mm/cma: change fallback behaviour for CMA freepage
      mm/page_alloc: factor out fallback freepage checking
      mm/compaction: enhance compaction finish condition

Juergen Gross (1):
      mm: use correct format specifiers when printing address ranges

Kim Phillips (1):
      mm/slub.c: fix typo in comment

Kirill A. Shutemov (74):
      hugetlb, x86: register 1G page size if we can allocate them at runtime
      mm: replace remap_file_pages() syscall with emulation
      mm: drop support of non-linear mapping from unmap/zap codepath
      mm: drop support of non-linear mapping from fault codepath
      mm: drop vm_ops->remap_pages and generic_file_remap_pages() stub
      proc: drop handling non-linear mappings
      rmap: drop support of non-linear mappings
      mm: replace vma->sharead.linear with vma->shared
      mm: remove rest usage of VM_NONLINEAR and pte_file()
      asm-generic: drop unused pte_file* helpers
      alpha: drop _PAGE_FILE and pte_file()-related helpers
      arc: drop _PAGE_FILE and pte_file()-related helpers
      arm64: drop PTE_FILE and pte_file()-related helpers
      arm: drop L_PTE_FILE and pte_file()-related helpers
      avr32: drop _PAGE_FILE and pte_file()-related helpers
      blackfin: drop pte_file()
      c6x: drop pte_file()
      cris: drop _PAGE_FILE and pte_file()-related helpers
      frv: drop _PAGE_FILE and pte_file()-related helpers
      hexagon: drop _PAGE_FILE and pte_file()-related helpers
      ia64: drop _PAGE_FILE and pte_file()-related helpers
      m32r: drop _PAGE_FILE and pte_file()-related helpers
      m68k: drop _PAGE_FILE and pte_file()-related helpers
      metag: drop _PAGE_FILE and pte_file()-related helpers
      microblaze: drop _PAGE_FILE and pte_file()-related helpers
      mips: drop _PAGE_FILE and pte_file()-related helpers
      mn10300: drop _PAGE_FILE and pte_file()-related helpers
      nios2: drop _PAGE_FILE and pte_file()-related helpers
      openrisc: drop _PAGE_FILE and pte_file()-related helpers
      parisc: drop _PAGE_FILE and pte_file()-related helpers
      s390: drop pte_file()-related helpers
      score: drop _PAGE_FILE and pte_file()-related helpers
      sh: drop _PAGE_FILE and pte_file()-related helpers
      sparc: drop pte_file()-related helpers
      tile: drop pte_file()-related helpers
      um: drop _PAGE_FILE and pte_file()-related helpers
      unicore32: drop pte_file()-related helpers
      x86: drop _PAGE_FILE and pte_file()-related helpers
      xtensa: drop _PAGE_FILE and pte_file()-related helpers
      mm: add fields for compound destructor and order into struct page
      sparc32: fix broken set_pte()
      mm/page_alloc.c: drop dead destroy_compound_page()
      mm: more checks on free_pages_prepare() for tail pages
      microblaze: define __PAGETABLE_PMD_FOLDED
      mm: make FIRST_USER_ADDRESS unsigned long on all archs
      mm, asm-generic: define PUD_SHIFT in <asm-generic/4level-fixup.h>
      arm: define __PAGETABLE_PMD_FOLDED for !LPAE
      mm: account pmd page tables to the process
      mm: fix false-positive warning on exit due mm_nr_pmds(mm)
      mm: /proc/pid/clear_refs: avoid split_huge_page()
      mm: do not use mm->nr_pmds on !MMU configurations
      mm: rename FOLL_MLOCK to FOLL_POPULATE
      mm: rename __mlock_vma_pages_range() to populate_vma_page_range()
      mm: move gup() -> posix mlock() error conversion out of __mm_populate
      mm: move mm_populate()-related code to mm/gup.c
      alpha: expose number of page table levels on Kconfig level
      arm64: expose number of page table levels on Kconfig level
      arm: expose number of page table levels on Kconfig level
      frv: mark PUD and PMD folded
      ia64: expose number of page table levels on Kconfig level
      m32r: mark PMD folded
      m68k: mark PMD folded and expose number of page table levels
      mips: expose number of page table levels on Kconfig level
      mn10300: mark PUD and PMD folded
      parisc: expose number of page table levels on Kconfig level
      powerpc: expose number of page table levels on Kconfig level
      s390: expose number of page table levels
      sh: expose number of page table levels
      sparc: expose number of page table levels
      tile: expose number of page table levels
      um: expose number of page table levels
      x86: expose number of page table levels on Kconfig level
      mm: define default PGTABLE_LEVELS to two
      mm: do not add nr_pmds into mm_struct if PMD is folded

Konstantin Khebnikov (1):
      page_writeback: put account_page_redirty() after set_page_dirty()

Konstantin Khlebnikov (3):
      proc/pagemap: walk page tables under pte lock
      page_writeback: clean up mess around cancel_dirty_page()
      mm: hide per-cpu lists in output of show_mem()

Mel Gorman (10):
      mm: numa: do not dereference pmd outside of the lock during NUMA hinting fault
      mm: add p[te|md] protnone helpers for use by NUMA balancing
      mm: convert p[te|md]_numa users to p[te|md]_protnone_numa
      ppc64: add paranoid warnings for unexpected DSISR_PROTFAULT
      mm: convert p[te|md]_mknonnuma and remaining page table manipulations
      mm: remove remaining references to NUMA hinting bits and helpers
      mm: numa: do not trap faults on the huge zero page
      x86: mm: restore original pte_special check
      mm: numa: add paranoid check around pte_protnone_numa
      mm: numa: avoid unnecessary TLB flushes when setting NUMA hinting entries

Michal Hocko (10):
      Merge remote-tracking branch 'tj-cgroups/for-3.20' into mmotm-akpm1
      oom: make sure that TIF_MEMDIE is set under task_lock
      oom: add helpers for setting and clearing TIF_MEMDIE
      oom: thaw the OOM victim if it is frozen
      PM: convert printk to pr_* equivalent
      sysrq: convert printk to pr_* equivalent
      oom, PM: make OOM detection in the freezer path raceless
      vmstat: do not use deferrable delayed work for vmstat_update
      memcg: fix low limit calculation
      mmotm: mm-cma-release-trigger-fix.patch

Minchan Kim (11):
      zram: check bd_openers instead of bd_holders
      zram: remove init_lock in zram_make_request
      mm: support madvise(MADV_FREE)
      mm: define MADV_FREE for some arches
      x86: add pmd_[dirty|mkclean] for THP
      sparc: add pmd_[dirty|mkclean] for THP
      powerpc: add pmd_[dirty|mkclean] for THP
      arm: add pmd_mkclean for THP
      arm64: add pmd_[dirty|mkclean] for THP
      mm: don't split THP page when syscall is called
      mm: remove lock validation check for MADV_FREE

Naoya Horiguchi (20):
      mm/hugetlb: reduce arch dependent code around follow_huge_*
      mm/hugetlb: pmd_huge() returns true for non-present hugepage
      mm/hugetlb: take page table lock in follow_huge_pmd()
      mm/hugetlb: fix getting refcount 0 page in hugetlb_fault()
      mm/hugetlb: add migration/hwpoisoned entry check in hugetlb_change_protection
      mm/hugetlb: add migration entry check in __unmap_hugepage_range
      mm/pagewalk: remove pgd_entry() and pud_entry()
      pagewalk: improve vma handling
      pagewalk: add walk_page_vma()
      smaps: remove mem_size_stats->vma and use walk_page_vma()
      clear_refs: remove clear_refs_private->vma and introduce clear_refs_test_walk()
      pagemap: use walk->vma instead of calling find_vma()
      numa_maps: fix typo in gather_hugetbl_stats
      numa_maps: remove numa_maps->vma
      memcg: cleanup preparation for page table walk
      arch/powerpc/mm/subpage-prot.c: use walk->vma and walk_page_vma()
      mempolicy: apply page table walker on queue_pages_range()
      mm: pagewalk: fix misbehavior of walk_page_range for vma(VM_PFNMAP)
      mincore: apply page table walker on do_mincore()
      mm: hwpoison: drop lru_add_drain_all() in __soft_offline_page()

Paul Bolle (1):
      mm: Fix comment typo "CONFIG_TRANSPARNTE_HUGE"

Petr Cermak (1):
      fs/proc/task_mmu.c: add user-space support for resetting mm->hiwater_rss (peak RSS)

Rafael Aquini (2):
      Documentation/filesystems/proc.txt: add /proc/pid/numa_maps interface explanation snippet
      fs: proc: task_mmu: show page size in /proc/<pid>/numa_maps

Rasmus Villemoes (40):
      mm/internal.h: don't split printk call in two
      mm/page_alloc.c: pull out init code from build_all_zonelists
      mm/mm_init.c: park mminit_verify_zonelist as __init
      mm/mm_init.c: mark mminit_loglevel __meminitdata
      kernel/cpuset.c: Mark cpuset_init_current_mems_allowed as __init
      kernel.h: remove ancient __FUNCTION__ hack
      lib/vsprintf.c: consume 'p' in format_decode
      lib/vsprintf.c: improve sanity check in vsnprintf()
      lib/vsprintf.c: replace while with do-while in skip_atoi
      lib/string_helpers.c:string_get_size(): remove redundant prefixes
      lib/string_helpers.c:string_get_size(): use 32 bit arithmetic when possible
      libstring_helpers.c:string_get_size(): return void
      lib/bitmap.c: more signed->unsigned conversions
      linux/nodemask.h: update bitmap wrappers to take unsigned int
      linux/cpumask.h: update bitmap wrappers to take unsigned int
      lib/bitmap.c: update bitmap_onto to unsigned
      lib/bitmap.c: change parameters of bitmap_fold to unsigned
      lib/bitmap.c: simplify bitmap_pos_to_ord
      lib/bitmap.c: simplify bitmap_ord_to_pos
      lib/bitmap.c: make the bits parameter of bitmap_remap unsigned
      lib/string.c: remove strnicmp()
      lib/interval_tree.c: simplify includes
      lib/sort.c: use simpler includes
      lib/dynamic_queue_limits.c: simplify includes
      lib/halfmd4.c: simplify includes
      lib/idr.c: remove redundant include
      lib/genalloc.c: remove redundant include
      lib/list_sort.c: rearrange includes
      lib/md5.c: simplify include
      lib/llist.c: remove redundant include
      lib/kobject_uevent.c: remove redundant include
      lib/nlattr.c: remove redundant include
      lib/plist.c: remove redundant include
      lib/radix-tree.c: change to simpler include
      lib/show_mem.c: remove redundant include
      lib/sort.c: move include inside #if 0
      lib/stmp_device.c: replace module.h include
      lib/strncpy_from_user.c: replace module.h include
      lib/percpu_ida.c: remove redundant includes
      lib/lcm.c: replace include

Rickard Strandqvist (1):
      arch/frv/mm/extable.c: remove unused function

Roman Gushchin (2):
      mm/mmap.c: fix arithmetic overflow in __vm_enough_memory()
      mm/nommu.c: fix arithmetic overflow in __vm_enough_memory()

Roman Pen (1):
      fs/mpage.c: forgotten WRITE_SYNC in case of data integrity write

Sasha Levin (3):
      mm: cma: debugfs interface
      mm: cma: allocation trigger
      mm: cma: release trigger

Sergei Rogachev (1):
      mm/page_owner.c: remove unnecessary stack_trace field

Sergey Senozhatsky (4):
      zram: clean up zram_meta_alloc()
      zram: fix umount-reset_store-mount race condition
      zram: rework reset and destroy path
      zram: remove request_queue from struct zram

Shachar Raindel (5):
      mm: refactor do_wp_page, extract the reuse case
      mm-refactor-do_wp_page-extract-the-reuse-case-fix
      mm: refactor do_wp_page - rewrite the unlock flow
      mm: refactor do_wp_page, extract the page copy flow
      mm: refactor do_wp_page handling of shared vma into a function

Sheng Yong (1):
      memory hotplug: use macro to switch between section and pfn

Tejun Heo (2):
      cgroup: reorder SUBSYS(blkio) in cgroup_subsys.h
      cgroup: add dummy css_put() for !CONFIG_CGROUPS

Tetsuo Handa (1):
      oom: don't count on mm-less current process

Toshi Kikuchi (1):
      lib/genalloc.c: fix the end addr check in addr_in_gen_pool()

Vaishali Thakkar (1):
      mm/slab_common.c: use kmem_cache_free()

Vinayak Menon (1):
      mm: vmscan: fix the page state calculation in too_many_isolated

Vladimir Davydov (31):
      memcg: zap __memcg_{charge,uncharge}_slab
      memcg: zap memcg_name argument of memcg_create_kmem_cache
      memcg: zap memcg_slab_caches and memcg_slab_mutex
      swap: remove unused mem_cgroup_uncharge_swapcache declaration
      vmscan: force scan offline memory cgroups
      list_lru: introduce list_lru_shrink_{count,walk}
      fs: consolidate {nr,free}_cached_objects args in shrink_control
      vmscan: per memory cgroup slab shrinkers
      memcg: rename some cache id related variables
      memcg: add rwsem to synchronize against memcg_caches arrays relocation
      list_lru: get rid of ->active_nodes
      list_lru: organize all list_lrus to list
      list_lru: introduce per-memcg lists
      fs: make shrinker memcg aware
      fs: shrinker: always scan at least one object of each type
      slab: embed memcg_cache_params to kmem_cache
      slab: link memcg caches of the same kind into a list
      cgroup: release css->id after css_free
      slab: use css id for naming per memcg caches
      memcg: free memcg_caches slot on css offline
      list_lru: add helpers to isolate items
      memcg: reparent list_lrus and free kmemcg_id on css offline
      slub: never fail to shrink cache
      slub: fix kmem_cache_shrink return value
      slub: make dead caches discard free slabs immediately
      memcg: cleanup static keys decrement
      ocfs2: copy fs uuid to superblock
      cleancache: zap uuid arg of cleancache_init_shared_fs
      cleancache: forbid overriding cleancache_ops
      cleancache: remove limit on the number of cleancache enabled filesystems
      cleancache-remove-limit-on-the-number-of-cleancache-enabled-filesystems-fix

Vlastimil Babka (9):
      mm, vmscan: wake up all pfmemalloc-throttled processes at once
      mm: set page->pfmemalloc in prep_new_page()
      mm, page_alloc: reduce number of alloc_pages* functions' parameters
      mm: reduce try_to_compact_pages parameters
      mm: microoptimize zonelist operations
      mm/mempolicy.c: merge alloc_hugepage_vma to alloc_pages_vma
      mm: when stealing freepages, also take pages created by splitting buddy page
      mm: always steal split buddies in fallback allocations
      mm: more aggressive page stealing for UNMOVABLE allocations

Wang, Yalin (2):
      mm: add VM_BUG_ON_PAGE() to page_mapcount()
      mm:add KPF_ZERO_PAGE flag for /proc/kpageflags

Weijie Yang (2):
      mm/page_alloc.c: place zone_id check before VM_BUG_ON_PAGE check
      mm: page_isolation: check pfn validity before access

Xishi Qiu (1):
      kmemcheck: move hook into __alloc_pages_nodemask() for the page allocator

Yaowei Bai (1):
      mm/page_alloc: fix comment
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
