Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4856B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 05:09:11 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id d63so1426932wma.4
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 02:09:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p79si1324168wmf.65.2018.02.01.02.09.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Feb 2018 02:09:09 -0800 (PST)
Date: Thu, 1 Feb 2018 11:09:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: mmotm git tree since-4.15 branch created (was: mmotm
 2018-01-31-16-51 uploaded)
Message-ID: <20180201100907.GH21609@dhcp22.suse.cz>
References: <5a7264b1.mqPv/eshq6wqQFu6%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5a7264b1.mqPv/eshq6wqQFu6%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mm-commits@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org


I have just created since-4.15 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v4.15 tag in Linus tree and mmotm-2018-01-31-16-51 +
I have pulled libnvdimm-for-next branch from the nvdim tree. Let me know
if I should pull some other trees that MM changes might depend on.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The shortlog says:
Alexander Potapenko (1):
      kasan: add functions for unpoisoning stack variables

Aliaksei Karaliou (1):
      mm/zsmalloc: simplify shrinker init/destroy

Andi Kleen (2):
      certs/blacklist_nohashes.c: fix const confusion in certs blacklist
      drivers/media/platform/sti/delta/delta-ipc.c: fix read buffer overflow

Andrei Vagin (1):
      mm: don't use the same value for MAP_FIXED_NOREPLACE and MAP_SYNC

Andrew Morton (7):
      include/linux/sched/mm.h: uninline mmdrop_async(), etc
      list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix
      mm-oom-cgroup-aware-oom-killer-fix
      mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix-2-fix
      fs-elf-drop-map_fixed-usage-from-elf_map-checkpatch-fixes
      mm-migrate-remove-reason-argument-from-new_page_t-fix-fix
      kasan-clean-up-kasan_shadow_scale_shift-usage-checkpatch-fixes

Andrey Konovalov (3):
      kasan: don't emit builtin calls when sanitization is off
      kasan: fix prototype author email address
      kasan: clean up KASAN_SHADOW_SCALE_SHIFT usage

Andrey Ryabinin (2):
      mm/memcontrol.c: try harder to decrease [memory,memsw].limit_in_bytes
      kasan/Makefile: support LLVM style asan parameters

Andy Shevchenko (1):
      scripts/decodecode: make it take multiline Code line

Aneesh Kumar K.V (3):
      selftests/vm: move 128TB mmap boundary test to generic directory
      powerpc/mm: update pmdp_invalidate to return old pmd value
      mm/thp: remove pmd_huge_split_prepare()

Arend van Spriel (1):
      scripts/tags.sh: change find_other_sources() for include directories

Arnd Bergmann (2):
      kasan: add declarations for internal functions
      kasan: rework Kconfig settings

Balasubramani Vivekanandan (1):
      mm/slub.c: fix wrong address during slab padding restoration

Byongho Lee (1):
      mm/slab_common.c: make calculate_alignment() static

Catalin Marinas (1):
      arm64: provide pmdp_establish() helper

Christoph Hellwig (16):
      memremap: provide stubs for vmem_altmap_offset and vmem_altmap_free
      mm: don't export arch_add_memory
      mm: don't export __add_pages
      mm: pass the vmem_altmap to arch_add_memory and __add_pages
      mm: pass the vmem_altmap to vmemmap_populate
      mm: pass the vmem_altmap to arch_remove_memory and __remove_pages
      mm: pass the vmem_altmap to vmemmap_free
      mm: pass the vmem_altmap to memmap_init_zone
      mm: split altmap memory map allocation from normal case
      mm: merge vmem_altmap_alloc into altmap_alloc_block_buf
      mm: move get_dev_pagemap out of line
      mm: optimize dev_pagemap reference counting around get_dev_pagemap
      memremap: remove to_vmem_altmap
      memremap: simplify duplicate region handling in devm_memremap_pages
      memremap: change devm_memremap_pages interface to use struct dev_pagemap
      memremap: merge find_dev_pagemap into get_dev_pagemap

