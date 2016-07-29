Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B21026B0253
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 08:57:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so39018150wme.1
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 05:57:12 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id f133si3377814wmf.85.2016.07.29.05.57.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 05:57:11 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id p129so42050939wmp.0
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 05:57:11 -0700 (PDT)
Date: Fri, 29 Jul 2016 14:57:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: mmotm git tree since-4.7 branch created (was: mmotm 2016-07-28-16-33
 uploaded)
Message-ID: <20160729125708.GD8031@dhcp22.suse.cz>
References: <579a9681.nQxUz4+tR82h3e/H%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <579a9681.nQxUz4+tR82h3e/H%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

I have just created since-4.7 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v4.7 tag in Linus tree and mmotm-2016-07-28-16-33
I have pulled cgroups, libnvdim and tip/mm trees because they seem to
have changes which might be needed. I had to drop the dma update pile
because it was causing just too many conflicts. Let me know if other
changes would be of a benefit.

Also note that based on Fenguang request there has been auto-latest
branch create which always tracks the last since-X.Y. This branch will
get rebased after each since-X.Y+1 is released.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The shortlog says:
Alexander Potapenko (2):
      mm, kasan: account for object redzone in SLUB's nearest_obj()
      mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB

Alexey Dobriyan (1):
      mm: faster kmalloc_array(), kcalloc()

Andy Lutomirski (4):
      mm: track NR_KERNEL_STACK in KiB instead of number of stacks
      mm: fix memcg stack accounting for sub-page stacks
      kdb: use task_cpu() instead of task_thread_info()->cpu
      printk: when dumping regs, show the stack, not thread_info

Aneesh Kumar K.V (5):
      include/linux/mmdebug.h: add VM_WARN which maps to WARN()
      powerpc/mm: check for irq disabled() only if DEBUG_VM is enabled
      mm/hugetlb: simplify hugetlb unmap
      mm: change the interface for __tlb_remove_page()
      mm/mmu_gather: track page size with mmu gather and force flush if page size change

Arnd Bergmann (2):
      fbmon: remove unused function argument
      compat: remove compat_printk()

Brian Foster (1):
      fs/fs-writeback.c: inode writeback list tracking tracepoints

Chen Gang (1):
      include/linux/memblock.h: Clean up code for several trivial details

Chris Metcalf (1):
      tile: support static_key usage in non-module __exit sections

Christoph Hellwig (1):
      memblock: include <asm/sections.h> instead of <asm-generic/sections.h>

Dan Williams (2):
      mm: CONFIG_ZONE_DEVICE stop depending on CONFIG_EXPERT
      mm: cleanup ifdef guards for vmem_altmap

Dave Chinner (1):
      fs/fs-writeback.c: add a new writeback list for sync

Dennis Chen (2):
      mm/memblock.c: add new infrastructure to address the mem limit issue
      arm64:acpi: fix the acpi alignment exception when 'mem=' specified

Ebru Akagunduz (6):
      mm: make optimistic check for swapin readahead
      mm: make swapin readahead to improve thp collapse rate
      mm, thp: make swapin readahead under down_read of mmap_sem
      mm, thp: fix locking inconsistency in collapse_huge_page
      mm, thp: fix comment inconsistency for swapin readahead functions
      mm, thp: convert from optimistic swapin collapsing to conservative

Eric Ren (1):
      ocfs2: fix a redundant re-initialization

Ganesh Mahendran (10):
      mm/compaction: remove unnecessary order check in try_to_compact_pages()
      mm/zsmalloc: use obj_index to keep consistent with others
      mm/zsmalloc: take obj index back from find_alloced_obj
      mm/zsmalloc: use class->objs_per_zspage to get num of max objects
      mm/zsmalloc: avoid calculate max objects of zspage twice
      mm/zsmalloc: keep comments consistent with code
      mm/zsmalloc: add __init,__exit attribute
      mm/zsmalloc: use helper to clear page->flags bit
      mm/zsmalloc: add trace events for zs_compact
      mm/zsmalloc: add per-class compact trace event

Huang Shijie (3):
      samples/jprobe: convert the printk to pr_info/pr_err
      samples/kretprobe: convert the printk to pr_info/pr_err
      samples/kretprobe: fix the wrong type

