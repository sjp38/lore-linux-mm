Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3B61C6B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 04:20:42 -0400 (EDT)
Received: by wiax7 with SMTP id x7so29496597wia.0
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 01:20:41 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id on7si2893317wic.76.2015.04.24.01.20.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 01:20:40 -0700 (PDT)
Received: by wizk4 with SMTP id k4so12831010wiz.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 01:20:39 -0700 (PDT)
Date: Fri, 24 Apr 2015 10:20:38 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mmotm 2015-04-23-16-38 uploaded
Message-ID: <20150424082038.GA32008@dhcp22.suse.cz>
References: <55398289.nLa6cVW4ipEZTFsW%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55398289.nLa6cVW4ipEZTFsW%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au

I have just created since-4.0 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v4.0 tag in Linus tree and mmotm-2015-04-23-16-38.

I have pulled some cgroup wide changes from Tejun.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The current shortlog says:
Alexander Kuleshov (1):
      mm/memblock.c: add debug output for memblock_add()

Alexandre Belloni (2):
      Documentation: bindings: add abracon,abx80x
      rtc-add-rtc-abx80x-a-driver-for-the-abracon-ab-x80x-i2c-rtc-v3

Andi Kleen (2):
      mm, hwpoison: add comment describing when to add new cases
      mm, hwpoison: remove obsolete "Notebook" todo list

Andrew Morton (12):
      mm-cma-allocation-trigger-fix
      mm/cma_debug.c: remove blank lines before DEFINE_SIMPLE_ATTRIBUTE()
      mm/compaction.c: fix "suitable_migration_target() unused" warning
      revert "zram: move compact_store() to sysfs functions area"
      mm-slab_common-support-the-slub_debug-boot-option-on-specific-object-size-fix
      slub-bulk-allocation-from-per-cpu-partial-pages-fix
      mm-fix-mprotect-behaviour-on-vm_locked-vmas-fix
      include/linux/page-flags.h: rename macros to avoid collisions
      x86-add-pmd_-for-thp-fix
      sparc-add-pmd_-for-thp-fix
      mm-support-madvisemadv_free-fix-2
      mm-move-lazy-free-pages-to-inactive-list-fix-fix

Andrey Ryabinin (2):
      mm/mempool.c: kasan: poison mempool elements
      kasan: Makefile: shut up warnings if CONFIG_COMPILE_TEST=y

Balasubramani Vivekanandan (1):
      memcg: print cgroup information when system panics due to panic_on_oom

Bandan Das (1):
      cgroup: Use kvfree in pidlist_free()