Christopher Diaz Riveros (1):
      mm/memcontrol.c: make local symbol static

Dan Williams (7):
      nfit, libnvdimm: deprecate the generic SMART ioctl
      tools/testing/nvdimm: smart alarm/threshold control
      mm, dax: introduce pfn_t_special()
      ext4: auto disable dax instead of failing mount
      ext2: auto disable dax instead of failing mount
      dax: require 'struct page' by default for filesystem dax
      Merge branch 'for-4.16/dax' into libnvdimm-for-next

David Rientjes (3):
      mm, mmu_notifier: annotate mmu notifiers with blockable invalidate callbacks
      mm, oom: avoid reaping only for mm's with blockable invalidate callbacks
      tools, vm: new option to specify kpageflags file

Dmitry Vyukov (5):
      kasan: detect invalid frees for large objects
      kasan: don't use __builtin_return_address(1)
      kasan: detect invalid frees for large mempool objects
      kasan: unify code between kasan_slab_free() and kasan_poison_kfree()
      kasan: detect invalid frees

Eric Biggers (8):
      userfaultfd: convert to use anon_inode_getfd()
      pipe, sysctl: drop 'min' parameter from pipe-max-size converter
      pipe, sysctl: remove pipe_proc_fn()
      pipe: actually allow root to exceed the pipe buffer limits
      pipe: fix off-by-one error when checking buffer limits
      pipe: reject F_SETPIPE_SZ with size over UINT_MAX
      pipe: simplify round_pipe_size()
      pipe: read buffer limits atomically

Henry Willard (1):
      mm: numa: do not trap faults on shared data section pages.

Huang Ying (1):
      mm, userfaultfd, THP: avoid waiting when PMD under THP migration

Jan H. Schonherr (3):
      mm: Fix memory size alignment in devm_memremap_pages_release()
      mm: Fix devm_memremap_pages() collision handling
      fs/dax.c: release PMD lock even when there is no PMD support in DAX

Jan Kara (1):
      mm: remove unused pgdat_reclaimable_pages()

Jeff Moyer (1):
      libnvdimm, btt: fix uninitialized err_lock

Jiankang Chen (1):
      mm/page_alloc.c: fix comment in __get_free_pages()

Johannes Weiner (3):
      mm: memcontrol: eliminate raw access to stat and event counters
      mm: memcontrol: implement lruvec stat functions on top of each other
      mm: memcontrol: fix excessive complexity in memory.stat reporting

Joonsoo Kim (4):
      mm/page_alloc: don't reserve ZONE_HIGHMEM for ZONE_MOVABLE request
      mm/cma: manage the memory of the CMA area by using the ZONE_MOVABLE
      mm/cma: remove ALLOC_CMA
      ARM: CMA: avoid double mapping to the CMA area if CONFIG_HIGHMEM=y

Josef Bacik (1):
      mm: use sc->priority for slab shrink targets

Kirill A. Shutemov (7):
      asm-generic: provide generic_pmdp_establish()
      arc: use generic_pmdp_establish as pmdp_establish
      arm/mm: provide pmdp_establish() helper
      mips: use generic_pmdp_establish as pmdp_establish
      x86/mm: provide pmdp_establish() helper
      mm: do not lose dirty and accessed bits in pmdp_invalidate()
      mm: use updated pmdp_invalidate() interface to track dirty/accessed bits

Kirill Tkhai (2):
      mm: make counting of list_lru_one::nr_items lockless
      mm-make-count-list_lru_one-nr_items-lockless-v2

Konstantin Khlebnikov (1):
      fs/proc/task_mmu.c: do not show VmExe bigger than total executable virtual memory

Laurent Dufour (1):
      mm: skip HWPoisoned pages when onlining pages

Logan Gunthorpe (1):
      memremap: drop private struct page_map

