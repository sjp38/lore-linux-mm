Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF5016B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 05:36:14 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id t92so5793968wrc.13
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 02:36:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 64si857685edk.152.2017.11.20.02.36.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 02:36:13 -0800 (PST)
Date: Mon, 20 Nov 2017 11:36:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: mmotm git tree since-4.14 branch created (was: mmotm
 2017-11-17-16-17 uploaded)
Message-ID: <20171120103611.xijt4leoohvsc3pc@dhcp22.suse.cz>
References: <5a0f7c4f.T3UdVwuRSnDL5xp1%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5a0f7c4f.T3UdVwuRSnDL5xp1%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

I have just created since-4.14 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v4.14 tag in Linus tree and mmotm-2017-11-17-16-17. I have
pulled ext4/dev and tip/x86/asm to satisfy dependencies. I wanted to
pull nvdimm tree as well but there were other dependeces I didn't feel
comfortable to resolve. If there are more trees to pull, please let me
know

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The shortlog says:
Aaron Lu (1):
      mm/page_alloc: make sure __rmqueue() etc are always inline

Alexandru Moise (1):
      mm/madvise: enable soft offline of HugeTLB pages at PUD level

Alexey Dobriyan (4):
      slab, slub, slob: add slab_flags_t
      slab, slub, slob: convert slab_flags_t to 32-bit
      proc: : uninline name_to_int()
      proc: use do-while in name_to_int()

Andi Kleen (2):
      kernel debug: support resetting WARN*_ONCE
      kernel debug: support resetting WARN_ONCE for all architectures

Andrew Morton (1):
      include/linux/sched/mm.h: uninline mmdrop_async(), etc

Andrey Ryabinin (2):
      mm: remove unused pgdat->inactive_ratio
      x86/mm/kasan: don't use vmemmap_populate() to initialize shadow

Andrey Vostrikov (1):
      lib/crc-ccitt: add CCITT-FALSE CRC16 variant

Anshuman Khandual (1):
      fs/hugetlbfs/inode.c: remove redundant -ENIVAL return from hugetlbfs_setattr()

Arnd Bergmann (1):
      mm: fix nodemask printing

Ayush Mittal (1):
      mm/page_owner.c: reduce page_owner structure size

Changbin Du (2):
      mm: update comments for struct page.mapping
      mm/swap_state.c: declare a few variables as __read_mostly

Colin Ian King (3):
      mm/rmap.c: remove redundant variable cend
      drivers/block/zram/zram_drv.c: make zram_page_end_io() static
      mm/hmm: remove redundant variable align_end

Corentin Labbe (1):
      mm: shmem: remove unused info variable

Dan Williams (4):
      mm: fix device-dax pud write-faults triggered by get_user_pages()
      mm: replace pud_write with pud_access_permitted in fault + gup paths
      mm: replace pmd_write with pmd_access_permitted in fault + gup paths
      mm: replace pte_write with pte_access_permitted in fault + gup paths

David Rientjes (3):
      mm/slab.c: only set __GFP_RECLAIMABLE once
      mm, compaction: kcompactd should not ignore pageblock skip
      mm, compaction: persistently skip hugetlbfs pageblocks

Fan Du (1):
      memory hotplug: fix comments when adding section

Gioh Kim (1):
      mm/memblock.c: make the index explicit argument of for_each_memblock_type

Gustavo A. R. Silva (2):
      mm/shmem.c: mark expected switch fall-through
      mm/list_lru.c: mark expected switch fall-through

Huang Ying (1):
      mm, swap: fix false error message in __swp_swapcount()

Jaewon Kim (1):
      mm/page_ext.c: check if page_ext is not prepared

Jan Kara (24):
      mm: implement find_get_pages_range_tag()
      btrfs: use pagevec_lookup_range_tag()
      ceph: use pagevec_lookup_range_tag()
      ext4: use pagevec_lookup_range_tag()
      f2fs: use pagevec_lookup_range_tag()
      f2fs: simplify page iteration loops
      f2fs: use find_get_pages_tag() for looking up single page
      gfs2: use pagevec_lookup_range_tag()
      nilfs2: use pagevec_lookup_range_tag()
      mm: use pagevec_lookup_range_tag() in __filemap_fdatawait_range()
      mm: use pagevec_lookup_range_tag() in write_cache_pages()
      mm: add variant of pagevec_lookup_range_tag() taking number of pages
      ceph: use pagevec_lookup_range_nr_tag()
      mm: remove nr_pages argument from pagevec_lookup_{,range}_tag()
      afs: use find_get_pages_range_tag()
      cifs: use find_get_pages_range_tag()
      mm: speed up cancel_dirty_page() for clean pages
      mm: refactor truncate_complete_page()
      mm: factor out page cache page freeing into a separate function
      mm: move accounting updates before page_cache_tree_delete()
      mm: move clearing of page->mapping to page_cache_tree_delete()
      mm: factor out checks and accounting from __delete_from_page_cache()
      mm: batch radix tree operations when truncating pages
      mm: readahead: increase maximum readahead window

