Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id B53766B0069
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 06:45:53 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id s18so2669607lam.9
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 03:45:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l5si34232910lam.12.2014.10.16.03.45.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Oct 2014 03:45:51 -0700 (PDT)
Date: Thu, 16 Oct 2014 12:45:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: since-3.17 branch opened for mm git tree (was: Re: mmotm
 2014-10-15-16-57 uploaded)
Message-ID: <20141016104548.GB338@dhcp22.suse.cz>
References: <543f0a1c.AmG8qX8YTuJY54NT%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <543f0a1c.AmG8qX8YTuJY54NT%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au

I have just created since-3.17 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v3.17 tag in Linus tree and mmotm-2014-10-15-16-57.

I have pulled some cgroup wide and percpu changes from Tejun which were
targeted at 3.18 to help memcg dependencies.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The current shortlog says:
Akinobu Mita (4):
      vfs: make guard_bh_eod() more generic
      vfs: guard end of device for mpage interface
      block_dev: implement readpages() to optimize sequential read
      cma: make default CMA area size zero for x86

Andrew Morton (9):
      mm/slab_common.c: suppress warning
      include/linux/migrate.h: remove migrate_page #define
      mm/mmap.c: clean up CONFIG_DEBUG_VM_RB checks
      mm/debug.c: use pr_emerg()
      mm-memcontrol-lockless-page-counters-fix
      mm-memcontrol-lockless-page-counters-fix
      mm-compaction-simplify-deferred-compaction-fix
      mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix
      do_shared_fault(): check that mmap_sem is held

Andrey Vagin (1):
      ipc: always handle a new value of auto_msgmni

Aneesh Kumar K.V (2):
      mm/gup.c: update generic gup implementation to handle hugepage directory
      arch/powerpc: switch to generic RCU get_user_pages_fast

Anton Blanchard (2):
      mm/page_alloc.c: convert boot printks without log level to pr_info
      powerpc: Enable DCACHE_WORD_ACCESS on ppc64le

Baoquan He (1):
      fs/proc/kcore.c: don't add modules range to kcore if it's equal to vmcore range

Chao Yu (1):
      zbud: avoid accessing last unused freelist

Christoph Lameter (2):
      slub: disable tracing and failslab for merged slabs
      vmstat: on-demand vmstat workers V8

Cyrill Gorcunov (4):
      mm: introduce check_data_rlimit helper
      mm: use may_adjust_brk helper
      prctl: PR_SET_MM -- factor out mmap_sem when updating mm::exe_file
      prctl: PR_SET_MM -- introduce PR_SET_MM_MAP operation

Dan Streetman (1):
      zsmalloc: simplify init_zspage free obj linking

David Rientjes (3):
      mm: rename allocflags_to_migratetype for clarity
      mm, compaction: pass gfp mask to compact_control
      mm, thp: fix collapsing of hugepages on madvise

Davidlohr Bueso (1):
      m68k: call find_vma with the mmap_sem held in sys_cacheflush()

Dongsheng Yang (1):
      cgroup: fix a typo in comment.

Geert Uytterhoeven (4):
      frv: remove unused cpuinfo_frv and friends to fix future build error
      alpha: use Kbuild logic to include <asm-generic/sections.h>
      include/linux/screen_info.h: remove unused ORIG_* macros
      nosave: consolidate __nosave_{begin,end} in <asm/sections.h>

Guenter Roeck (1):
      Revert "percpu: free percpu allocation info for uniprocessor system"

Heesub Shin (1):
      mm/zbud: init user ops only when it is needed

Ionut Alexa (1):
      kernel/async.c: switch to pr_foo()

Jamie Liu (1):
      mm: vmscan: count only dirty pages as congested

Jean Delvare (1):
      CMA: document cma=0

Jerry Hoemann (1):
      fsnotify: next_i is freed during fsnotify_unmount_inodes.

Johannes Weiner (12):
      mm: remove noisy remainder of the scan_unevictable interface
      mm: clean up zone flags
      mm: memcontrol: simplify detecting when the memory+swap limit is hit
      mm: memcontrol: fix transparent huge page allocations under pressure
      mm: memcontrol: lockless page counters
      mm: hugetlb_cgroup: convert to lockless page counters
      kernel: res_counter: remove the unused API
      mm: memcontrol: convert reclaim iterator to simple css refcounting
      mm: memcontrol: take a css reference for each charged page
      mm: memcontrol: remove obsolete kmemcg pinning tricks
      mm: memcontrol: continue cache reclaim from offlined groups
      mm: memcontrol: remove synchronous stock draining code

