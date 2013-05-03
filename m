Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id B201E6B02E9
	for <linux-mm@kvack.org>; Fri,  3 May 2013 14:41:20 -0400 (EDT)
Date: Fri, 3 May 2013 20:41:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: since-3.9 branch opened for mm git tree
Message-ID: <20130503184113.GA30508@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, akpm@linux-foundation.org

Hi,
I have just created since-3.9 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v3.9 tag in Linus tree and mmots 2013-04-30-15-59 + all mm
patches already merged from mm tree and Tejun's for-3.10 (2a0010af)
branch merged because it contains many cgroups cleans which are
necessary for memcg.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1  D22D 48E2 09A2 B310 E347)

This also means that since-3.8 branch is no longer updated.

The current shortlog says:
Andrew Morton (11):
      mm/shmem.c: remove an ifdef
      include/linux/memory.h: implement register_hotmemory_notifier()
      ipc/util.c: use register_hotmemory_notifier()
      mm/slub.c: use register_hotmemory_notifier()
      drivers/base/node.c: switch to register_hotmemory_notifier()
      fs/proc/kcore.c: use register_hotmemory_notifier()
      kernel/cpuset.c: use register_hotmemory_notifier()
      revert "ipc: don't allocate a copy larger than max"
      include/linux/mmzone.h: cleanups
      include-linux-mmzoneh-cleanups-fix
      memcg-debugging-facility-to-access-dangling-memcgs-fix

Andrew Shewmaker (3):
      mm: limit growth of 3% hardcoded other user reserve
      mm: replace hardcoded 3% with admin_reserve_pages knob
      mm: reinititalise user and admin reserves if memory is added or removed

Anton Vorontsov (1):
      memcg: add memory.pressure_level events

Anurup m (1):
      fs/fscache/stats.c: fix memory leak

Aristeu Rozanski (4):
      devcg: expand may_access() logic
      devcg: prepare may_access() for hierarchy support
      devcg: use css_online and css_offline
      devcg: propagate local changes down the hierarchy

Atsushi Kumagai (1):
      kexec, vmalloc: export additional vmalloc layer information

Ben Hutchings (1):
      mm: try harder to allocate vmemmap blocks

Borislav Petkov (1):
      scripts/decodecode: make faulting insn ptr more robust

Catalin Marinas (1):
      arm: set the page table freeing ceiling to TASK_SIZE

Chen Gang (2):
      kernel/auditfilter.c: tree and watch will memory leak when failure occurs
      kernel/audit_tree.c: tree will leak memory when failure occurs in audit_trim_trees()

Cody P Schafer (4):
      page_alloc: make setup_nr_node_ids() usable for arch init code
      x86/mm/numa: use setup_nr_node_ids() instead of opencoding.
      powerpc/mm/numa: use setup_nr_node_ids() instead of opencoding.
      mm/vmstat: add note on safety of drain_zonestat

Cyril Hrubis (1):
      mm/mmap: check for RLIMIT_AS before unmapping

Darrick J. Wong (1):
      mm: make snapshotting pages for stable writes a per-bio operation

David Rientjes (4):
      mm, show_mem: suppress page counts in non-blockable contexts
      mm, hugetlb: include hugepages in meminfo
      mm, hotplug: avoid compiling memory hotremove functions when disabled
      mm, memcg: give exiting processes access to memory reserves

Dmitry Monakhov (1):
      fs: fix fsync() error reporting

Gao feng (3):
      audit: don't check if kauditd is valid every time
      audit: remove duplicate export of audit_enabled
      audit: remove unnecessary #if CONFIG_AUDIT

Gerald Schaefer (1):
      mm/hugetlb: add more arch-defined huge_pte functions

Glauber Costa (1):
      memcg: debugging facility to access dangling memcgs

Guenter Roeck (1):
      gcc4: disable __compiletime_object_size for GCC 4.6+

Hampson, Steven T (1):
      mm: merging memory blocks resets mempolicy

Hillf Danton (2):
      rmap: recompute pgoff for unmapping huge page
      mm/vmscan.c: minor cleanup for kswapd

Hugh Dickins (1):
      mm: allow arch code to control the user page table ceiling

James Hogan (1):
      debug_locks.h: make warning more verbose

Jan Kara (2):
      direct-io: fix boundary block handling
      direct-io: submit bio after boundary buffer is added to it

Jerome Marchand (1):
      swap: redirty page if page write fails on swap file