Huang Ying (2):
      thp: fix comments of __pmd_trans_huge_lock()
      mm, THP: clean up return value of madvise_free_huge_pmd

Hugh Dickins (2):
      shmem: get_unmapped_area align huge page
      mm, compaction: don't isolate PageWriteback pages in MIGRATE_SYNC_LIGHT mode

Jason Baron (6):
      powerpc: add explicit #include <asm/asm-compat.h> for jump label
      sparc: support static_key usage in non-module __exit sections
      arm: jump label may reference text in __exit
      jump_label: remove bug.h, atomic.h dependencies for HAVE_JUMP_LABEL
      dynamic_debug: add jump label support
      s390: add explicit <linux/stringify.h> for jump label

Johannes Weiner (1):
      mm: fix vm-scalability regression in cgroup-aware workingset code

Joonsoo Kim (8):
      mm/compaction: split freepages without holding the zone lock
      mm/page_owner: initialize page owner without holding the zone lock
      mm/page_owner: copy last_migrate_reason in copy_page_owner()
      mm/page_owner: introduce split_page_owner and replace manual handling
      tools/vm/page_owner: increase temporary buffer size
      mm/page_owner: use stackdepot to store stacktrace
      mm/page_alloc: introduce post allocation processing on page allocator
      mm/page_isolation: clean up confused code

Joseph Qi (4):
      ocfs2: cleanup unneeded goto in ocfs2_create_new_inode_locks
      ocfs2/dlm: fix memory leak of dlm_debug_ctxt
      ocfs2: cleanup implemented prototypes
      ocfs2: remove obscure BUG_ON in dlmglue

Junxiao Bi (1):
      ocfs2: improve recovery performance

Kirill A. Shutemov (34):
      khugepaged: recheck pmd after mmap_sem re-acquired
      thp, mlock: update unevictable-lru.txt
      mm: do not pass mm_struct into handle_mm_fault
      mm: introduce fault_env
      mm: postpone page table allocation until we have page to map
      rmap: support file thp
      mm: introduce do_set_pmd()
      thp, vmstats: add counters for huge file pages
      thp: support file pages in zap_huge_pmd()
      thp: handle file pages in split_huge_pmd()
      thp: handle file COW faults
      thp: skip file huge pmd on copy_huge_pmd()
      thp: prepare change_huge_pmd() for file thp
      thp: run vma_adjust_trans_huge() outside i_mmap_rwsem
      thp: file pages support for split_huge_page()
      thp, mlock: do not mlock PTE-mapped file huge pages
      vmscan: split file huge pages before paging them out
      page-flags: relax policy for PG_mappedtodisk and PG_reclaim
      radix-tree: implement radix_tree_maybe_preload_order()
      filemap: prepare find and delete operations for huge pages
      truncate: handle file thp
      mm, rmap: account shmem thp pages
      shmem: prepare huge= mount option and sysfs knob
      shmem: add huge pages support
      shmem, thp: respect MADV_{NO,}HUGEPAGE for file mappings
      thp: extract khugepaged from mm/huge_memory.c
      khugepaged: move up_read(mmap_sem) out of khugepaged_alloc_page()
      shmem: make shmem_inode_info::lock irq-safe
      khugepaged: add support of collapse for tmpfs/shmem pages
      thp: introduce CONFIG_TRANSPARENT_HUGE_PAGECACHE
      shmem: split huge pages beyond i_size under memory pressure
      thp: update Documentation/{vm/transhuge,filesystems/proc}.txt
      mm: fix use-after-free if memory allocation failed in vma_adjust()
      lib/stackdepot.c: use __GFP_NOWARN for stack allocations

Li RongQing (3):
      mm/memcontrol.c: remove the useless parameter for mc_handle_swap_pte
      mm: memcontrol: remove BUG_ON in uncharge_list
      mm: memcontrol: fix documentation for compound parameter

Markus Elfring (1):
      zsmalloc: Delete an unnecessary check before the function call "iput"

Masahiro Yamada (1):
      tree-wide: replace config_enabled() with IS_ENABLED()