Joonsoo Kim (13):
      mm/slab_common: move kmem_cache definition to internal header
      mm/sl[ao]b: always track caller in kmalloc_(node_)track_caller()
      mm/slab: move cache_flusharray() out of unlikely.text section
      mm/slab: noinline __ac_put_obj()
      mm/slab: factor out unlikely part of cache_free_alien()
      topology: add support for node_to_mem_node() to determine the fallback node
      slub: fall back to node_to_mem_node() node if allocating on memoryless node
      mm/slab_common: commonize slab merge logic
      mm/slab: support slab merge
      mm/slab: use percpu allocator for cpu cache
      mm/slab: fix unaligned access on sparc64
      mm/compaction.c: avoid premature range skip in isolate_migratepages_range
      zsmalloc: merge size_class to reduce fragmentation

Junxiao Bi (1):
      mm: clear __GFP_FS when PF_MEMALLOC_NOIO is set

Konstantin Khlebnikov (4):
      mm/balloon_compaction: redesign ballooned pages management
      mm/balloon_compaction: remove balloon mapping and flag AS_BALLOON_MAP
      mm/balloon_compaction: add vmstat counters and kpageflags bit
      selftests/vm/transhuge-stress: stress test for memory compaction

Laura Abbott (5):
      lib/genalloc.c: add power aligned algorithm
      lib/genalloc.c: add genpool range check function
      common: dma-mapping: introduce common remapping functions
      arm: use genalloc for the atomic pool
      arm64: add atomic pool for non-coherent and CMA allocations

Li Zefan (3):
      cgroup: remove some useless forward declarations
      cgroup: remove redundant code in cgroup_rmdir()
      cgroup: remove bogus comments

Liviu Dudau (1):
      PCI: Add pci_remap_iospace() to map bus I/O resources

Marek Szyprowski (4):
      mm: cma: adjust address limit to avoid hitting low/high memory boundary
      ARM: mm: don't limit default CMA region only to low memory
      drivers: dma-contiguous: add initialization from device tree
      drivers: of: add return value to of_reserved_mem_device_init()

Mark Rustad (2):
      mm/page-writeback.c: use min3/max3 macros to avoid shadow warnings
      ipc: resolve shadow warnings

Masahiro Yamada (1):
      list: include linux/kernel.h

Mel Gorman (4):
      mm: remove misleading ARCH_USES_NUMA_PROT_NONE
      mm: page_alloc: Make paranoid check in move_freepages a VM_BUG_ON
      mm: page_alloc: default node-ordering on 64-bit NUMA, zone-ordering on 32-bit
      mm: mempolicy: skip inaccessible VMAs when setting MPOL_MF_LAZY

Michael Opdenacker (1):
      frv: remove deprecated IRQF_DISABLED

Michal Hocko (4):
      Merge remote-tracking branch 'tj-cgroups/for-3.18' into mmotm-3.17
      Merge remote-tracking branch 'tj-percpu/for-3.18' into mmotm-3.17
      mm: memcontrol: do not kill uncharge batching in free_pages_and_swap_cache
      mm-memcontrol-convert-reclaim-iterator-to-simple-css-refcounting-fix

Michal Nazarewicz (2):
      include/linux/kernel.h: rewrite min3, max3 and clamp using min and max
      include/linux/kernel.h: deduplicate code implementing clamp* macros

Michele Curti (1):
      include/linux/blkdev.h: use NULL instead of zero

Mikulas Patocka (1):
      slab: fix for_each_kmem_cache_node()

Minchan Kim (4):
      zsmalloc: move pages_allocated to zs_pool
      zsmalloc: change return value unit of zs_get_total_size_bytes
      zram: zram memory size limitation
      zram: report maximum used memory

Nishanth Aravamudan (1):
      kernel/kthread.c: partial revert of 81c98869faa5 ("kthread: ensure locality of task_struct allocations")

