Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 35B2D6B0080
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 12:21:43 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id d49so8997408eek.41
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 09:21:42 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si30913281eer.117.2014.04.16.09.21.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 09:21:41 -0700 (PDT)
Date: Wed, 16 Apr 2014 18:21:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Subject: since-3.14 branch opened for mm git tree (was: Re: mmotm
 2014-04-15-16-14 uploaded)
Message-ID: <20140416162139.GE12866@dhcp22.suse.cz>
References: <20140415231550.2D2F05A4260@corp2gmr1-2.hot.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140415231550.2D2F05A4260@corp2gmr1-2.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

I have just created since-3.14 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v3.14 tag in Linus tree and mmotm-2014-04-15-16-14.

I have pulled some cgroup wide changes from Tejun and Pekka's slab
changes.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The current shortlog says:
Alex Thorlton (3):
      mm: revert "thp: make MADV_HUGEPAGE check for mm->def_flags"
      mm, thp: add VM_INIT_DEF_MASK and PRCTL_THP_DISABLE
      exec: kill the unnecessary mm->def_flags setting in load_elf_binary()

Andrew Morton (9):
      drivers/lguest/page_tables.c: rename do_set_pte()
      mips-export-flush_icache_range-fix
      mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3-fix
      pagewalk-update-page-table-walker-core-fix-end-address-calculation-in-walk_page_range-fix
      pagemap-redefine-callback-functions-for-page-table-walker-fix
      pagewalk-remove-argument-hmask-from-hugetlb_entry-fix-fix
      mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix
      mm/compaction.c:isolate_freepages_block(): small tuneup
      do_shared_fault(): check that mmap_sem is held

Andrey Vagin (1):
      proc: show mnt_id in /proc/pid/fdinfo

Bob Liu (1):
      mm: rmap: don't try to add an unevictable page to lru list

Catalin Marinas (1):
      arm64: Extend the PCI I/O space to 16MB

Choi Gi-yong (1):
      mm: fix 'ERROR: do not initialise globals to 0 or NULL' and coding style

Christoph Lameter (8):
      percpu: add raw_cpu_ops
      mm: use raw_cpu ops for determining current NUMA node
      modules: use raw_cpu_write for initialization of per cpu refcount.
      net: replace __this_cpu_inc in route.c with raw_cpu_inc
      slub: use raw_cpu_inc for incrementing statistics
      vmstat: use raw_cpu_ops to avoid false positives on preemption checks
      percpu: add preemption checks to __this_cpu ops
      vmscan: reclaim_clean_pages_from_list() must use mod_zone_page_state()

Colin Cross (1):
      dma-buf: avoid using IS_ERR_OR_NULL

Cyrill Gorcunov (3):
      mm: softdirty: make freshly remapped file pages being softdirty unconditionally
      mm: softdirty: don't forget to save file map softdiry bit on unmap
      mm: softdirty: clear VM_SOFTDIRTY flag inside clear_refs_write() instead of clear_soft_dirty()

Dave Hansen (2):
      mm: slab/slub: use page->list consistently instead of page->lru
      drop_caches: add some documentation and info message

Dave Jones (1):
      slub: fix leak of 'name' in sysfs_slab_add

Dave Young (1):
      x86/mm: sparse warning fix for early_memremap

David Howells (2):
      asm/system.h: clean asm/system.h from docs
      asm/system.h: um: arch_align_stack() moved to asm/exec.h

David Rientjes (9):
      mm, compaction: ignore pageblock skip when manually invoking compaction
      mm, hugetlb: mark some bootstrap functions as __init
      mm, compaction: avoid isolating pinned pages
      fork: collapse copy_flags into copy_process
      mm, mempolicy: rename slab_node for clarity
      mm, mempolicy: remove per-process flag
      res_counter: remove interface for locked charging and uncharging
      mm, compaction: determine isolation mode only once
      arch/x86/mm/kmemcheck/kmemcheck.c: use kstrtoint() instead of sscanf()

