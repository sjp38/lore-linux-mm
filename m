Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 949946B0032
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 07:19:57 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id l15so12314606wiw.4
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 04:19:56 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q10si1171128wjy.2.2014.12.16.04.19.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Dec 2014 04:19:55 -0800 (PST)
Date: Tue, 16 Dec 2014 13:19:53 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mmotm 2014-12-15-17-05 uploaded
Message-ID: <20141216121953.GC22914@dhcp22.suse.cz>
References: <548f85ac.CKlyI3on1DaQgGu+%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <548f85ac.CKlyI3on1DaQgGu+%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au

Subject: since-3.18 branch opened for mm git tree (was: Re: mmotm 2014-12-15-17-05 uploaded)

I have just created since-3.18 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v3.18 tag in Linus tree and mmotm-2014-12-15-17-05.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The current shortlog says:
Akinobu Mita (1):
      cma: make default CMA area size zero for x86

Alex Elder (1):
      printk: drop logbuf_cpu volatile qualifier

Andrew Morton (9):
      slab: improve checking for invalid gfp_flags
      fs/binfmt_misc.c: use GFP_KERNEL instead of GFP_USER
      include/linux/kmemleak.h: needs slab.h
      mm/page_alloc.c:__alloc_pages_nodemask(): don't alter arg gfp_mask
      mm-page_allocc-__alloc_pages_nodemask-dont-alter-arg-gfp_mask-fix
      mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix
      x86-add-pmd_-for-thp-fix
      sparc-add-pmd_-for-thp-fix
      do_shared_fault(): check that mmap_sem is held

Andrey Ryabinin (1):
      mm: slub: fix format mismatches in slab_err() callers

Andy Lutomirski (1):
      init: allow CONFIG_INIT_FALLBACK=n to disable defaults if init= fails

Aneesh Kumar K.V (1):
      mm/numa balancing: rearrange Kconfig entry

Anton Blanchard (1):
      mm/page_alloc.c: convert boot printks without log level to pr_info

Christoph Lameter (5):
      percpu: remove __get_cpu_var and __raw_get_cpu_var macros
      percpu: update local_ops.txt to reflect this_cpu operations
      parisc: percpu: update comments referring to __get_cpu_var
      percpu: Convert remaining __get_cpu_var uses in 3.18-rcX
      powerpc: Replace __get_cpu_var uses

Dan Carpenter (2):
      cpuset: lock vs unlock typo
      sh: off by one BUG_ON() in setup_bootmem_node()

Dave Hansen (2):
      ipc/shm.c: fix overly aggressive shmdt() when calls span multiple segments
      shmdt: use i_size_read() instead of ->i_size

David Rientjes (1):
      fs, seq_file: fallback to vmalloc instead of oom kill processes

Davidlohr Bueso (11):
      mm,fs: introduce helpers around the i_mmap_mutex
      mm: use new helper functions around the i_mmap_mutex
      mm: convert i_mmap_mutex to rwsem
      mm/rmap: share the i_mmap_rwsem
      uprobes: share the i_mmap_rwsem
      mm/xip: share the i_mmap_rwsem
      mm/memory-failure: share the i_mmap_rwsem
      mm/nommu: share the i_mmap_rwsem
      mm/memory.c: share the i_mmap_rwsem
      mm/rmap: calculate page offset when needed
      mm,vmacache: count number of system-wide flushes

Debabrata Banerjee (1):
      procfs: fix error handling of proc_register()

Dmitry Monakhov (2):
      ratelimit: add initialization macro
      fault-inject: add ratelimit option

Dmitry Vyukov (1):
      mm/vmalloc.c: fix memory ordering bug

Florian Fainelli (2):
      dma-debug: introduce dma_debug_disabled
      dma-debug: prevent early callers from crashing

Ganesh Mahendran (3):
      mm/zsmalloc: avoid duplicate assignment of prev_class
      mm/zsmalloc: allocate exactly size of struct zs_pool
      zram: use DEVICE_ATTR_[RW|RO|WO] to define zram sys device attribute

Gregory Fong (1):
      mm: cma: align to physical address, not CMA region position

Heesub Shin (1):
      mm/zbud: init user ops only when it is needed

Heinrich Schuchardt (1):
      fallocate: create FAN_MODIFY and IN_MODIFY events

Hillf Danton (1):
      mm: hugetlb: fix __unmap_hugepage_range()

Hugh Dickins (1):
      mm: unmapped page migration avoid unmap+remap overhead