Baoquan He (1):
      mm/memblock.c: rename local variable of memblock_type to `type'

Boaz Harrosh (3):
      mm: new pfn_mkwrite same as page_mkwrite for VM_PFNMAP
      dax: use pfn_mkwrite to update c/mtime + freeze protection
      dax: unify ext2/4_{dax,}_file_operations

Borislav Petkov (1):
      include/linux/mm.h: simplify flag check

Chen Gang (1):
      mm: memcontrol: let mem_cgroup_move_account() have effect only if MMU enabled

Chen Hanxiao (1):
      /proc/PID/status: show all sets of pid according to ns

Chris J Arges (1):
      mm/slub.c: parse slub_debug O option in switch statement

Christoph Lameter (3):
      slab: infrastructure for bulk object allocation and freeing
      slub bulk alloc: extract objects from the per cpu slab
      slub: bulk allocation from per cpu partial pages

Daniel Sanders (1):
      slab: correct size_index table before replacing the bootstrap kmem_cache_node

David Rientjes (15):
      arch/sh/kernel/dwarf.c: destroy mempools on cleanup
      arch/sh/kernel/dwarf.c: use mempool_create_slab_pool()
      mm, slab: correct config option in comment
      mm, hotplug: fix concurrent memory hot-add deadlock
      mm, mempolicy: migrate_to_node should only migrate to node
      mm: remove GFP_THISNODE
      mm, thp: really limit transparent hugepage allocation to local node
      kernel, cpuset: remove exception for __GFP_THISNODE
      mm, mempool: do not allow atomic resizing
      mm, hugetlb: abort __get_user_pages if current has been oom killed
      fs, jfs: remove slab object constructor
      mm, mempool: disallow mempools based on slab caches with constructors
      mm, mempool: poison elements backed by slab allocator
      mm, doc: cleanup and clarify munmap behavior for hugetlb memory
      mm, selftests: test return value of munmap for MAP_HUGETLB memory

Davidlohr Bueso (1):
      prctl: avoid using mmap_sem for exe_file serialization

Derek (2):
      mremap should return -ENOMEM when __vm_enough_memory fail
      mm/mremap.c: clean up goto just return ERR_PTR

Dmitry Safonov (1):
      mm: cma: add functions to get region pages counters

Ebru Akagunduz (1):
      mm: incorporate zero pages into transparent huge pages

Eric B Munson (2):
      mm: allow compaction of unevictable pages
      Documentation/vm/unevictable-lru.txt: document interaction between compaction and the unevictable LRU

Fabian Frederick (1):
      slob: make slob_alloc_node() static and remove EXPORT_SYMBOL()

Gavin Guo (1):
      mm/slab_common: support the slub_debug boot option on specific object size

Geert Uytterhoeven (4):
      mm/migrate: mark unmap_and_move() "noinline" to avoid ICE in gcc 4.7.3
      lib/vsprintf: document %p parameters passed by reference
      lib/vsprintf: Move integer format types to the top
      lib/vsprintf: add %pC{,n,r} format specifiers for clocks

Gerald Schaefer (1):
      mm/hugetlb: use pmd_page() in follow_huge_pmd()

Gioh Kim (1):
      mm/compaction: reset compaction scanner positions

Heesub Shin (1):
      zsmalloc: fix fatal corruption due to wrong size class selection

Heinrich Schuchardt (5):
      kernel/fork.c: new function for max_threads
      kernel/fork.c: avoid division by zero
      kernel/sysctl.c: threads-max observe limits
      Doc/sysctl/kernel.txt: document threads-max
      kernel/sysctl.c: detect overflows when converting to int

James Custer (1):
      mm: fix invalid use of pfn_valid_within in test_pages_in_a_zone

Jason Low (2):
      mm: use READ_ONCE() for non-scalar types
      mm: remove rest of ACCESS_ONCE() usages

Jean Delvare (1):
      fork_init: update max_threads comment

Jiri Kosina (1):
      thp: cleanup how khugepaged enters freezer

Joe Perches (4):
      slub: use bool function return values of true/false not 1/0
      compiler-gcc.h: neatening
      compiler-gcc: integrate the various compiler-gcc[345].h files
      kasan: show gcc version requirements in Kconfig and Documentation

Johannes Weiner (1):
      mm: memcontrol: update copyright notice

Joonsoo Kim (3):
      mm/cma: change fallback behaviour for CMA freepage
      mm/page_alloc: factor out fallback freepage checking
      mm/compaction: enhance compaction finish condition

Julia Lawall (1):
      zram: fix error return code

Kees Cook (10):
      arm: factor out mmap ASLR into mmap_rnd
      x86: standardize mmap_rnd() usage
      arm64: standardize mmap_rnd() usage
      mips: extract logic for mmap_rnd()
      powerpc: standardize mmap_rnd() usage
      s390: standardize mmap_rnd() usage
      mm: expose arch_mmap_rnd when available
      s390: redefine randomize_et_dyn for ELF_ET_DYN_BASE
      mm: split ET_DYN ASLR from mmap ASLR
      mm: fold arch_randomize_brk into ARCH_HAS_ELF_RANDOMIZE

Kirill A. Shutemov (42):
      mm: rename FOLL_MLOCK to FOLL_POPULATE
      mm: rename __mlock_vma_pages_range() to populate_vma_page_range()
      mm: move gup() -> posix mlock() error conversion out of __mm_populate
      mm: move mm_populate()-related code to mm/gup.c
      alpha: expose number of page table levels on Kconfig level
      arm64: expose number of page table levels on Kconfig level
      arm: expose number of page table levels on Kconfig level
      ia64: expose number of page table levels on Kconfig level
      m68k: mark PMD folded and expose number of page table levels
      mips: expose number of page table levels on Kconfig level
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
      mm: consolidate all page-flags helpers in <linux/page-flags.h>
      mm: avoid tail page refcounting on non-THP compound pages
      thp: handle errors in hugepage_init() properly
      thp: do not adjust zone water marks if khugepaged is not started
      mm: uninline and cleanup page-mapping related helpers
      thp: cleanup khugepaged startup
      mm: fix mprotect() behaviour on VM_LOCKED VMAs
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

Kirill Tkhai (1):
      fs/exec.c:de_thread: move notify_count write under lock

Konstantin Khlebnikov (5):
      page_writeback: clean up mess around cancel_dirty_page()
      mm: hide per-cpu lists in output of show_mem()
      mm: completely remove dumping per-cpu lists from show_mem()
      mm/memory: also print a_ops->readpage in print_bad_pte()
      mm: rcu-protected get_mm_exe_file()

Laurent Dufour (3):
      mm: new mm hook framework
      mm: new arch_remap() hook
      powerpc/mm: tracking vDSO remap

Marcin Jabrzyk (2):
      zram: remove obsolete ZRAM_DEBUG option
      zsmalloc: remove obsolete ZSMALLOC_DEBUG

Mel Gorman (1):
      mm: numa: remove migrate_ratelimited

Michael Davidson (1):
      fs/binfmt_elf.c: fix bug in loading of PIE binaries

Michal Hocko (5):
      Merge remote-tracking branch 'tj-cgroups/for-4.1' into mmotm-base
      mm: clarify __GFP_NOFAIL deprecation status
      sparc: clarify __GFP_NOFAIL allocation
      mm, memcg: sync allocation and memcg charge gfp flags for THP
      fork: report pid reservation failure properly

Mike Kravetz (4):
      hugetlbfs: add minimum size tracking fields to subpool structure
      hugetlbfs: add minimum size accounting to subpools
      hugetlbfs: accept subpool min_size mount option and setup accordingly
      hugetlbfs: document min_size mount option and cleanup

Minchan Kim (24):
      mm: rename deactivate_page to deactivate_file_page
      zsmalloc: decouple handle and object
      zsmalloc: factor out obj_[malloc|free]
      zsmalloc: support compaction
      zsmalloc: adjust ZS_ALMOST_FULL
      zram: support compaction
      zsmalloc: record handle in page->private for huge object
      zsmalloc: add fullness into stat
      zsmalloc: zsmalloc documentation
      zsmalloc: remove unnecessary insertion/removal of zspage in compaction
      zram: add Designated Reviewer for zram in MAINTAINERS
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

Naoya Horiguchi (10):
      mm/memory-failure.c: define page types for action_result() in one place
      mm/migrate: check-before-clear PageSwapCache
      mm/page-writeback: check-before-clear PageReclaim
      mm: don't call __page_cache_release for hugetlb
      mm: hugetlb: introduce page_huge_active
      mm: hugetlb: cleanup using paeg_huge_active()
      mm/memory-failure: call shake_page() when error hits thp tail page
      mm: soft-offline: fix num_poisoned_pages counting on concurrent events
      mm/hwpoison-inject: fix refcounting in no-injection case
      mm/hwpoison-inject: check PageLRU of hpage

Nishanth Aravamudan (1):
      mm: vmscan: do not throttle based on pfmemalloc reserves if node has no reclaimable pages

Oleg Nesterov (2):
      ptrace: fix race between ptrace_resume() and wait_task_stopped()
      ptrace: ptrace_detach() can no longer race with SIGKILL

Paul Bolle (1):
      mm: Fix comment typo "CONFIG_TRANSPARNTE_HUGE"

Philippe De Muyter (1):
      rtc: add rtc-abx80x, a driver for the Abracon AB x80x i2c rtc

Rasmus Villemoes (11):
      mm/mmap.c: use while instead of if+goto
      include/linux: remove empty conditionals
      lib/vsprintf.c: eliminate some branches
      lib/vsprintf.c: reduce stack use in number()
      lib/vsprintf.c: eliminate duplicate hex string array
      lib/vsprintf.c: another small hack
      lib/vsprintf.c: fix potential NULL deref in hex_string
      lib/string_helpers.c: refactor string_escape_mem
      lib/string_helpers.c: change semantics of string_escape_mem
      fs/binfmt_misc.c: simplify entry_status()
      linux/slab.h: fix three off-by-one typos in comment

Rik van Riel (3):
      sched, isolcpu: make cpu_isolated_map visible outside scheduler
      cpusets, isolcpus: exclude isolcpus from load balancing in cpusets
      cpuset, isolcpus: document relationship between cpusets & isolcpus

Roman Pen (4):
      mm/vmalloc: fix possible exhaustion of vmalloc space caused by vm_map_ram allocator
      mm/vmalloc: occupy newly allocated vmap block just after allocation
      mm/vmalloc: get rid of dirty bitmap inside vmap_block structure
      fs/mpage.c: forgotten WRITE_SYNC in case of data integrity write

Sasha Levin (5):
      mm: cma: debugfs interface
      mm: cma: allocation trigger
      mm: cma: release trigger
      cma: debug: document new debugfs interface
      mm: cma: constify and use correct signness in mm/cma.c

Sergey Senozhatsky (11):
      zram: remove `num_migrated' device attr
      zram: move compact_store() to sysfs functions area
      zram: use generic start/end io accounting
      zram: describe device attrs in documentation
      zram: export new 'io_stat' sysfs attrs
      zram: export new 'mm_stat' sysfs attrs
      zram: deprecate zram attrs sysfs nodes
      zsmalloc: remove synchronize_rcu from zs_compact()
      zsmalloc: micro-optimize zs_object_copy()
      zsmalloc: remove extra cond_resched() in __zs_compact
      cpumask: don't perform while loop in cpumask_next_and()