Davidlohr Bueso (7):
      mm, hugetlb: fix race in region tracking
      mm, hugetlb: improve page-fault scalability
      mm/memory.c: update comment in unmap_single_vma()
      mm: per-thread vma caching
      mm: fix CONFIG_DEBUG_VM_RB description
      mm,vmacache: add debug data
      mm,vmacache: optimize overflow system-wide flushing

Djalal Harouni (2):
      procfs: make /proc/*/{stack,syscall,personality} 0400
      procfs: make /proc/*/pagemap 0400

Emil Medve (1):
      memblock: use for_each_memblock()

Eric W. Biederman (1):
      vfs: Remove unnecessary calls of check_submounts_and_drop

Fabian Frederick (4):
      sys_sysfs: Add CONFIG_SYSFS_SYSCALL
      mm/memblock.c: use PFN_PHYS()
      mm/readahead.c: inline ra_submit
      kernel/panic.c: display reason at end + pr_emerg

Fengguang Wu (1):
      cgroup: fix coccinelle warnings

Gideon Israel Dsouza (2):
      mm: use macros from compiler.h instead of __attribute__((...))
      kernel: use macros from compiler.h instead of __attribute__((...))

Gioh Kim (1):
      mm/vmalloc.c: enhance vm_map_ram() comment

Guillaume Morin (1):
      kernel/exit.c: call proc_exit_connector() after exit_state is set

Jianyu Zhan (1):
      mm/slab.c: cleanup outdated comments and unify variables naming

Joe Perches (2):
      slab: Make allocations with GFP_ZERO slightly more efficient
      err.h: use bool for IS_ERR and IS_ERR_OR_NULL

Johannes Weiner (19):
      mm: vmstat: fix UP zone state accounting
      fs: cachefiles: use add_to_page_cache_lru()
      lib: radix-tree: add radix_tree_delete_item()
      mm: shmem: save one radix tree lookup when truncating swapped pages
      mm: filemap: move radix tree hole searching here
      mm + fs: prepare for non-page entries in page cache radix trees
      mm + fs: store shadow entries in page cache
      mm: thrash detection-based file cache sizing
      lib: radix_tree: tree node interface
      mm: keep page cache radix tree nodes in check
      mm: memcg: remove unnecessary preemption disabling
      mm: memcg: remove mem_cgroup_move_account_page_stat()
      mm: memcg: inline mem_cgroup_charge_common()
      mm: memcg: push !mm handling out to page cache charge function
      memcg: remove unnecessary !mm check from try_get_mem_cgroup_from_mm()
      memcg: get_mem_cgroup_from_mm()
      memcg: sanitize __mem_cgroup_try_charge() call protocol
      mm: page_alloc: spill to remote nodes before waking kswapd
      mm: vmscan: do not swap anon pages just because free+file is low

John Hubbard (1):
      mm/page_alloc.c: change mm debug routines back to EXPORT_SYMBOL

Joonsoo Kim (17):
      slab: factor out calculate nr objects in cache_estimate
      slab: introduce helper functions to get/set free object
      slab: restrict the number of objects in a slab
      slab: introduce byte sized index for the freelist of a slab
      slab: make more slab management structure off the slab
      slub: fix high order page allocation problem with __GFP_NOFAIL
      slab: fix wrongly used macro
      mm, hugetlb: unify region structure handling
      mm, hugetlb: improve, cleanup resv_map parameters
      mm, hugetlb: remove resv_map_put
      mm, hugetlb: use vma_resv_map() map types
      mm/compaction: disallow high-order page for migration target
      mm/compaction: do not call suitable_migration_target() on every page
      mm/compaction: change the timing to check to drop the spinlock
      mm/compaction: check pageblock suitability once per pageblock
      mm/compaction: clean-up code on success of ballon isolation
      zram: support REQ_DISCARD