James Custer (1):
      mm: fix invalid use of pfn_valid_within in test_pages_in_a_zone

Jamie Liu (1):
      mm: vmscan: count only dirty pages as congested

Jan Kara (2):
      fsnotify: unify inode and mount marks handling
      fsnotify: remove destroy_list from fsnotify_mark

Jesse Barnes (2):
      mm: export find_extend_vma() and handle_mm_fault() for driver use
      iommu/amd: use handle_mm_fault directly

Jianyu Zhan (1):
      mm, gfp: escalatedly define GFP_HIGHUSER and GFP_HIGHUSER_MOVABLE

Joe Perches (2):
      printk: remove used-once early_vprintk
      printk: add and use LOGLEVEL_<level> defines for KERN_<LEVEL> equivalents

Johannes Weiner (27):
      mm: memcontrol: lockless page counters
      mm: hugetlb_cgroup: convert to lockless page counters
      kernel: res_counter: remove the unused API
      mm: memcontrol: convert reclaim iterator to simple css refcounting
      mm: memcontrol: take a css reference for each charged page
      mm: memcontrol: remove obsolete kmemcg pinning tricks
      mm: memcontrol: continue cache reclaim from offlined groups
      mm: memcontrol: remove synchronous stock draining code
      mm: memcontrol: update mem_cgroup_page_lruvec() documentation
      mm: memcontrol: clarify migration where old page is uncharged
      mm: memcontrol: uncharge pages on swapout
      mm: memcontrol: remove unnecessary PCG_MEMSW memory+swap charge flag
      mm: memcontrol: remove unnecessary PCG_MEM memory charge flag
      mm: memcontrol: remove unnecessary PCG_USED pc->mem_cgroup valid flag
      mm: memcontrol: inline memcg->move_lock locking
      mm: memcontrol: don't pass a NULL memcg to mem_cgroup_end_move()
      mm: memcontrol: fold mem_cgroup_start_move()/mem_cgroup_end_move()
      mm: memcontrol: shorten the page statistics update slowpath
      mm: memcontrol: remove bogus NULL check after mem_cgroup_from_task()
      mm: memcontrol: pull the NULL check from __mem_cgroup_same_or_subtree()
      mm: memcontrol: drop bogus RCU locking from mem_cgroup_same_or_subtree()
      mm: memcontrol: remove stale page_cgroup_lock comment
      mm: embed the memcg pointer directly into struct page
      mm: page_cgroup: rename file to mm/swap_cgroup.c
      mm: move page->mem_cgroup bad page handling into generic code
      mm: vmscan: invoke slab shrinkers from shrink_zone()
      mm: page_alloc: embed OOM killing naturally into allocation slowpath

Joonsoo Kim (12):
      mm/CMA: fix boot regression due to physical address of high_memory
      mm/slab: reverse iteration on find_mergeable()
      mm/debug-pagealloc: cleanup page guard code
      mm/page_ext: resurrect struct page extending code for debugging
      mm/debug-pagealloc: prepare boottime configurable on/off
      mm/debug-pagealloc: make debug-pagealloc boottime configurable
      mm/nommu: use alloc_pages_exact() rather than its own implementation
      stacktrace: introduce snprint_stack_trace for buffer output
      mm/page_owner: keep track of page owners
      mm/page_owner: correct owner information for early allocated pages
      Documentation: add new page_owner document
      zsmalloc: merge size_class to reduce fragmentation

Jungseung Lee (1):
      fs/binfmt_elf.c: fix internal inconsistency relating to vma dump size

Kirill A. Shutemov (3):
      thp: do not mark zero-page pmd write-protected explicitly
      mm: fix huge zero page accounting in smaps report
      mm: replace remap_file_pages() syscall with emulation

LQYMGT (1):
      mm: slab/slub: coding style: whitespaces and tabs mixture

Li Haifeng (1):
      mm/frontswap.c: fix the condition in BUG_ON

Luiz Capitulino (3):
      hugetlb: fix hugepages= entry in kernel-parameters.txt
      hugetlb: alloc_bootmem_huge_page(): use IS_ALIGNED()
      hugetlb: hugetlb_register_all_nodes(): add __init marker

Mahendran Ganesh (3):
      mm/zsmalloc: support allocating obj with size of ZS_MAX_ALLOC_SIZE
      mm/zram: correct ZRAM_ZERO flag bit position
      mm/zswap: add __init to some functions in zswap

Manfred Spraul (3):
      ipc/sem.c: change memory barrier in sem_lock() to smp_rmb()
      ipc/sem.c: increase SEMMSL, SEMMNI, SEMOPM
      ipc/msg: increase MSGMNI, remove scaling