Jiang Liu (39):
      mm: introduce common help functions to deal with reserved/managed pages
      mm/alpha: use common help functions to free reserved pages
      mm/ARM: use common help functions to free reserved pages
      mm/avr32: use common help functions to free reserved pages
      mm/blackfin: use common help functions to free reserved pages
      mm/c6x: use common help functions to free reserved pages
      mm/cris: use common help functions to free reserved pages
      mm/FRV: use common help functions to free reserved pages
      mm/h8300: use common help functions to free reserved pages
      mm/IA64: use common help functions to free reserved pages
      mm/m32r: use common help functions to free reserved pages
      mm/m68k: use common help functions to free reserved pages
      mm/microblaze: use common help functions to free reserved pages
      mm/MIPS: use common help functions to free reserved pages
      mm/mn10300: use common help functions to free reserved pages
      mm/openrisc: use common help functions to free reserved pages
      mm/parisc: use common help functions to free reserved pages
      mm/ppc: use common help functions to free reserved pages
      mm/s390: use common help functions to free reserved pages
      mm/score: use common help functions to free reserved pages
      mm/SH: use common help functions to free reserved pages
      mm/um: use common help functions to free reserved pages
      mm/unicore32: use common help functions to free reserved pages
      mm/x86: use common help functions to free reserved pages
      mm/xtensa: use common help functions to free reserved pages
      mm/arc: use common help functions to free reserved pages
      mm/metag: use common help functions to free reserved pages
      mm,kexec: use common help functions to free reserved pages
      mm: introduce free_highmem_page() helper to free highmem pages into buddy system
      mm/ARM: use free_highmem_page() to free highmem pages into buddy system
      mm/FRV: use free_highmem_page() to free highmem pages into buddy system
      mm/metag: use free_highmem_page() to free highmem pages into buddy system
      mm/microblaze: use free_highmem_page() to free highmem pages into buddy system
      mm/MIPS: use free_highmem_page() to free highmem pages into buddy system
      mm/PPC: use free_highmem_page() to free highmem pages into buddy system
      mm/SPARC: use free_highmem_page() to free highmem pages into buddy system
      mm/um: use free_highmem_page() to free highmem pages into buddy system
      mm/x86: use free_highmem_page() to free highmem pages into buddy system
      mm/SPARC: use common help functions to free reserved pages

Jianguo Wu (1):
      mm/migrate: fix comment typo syncronous->synchronous

Johannes Weiner (4):
      sparse-vmemmap: specify vmemmap population range in bytes
      x86-64: remove dead debugging code for !pse setups
      x86-64: use vmemmap_populate_basepages() for !pse setups
      x86-64: fall back to regular page vmemmap on allocation failure

Joonsoo Kim (10):
      mm, vmalloc: change iterating a vmlist to find_vm_area()
      mm, vmalloc: move get_vmalloc_info() to vmalloc.c
      mm, vmalloc: protect va->vm by vmap_area_lock
      mm, vmalloc: iterate vmap_area_list, instead of vmlist in vread/vwrite()
      mm, vmalloc: iterate vmap_area_list in get_vmalloc_info()
      mm, vmalloc: iterate vmap_area_list, instead of vmlist, in vmallocinfo()
      mm, vmalloc: export vmap_area_list, instead of vmlist
      mm, vmalloc: remove list management of vmlist after initializing vmalloc
      mm, nobootmem: clean-up of free_low_memory_core_early()
      mm, nobootmem: do memset() after memblock_reserve()

Josh Triplett (1):
      fs: don't compile in drop_caches.c when CONFIG_SYSCTL=n

Kevin Wilson (1):
      cgroup: remove unused parameter in cgroup_task_migrate().

Kirill A. Shutemov (1):
      thp: fix huge zero page logic for page with pfn == 0

Kirill Tkhai (1):
      sparc64: Do not save/restore interrupts in get_new_mmu_context()

Li Zefan (24):
      cgroup: fix cgroup_path() vs rename() race
      cpuset: use cgroup_name() in cpuset_print_task_mems_allowed()
      cgroup: no need to check css refs for release notification
      cgroup: avoid accessing modular cgroup subsys structure without locking
      res_counter: remove include of cgroup.h from res_counter.h
      cpuset: remove include of cgroup.h from cpuset.h
      cpuset: fix RCU lockdep splat in cpuset_print_task_mems_allowed()
      cgroup: remove cgroup_is_descendant()
      cgroup: remove unused variables in cgroup_destroy_locked()
      cgroup: hold cgroup_mutex before calling css_offline()
      cgroup: don't bother to resize pid array
      cgroup: remove useless code in cgroup_write_event_control()
      cgroup: fix an off-by-one bug which may trigger BUG_ON()
      cgroup: consolidate cgroup_attach_task() and cgroup_attach_proc()
      cgroup: make sure parent won't be destroyed before its children
      cgroup: implement cgroup_is_descendant()
      cgroup: remove cgrp->top_cgroup
      cgroup: fix broken file xattrs
      cgroup: fix use-after-free when umounting cgroupfs
      cgroup: restore the call to eventfd->poll()
      cpuset: fix cpu hotplug vs rebuild_sched_domains() race
      cpuset: fix compile warning when CONFIG_SMP=n
      memcg: avoid accessing memcg after releasing reference
      memcg: take reference before releasing rcu_read_lock