Mel Gorman (43):
      mm, meminit: remove early_page_nid_uninitialised
      mm, vmstat: add infrastructure for per-node vmstats
      mm, vmscan: move lru_lock to the node
      mm, vmscan: move LRU lists to node
      mm, mmzone: clarify the usage of zone padding
      mm, vmscan: begin reclaiming pages on a per-node basis
      mm, vmscan: have kswapd only scan based on the highest requested zone
      mm, vmscan: make kswapd reclaim in terms of nodes
      mm, vmscan: remove balance gap
      mm, vmscan: simplify the logic deciding whether kswapd sleeps
      mm, vmscan: by default have direct reclaim only shrink once per node
      mm, vmscan: remove duplicate logic clearing node congestion and dirty state
      mm: vmscan: do not reclaim from kswapd if there is any eligible zone
      mm, vmscan: make shrink_node decisions more node-centric
      mm, memcg: move memcg limit enforcement from zones to nodes
      mm, workingset: make working set detection node-aware
      mm, page_alloc: consider dirtyable memory in terms of nodes
      mm: move page mapped accounting to the node
      mm: rename NR_ANON_PAGES to NR_ANON_MAPPED
      mm: move most file-based accounting to the node
      mm: move vmscan writes and file write accounting to the node
      mm, vmscan: only wakeup kswapd once per node for the requested classzone
      mm, page_alloc: wake kswapd based on the highest eligible zone
      mm: convert zone_reclaim to node_reclaim
      mm, vmscan: avoid passing in classzone_idx unnecessarily to shrink_node
      mm, vmscan: avoid passing in classzone_idx unnecessarily to compaction_ready
      mm, vmscan: avoid passing in `remaining' unnecessarily to prepare_kswapd_sleep()
      mm, vmscan: Have kswapd reclaim from all zones if reclaiming and buffer_heads_over_limit
      mm, vmscan: add classzone information to tracepoints
      mm, page_alloc: remove fair zone allocation policy
      mm: page_alloc: cache the last node whose dirty limit is reached
      mm: vmstat: replace __count_zone_vm_events with a zone id equivalent
      mm: vmstat: account per-zone stalls and pages skipped during reclaim
      mm, vmstat: print node-based stats in zoneinfo file
      mm, vmstat: remove zone and node double accounting by approximating retries
      mm, pagevec: release/reacquire lru_lock on pgdat change
      mm, vmscan: Update all zone LRU sizes before updating memcg
      mm, vmscan: remove redundant check in shrink_zones()
      mm, vmscan: release/reacquire lru_lock on pgdat change
      mm, vmscan: remove highmem_file_pages
      mm: remove reclaim and compaction retry approximations
      mm: consider whether to decivate based on eligible zones inactive ratio
      mm, vmscan: account for skipped pages as a partial scan

Michal Hocko (22):
      Merge remote-tracking branch 'tj-cgroups/for-4.8' into mmotm-since-4.7
      Merge tag 'libnvdimm-for-4.8' into mmotm-since-4.7
      Merge remote-tracking branch 'tip/x86-mm-for-linus' into mmotm-since-4.7
      arm: get rid of superfluous __GFP_REPEAT
      slab: make GFP_SLAB_BUG_MASK information more human readable
      slab: do not panic on invalid gfp_mask
      mm, oom_reaper: make sure that mmput_async is called only when memory was reaped
      mm, memcg: use consistent gfp flags during readahead
      proc, oom: drop bogus task_lock and mm check
      proc, oom: drop bogus sighand lock
      proc, oom_adj: extract oom_score_adj setting into a helper
      mm, oom_adj: make sure processes sharing mm have same view of oom_score_adj
      mm, oom: skip vforked tasks from being selected
      mm, oom: kill all tasks sharing the mm
      mm, oom: fortify task_will_free_mem()
      mm, oom: task_will_free_mem should skip oom_reaped tasks
      mm, oom_reaper: do not attempt to reap a task more than twice
      mm, oom: hide mm which is shared with kthread or global init
      mm, oom: tighten task_will_free_mem() locking
      freezer, oom: check TIF_MEMDIE on the correct task
      cpuset, mm: fix TIF_MEMDIE check in cpuset_change_task_nodemask
      Revert "mm, mempool: only set __GFP_NOMEMALLOC if there are free elements"

Mikulas Patocka (2):
      mm: add cond_resched() to generic_swapfile_activate()
      mm: optimize copy_page_to/from_iter_iovec

Minchan Kim (19):
      mm: use put_page() to free page instead of putback_lru_page()
      mm: migrate: support non-lru movable page migration
      mm: balloon: use general non-lru movable page feature
      zsmalloc: keep max_object in size_class
      zsmalloc: use bit_spin_lock
      zsmalloc: use accessor
      zsmalloc: factor page chain functionality out
      zsmalloc: introduce zspage structure
      zsmalloc: separate free_zspage from putback_zspage
      zsmalloc: use freeobj for index
      zsmalloc: page migration support
      zram: use __GFP_MOVABLE for memory allocation
      zsmalloc: use OBJ_TAG_BIT for bit shifter
      mm: add NR_ZSMALLOC to vmstat
      mm: fix build warnings in <linux/compaction.h>
      mm, page_alloc: fix dirtyable highmem calculation
      mm: show node_pages_scanned per node, not zone
      mm: add per-zone lru list stat
      mm: bail out in shrink_inactive_list()

Naoya Horiguchi (2):
      mm: thp: check pmd_trans_unstable() after split_huge_pmd()
      mm: hwpoison: remove incorrect comments

Oliver O'Halloran (1):
      mm/init: fix zone boundary creation

Randy Dunlap (1):
      pnpbios: add header file to fix build errors

Reza Arbab (3):
      memory-hotplug: add move_pfn_range()
      memory-hotplug: more general validation of zone during online
      memory-hotplug: use zone_can_shift() for sysfs valid_zones attribute

Ross Zwisler (2):
      dax: some small updates to dax.txt documentation
      dax: remote unused fault wrappers

Sergey Senozhatsky (7):
      zram: rename zstrm find-release functions
      zram: switch to crypto compress API
      zram: use crypto api to check alg availability
      zram: cosmetic: cleanup documentation
      zram: delete custom lzo/lz4
      zram: add more compression algorithms
      zram: drop gfp_t from zcomp_strm_alloc()

Stephen Boyd (1):
      dma-debug: track bucket lock state for static checkers

Sudip Mukherjee (2):
      m32r: add __ucmpdi2 to fix build failure
      drivers/fpga/Kconfig: fix build failure

Tetsuo Handa (1):
      mm,oom: remove unused argument from oom_scan_process_thread().

Thomas Garnier (2):
      mm: reorganize SLAB freelist randomization
      mm: SLUB freelist randomization

Vegard Nossum (1):
      kmemleak: don't hang if user disables scanning early

Vladimir Davydov (10):
      mm: zap ZONE_OOM_LOCKED
      mm: oom: add memcg to oom_control
      mm: remove pointless struct in struct page definition
      mm: clean up non-standard page->_mapcount users
      mm: memcontrol: cleanup kmem charge functions
      mm: charge/uncharge kmemcg from generic page allocator paths
      mm: memcontrol: teach uncharge_list to deal with kmem pages
      arch: x86: charge page tables to kmemcg
      pipe: account to kmemcg
      af_unix: charge buffers to kmemcg

Vlastimil Babka (8):
      mm, frontswap: convert frontswap_enabled to static key
      mm, page_alloc: set alloc_flags only once in slowpath
      mm, page_alloc: don't retry initial attempt in slowpath
      mm, page_alloc: restructure direct compaction handling in slowpath
      mm, page_alloc: make THP-specific decisions more generic
      mm, thp: remove __GFP_NORETRY from khugepaged and madvised allocations
      mm, compaction: introduce direct compaction priority
      mm, compaction: simplify contended compaction handling

Wei Yongjun (1):
      mm/slab: use list_move instead of list_del/list_add

Xishi Qiu (1):
      mem-hotplug: alloc new page from a nearest neighbor node when mem-offline

Zhou Chengming (1):
      make __section_nr() more efficient

nimisolo (1):
      mm/memblock.c:memblock_add_range(): if nr_new is 0 just return

piaojun (1):
      ocfs2/cluster: clean up unnecessary assignment for 'ret'

zhong jiang (4):
      mm: update the comment in __isolate_free_page
      mm/hugetlb.c: fix race when migrating pages
      mm/page_owner: align with pageblock_nr pages
      mm/vmstat.c: walk the zone in pageblock_nr_pages steps

zijun_hu (1):
      mm/memblock.c: fix index adjustment error in __next_mem_range_rev()


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