Markus Elfring (1):
      mm/zswap: delete unnecessary check before calling free_percpu()

Mel Gorman (1):
      mm: fadvise: document the fadvise(FADV_DONTNEED) behaviour for partial pages

Michal Hocko (3):
      Merge remote-tracking branch 'tj-cgroups/for-3.19' into mmotm-3.18
      mm: memcontrol: micro-optimize mem_cgroup_split_huge_fixup()
      mm, memcg: fix potential undefined behaviour in page stat accounting

Michal Nazarewicz (1):
      lib: bitmap: add alignment offset for bitmap_find_next_zero_area()

Michele Curti (1):
      mm/memcontrol.c: fix defined but not used compiler warning

Mike Frysinger (2):
      binfmt_misc: add comments & debug logs
      binfmt_misc: clean up code style a bit

Minchan Kim (10):
      zsmalloc: correct fragile [kmap|kunmap]_atomic use
      mm: support madvise(MADV_FREE)
      mm: define MADV_FREE for some arches
      x86: add pmd_[dirty|mkclean] for THP
      sparc: add pmd_[dirty|mkclean] for THP
      powerpc: add pmd_[dirty|mkclean] for THP
      arm: add pmd_mkclean for THP
      arm64: add pmd_[dirty|mkclean] for THP
      mm: don't split THP page when syscall is called
      mm: remove lock validation check for MADV_FREE

Nicolas Dichtel (2):
      fs/proc: use a rb tree for the directory entries
      fs/proc.c: use rb_entry_safe() instead of rb_entry()

Oleg Nesterov (30):
      proc: task_state: read cred->group_info outside of task_lock()
      proc: task_state: deuglify the max_fds calculation
      proc: task_state: move the main seq_printf() outside of rcu_read_lock()
      proc: task_state: ptrace_parent() doesn't need pid_alive() check
      sched_show_task: fix unsafe usage of ->real_parent
      exit: reparent: use ->ptrace_entry rather than ->sibling for EXIT_DEAD tasks
      exit: reparent: cleanup the changing of ->parent
      exit: reparent: cleanup the usage of reparent_leader()
      exit: ptrace: shift "reap dead" code from exit_ptrace() to forget_original_parent()
      usermodehelper: don't use CLONE_VFORK for ____call_usermodehelper()
      usermodehelper: kill the kmod_thread_locker logic
      exit: wait: cleanup the ptrace_reparented() checks
      exit: wait: don't use zombie->real_parent
      exit: wait: drop tasklist_lock before psig->c* accounting
      exit: release_task: fix the comment about group leader accounting
      exit: proc: don't try to flush /proc/tgid/task/tgid
      exit: reparent: fix the dead-parent PR_SET_CHILD_SUBREAPER reparenting
      exit: reparent: fix the cross-namespace PR_SET_CHILD_SUBREAPER reparenting
      exit: reparent: s/while_each_thread/for_each_thread/ in find_new_reaper()
      exit: reparent: document the ->has_child_subreaper checks
      exit: reparent: introduce find_child_reaper()
      exit: reparent: introduce find_alive_thread()
      exit: reparent: avoid find_new_reaper() if no children
      exit: reparent: call forget_original_parent() under tasklist_lock
      exit: exit_notify: re-use "dead" list to autoreap current
      exit: pidns: alloc_pid() leaks pid_namespace if child_reaper is exiting
      exit: pidns: fix/update the comments in zap_pid_ns_processes()
      oom: don't assume that a coredumping thread will exit soon
      oom: kill the insufficient and no longer needed PT_TRACE_EXIT check
      exit: fix race between wait_consider_task() and wait_task_zombie()

Paul Bolle (1):
      mm: Fix comment typo "CONFIG_TRANSPARNTE_HUGE"

Peter Zijlstra (11):
      locking/mutex: Don't assume TASK_RUNNING
      sched/wait: Provide infrastructure to deal with nested blocking
      sched/wait: Add might_sleep() checks
      sched, exit: Deal with nested sleeps
      sched, inotify: Deal with nested sleeps
      sched, tty: Deal with nested sleeps
      sched, smp: Correctly deal with nested sleeps
      sched, modules: Fix nested sleep in add_unformed_module()
      sched, net: Clean up sk_wait_event() vs. might_sleep()
      sched: Debug nested sleeps
      sched: Exclude cond_resched() from nested sleep test