Josh Triplett (7):
      ppc: make PPC_BOOK3S_64 select IRQ_WORK
      kconfig: make allnoconfig disable options behind EMBEDDED and EXPERT
      bug: when !CONFIG_BUG, simplify WARN_ON_ONCE and family
      include/asm-generic/bug.h: style fix: s/while(0)/while (0)/
      bug: when !CONFIG_BUG, make WARN call no_printk to check format and args
      bug: Make BUG() always stop the machine
      x86: always define BUG() and HAVE_ARCH_BUG, even with !CONFIG_BUG

Kees Cook (1):
      mips: export flush_icache_range

Kirill A. Shutemov (14):
      mm: rename __do_fault() -> do_fault()
      mm: do_fault(): extract to call vm_ops->do_fault() to separate function
      mm: introduce do_read_fault()
      mm: introduce do_cow_fault()
      mm: introduce do_shared_fault() and drop do_fault()
      mm: consolidate code to call vm_ops->page_mkwrite()
      mm: consolidate code to setup pte
      mm, thp: drop do_huge_pmd_wp_zero_page_fallback()
      mm: disable split page table lock for !MMU
      mm: introduce vm_ops->map_pages()
      mm: implement ->map_pages for page cache
      mm: cleanup size checks in filemap_fault() and filemap_map_pages()
      mm: add debugfs tunable for fault_around_order
      mm: use 'const char *' insted of 'char *' for reason in dump_page()

Konstantin Khlebnikov (1):
      tools/vm/page-types.c: page-cache sniffing feature

Li Zefan (10):
      cgroup: fix locking in cgroupstats_build()
      cgroup: fix memory leak in cgroup_mount()
      cgroup: deal with dummp_top in cgroup_name() and cgroup_path()
      cgroup: add a validation check to cgroup_add_cftyps()
      cpuset: use rcu_read_lock() to protect task_cs()
      cgroup: fix spurious lockdep warning in cgroup_exit()
      cgroup: remove useless argument from cgroup_exit()
      cpuset: use rcu_read_lock() to protect task_cs()
      kernfs: fix kernfs_node_from_dentry()
      cgroup: fix top cgroup refcnt leak

Luiz Capitulino (1):
      fs/proc/meminfo: meminfo_proc_show(): fix typo in comment

Mark Salter (4):
      mm: create generic early_ioremap() support
      x86: use generic early_ioremap
      arm64: initialize pgprot info earlier in boot
      arm64: add early_ioremap support

Mel Gorman (3):
      mm: optimize put_mems_allowed() usage
      mm: numa: recheck for transhuge pages under lock during protection changes
      mm: use paravirt friendly ops for NUMA hinting ptes

Michal Hocko (6):
      mm: exclude memoryless nodes from zone_reclaim
      memcg: do not replicate get_mem_cgroup_from_mm in __mem_cgroup_try_charge
      memcg: rename high level charging functions
      Merge remote-tracking branch 'tj/for-3.15' into mmotm-3.14
      cgroup: rename subsys_id -> id
      Merge remote-tracking branch 'pekka/slab/for-linus' into mmotm-3.14

Miklos Szeredi (1):
      mm: remove unused arg of set_page_dirty_balance()

Mikulas Patocka (1):
      mempool: add unlikely and likely hints

Minchan Kim (2):
      zram: propagate error to user
      mm/zswap: support multiple swap devices

Mizuma, Masayoshi (2):
      mm: hugetlb: fix softlockup when a large number of hugepages are freed.
      mm/hugetlb.c: add cond_resched_lock() in return_unused_surplus_pages()

Monam Agarwal (3):
      cgroup: Use RCU_INIT_POINTER(x, NULL) in cgroup.c
      fs/proc/inode.c: use RCU_INIT_POINTER(x, NULL)
      lib/idr.c: use RCU_INIT_POINTER(x, NULL)