Marc-Andre Lureau (10):
      shmem: unexport shmem_add_seals()/shmem_get_seals()
      shmem: rename functions that are memfd-related
      hugetlb: expose hugetlbfs_inode_info in header
      hugetlb: implement memfd sealing
      shmem: add sealing support to hugetlb-backed memfd
      memfd-test: test hugetlbfs sealing
      memfd-test: add 'memfd-hugetlb:' prefix when testing hugetlbfs
      memfd-test: move common code to a shared unit
      memfd-test: run fuse test on hugetlb backend memory
      mm/page_owner: align with pageblock_nr_pages

Markus Elfring (1):
      arch/score/kernel/setup.c: combine two seq_printf() calls into one call in show_cpuinfo()

Martin Kelly (1):
      tools: fix cross-compile var clobbering

Martin Schwidefsky (1):
      s390/mm: modify pmdp_invalidate to return old value.

Matt Redfearn (1):
      watchdog: indydog: Add dependency on SGI_HAS_INDYDOG

Matthew Wilcox (10):
      mm: add unmap_mapping_pages()
      mm: get 7% more pages in a pagevec
      mm: align struct page more aesthetically
      mm: de-indent struct page
      mm: remove misleading alignment claims
      mm: improve comment on page->mapping
      mm: introduce _slub_counter_t
      mm: store compound_dtor / compound_order as bytes
      mm: document how to use struct page
      mm: remove reference to PG_buddy

Maxim Patlasov (1):
      mm: add strictlimit knob

Mel Gorman (1):
      mm: pin address_space before dereferencing it while isolating an LRU page

Michael Ellerman (1):
      mm-introduce-map_fixed_safe-fix

Michal Hocko (20):
      mm: drop hotplug lock from lru_add_drain_all()
      mm, hugetlb: remove hugepages_treat_as_movable sysctl
      mm, hugetlb: unify core page allocation accounting and initialization
      mm, hugetlb: integrate giga hugetlb more naturally to the allocation path
      mm, hugetlb: do not rely on overcommit limit during migration
      mm, hugetlb: get rid of surplus page accounting tricks
      mm, hugetlb: further simplify hugetlb allocation API
      hugetlb, mempolicy: fix the mbind hugetlb migration
      hugetlb, mbind: fall back to default policy if vma is NULL
      mm, memory_hotplug: fix memmap initialization
      oom, memcg: clarify root memcg oom accounting
      mm: introduce MAP_FIXED_NOREPLACE
      fs, elf: drop MAP_FIXED usage from elf_map
      fs-elf-drop-map_fixed-usage-from-elf_map-fix-fix
      mm, numa: rework do_pages_move
      mm, migrate: remove reason argument from new_page_t
      mm-migrate-remove-reason-argument-from-new_page_t-fix
      mm, memory-failure: fix migration callback
      mm: unclutter THP migration
      Merge remote-tracking branch 'nvdim/libnvdimm-for-next' into mmotm-4.15

Mike Rapoport (4):
      mm: update comment describing tlb_gather_mmu
      mm: docs: fixup punctuation
      mm: docs: fix parameter names mismatch
      mm: docs: add blank lines to silence sphinx "Unexpected indentation" errors

Miles Chen (2):
      slub: remove obsolete comments of put_cpu_partial()
      mm: remove PG_highmem description

Minchan Kim (1):
      mm: do not stall register_shrinker()

Naoya Horiguchi (2):
      mm: hwpoison: disable memory error handling on 1GB hugepage
      mm-hwpoison-disable-memory-error-handling-on-1gb-hugepage-v2

Nick Desaulniers (1):
      zsmalloc: use U suffix for negative literals being shifted

Nitin Gupta (1):
      sparc64: update pmdp_invalidate() to return old pmd value

Oscar Salvador (5):
      mm/slab.c: remove redundant assignments for slab_state
      mm/memory_hotplug.c: remove unnecesary check from register_page_bootmem_info_section()
      mm: memory_hotplug: remove second __nr_to_section in register_page_bootmem_info_section()
      mm/page_owner.c: clean up init_pages_in_zone()
      mm/page_ext.c: make page_ext_init a noop when CONFIG_PAGE_EXTENSION but nothing uses it