Oleg Nesterov (26):
      fs/proc/task_mmu.c: don't use task->mm in m_start() and show_*map()
      fs/proc/task_mmu.c: unify/simplify do_maps_open() and numa_maps_open()
      proc: introduce proc_mem_open()
      fs/proc/task_mmu.c: shift mm_access() from m_start() to proc_maps_open()
      fs/proc/task_mmu.c: simplify the vma_stop() logic
      fs/proc/task_mmu.c: cleanup the "tail_vma" horror in m_next()
      fs/proc/task_mmu.c: shift "priv->task = NULL" from m_start() to m_stop()
      fs/proc/task_mmu.c: kill the suboptimal and confusing m->version logic
      fs/proc/task_mmu.c: simplify m_start() to make it readable
      fs/proc/task_mmu.c: introduce m_next_vma() helper
      fs/proc/task_mmu.c: reintroduce m->version logic
      fs/proc/task_mmu.c: update m->version in the main loop in m_start()
      fs/proc/task_nommu.c: change maps_open() to use __seq_open_private()
      fs/proc/task_nommu.c: shift mm_access() from m_start() to proc_maps_open()
      fs/proc/task_nommu.c: don't use priv->task->mm
      proc/maps: replace proc_maps_private->pid with "struct inode *inode"
      proc/maps: make vm_is_stack() logic namespace-friendly
      mempolicy: change alloc_pages_vma() to use mpol_cond_put()
      mempolicy: change get_task_policy() to return default_policy rather than NULL
      mempolicy: sanitize the usage of get_task_policy()
      mempolicy: remove the "task" arg of vma_policy_mof() and simplify it
      mempolicy: introduce __get_vma_policy(), export get_task_policy()
      mempolicy: fix show_numa_map() vs exec() + do_set_mempolicy() race
      mempolicy: kill do_set_mempolicy()->down_write(&mm->mmap_sem)
      mempolicy: unexport get_vma_policy() and remove its "task" arg
      ipc/shm: kill the historical/wrong mm->start_stack check

Paul McQuade (5):
      mm/mremap.c: use linux headers
      mm/filemap.c: remove trailing whitespace
      mm/bootmem.c: use include/linux/ headers
      mm: ksm use pr_err instead of printk
      mm/dmapool.c: fixed a brace coding style issue

Peter Feiner (2):
      mm: softdirty: unmapped addresses between VMAs are clean
      mm: softdirty: enable write notifications on VMAs after VM_SOFTDIRTY cleared

Pintu Kumar (2):
      mm/vmalloc.c: replace printk with pr_warn
      mm/vmscan.c: replace printk with pr_err

Riku Voipio (1):
      gcov: add ARM64 to GCOV_PROFILE_ALL

Rob Jones (3):
      mm/vmalloc.c: use seq_open_private() instead of seq_open()
      mm/slab.c: use __seq_open_private() instead of seq_open()
      ipc/util.c: use __seq_open_private() instead of seq_open()

Roman Pen (1):
      fs/mpage.c: forgotten WRITE_SYNC in case of data integrity write

Sasha Levin (7):
      mm: introduce dump_vma
      mm: introduce VM_BUG_ON_VMA
      mm: convert a few VM_BUG_ON callers to VM_BUG_ON_VMA
      mm: move debug code out of page_alloc.c
      mm: introduce VM_BUG_ON_MM
      mm: use VM_BUG_ON_MM where possible
      kernel: add support for gcc 5

Scotty Bauer (1):
      kernel/sys.c: compat sysinfo syscall: fix undefined behavior

Sebastian Andrzej Siewior (1):
      mm: dmapool: add/remove sysfs file outside of the pool lock lock

Sebastien Buisson (1):
      fs/buffer.c: increase the buffer-head per-CPU LRU size

Sergey Senozhatsky (1):
      zram: use notify_free to account all free notifications

Steve Capper (6):
      mm: introduce a general RCU get_user_pages_fast()
      arm: mm: introduce special ptes for LPAE
      arm: mm: enable HAVE_RCU_TABLE_FREE logic
      arm: mm: enable RCU fast_gup
      arm64: mm: enable HAVE_RCU_TABLE_FREE logic
      arm64: mm: enable RCU fast_gup