Naoya Horiguchi (18):
      mm/hugetlb.c: add NULL check of return value of huge_pte_offset
      mm, hugetlbfs: fix rmapping for anonymous hugepages with page_pgoff()
      mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v2
      mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3
      pagewalk: update page table walker core
      mm/pagewalk.c: fix end address calculation in walk_page_range()
      pagewalk: add walk_page_vma()
      smaps: redefine callback functions for page table walker
      clear_refs: redefine callback functions for page table walker
      pagemap: redefine callback functions for page table walker
      numa_maps: redefine callback functions for page table walker
      memcg: redefine callback functions for page table walker
      arch/powerpc/mm/subpage-prot.c: use walk_page_vma() instead of walk_page_range()
      pagewalk: remove argument hmask from hugetlb_entry()
      fs/proc/task_mmu.c: assume non-NULL vma in pagemap_hugetlb()
      mempolicy: apply page table walker on queue_pages_range()
      mm: add !pte_present() check on existing hugetlb_entry callbacks
      mm/pagewalk.c: move pte null check

Ning Qu (1):
      mm: implement ->map_pages for shmem/tmpfs

Oleg Nesterov (10):
      exit: call disassociate_ctty() before exit_task_namespaces()
      exit: move check_stack_usage() to the end of do_exit()
      exec: kill bprm->tcomm[], simplify the "basename" logic
      wait: fix reparent_leader() vs EXIT_DEAD->EXIT_ZOMBIE race
      wait: introduce EXIT_TRACE to avoid the racy EXIT_DEAD->EXIT_ZOMBIE transition
      wait: use EXIT_TRACE only if thread_group_leader(zombie)
      wait: completely ignore the EXIT_DEAD tasks
      wait: swap EXIT_ZOMBIE and EXIT_DEAD to hide EXIT_TRACE from user-space
      wait: WSTOPPED|WCONTINUED hangs if a zombie child is traced by real_parent
      wait: WSTOPPED|WCONTINUED doesn't work if a zombie leader is traced by another process

Paul Gortmaker (1):
      sparc: fix implicit include of slab.h in leon_pci_grpci2.c

Peter Foley (1):
      init/Kconfig: move the trusted keyring config option to general setup

Raghavendra K T (1):
      mm/readahead.c: fix readahead failure for memoryless NUMA nodes and limit readahead pages

Rashika Kheria (8):
      mm/compaction.c: mark function as static
      mm/memory.c: mark functions as static
      mm/mmap.c: mark function as static
      mm/process_vm_access.c: mark function as static
      mm/page_cgroup.c: mark functions as static
      mm/nobootmem.c: mark function as static
      include/linux/mm.h: remove ifdef condition
      include/linux/crash_dump.h: add vmcore_cleanup() prototype

Richard Cochran (1):
      kernfs: fix off by one error.

Rik van Riel (2):
      mm,numa: reorganize change_pmd_range()
      mm: move mmu notifier call from change_protection to change_pmd_range

Roman Pen (1):
      fs/mpage.c: forgotten WRITE_SYNC in case of data integrity write

Sasha Levin (1):
      mm: remove read_cache_page_async()

SeongJae Park (3):
      mm/zswap.c: fix trivial typo and arrange indentation
      mm/zswap.c: update zsmalloc in comment to zbud
      mm/zswap.c: remove unnecessary parentheses

Sergey Senozhatsky (20):
      zram: drop `init_done' struct zram member
      zram: do not pass rw argument to __zram_make_request()
      zram: remove good and bad compress stats
      zram: use atomic64_t for all zram stats
      zram: remove zram stats code duplication
      zram: report failed read and write stats
      zram: drop not used table `count' member
      zram: move zram size warning to documentation
      zram: document failed_reads, failed_writes stats
      zram: delete zram_init_device()
      zram: introduce compressing backend abstraction
      zram: use zcomp compressing backends
      zram: factor out single stream compression
      zram: add multi stream functionality
      zram: add set_max_streams knob
      zram: make compression algorithm selection possible
      zram: add lz4 algorithm backend
      zram: move comp allocation out of init_lock
      zram: return error-valued pointer from zcomp_create()
      zram: use scnprintf() in attrs show() methods

Srikar Dronamraju (1):
      numa: use LAST_CPUPID_SHIFT to calculate LAST_CPUPID_MASK