Jason Baron (2):
      epoll: avoid calling ep_call_nested() from ep_poll_safewake()
      epoll: remove ep_call_nested() from ep_eventpoll_poll()

Joe Lawrence (4):
      pipe: match pipe_max_size data type with procfs
      pipe: avoid round_pipe_size() nr_pages overflow on 32-bit
      pipe: add proc_dopipe_max_size() to safely assign pipe_max_size
      sysctl: check for UINT_MAX before unsigned int min/max

Joe Perches (1):
      spelling.txt: add "unnecessary" typo variants

Johannes Thumshirn (6):
      include/linux/slab.h: add kmalloc_array_node() and kcalloc_node()
      block/blk-mq.c: use kmalloc_array_node()
      drivers/infiniband/hw/qib/qib_init.c: use kmalloc_array_node()
      drivers/infiniband/sw/rdmavt/qp.c: use kmalloc_array_node()
      mm/mempool.c: use kmalloc_array_node()
      net/rds/ib_fmr.c: use kmalloc_array_node()

Johannes Weiner (1):
      fs: fuse: account fuse_inode slab memory as reclaimable

Jerome Glisse (2):
      mm/mmu_notifier: avoid double notification when it is useless
      mm/mmu_notifier: avoid call to invalidate_range() in range_end()

Kangmin Park (1):
      Documentation/sysctl/vm.txt: fix typo

Kees Cook (2):
      mm/page-writeback.c: convert timers to use timer_setup()
      sh/boot: add static stack-protector to pre-kernel

Kemi Wang (1):
      mm, sysctl: make NUMA stats configurable

Kirill A. Shutemov (4):
      mm: account pud page tables
      mm: introduce wrappers to access mm->nr_ptes
      mm: consolidate page table accounting
      mm: add infrastructure for get_user_pages_fast() benchmarking

Kirill Tkhai (1):
      mm: make counting of list_lru_one::nr_items lockless

Konstantin Khlebnikov (2):
      kmemleak: change /sys/kernel/debug/kmemleak permissions from 0444 to 0644
      fs/proc/task_mmu.c: do not show VmExe bigger than total executable virtual memory

Laszlo Toth (1):
      mm, soft_offline: improve hugepage soft offlining error log

Laurent Dufour (1):
      mm: skip HWPoisoned pages when onlining pages

Levin, Alexander (Sasha Levin) (4):
      kmemcheck: remove annotations
      kmemcheck: stop using GFP_NOTRACK and SLAB_NOTRACK
      kmemcheck: remove whats left of NOTRACK flags
      kmemcheck: rip it out

Masahiro Yamada (3):
      include/linux/bitfield.h: include <linux/build_bug.h> instead of <linux/bug.h>
      include/linux/radix-tree.h: remove unneeded #include <linux/bug.h>
      init/version.c: include <linux/export.h> instead of <linux/module.h>

Mel Gorman (9):
      mm, page_alloc: enable/disable IRQs once when freeing a list of pages
      mm, truncate: do not check mapping for every page being truncated
      mm, truncate: remove all exceptional entries from pagevec under one lock
      mm: only drain per-cpu pagevecs once per pagevec usage
      mm, pagevec: remove cold parameter for pagevecs
      mm: remove cold parameter for release_pages
      mm: remove cold parameter from free_hot_cold_page*
      mm: remove __GFP_COLD
      mm, pagevec: rename pagevec drained field