Pintu Kumar (4):
      mm/vmalloc.c: replace printk with pr_warn
      mm/vmscan.c: replace printk with pr_err
      mm: cma: split cma-reserved in dmesg log
      fs: proc: include cma info in proc/meminfo

Pranith Kumar (1):
      slab: replace smp_read_barrier_depends() with lockless_dereference()

Prarit Bhargava (1):
      kernel: add panic_on_warn

Rickard Strandqvist (1):
      mm/memcontrol.c: remove unused mem_cgroup_lru_names_not_uptodate()

Roman Pen (1):
      fs/mpage.c: forgotten WRITE_SYNC in case of data integrity write

Sasha Levin (1):
      mm, hugetlb: correct bit shift in hstate_sizelog()

SeongJae Park (1):
      cgroups: Documentation: fix trivial typos and wrong paragraph numberings

Sergey Senozhatsky (1):
      zsmalloc: fix zs_init cpu notifier error handling

Sougata Santra (1):
      hfsplus: fix longname handling

Tejun Heo (7):
      cgroup: separate out cgroup_calc_child_subsys_mask() from cgroup_refresh_child_subsys_mask()
      cgroup: restructure child_subsys_mask handling in cgroup_subtree_control_write()
      cgroup: fix the async css offline wait logic in cgroup_subtree_control_write()
      cgroup: add cgroup_subsys->css_released()
      cgroup: add cgroup_subsys->css_e_css_changed()
      cgroup: implement cgroup_get_e_css()
      mm: move swp_entry_t definition to include/linux/mm_types.h

Thierry Reding (1):
      mm/cma: make kmemleak ignore CMA regions

Tony Luck (1):
      mm/memblock.c: refactor functions to set/clear MEMBLOCK_HOTPLUG

Vishnu Pratap Singh (1):
      lib/show_mem.c: adds cma reserved information

Vladimir Davydov (16):
      cpuset: convert callback_mutex to a spinlock
      cpuset: simplify cpuset_node_allowed API
      slab: print slabinfo header in seq show
      memcg: simplify unreclaimable groups handling in soft limit reclaim
      memcg: remove activate_kmem_mutex
      memcg: remove mem_cgroup_reclaimable check from soft reclaim
      memcg: use generic slab iterators for showing slabinfo
      memcg: __mem_cgroup_free: remove stale disarm_static_keys comment
      memcg: don't check mm in __memcg_kmem_{get_cache,newpage_charge}
      memcg: do not abuse memcg_kmem_skip_account
      memcg: zap kmem_account_flags
      memcg: only check memcg_kmem_skip_account in __memcg_kmem_get_cache
      memcg: turn memcg_kmem_skip_account into a bit field
      memcg: fix possible use-after-free in memcg_kmem_get_cache()
      slab: fix cpuset check in fallback_alloc
      slub: fix cpuset check in get_any_partial

Vlastimil Babka (9):
      mm: introduce single zone pcplists drain
      mm, page_isolation: drain single zone pcplists
      mm, cma: drain single zone pcplists
      mm, memory_hotplug/failure: drain single zone pcplists
      mm, compaction: pass classzone_idx and alloc_flags to watermark checking
      mm, compaction: simplify deferred compaction
      mm, compaction: defer only on COMPACT_COMPLETE
      mm, compaction: always update cached scanner positions
      mm, compaction: more focused lru and pcplists draining

Wei Yuan (1):
      mm: fix a spelling mistake

Weijie Yang (2):
      mm: mincore: add hwpoison page handle
      mm: page_isolation: check pfn validity before access

Yann Droneaud (5):
      ia64: replace get_unused_fd() with get_unused_fd_flags(0)
      ppc/cell: replace get_unused_fd() with get_unused_fd_flags(0)
      binfmt_misc: replace get_unused_fd() with get_unused_fd_flags(0)
      fs/file.c: replace get_unused_fd() with get_unused_fd_flags(0)
      include/linux/file.h: remove get_unused_fd() macro

Yu Zhao (1):
      mm: verify compound order when freeing a page

Zhang Zhen (2):
      memory-hotplug: remove redundant call of page_to_pfn
      mm/memcontrol.c: remove the unused arg in __memcg_kmem_get_cache()

Zhihui Zhang (1):
      mm/mempolicy.c: remove unnecessary is_valid_nodemask()

Zhong Hongbo (1):
      mm: remove the highmem zones' memmap in the highmem zone

karam.lee (3):
      zram: remove bio parameter from zram_bvec_rw()
      zram: change parameter from vaild_io_request()
      zram: implement rw_page operation of zram

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