Tejun Heo (34):
      percpu: remove the usage of separate populated bitmap in percpu-vm
      percpu: remove @may_alloc from pcpu_get_pages()
      percpu: move common parts out of pcpu_[de]populate_chunk()
      percpu: move region iterations out of pcpu_[de]populate_chunk()
      percpu: make percpu-km set chunk->populated bitmap properly
      percpu: restructure locking
      percpu: make pcpu_alloc_area() capable of allocating only from populated areas
      percpu: indent the population block in pcpu_alloc()
      percpu: implement [__]alloc_percpu_gfp()
      percpu: make sure chunk->map array has available space
      percpu: implmeent pcpu_nr_empty_pop_pages and chunk->nr_populated
      percpu: rename pcpu_reclaim_work to pcpu_balance_work
      percpu: implement asynchronous chunk population
      percpu_counter: make percpu_counters_lock irq-safe
      percpu_counter: add @gfp to percpu_counter_init()
      proportions: add @gfp to init functions
      percpu-refcount: add @gfp to percpu_ref_init()
      percpu: fix locking regression in the failure path of pcpu_alloc()
      Merge branch 'for-3.17-fixes' of ra.kernel.org:/.../tj/cgroup into for-3.18
      percpu-refcount: improve WARN messages
      percpu-refcount: make percpu_ref based on longs instead of ints
      Merge branch 'for-linus' of git://git.kernel.org/.../axboe/linux-block into for-3.18
      Revert "blk-mq, percpu_ref: implement a kludge for SCSI blk-mq stall during probe"
      percpu_ref: relocate percpu_ref_reinit()
      percpu_ref: minor code and comment updates
      percpu_ref: replace pcpu_ prefix with percpu_
      percpu_ref: rename things to prepare for decoupling percpu/atomic mode switch
      percpu_ref: add PCPU_REF_DEAD
      percpu_ref: decouple switching to atomic mode and killing
      percpu_ref: decouple switching to percpu mode and reinit
      percpu_ref: add PERCPU_REF_INIT_* flags
      percpu_ref: make INIT_ATOMIC and switch_to_atomic() sticky
      blk-mq, percpu_ref: start q->mq_usage_counter in atomic mode
      percpu: fix how @gfp is interpreted by the percpu allocator

Vincent Sanders (1):
      ARM: 8153/1: Enable gcov support on the ARM architecture

Vladimir Davydov (4):
      memcg: move memcg_{alloc,free}_cache_params to slab_common.c
      memcg: don't call memcg_update_all_caches if new cache id fits
      memcg: move memcg_update_cache_size() to slab_common.c
      memcg: zap memcg_can_account_kmem

Vlastimil Babka (21):
      mm: page_alloc: determine migratetype only once
      mm, THP: don't hold mmap_sem in khugepaged when allocating THP
      mm, compaction: defer each zone individually instead of preferred zone
      mm, compaction: do not count compact_stall if all zones skipped compaction
      mm, compaction: do not recheck suitable_migration_target under lock
      mm, compaction: move pageblock checks up from isolate_migratepages_range()
      mm, compaction: reduce zone checking frequency in the migration scanner
      mm, compaction: khugepaged should not give up due to need_resched()
      mm, compaction: periodically drop lock and restore IRQs in scanners
      mm, compaction: skip rechecks when lock was already held
      mm, compaction: remember position within pageblock in free pages scanner
      mm, compaction: skip buddy pages by their order in the migrate scanner
      mm: introduce single zone pcplists drain
      mm, page_isolation: drain single zone pcplists
      mm, cma: drain single zone pcplists
      mm, memory_hotplug/failure: drain single zone pcplists
      mm, compaction: pass classzone_idx and alloc_flags to watermark checking
      mm, compaction: simplify deferred compaction
      mm, compaction: defer only on COMPACT_COMPLETE
      mm, compaction: always update cached scanner positions
      mm, compaction: more focused lru and pcplists draining

Wang Nan (1):
      cgroup/kmemleak: add kmemleak_free() for cgroup deallocations.

Wang Sheng-Hui (1):
      mm/zsmalloc.c: correct comment for fullness group computation

Weijie Yang (2):
      mm: page_alloc: avoid wakeup kswapd on the unintended node
      mm/cma: fix cma bitmap aligned mask computing

Xiubo Li (1):
      mm/compaction.c: fix warning of 'flags' may be used uninitialized

Xue jiufei (1):
      ocfs2: fix a deadlock while o2net_wq doing direct memory reclaim

Yasuaki Ishimatsu (1):
      drivers/firmware/memmap.c: don't create memmap sysfs of same firmware_map_entry

Ying Xue (1):
      acct: eliminate compile warning

Yu Zhao (2):
      mm: free compound page with correct order
      mm: verify compound order when freeing a page

Zefan Li (9):
      cgroup: use a per-cgroup work for release agent
      cgroup: simplify proc_cgroup_show()
      cpuset: simplify proc_cpuset_show()
      cgroup: remove redundant check in cgroup_ino()
      perf/cgroup: Remove perf_put_cgroup()
      cgroup: remove CGRP_RELEASABLE flag
      cgroup: fix missing unlock in cgroup_release_agent()
      cgroup: remove redundant variable in cgroup_mount()
      Revert "cgroup: remove redundant variable in cgroup_mount()"

Zhang Zhen (1):
      memory-hotplug: add sysfs valid_zones attribute

vishnu.ps (2):
      mm/mmap.c: whitespace fixes
      kernel/sys.c: whitespace fixes

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