Michal Hocko (13):
      mm: drop migrate type checks from has_unmovable_pages
      mm: distinguish CMA and MOVABLE isolation in has_unmovable_pages()
      mm, page_alloc: fail has_unmovable_pages when seeing reserved pages
      mm, memory_hotplug: do not fail offlining too early
      mm, memory_hotplug: remove timeout from __offline_memory
      mm, arch: remove empty_bad_page*
      Merge remote-tracking branch 'tip/x86/asm' into mmotm-since-4.14-base
      mm, sparse: do not swamp log with huge vmemmap allocation failures
      mm: do not rely on preempt_count in print_vma_addr
      mm: simplify nodemask printing
      mm, memory_hotplug: do not back off draining pcp free pages from kworker context
      mm, hugetlb: remove hugepages_treat_as_movable sysctl
      Merge remote-tracking branch 'ext-tree/dev' into mmotm-merge

Mike Rapoport (1):
      userfaultfd: use mmgrab instead of open-coded increment of mm_count

Miles Chen (3):
      mm/slob.c: remove an unnecessary check for __GFP_ZERO
      slub: fix sysfs duplicate filename creation when slub_debug=O
      lib/dma-debug.c: fix incorrect pfn calculation

Minchan Kim (5):
      zram: set BDI_CAP_STABLE_WRITES once
      bdi: introduce BDI_CAP_SYNCHRONOUS_IO
      mm, swap: introduce SWP_SYNCHRONOUS_IO
      mm, swap: skip swapcache for swapin of synchronous device
      mm: swap: SWP_SYNCHRONOUS_IO: skip swapcache only if swapped page has no other reference

Oscar Salvador (1):
      mm: make alloc_node_mem_map a void call if we don't have CONFIG_FLAT_NODE_MEM_MAP

Otto Ebeling (1):
      Unify migrate_pages and move_pages access checks

Pavel Tatashin (10):
      mm: deferred_init_memmap improvements
      x86/mm: set fields in deferred pages
      sparc64/mm: set fields in deferred pages
      sparc64: simplify vmemmap_populate
      mm: define memblock_virt_alloc_try_nid_raw
      mm: zero reserved and unavailable struct pages
      mm: stop zeroing memory during allocation in vmemmap
      sparc64: optimize struct page zeroing
      mm/page_alloc.c: broken deferred calculation
      sparc64: NG4 memset 32 bits overflow

Pintu Agarwal (1):
      mm/cma.c: change pr_info to pr_err for cma_alloc fail log

Ralph Campbell (1):
      mm/hmm: constify hmm_devmem_page_get_drvdata() parameter

Roman Gushchin (1):
      proc, coredump: add CoreDumping flag to /proc/pid/status

Sergey Senozhatsky (3):
      zram: add zstd to the supported algorithms list
      zram: remove zlib from the list of recommended algorithms
      zsmalloc: calling zs_map_object() from irq is a bug

Shakeel Butt (3):
      fs, mm: account filp cache to kmemcg
      mm: mlock: remove lru_add_drain_all()
      epoll: account epitem and eppoll_entry to kmemcg

Tahsin Erdogan (1):
      mm/page-writeback.c: remove unused parameter from balance_dirty_pages()

Tetsuo Handa (2):
      mm: don't warn about allocations which stall for too long
      mm,oom_reaper: remove pointless kthread_run() error check

Tim Chen (1):
      mm/swap_slots.c: fix race conditions in swap_slots cache init

Vinayak Menon (1):
      mm: vmscan: do not pass reclaimed slab to vmpressure

Vitaly Wool (1):
      mm/z3fold.c: use kref to prevent page free/compact race

Vlastimil Babka (5):
      mm, page_alloc: simplify list handling in rmqueue_bulk()
      mm, page_alloc: fix potential false positive in __zone_watermark_ok
      mm, compaction: extend pageblock_skip_persistent() to all compound pages
      mm, compaction: split off flag for not updating skip hints
      mm, compaction: remove unneeded pageblock_skip_persistent() checks

Wang Long (1):
      writeback: remove unused function parameter

Wang Nan (1):
      mm, oom_reaper: gather each vma to prevent leaking TLB entry

Wei Yang (1):
      mm/page_alloc: return 0 in case this node has no page within the zone

Will Deacon (2):
      arm64/mm/kasan: don't use vmemmap_populate() to initialize shadow
      scripts/decodecode: fix decoding for AArch64 (arm64) instructions

Yafang Shao (1):
      mm/page-writeback.c: print a warning if the vm dirtiness settings are illogical

Yang Shi (3):
      tools: slabinfo: add "-U" option to show unreclaimable slabs only
      mm: slabinfo: remove CONFIG_SLABINFO
      mm: oom: show unreclaimable slab info when unreclaimable slabs > user memory

weiping zhang (1):
      shmem: convert shmem_init_inodecache() to void

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