Shachar Raindel (4):
      mm: refactor do_wp_page, extract the reuse case
      mm: refactor do_wp_page - rewrite the unlock flow
      mm: refactor do_wp_page, extract the page copy flow
      mm: refactor do_wp_page handling of shared vma into a function

Sheng Yong (1):
      memory hotplug: use macro to switch between section and pfn

Stefan Strogin (1):
      mm: cma: add trace events for CMA allocations and freeings

Steven Rostedt (1):
      printk: comment pr_cont() stating it is only to continue a line

Toshi Kani (6):
      mm: change __get_vm_area_node() to use fls_long()
      lib/ioremap.c: add huge I/O map capability interfaces
      mm: change ioremap to set up huge I/O mappings
      mm: change vunmap to tear down huge KVA mappings
      x86, mm: support huge I/O mapping capability I/F
      x86, mm: support huge KVA mappings on x86

Vinayak Menon (1):
      mm: vmscan: fix the page state calculation in too_many_isolated

Vladimir Davydov (8):
      cgroup: call cgroup_subsys->bind on cgroup subsys initialization
      ocfs2: copy fs uuid to superblock
      cleancache: zap uuid arg of cleancache_init_shared_fs
      cleancache: forbid overriding cleancache_ops
      cleancache: remove limit on the number of cleancache enabled filesystems
      memcg: zap mem_cgroup_lookup()
      memcg: remove obsolete comment
      signal: remove warning about using SI_TKILL in rt_[tg]sigqueueinfo

Vladimir Murzin (6):
      mm: move memtest under mm
      memtest: use phys_addr_t for physical addresses
      arm64: add support for memtest
      arm: add support for memtest
      Kconfig: memtest: update number of test patterns up to 17
      Documentation: update arch list in the 'memtest' entry

Weijie Yang (1):
      mm: page_isolation: check pfn validity before access

Yaowei Bai (2):
      mm/page_alloc.c: clean up comment
      mm/oom_kill.c: fix typo in comment

Yinghao Xie (1):
      mm/zsmalloc.c: fix comment for get_pages_per_zspage

Zefan Li (1):
      cpuset: initialize cpuset a bit early

Zhang Zhen (2):
      mm: refactor zone_movable_is_highmem()
      mm/hugetlb: reduce arch dependent code about huge_pmd_unshare


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