Stephen Hemminger (1):
      idr: remove dead code

Stephen Rothwell (1):
      sun4M: add include of slab.h for kzalloc

Suleiman Souhlal (1):
      mm: only force scan in reclaim when none of the LRUs are big enough.

Tejun Heo (92):
      kernfs: make kernfs_deactivate() honor KERNFS_LOCKDEP flag
      kernfs: replace kernfs_node->u.completion with kernfs_root->deactivate_waitq
      kernfs: restructure removal path to fix possible premature return
      kernfs: invoke kernfs_unmap_bin_file() directly from kernfs_deactivate()
      kernfs: remove kernfs_addrm_cxt
      kernfs: remove KERNFS_ACTIVE_REF and add kernfs_lockdep()
      kernfs: remove KERNFS_REMOVED
      kernfs, sysfs, driver-core: implement kernfs_remove_self() and its wrappers
      pci: use device_remove_file_self() instead of device_schedule_callback()
      scsi: use device_remove_file_self() instead of device_schedule_callback()
      s390: use device_remove_file_self() instead of device_schedule_callback()
      sysfs, driver-core: remove unused {sysfs|device}_schedule_callback_owner()
      kernfs: invoke dir_ops while holding active ref of the target node
      kernfs: rename kernfs_dir_ops to kernfs_syscall_ops
      kernfs: implement kernfs_syscall_ops->remount_fs() and ->show_options()
      kernfs: add missing kernfs_active() checks in directory operations
      kernfs: allow nodes to be created in the deactivated state
      kernfs: implement kernfs_ops->atomic_write_len
      kernfs: add kernfs_open_file->priv
      kernfs: implement kernfs_node_from_dentry(), kernfs_root_from_sb() and kernfs_rename()
      kernfs: implement kernfs_get_parent(), kernfs_name/path() and friends
      sysfs, kobject: add sysfs wrapper for kernfs_enable_ns()
      kernfs: add CONFIG_KERNFS
      cgroup: make CONFIG_CGROUP_NET_PRIO bool and drop unnecessary init_netclassid_cgroup()
      cgroup: drop module support
      cgroup: clean up cgroup_subsys names and initialization
      cgroup: rename cgroup_subsys->subsys_id to ->id
      cgroup: update locking in cgroup_show_options()
      cgroup: remove cgroup_root_mutex
      Merge branch 'for-3.14-fixes' into for-3.15
      Merge branch 'driver-core-next' into cgroup/for-3.15
      Merge branch 'cgroup/for-3.14-fixes' into cgroup/for-3.15
      cgroup: improve css_from_dir() into css_tryget_from_dir()
      cgroup: introduce cgroup_tree_mutex
      cgroup: release cgroup_mutex over file removals
      cgroup: restructure locking and error handling in cgroup_mount()
      cgroup: factor out cgroup_setup_root() from cgroup_mount()
      cgroup: update cgroup name handling
      cgroup: make cgroup_subsys->base_cftypes use cgroup_add_cftypes()
      cgroup: update the meaning of cftype->max_write_len
      cgroup: introduce cgroup_init/exit_cftypes()
      cgroup: introduce cgroup_ino()
      cgroup: misc preps for kernfs conversion
      cgroup: relocate functions in preparation of kernfs conversion
      cgroup: convert to kernfs
      cgroup: warn if "xattr" is specified with "sane_behavior"
      cgroup: relocate cgroup_rm_cftypes()
      cgroup: remove cftype_set
      cgroup: simplify dynamic cftype addition and removal
      cgroup: make cgroup hold onto its kernfs_node
      cgroup: remove cgroup->name
      cgroup: rename cgroupfs_root->number_of_cgroups to ->nr_cgrps and make it atomic_t
      cgroup: remove cgroupfs_root->refcnt
      cgroup: disallow xattr, release_agent and name if sane_behavior
      cgroup: drop CGRP_ROOT_SUBSYS_BOUND
      cgroup: enable task_cg_lists on the first cgroup mount
      cgroup: relocate cgroup_enable_task_cg_lists()
      cgroup: implement cgroup_has_tasks() and unexport cgroup_task_count()
      cgroup: reimplement cgroup_transfer_tasks() without using css_scan_tasks()
      cgroup: make css_set_lock a rwsem and rename it to css_set_rwsem
      cpuset: use css_task_iter_start/next/end() instead of css_scan_tasks()
      cgroup: remove css_scan_tasks()
      cgroup: separate out put_css_set_locked() and remove put_css_set_taskexit()
      cgroup: move css_set_rwsem locking outside of cgroup_task_migrate()
      cgroup: drop @skip_css from cgroup_taskset_for_each()
      cpuset: don't use cgroup_taskset_cur_css()
      cgroup: remove cgroup_taskset_cur_css() and cgroup_taskset_size()
      cgroup: cosmetic updates to cgroup_attach_task()
      cgroup: unexport functions
      Merge branch 'cgroup/for-3.14-fixes' into cgroup/for-3.15
      cgroup: add css_set->mg_tasks
      cgroup: use css_set->mg_tasks to track target tasks during migration
      cgroup: separate out cset_group_from_root() from task_cgroup_from_root()
      cgroup: split process / task migration into four steps
      cgroup: update how a newly forked task gets associated with css_set
      cgroup: drop task_lock() protection around task->cgroups
      cgroup: update cgroup_transfer_tasks() to either succeed or fail
      cgroup_freezer: document freezer_fork() subtleties
      cgroup: relocate setting of CGRP_DEAD
      cgroup: reorganize cgroup bootstrapping
      cgroup: use cgroup_setup_root() to initialize cgroup_dummy_root
      cgroup: remove NULL checks from [pr_cont_]cgroup_{name|path}()
      cgroup: treat cgroup_dummy_root as an equivalent hierarchy during rebinding
      cgroup: move ->subsys_mask from cgroupfs_root to cgroup
      cgroup: rename cgroup_dummy_root and related names
      cgroup: drop const from @buffer of cftype->write_string()
      cgroup: make cgrp_dfl_root mountable
      cgroup: implement CFTYPE_ONLY_ON_DFL
      cgroup: fix cgroup_taskset walking order
      cgroup: break kernfs active_ref protection in cgroup directory operations
      kernfs: fix hash calculation in kernfs_rename_ns()
      cgroup: newly created dirs and files should be owned by the creator