Li Zhong (1):
      cpuset: use rebuild_sched_domains() in cpuset_hotplug_workfn()

Mel Gorman (2):
      mm: page_alloc: avoid marking zones full prematurely after zone_reclaim()
      mm: swap: mark swap pages writeback before queueing for direct IO

Michal Hocko (10):
      memcg: fix memcg_cache_name() to use cgroup_name()
      Merge remote-tracking branch 'tj-cgroups/for-3.10' into mmotm
      memcg: keep prev's css alive for the whole mem_cgroup_iter
      memcg: rework mem_cgroup_iter to use cgroup iterators
      memcg: relax memcg iter caching
      memcg: simplify mem_cgroup_iter
      memcg: further simplify mem_cgroup_iter
      cgroup: remove css_get_next
      memcg: do not check for do_swap_account in mem_cgroup_{read,write,reset}
      drop_caches: add some documentation and info message

Michel Lespinasse (2):
      mm/memcontrol.c: remove unnecessary ;
      mm: remove free_area_cache

Mike Yoknis (1):
      mm: memmap_init_zone() performance improvement

Minchan Kim (1):
      THP: fix comment about memory barrier

Ming Lei (1):
      fs/read_write.c: fix generic_file_llseek() comment

Naoya Horiguchi (1):
      HWPOISON: check dirty flag to match against clean page

Oleg Nesterov (2):
      kthread: introduce to_live_kthread()
      kthread: kill task_get_live_kthread()

Paul E. McKenney (1):
      vm: adjust ifdef for TINY_RCU

Rafael Aquini (1):
      mm: add vm event counters for balloon pages compaction

Rakib Mullick (1):
      kernel/auditsc.c: use kzalloc instead of kmalloc+memset

Rami Rosen (3):
      cgroups: Documentation/cgroup/cgroup.txt - a trivial fix.
      cgroup: remove bind() method from cgroup_subsys.
      devcg: remove parent_cgroup.

Randy Dunlap (1):
      mm: fix memory_hotplug.c printk format warning

Rasmus Villemoes (1):
      mm: madvise: complete input validation before taking lock

Rob Landley (1):
      mkcapflags.pl: convert to mkcapflags.sh

Robert Jarzmik (1):
      mm: trace filemap add and del

Russ Anderson (1):
      mm: speedup in __early_pfn_to_nid

Seth Jennings (2):
      mm: break up swap_writepage() for frontswap backends
      mm: allow for outstanding swap writeback accounting

Shaohua Li (1):
      mm: thp: add split tail pages to shrink page list in page reclaim

Srivatsa S. Bhat (1):
      mm: rewrite the comment over migrate_pages() more comprehensibly

Tang Chen (2):
      mm: Remove unused parameter of pages_correctly_reserved()
      memblock: fix missing comment of memblock_insert_region()

Tejun Heo (13):
      cgroup, cpuset: replace move_member_tasks_to_cpuset() with cgroup_transfer_tasks()
      cgroup: relocate cgroup_lock_live_group() and cgroup_attach_task_all()
      cgroup: unexport locking interface and cgroup_attach_task()
      cgroup: kill cgroup_[un]lock()
      cgroup: remove cgroup_lock_is_held()
      devcg: remove broken_hierarchy tag
      perf: make perf_event cgroup hierarchical
      Revert "cgroup: remove bind() method from cgroup_subsys."
      cgroup: make cgroup_path() not print double slashes
      cgroup: convert cgroupfs_root flag bits to masks and add CGRP_ prefix
      move cgroupfs_root to include/linux/cgroup.h
      cgroup: introduce sane_behavior mount option
      memcg: force use_hierarchy if sane_behavior

Tkhai Kirill (1):
      sparc64: Do not change num_physpages during initmem freeing

Toshi Kani (4):
      mm: walk_memory_range(): fix typo in comment
      resource: add __adjust_resource() for internal use
      resource: add release_mem_region_adjustable()
      mm: change __remove_pages() to call release_mem_region_adjustable()

Vinayak Menon (1):
      mmKconfig: add an option to disable bounce

Vineet Gupta (1):
      memblock: add assertion for zero allocation alignment

Xi Wang (2):
      drivers/usb/gadget/amd5536udc.c: avoid calling dma_pool_create() with NULL dev
      mm/dmapool.c: fix null dev in dma_pool_create()

Yasuaki Ishimatsu (3):
      firmware, memmap: fix firmware_map_entry leak
      numa, cpu hotplug: change links of CPU and node when changing node number by onlining CPU
      mem hotunplug: fix kfree() of bootmem memory

Yijing Wang (1):
      mm: remove CONFIG_HOTPLUG ifdefs

Zhang Yanfei (1):
      mmap: find_vma: remove the WARN_ON_ONCE(!mm) check

majianpeng (1):
      fs/buffer.c: remove unnecessary init operation after allocating buffer_head.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