Paul Lawrence (3):
      kasan: add compiler support for clang
      kasan: support alloca() poisoning
      kasan: add tests for alloca poisoning

Pavel Tatashin (3):
      mm: relax deferred struct page requirements
      mm: split deferred_init_range into initializing and freeing parts
      sparc64: NG4 memset 32 bits overflow

Petr Tesarik (1):
      include/linux/mmzone.h: fix explanation of lower bits in the SPARSEMEM mem_map pointer

Pravin Shedge (1):
      mm/userfaultfd.c: remove duplicate include

Ralph Campbell (1):
      mm/hmm: fix uninitialized use of 'entry' in hmm_vma_walk_pmd()

Randy Dunlap (1):
      mm/swap.c: make functions and their kernel-doc agree

Roman Gushchin (10):
      mm: show total hugetlb memory consumption in /proc/meminfo
      mm, oom: refactor oom_kill_process()
      mm: implement mem_cgroup_scan_tasks() for the root memory cgroup
      mm, oom: cgroup-aware OOM killer
      mm, oom: introduce memory.oom_group
      mm, oom: return error on access to memory.oom_group if groupoom is disabled
      mm, oom: add cgroup v2 mount option for cgroup-aware OOM killer
      mm, oom, docs: describe the cgroup-aware OOM killer
      mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix
      cgroup: list groupoom in cgroup features

Sergey Senozhatsky (3):
      mm: remove unneeded kallsyms include
      hrtimer: remove unneeded kallsyms include
      genirq: remove unneeded kallsyms include

Shakeel Butt (2):
      mm, mlock, vmscan: no more skipping pagevecs
      vfs: remove might_sleep() from clear_inode()

Shile Zhang (1):
      mm/page_alloc.c: fix typos in comments

Srividya Desireddy (1):
      zswap: same-filled pages handling

Sudip Mukherjee (1):
      m32r: remove abort()

Tetsuo Handa (1):
      mm,vmscan: mark register_shrinker() as __must_check

Vasyl Gomonovych (2):
      mm/page_owner.c: use PTR_ERR_OR_ZERO()
      mm/interval_tree.c: use vma_pages() helper

Waiman Long (1):
      mm/list_lru.c: prefetch neighboring list entries before acquiring lock

William Kucharski (1):
      mm: correct comments regarding do_fault_around()

Yang Shi (4):
      mm: kmemleak: remove unused hardirq.h
      mm/filemap.c: remove include of hardirq.h
      mm: thp: use down_read_trylock() in khugepaged to avoid long block
      mm/compaction.c: fix comment for try_to_compact_pages()

Yaowei Bai (7):
      mm/memblock: memblock_is_map/region_memory can be boolean
      lib/lockref: __lockref_is_dead can be boolean
      kernel/cpuset: current_cpuset_is_being_rebound can be boolean
      kernel/resource: iomem_is_exclusive can be boolean
      kernel/module: module_is_live can be boolean
      kernel/mutex: mutex_is_locked can be boolean
      crash_dump: is_kdump_kernel can be boolean

Yisheng Xie (4):
      mm/mempolicy: remove redundant check in get_nodes
      mm/mempolicy: fix the check of nodemask from user
      mm/mempolicy: add nodes_empty check in SYSC_migrate_pages
      mm/huge_memory.c: fix comment in __split_huge_pmd_locked

Yu Zhao (3):
      zswap: only save zswap header when necessary
      memcg: refactor mem_cgroup_resize_limit()
      mm: don't expose page to fast gup before it's ready

kbuild test robot (1):
      kasan: __asan_set_shadow_00 can be static

shidao.ytt (1):
      mm/fadvise: discard partial page if endbyte is also EOF

zhong jiang (1):
      mm/page_owner: align with pageblock_nr pages

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