Uwe Kleine-Konig (1):
      Kconfig: rename HAS_IOPORT to HAS_IOPORT_MAP

Vladimir Davydov (15):
      mm: vmscan: respect NUMA policy mask when shrinking slab on direct reclaim
      mm: vmscan: move call to shrink_slab() to shrink_zones()
      mm: vmscan: remove shrink_control arg from do_try_to_free_pages()
      mm: vmscan: shrink_slab: rename max_pass -> freeable
      kobject: don't block for each kobject_uevent
      slub: do not drop slab_mutex for sysfs_slab_add
      memcg, slab: never try to merge memcg caches
      memcg, slab: cleanup memcg cache creation
      memcg, slab: separate memcg vs root cache creation paths
      memcg, slab: unregister cache from memcg before starting to destroy it
      memcg, slab: do not destroy children caches if parent has aliases
      slub: adjust memcg caches when creating cache alias
      slub: rework sysfs layout for memcg caches
      sl[au]b: charge slabs to kmemcg explicitly
      mm: get rid of __GFP_KMEMCG

Vlastimil Babka (1):
      mm: try_to_unmap_cluster() should lock_page() before mlocking

WANG Chao (1):
      vmcore: continue vmcore initialization if PT_NOTE is found empty

Wang YanQing (1):
      kernel/groups.c: remove return value of set_groups

Weijie Yang (2):
      mm/vmscan: restore sc->gfp_mask after promoting it to __GFP_HIGHMEM
      mm/vmscan: do not check compaction_ready on promoted zones

Zhang Yanfei (1):
      madvise: correct the comment of MADV_DODUMP flag

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
