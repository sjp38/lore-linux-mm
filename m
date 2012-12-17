Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id D1D806B002B
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 09:43:03 -0500 (EST)
Date: Mon, 17 Dec 2012 15:43:00 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: -mm git tree for since-3.7 is open (was: mmotm 2012-12-14-17-51
 uploaded)
Message-ID: <20121217144300.GA25432@dhcp22.suse.cz>
References: <20121215015227.144C820004E@hpza10.eem.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121215015227.144C820004E@hpza10.eem.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Tejun Heo <htejun@gmail.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>

Hi,
I have just pushed a new since-3.7 branch to the -mm git tree
(git://git.kernel.org/.../mhocko/mm.git) which is tagged as
mmotm-2012-12-14-17-51.
This branch contains all -mm related patches on top of v3.7 Linus tree.

The following branches have been merged into the tree:
	- for-3.8 -git://git.kernel.org/.../tj/cgroup.git 
	- slab/next - git://git.kernel.org/.../penberg/linux.git
	- balancenuma-v11 - git://git.kernel.org/.../mel/linux-balancenuma
If there are any other that are needed for -mm, just let me know. If
there are any branches which will continue in development and they have
conflicts potential (e.g. cgroup with memcg work or slab with kmem
accounting) then let me know and I will set up them for periodic merging
(which expects that those branches are pre merge window like in the
past).

The shortlog says:
Andi Kleen (2):
      mm: support more pagesizes for MAP_HUGETLB/SHM_HUGETLB
      selftests: add a test program for variable huge page sizes in mmap/shmget

Andrea Arcangeli (5):
      mm: numa: define _PAGE_NUMA
      mm: numa: pte_numa() and pmd_numa()
      mm: numa: Support NUMA hinting page faults from gup/gup_fast
      mm: numa: split_huge_page: transfer the NUMA type from the pmd to the pte
      mm: numa: Structures for Migrate On Fault per NUMA migration rate limiting

Andrew Morton (11):
      arch/sparc/kernel/sys_sparc_64.c: s/COLOUR/COLOR/
      mm: add a reminder comment for __GFP_BITS_SHIFT
      memory-hotplug-document-and-enable-config_movable_node-fix
      slab-slub-struct-memcg_params-fix
      slub-slub-specific-propagation-changes-fix
      mm/mprotect.c: coding-style cleanups
      mm-hugetlb-create-hugetlb-cgroup-file-in-hugetlb_init-fix
      mm-hugetlb-create-hugetlb-cgroup-file-in-hugetlb_init-fix-2
      drop_caches-add-some-documentation-and-info-messsge-checkpatch-fixes
      swap-add-a-simple-detector-for-inappropriate-swapin-readahead-fix
      memcg-debugging-facility-to-access-dangling-memcgs-fix

Arnd Bergmann (1):
      mm/slob: use min_t() to compare ARCH_SLAB_MINALIGN

Bob Liu (4):
      thp: clean up __collapse_huge_page_isolate
      mm: introduce mm_find_pmd()
      thp: introduce hugepage_vma_check()
      thp: cleanup: introduce mk_huge_pmd()

Cesar Eduardo Barros (2):
      mm: refactor reinsert of swap_info in sys_swapoff()
      mm: do not call frontswap_init() during swapoff

Christoph Lameter (6):
      slub: Use correct cpu_slab on dead cpu
      slab: Simplify bootstrap
      mm, sl[au]b: create common functions for boot slab creation
      slub: Use statically allocated kmem_cache boot structure for bootstrap
      slab: Use the new create_boot_cache function to simplify bootstrap
      mm/sl[aou]b: Common alignment code

David Rientjes (9):
      mm, memcg: make mem_cgroup_out_of_memory() static
      mm, oom: allow exiting threads to have access to memory reserves
      mm, mempolicy: remove duplicate code
      mm, oom: change type of oom_score_adj to short
      mm, oom: fix race when specifying a thread as the oom origin
      mm, memcg: avoid unnecessary function call when memcg is disabled
      mm, oom: cleanup pagefault oom handler
      mm, oom: remove redundant sleep in pagefault oom handler
      mm, oom: remove statically defined arch functions of same name

Davidlohr Bueso (1):
      Documentation: ABI: /sys/devices/system/node/

Dominik Dingel (1):
      mm/memory.c: remove unused code from do_wp_page()

Ezequiel Garcia (4):
      mm/slob: Drop usage of page->private for storing page-sized allocations
      mm/slob: Use object_size field in kmem_cache_size()
      mm/sl[aou]b: Move common kmem_cache_size() to slab.h
      mm/slob: Use free_page instead of put_page for page-size kmalloc allocations

Gao feng (3):
      cgroup: use cgroup_addrm_files() in cgroup_clear_directory()
      cgroup: remove subsystem files when remounting cgroup
      cgroup_rm_file: don't delete the uncreated files

Glauber Costa (41):
      mm/sl[au]b: Move slabinfo processing to slab_common.c
      mm/sl[au]b: Move print_slabinfo_header to slab_common.c
      sl[au]b: Process slabinfo_show in common code
      slub: Commonize slab_cache field in struct page
      slab: Ignore internal flags in cache creation
      cgroup: warn about broken hierarchies only after css_online
      memcg: change defines to an enum
      memcg: kmem accounting basic infrastructure
      mm: add a __GFP_KMEMCG flag
      memcg: kmem controller infrastructure
      memcg: replace __always_inline with plain inline
      mm: allocate kernel pages to the right memcg
      res_counter: return amount of charges after res_counter_uncharge()
      memcg: kmem accounting lifecycle management
      memcg: use static branches when code not in use
      memcg: allow a memcg with kmem charges to be destructed
      memcg: execute the whole memcg freeing in free_worker()
      fork: protect architectures where THREAD_SIZE >= PAGE_SIZE against fork bombs
      memcg: add documentation about the kmem controller
      slab/slub: struct memcg_params
      slab: annotate on-slab caches nodelist locks
      slab/slub: consider a memcg parameter in kmem_create_cache
      memcg: allocate memory for memcg caches whenever a new memcg appears
      memcg: simplify ida initialization
      memcg: infrastructure to match an allocation to the right cache
      memcg: skip memcg kmem allocations in specified code regions
      memcg: remove test for current->mm in memcg_stop/resume_kmem_account
      sl[au]b: always get the cache from its page in kmem_cache_free()
      sl[au]b: allocate objects from memcg cache
      memcg: destroy memcg caches
      move include of workqueue.h to top of slab.h file
      memcg/sl[au]b: track all the memcg children of a kmem_cache
      memcg/sl[au]b: shrink dead caches
      memcg: get rid of once-per-second cache shrinking for dead memcgs
      memcg: aggregate memcg cache values in slabinfo
      slab: propagate tunable values
      slub: slub-specific propagation changes
      kmem: add slab-specific documentation about the kmem controller
      memcg: add comments clarifying aspects of cache attribute propagation
      slub: drop mutex before deleting sysfs entry
      memcg: debugging facility to access dangling memcgs

Greg Thelen (3):
      cgroup: fix lockdep warning for event_control
      cgroup: list_del_init() on removed events
      res_counter: delete res_counter_write()

Hillf Danton (2):
      mm: numa: split_huge_page: Transfer last_nid on tail page
      mm: numa: migrate: Set last_nid on newly allocated page

Hugh Dickins (2):
      tmpfs: support SEEK_DATA and SEEK_HOLE (reprise)
      mm: fix kernel BUG at huge_memory.c:1474!

Ingo Molnar (3):
      mm: Optimize the TLB flush of sys_mprotect() and change_protection() users
      mm/rmap: Convert the struct anon_vma::mutex to an rwsem
      mm/rmap, migration: Make rmap_walk_anon() and try_to_unmap_anon() more scalable

Jan Kara (1):
      mm: add comment on storage key dirty bit semantics

Jeff Liu (2):
      Documentation/cgroups/memory.txt: s/mem_cgroup_charge/mem_cgroup_change_common/
      mm/vmscan.c: try_to_freeze() returns boolean

Jiang Liu (2):
      mm: introduce new field "managed_pages" to struct zone
      mm: provide more accurate estimation of pages occupied by memmap

Jianguo Wu (1):
      mm/hugetlb: create hugetlb cgroup file in hugetlb_init

Joonsoo Kim (10):
      slub: remove one code path and reduce lock contention in __slab_free()
      mm, highmem: use PKMAP_NR() to calculate an index of pkmap
      mm, highmem: remove useless pool_lock
      mm, highmem: remove page_address_pool list
      mm, highmem: get virtual address of the page using PKMAP_ADDR()
      avr32, kconfig: remove HAVE_ARCH_BOOTMEM
      bootmem: fix wrong call parameter for free_bootmem()
      bootmem: remove not implemented function call, bootmem_arch_preferred_node()
      bootmem: remove alloc_arch_preferred_bootmem()
      mm: WARN_ON_ONCE if f_op->mmap() change vma's start address

Kirill A. Shutemov (16):
      mm: use IS_ENABLED(CONFIG_NUMA) instead of NUMA_BUILD
      mm: use IS_ENABLED(CONFIG_COMPACTION) instead of COMPACTION_BUILD
      thp: huge zero page: basic preparation
      thp: zap_huge_pmd(): zap huge zero pmd
      thp: copy_huge_pmd(): copy huge zero page
      thp: do_huge_pmd_wp_page(): handle huge zero page
      thp: change_huge_pmd(): make sure we don't try to make a page writable
      thp: change split_huge_page_pmd() interface
      thp: implement splitting pmd for huge zero page
      thp: setup huge zero page on non-write page fault
      thp: lazy huge zero page allocation
      thp: implement refcounting for huge zero page
      thp, vmstat: implement HZP_ALLOC and HZP_ALLOC_FAILED events
      thp: introduce sysfs knob to disable huge zero page
      thp: avoid race on multiple parallel page faults to the same page
      asm-generic, mm: pgtable: consolidate zero page helpers

Lai Jiangshan (22):
      memory_hotplug: fix possible incorrect node_states[N_NORMAL_MEMORY]
      slub, hotplug: ignore unrelated node's hot-adding and hot-removing
      drivers/base/node.c: cleanup node_state_attr[]
      mm, memory-hotplug: dynamic configure movable memory and portion memory
      memory_hotplug: handle empty zone when online_movable/online_kernel
      memory_hotplug: ensure every online node has NORMAL memory
      mm: node_states: introduce N_MEMORY
      cpuset: use N_MEMORY instead N_HIGH_MEMORY
      procfs: use N_MEMORY instead N_HIGH_MEMORY
      memcontrol: use N_MEMORY instead N_HIGH_MEMORY
      oom: use N_MEMORY instead N_HIGH_MEMORY
      mm,migrate: use N_MEMORY instead N_HIGH_MEMORY
      mempolicy: use N_MEMORY instead N_HIGH_MEMORY
      hugetlb: use N_MEMORY instead N_HIGH_MEMORY
      vmstat: use N_MEMORY instead N_HIGH_MEMORY
      kthread: use N_MEMORY instead N_HIGH_MEMORY
      init: use N_MEMORY instead N_HIGH_MEMORY
      vmscan: use N_MEMORY instead N_HIGH_MEMORY
      page_alloc: use N_MEMORY instead N_HIGH_MEMORY change the node_states initialization
      hotplug: update nodemasks management
      numa: add CONFIG_MOVABLE_NODE for movable-dedicated node
      memory_hotplug: allow online/offline memory to result movable node

Lee Schermerhorn (3):
      mm: mempolicy: Add MPOL_NOOP
      mm: mempolicy: Check for misplaced page
      mm: mempolicy: Add MPOL_MF_LAZY

Li Zhong (1):
      cgroup: move list add after list head initilization

Lin Feng (1):
      mm/bootmem.c: remove unused wrapper function reserve_bootmem_generic()

Marek Szyprowski (4):
      mm: cma: skip watermarks check for already isolated blocks in split_free_page()
      mm: cma: remove watermark hacks
      mm: use migrate_prep() instead of migrate_prep_local()
      mm: cma: WARN if freed memory is still in use

Matthieu CASTET (1):
      dmapool: make DMAPOOL_DEBUG detect corruption of free marker

Mel Gorman (26):
      mm: Check if PTE is already allocated during page fault
      mm: compaction: Move migration fail/success stats to migrate.c
      mm: migrate: Add a tracepoint for migrate_pages
      mm: compaction: Add scanned and isolated counters for compaction
      mm: numa: Create basic numa page hinting infrastructure
      mm: migrate: Drop the misplaced pages reference count if the target node is full
      mm: mempolicy: Use _PAGE_NUMA to migrate pages
      mm: mempolicy: Implement change_prot_numa() in terms of change_protection()
      mm: mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now
      sched, numa, mm: Count WS scanning against present PTEs, not virtual memory ranges
      mm: numa: Add pte updates, hinting and migration stats
      mm: numa: Migrate on reference policy
      mm: numa: Migrate pages handled during a pmd_numa hinting fault
      mm: numa: Rate limit the amount of memory that is migrated between nodes
      mm: numa: Rate limit setting of pte_numa if node is saturated
      sched: numa: Slowly increase the scanning period as NUMA faults are handled
      mm: numa: Introduce last_nid to the page frame
      mm: numa: Use a two-stage filter to restrict pages being migrated for unlikely task<->node relationships
      mm: sched: Adapt the scanning rate if a NUMA hinting fault does not migrate
      mm: sched: numa: Control enabling and disabling of NUMA balancing
      mm: sched: numa: Control enabling and disabling of NUMA balancing if !SCHED_DEBUG
      mm: sched: numa: Delay PTE scanning until a task is scheduled on a new node
      mm: numa: Add THP migration for the NUMA working set scanning fault case.
      mm: numa: Add THP migration for the NUMA working set scanning fault case build fix
      mm: numa: Account for failed allocations and isolations as migration failures
      mm: migrate: Account a transhuge page properly when rate limiting

Michal Hocko (10):
      memcg: split mem_cgroup_force_empty into reclaiming and reparenting parts
      memcg: root_cgroup cannot reach mem_cgroup_move_parent
      memcg: Simplify mem_cgroup_force_empty_list error handling
      memcg: make mem_cgroup_reparent_charges non failing
      hugetlb: do not fail in hugetlb_cgroup_pre_destroy
      memcg: do not check for mm in __mem_cgroup_count_vm_event
      Merge remote-tracking branch 'tj-cgroups/for-3.8' into mmotm
      Merge remote-tracking branch 'pekka/slab/next' into mmotm
      Merge tag 'balancenuma-v11' from git://git.kernel.org/.../mel/linux-balancenuma into mmotm
      drop_caches: add some documentation and info message

Michel Lespinasse (15):
      mm: augment vma rbtree with rb_subtree_gap
      mm: check rb_subtree_gap correctness
      mm: vm_unmapped_area() lookup function
      mm: use vm_unmapped_area() on x86_64 architecture
      mm: fix cache coloring on x86_64 architecture
      mm: use vm_unmapped_area() in hugetlbfs
      mm: use vm_unmapped_area() in hugetlbfs on i386 architecture
      mm: use vm_unmapped_area() on mips architecture
      mm: use vm_unmapped_area() on arm architecture
      mm: use vm_unmapped_area() on sh architecture
      mm: use vm_unmapped_area() on sparc32 architecture
      mm: use vm_unmapped_area() in hugetlbfs on tile architecture
      mm: use vm_unmapped_area() on sparc64 architecture
      mm: use vm_unmapped_area() in hugetlbfs on sparc64 architecture
      mm: protect against concurrent vma expansion

Mike Yoknis (1):
      mm: memmap_init_zone() performance improvement

Namjae Jeon (2):
      cgroup: update Documentation/cgroups/00-INDEX
      writeback: remove nr_pages_dirtied arg from balance_dirty_pages_ratelimited_nr()

Naoya Horiguchi (5):
      mm: hwpoison: fix action_result() to print out dirty/clean
      hwpoison, hugetlbfs: fix "bad pmd" warning in unmapping hwpoisoned hugepage
      hwpoison, hugetlbfs: fix RSS-counter warning
      mm/hugetlb.c: fix warning on freeing hwpoisoned hugepage
      mm: print out information of file affected by memory error

Oleg Nesterov (1):
      freezer: change ptrace_stop/do_signal_stop to use freezable_schedule()

Pekka Enberg (1):
      Merge branch 'slab/procfs' into slab/next

Peter Zijlstra (6):
      mm: Count the number of pages affected in change_protection()
      mm: mempolicy: Make MPOL_LOCAL a real policy
      mm: migrate: Introduce migrate_misplaced_page()
      mm: numa: Add fault driven placement and migration
      mm: sched: numa: Implement constant, per task Working Set Sampling (WSS) rate
      mm: sched: numa: Implement slow start for working set sampling

Petr Holasek (1):
      KSM: numa awareness sysfs knob

Rabin Vincent (1):
      mm: show migration types in show_mem

Rafael Aquini (7):
      mm: adjust address_space_operations.migratepage() return code
      mm: redefine address_space.assoc_mapping
      mm: introduce a common interface for balloon pages mobility
      mm: introduce compaction and migration for ballooned pages
      virtio_balloon: introduce migration primitives to balloon pages
      mm: introduce putback_movable_pages()
      mm: add vm event counters for balloon pages compaction

Randy Dunlap (1):
      mm: fix slab.c kernel-doc warnings

Rik van Riel (7):
      x86: mm: only do a local tlb flush in ptep_set_access_flags()
      x86: mm: drop TLB flush from ptep_set_access_flags
      mm,generic: only flush the local TLB in ptep_set_access_flags
      x86/mm: Introduce pte_accessible()
      mm: Only flush the TLB when clearing an accessible pte
      mm,vmscan: only evict file pages when we have plenty
      mm: rearrange vm_area_struct for fewer cache misses

Shaohua Li (1):
      swap: add a simple detector for inappropriate swapin readahead

Suleiman Souhlal (2):
      memcg: make it possible to use the stock for more than one page
      memcg: reclaim when more than one page needed

Tang Chen (2):
      mm/memory_hotplug.c: update start_pfn in zone and pg_data when spanned_pages == 0.
      memory-hotplug: document and enable CONFIG_MOVABLE_NODE

Tao Ma (2):
      cgroup: set 'start' with the right value in cgroup_path.
      cgroup: remove obsolete guarantee from cgroup_task_migrate.

Tejun Heo (51):
      cgroup: cgroup_subsys->fork() should be called after the task is added to css_set
      freezer: add missing mb's to freezer_count() and freezer_should_skip()
      cgroup_freezer: make it official that writes to freezer.state don't fail
      cgroup_freezer: don't stall transition to FROZEN for PF_NOFREEZE or PF_FREEZER_SKIP tasks
      cgroup_freezer: allow moving tasks in and out of a frozen cgroup
      cgroup_freezer: prepare update_if_frozen() for locking change
      cgroup_freezer: don't use cgroup_lock_live_group()
      cgroup: kill cgroup_subsys->__DEPRECATED_clear_css_refs
      cgroup: kill CSS_REMOVED
      cgroup: use cgroup_lock_live_group(parent) in cgroup_create()
      cgroup: deactivate CSS's and mark cgroup dead before invoking ->pre_destroy()
      cgroup: remove CGRP_WAIT_ON_RMDIR, cgroup_exclude_rmdir() and cgroup_release_and_wakeup_rmdir()
      cgroup: make ->pre_destroy() return void
      Merge branch 'cgroup-rmdir-updates' into cgroup/for-3.8
      Merge branch 'cgroup/for-3.7-fixes' into cgroup/for-3.8
      device_cgroup: add lockdep asserts
      cgroup: add cgroup_subsys->post_create()
      cgroup: use rculist ops for cgroup->children
      cgroup: implement generic child / descendant walk macros
      cgroup_freezer: trivial cleanups
      cgroup_freezer: prepare freezer_change_state() for full hierarchy support
      cgroup_freezer: make freezer->state mask of flags
      cgroup_freezer: introduce CGROUP_FREEZING_[SELF|PARENT]
      cgroup_freezer: add ->post_create() and ->pre_destroy() and track online state
      cgroup_freezer: implement proper hierarchy support
      cgroup: remove incorrect dget/dput() pair in cgroup_create_dir()
      cgroup: initialize cgrp->allcg_node in init_cgroup_housekeeping()
      cgroup: open-code cgroup_create_dir()
      cgroup: create directory before linking while creating a new cgroup
      cgroup: cgroup->dentry isn't a RCU pointer
      cgroup: make CSS_* flags bit masks instead of bit positions
      cgroup: trivial cleanup for cgroup_init/load_subsys()
      cgroup: lock cgroup_mutex in cgroup_init_subsys()
      cgroup: fix harmless bugs in cgroup_load_subsys() fail path and cgroup_unload_subsys()
      cgroup: separate out cgroup_destroy_locked()
      cgroup: introduce CSS_ONLINE flag and on/offline_css() helpers
      cgroup: simplify cgroup_load_subsys() failure path
      cgroup: use mutex_trylock() when grabbing i_mutex of a new cgroup directory
      cgroup: update cgroup_create() failure path
      cgroup: allow ->post_create() to fail
      cgroup: rename ->create/post_create/pre_destroy/destroy() to ->css_alloc/online/offline/free()
      cgroup: s/CGRP_CLONE_CHILDREN/CGRP_CPUSET_CLONE_CHILDREN/
      cgroup, cpuset: remove cgroup_subsys->post_clone()
      cgroup: add cgroup->id
      netcls_cgroup: move config inheritance to ->css_online() and remove .broken_hierarchy marking
      netprio_cgroup: simplify write_priomap()
      netprio_cgroup: shorten variable names in extend_netdev_table()
      netprio_cgroup: reimplement priomap expansion
      netprio_cgroup: use cgroup->id instead of cgroup_netprio_state->prioidx
      netprio_cgroup: implement netprio[_set]_prio() helpers
      netprio_cgroup: allow nesting and inherit config on cgroup creation

Thierry Reding (1):
      mm: compaction: Fix compiler warning

Wanpeng Li (1):
      mm/memblock: reduce overhead in binary search

Wen Congyang (7):
      memory-hotplug: skip HWPoisoned page when offlining pages
      memory-hotplug: update mce_bad_pages when removing the memory
      memory-hotplug: auto offline page_cgroup when onlining memory block failed
      memory-hotplug: fix NR_FREE_PAGES mismatch
      numa: convert static memory to dynamically allocated memory for per node device
      memory-hotplug, mm/sparse.c: clear the memory to store struct page
      memory-hotplug: allocate zone's pcp before onlining pages

Will Deacon (1):
      mm: thp: set the accessed flag for old pages on access fault

Xi Wang (2):
      drivers/usb/gadget/amd5536udc.c: avoid calling dma_pool_create() with NULL dev
      mm/dmapool.c: fix null dev in dma_pool_create()

Yan Hong (3):
      writeback: fix a typo in comment
      fs/buffer.c: do not inline exported function
      fs/buffer.c: remove redundant initialization in alloc_page_buffers()

Yasuaki Ishimatsu (3):
      memory hotplug: suppress "Device memoryX does not have a release() function" warning
      memory-hotplug: suppress "Device nodeX does not have a release() function" warning
      mm: cleanup register_node()
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
