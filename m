Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id D88ED6B0037
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 09:19:05 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id u57so3839359wes.17
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 06:19:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cg9si2195310wib.31.2014.06.20.06.18.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 06:18:55 -0700 (PDT)
Date: Fri, 20 Jun 2014 15:18:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: since-3.15 branch opened for mm git tree (was: Re: mmotm
 2014-06-19-16-33 uploaded)
Message-ID: <20140620131843.GC23115@dhcp22.suse.cz>
References: <53a37382.lV+82Dvr0NcrbYia%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53a37382.lV+82Dvr0NcrbYia%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org


I have just created since-3.15 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v3.15 tag in Linus tree and mmotm-2014-06-19-16-33.

I have pulled some cgroup wide changes from Tejun and tree wide barriers
change by Peter.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The current shortlog says:
Akinobu Mita (6):
      x86: make dma_alloc_coherent() return zeroed memory if CMA is enabled
      x86: enable DMA CMA with swiotlb
      intel-iommu: integrate DMA CMA
      memblock: introduce memblock_alloc_range()
      cma: add placement specifier for "cma=" kernel parameter
      arch/x86/kernel/pci-dma.c: fix dma_generic_alloc_coherent() when CONFIG_DMA_CMA is enabled

Andrew Morton (17):
      mm/huge_memory.c: complete conversion to pr_foo()
      include/linux/mmdebug.h: add VM_WARN_ON() and VM_WARN_ON_ONCE()
      fs/hugetlbfs/inode.c: complete conversion to pr_foo()
      init/main.c: don't use pr_debug()
      init/main.c: remove an ifdef
      hugetlb-fix-copy_hugetlb_page_range-to-handle-migration-hwpoisoned-entry-checkpatch-fixes
      slub-use-new-node-functions-checkpatch-fixes
      mm/page_alloc.c: unexport alloc_pages_exact_nid()
      dma-cma-support-arbitrary-bitmap-granularity-fix
      mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3-fix
      mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix
      mm/compaction.c:isolate_freepages_block(): small tuneup
      do_shared_fault(): check that mmap_sem is held
      memcg-deprecate-memoryforce_empty-knob-fix
      slab-use-get_node-and-kmem_cache_node-functions-fix-2
      mm-memcontrol-rewrite-charge-api-fix
      mm-memcontrol-rewrite-uncharge-api-fix

Andrey Ryabinin (2):
      mm: slab.h: wrap the whole file with guarding macro
      mm: slub: SLUB_DEBUG=n: use the same alloc/free hooks as for SLUB_DEBUG=y

Andy Shevchenko (2):
      mm/dmapool.c: reuse devres_release() to free resources
      include/linux/gfp.h: exclude duplicate header

Axel Lin (1):
      fs/binfmt_flat.c: make old_reloc() static

Borislav Petkov (1):
      kernel/printk: use symbolic defines for console loglevels

Catalin Marinas (4):
      mm: introduce kmemleak_update_trace()
      lib/radix-tree.c: update the kmemleak stack trace for radix tree allocations
      mm/mempool.c: update the kmemleak stack trace for mempool allocations
      mm/memblock.c: call kmemleak directly from memblock_(alloc|free)

Chen Yucong (3):
      hwpoison: remove unused global variable in do_machine_check()
      mm/swapfile.c: delete the "last_in_cluster < scan_base" loop in the body of scan_swap_map()
      hwpoison: fix the handling path of the victimized page frame that belong to non-LRU

Christoph Lameter (8):
      percpu: Replace __get_cpu_var with this_cpu_ptr
      mm: replace __get_cpu_var uses with this_cpu_ptr
      MAINTAINERS: SLAB maintainer update
      slab common: add functions for kmem_cache_node access
      slub: use new node functions
      slub-use-new-node-functions-fix
      slab: use get_node() and kmem_cache_node() functions
      slab-use-get_node-and-kmem_cache_node-functions-fix

Cyrill Gorcunov (5):
      mm: softdirty: make freshly remapped file pages being softdirty unconditionally
      mm: softdirty: don't forget to save file map softdiry bit on unmap
      mm: softdirty: clear VM_SOFTDIRTY flag inside clear_refs_write() instead of clear_soft_dirty()
      mm: x86 pgtable: drop unneeded preprocessor ifdef
      mm: x86 pgtable: require X86_64 for soft-dirty tracker

Daeseok Youn (1):
      mm/dmapool.c: remove redundant NULL check for dev in dma_pool_create()

Dan Carpenter (1):
      lib/string.c: use the name "C-string" in comments

Dan Streetman (7):
      swap: change swap_info singly-linked list to list_head
      lib/plist: add helper functions
      lib/plist: add plist_requeue
      swap: change swap_list_head to plist, add swap_avail_head
      Documentation: expand/clarify debug documentation
      lib/plist.c: replace pr_debug with printk in plist_test()
      lib/plist.c: make CONFIG_DEBUG_PI_LIST selectable

Dave Chinner (1):
      fs/superblock: unregister sb shrinker before ->kill_sb()

Dave Hansen (5):
      mm: slub: fix ALLOC_SLOWPATH stat
      mm: pass VM_BUG_ON() reason to dump_page()
      mm: debug: make bad_range() output more usable and readable
      mm: shrinker trace points: fix negatives
      mm: shrinker: add nid to tracepoint output

David Rientjes (10):
      mm, slab: suppress out of memory warning unless debug is enabled
      mm, migration: add destination page freeing callback
      mm, compaction: return failed migration target pages back to freelist
      mm, compaction: add per-zone migration pfn cache for async compaction
      mm, compaction: embed migration mode in compact_control
      mm, thp: avoid excessive compaction latency during fault
      mm, compaction: terminate async compaction when rescheduling
      mm, hotplug: probe interface is available on several platforms
      mm, slab: mark enable_cpucache as init text
      mm, slub: mark resiliency_test as init text

Davidlohr Bueso (9):
      mm,vmacache: add debug data
      mm,vmacache: optimize overflow system-wide flushing
      arc: call find_vma with the mmap_sem held
      ipc,shm: document new limits in the uapi header
      ipc,msg: use current->state helpers
      ipc,msg: move some msgq ns code around
      ipc,msg: document volatile r_msg
      blackfin/ptrace: call find_vma with the mmap_sem held
      m68k: call find_vma with the mmap_sem held in sys_cacheflush()

Denys Vlasenko (1):
      Documentation/sysctl/vm.txt: clarify vfs_cache_pressure description

Don Zickus (1):
      kernel/watchdog.c: remove preemption restrictions when restarting lockup detector

Duan Jiong (1):
      mm/mmap.c: replace IS_ERR and PTR_ERR with PTR_ERR_OR_ZERO

Emil Medve (1):
      arch/x86/mm/numa.c: use for_each_memblock()

Eric Dumazet (1):
      mm/zswap: NUMA aware allocation for zswap_dstmem

Fabian Frederick (57):
      kernel/cgroup.c: fix 2 kernel-doc warnings
      kernel/cpuset.c: kernel-doc fixes
      kernel/cpuset.c: convert printk to pr_foo()
      fs/fscache: convert printk to pr_foo()
      fs/fscache: replace seq_printf by seq_puts
      lib/debugobjects.c: convert printk to pr_foo()
      lib/debugobjects.c: add pr_fmt to logging
      lib/debugobjects.c: convert printk(KERN_DEBUG to pr_debug
      fs/libfs.c: add generic data flush to fsync
      mm/slub.c: convert printk to pr_foo()
      mm/slub.c: convert vnsprintf-static to va_format
      mm/memory_hotplug.c: use PFN_DOWN()
      mm/memblock.c: use PFN_DOWN
      mm/memcontrol.c: remove NULL assignment on static
      mm/vmalloc.c: replace seq_printf by seq_puts
      mm/mempolicy.c: parameter doc uniformization
      fs/hugetlbfs/inode.c: add static to hugetlbfs_i_mmap_mutex_key
      fs/hugetlbfs/inode.c: use static const for dentry_operations
      fs/hugetlbfs/inode.c: remove null test before kfree
      mm/zbud.c: make size unsigned like unique callsite
      sys_sgetmask/sys_ssetmask: add CONFIG_SGETMASK_SYSCALL
      fs/efivarfs/super.c: use static const for dentry_operations
      fs/exportfs/expfs.c: kernel-doc warning fixes
      kernel/cpu.c: convert printk to pr_foo()
      kernel/backtracetest.c: replace no level printk by pr_info()
      kernel/capability.c: code clean-up
      kernel/exec_domain.c: code clean-up
      kernel/latencytop.c: convert seq_printf to seq_puts
      kernel/stop_machine.c: kernel-doc warning fix
      kernel/tracepoint.c: kernel-doc fixes
      kernel/res_counter.c: replace simple_strtoull by kstrtoull
      kernel/reboot.c: convert simple_strtoul to kstrtoint
      kernel/utsname_sysctl.c: replace obsolete __initcall by device_initcall
      kernel/hung_task.c: convert simple_strtoul to kstrtouint
      lib/libcrc32c.c: use PTR_ERR_OR_ZERO
      lib/vsprintf.c: fix comparison to bool
      lib/radix-tree.c: kernel-doc warning fix
      lib/crc32.c: remove unnecessary __constant
      lib/digsig.c: kernel-doc warning fixes
      lib/nlattr.c: move EXPORT_SYMBOL after functions
      lib/textsearch.c: move EXPORT_SYMBOL after functions
      lib/bug.c: convert printk to pr_foo()
      lib/atomic64_test.c: convert printk(KERN_INFO to pr_info
      lib/asn1_decoder.c: kernel-doc warning fix
      kernel/compat.c: use sizeof() instead of sizeof
      fs/efs: convert printk to pr_foo()
      fs/efs: add pr_fmt / use __func__
      fs/efs: convert printk(KERN_DEBUG to pr_debug
      fs/binfmt_elf.c: fix bool assignements
      kernel/seccomp.c: kernel-doc warning fix
      mm/kmemleak-test.c: use pr_fmt for logging
      mm/slab.c: add __init to init_lock_keys
      mm/readahead.c: remove unused file_ra_state from count_history_pages
      mm/memory_hotplug.c: add __meminit to grow_zone_span/grow_pgdat_span
      mm/page_alloc.c: add __meminit to alloc_pages_exact_nid()
      include/linux/memblock.h: add __init to memblock_set_bottom_up()
      mm/internal.h: use nth_page

Gioh Kim (1):
      drivers/base/dma-contiguous.c: erratum of dev_get_cma_area

Heesub Shin (1):
      mm/compaction: clean up unused code lines

Heinrich Schuchardt (1):
      fanotify: check file flags passed in fanotify_init

Huang Shijie (1):
      mm/mmap.c: remove the first mapping check

Hugh Dickins (4):
      mm: fix sleeping function warning from __put_anon_vma
      mm, memcg: periodically schedule when emptying page list
      tmpfs: ZERO_RANGE and COLLAPSE_RANGE not currently supported
      mm/memory.c: use entry = ACCESS_ONCE(*pte) in handle_pte_fault()

James Hogan (1):
      compiler.h: avoid sparse errors in __compiletime_error_fallback()

Jan Kara (4):
      printk: remove outdated comment
      printk: release lockbuf_lock before calling console_trylock_for_printk()
      printk: fix lockdep instrumentation of console_sem
      printk: enable interrupts before calling console_trylock_for_printk()

Jianpeng Ma (1):
      mm/kmemleak.c: use %u to print ->checksum

Jianyu Zhan (13):
      cgroup: clean up obsolete comment for parse_cgroupfs_options()
      cgroup: remove orphaned cgroup_pidlist_seq_operations
      cgroup: replace pr_warning with preferred pr_warn
      mm/swap.c: clean up *lru_cache_add* functions
      mm/swap.c: introduce put_[un]refcounted_compound_page helpers for splitting put_compound_page()
      mm/swap.c: split put_compound_page()
      mm: introdule compound_head_by_tail()
      mm: use the light version __mod_zone_page_state in mlocked_vma_newpage()
      mm: fold mlocked_vma_newpage() into its only call site
      mm, hugetlb: move the error handle logic out of normal code path
      mm/vmscan.c: use DIV_ROUND_UP for calculation of zone's balance_gap and correct comments.
      mm/page-writeback.c: remove outdated comment
      mm: memcontrol: clean up memcg zoneinfo lookup

Joe Perches (19):
      cgroup: Use more current logging style
      arm: convert use of typedef ctl_table to struct ctl_table
      ia64: convert use of typedef ctl_table to struct ctl_table
      tile: convert use of typedef ctl_table to struct ctl_table
      cdrom: convert use of typedef ctl_table to struct ctl_table
      random: convert use of typedef ctl_table to struct ctl_table
      parport: convert use of typedef ctl_table to struct ctl_table
      scsi: convert use of typedef ctl_table to struct ctl_table
      coda: convert use of typedef ctl_table to struct ctl_table
      fscache: convert use of typedef ctl_table to struct ctl_table
      lockd: convert use of typedef ctl_table to struct ctl_table
      nfs: convert use of typedef ctl_table to struct ctl_table
      inotify: convert use of typedef ctl_table to struct ctl_table
      ntfs: convert use of typedef ctl_table to struct ctl_table
      fs: convert use of typedef ctl_table to struct ctl_table
      key: convert use of typedef ctl_table to struct ctl_table
      ipc: convert use of typedef ctl_table to struct ctl_table
      sysctl: convert use of typedef ctl_table to struct ctl_table
      mm: convert use of typedef ctl_table to struct ctl_table

Johannes Weiner (15):
      mm: memcontrol: remove hierarchy restrictions for swappiness and oom_control
      mm: vmscan: clear kswapd's special reclaim powers before exiting
      mm: memcontrol: remove unnecessary memcg argument from soft limit functions
      mm: memcontrol: fold mem_cgroup_do_charge()
      mm: memcontrol: rearrange charging fast path
      mm: memcontrol: reclaim at least once for __GFP_NORETRY
      mm: huge_memory: use GFP_TRANSHUGE when charging huge pages
      mm: memcontrol: retry reclaim for oom-disabled and __GFP_NOFAIL charges
      mm: memcontrol: simplify move precharge function
      mm: memcontrol: catch root bypass in move precharge
      mm: memcontrol: use root_mem_cgroup res_counter
      mm: memcontrol: remove ordering between pc->mem_cgroup and PageCgroupUsed
      mm: memcontrol: do not acquire page_cgroup lock for kmem pages
      mm: memcontrol: rewrite charge API
      mm: memcontrol: rewrite uncharge API

John Stultz (4):
      printk: disable preemption for printk_sched
      printk: rename printk_sched to printk_deferred
      printk: Add printk_deferred_once
      timekeeping: use printk_deferred when holding timekeeping seqlock

Jonathan Gonzalez V (1):
      drm/exynos: call find_vma with the mmap_sem held

Joonsoo Kim (11):
      slub: search partial list on numa_mem_id(), instead of numa_node_id()
      vmalloc: use rcu list iterator to reduce vmap_area_lock contention
      CMA: correct unlock target
      DMA, CMA: separate core CMA management codes from DMA APIs
      DMA, CMA: support alignment constraint on CMA region
      DMA, CMA: support arbitrary bitmap granularity
      CMA: generalize CMA reserved area management functionality
      PPC, KVM, CMA: use general CMA reserved area management framework
      mm, CMA: clean-up CMA allocation error path
      mm, CMA: change cma_declare_contiguous() to obey coding convention
      mm, CMA: clean-up log message

Josh Triplett (1):
      MAINTAINERS: add linux-api for review of API/ABI changes

Kirill A. Shutemov (13):
      thp: consolidate assert checks in __split_huge_page()
      mm: move get_user_pages()-related code to separate file
      mm: extract in_gate_area() case from __get_user_pages()
      mm: cleanup follow_page_mask()
      mm: extract code to fault in a page from __get_user_pages()
      mm: cleanup __get_user_pages()
      mm/rmap.c: make page_referenced_one() and try_to_unmap_one() static
      mm: update comment for DEFAULT_MAX_MAP_COUNT
      mm: fix typo in comment in do_fault_around()
      mm: nominate faultaround area in bytes rather than page order
      mm: document do_fault_around() feature
      kernel/user.c: drop unused field 'files' from user_struct
      mm: mark remap_file_pages() syscall as deprecated

Konstantin Khlebnikov (4):
      tools/vm/page-types.c: catch sigbus if raced with truncate
      mm/process_vm_access: move config option into init/Kconfig
      mm/rmap.c: don't call mmu_notifier_invalidate_page() during munlock
      mm/rmap.c: cleanup ttu_flags

Lasse Collin (2):
      lib/xz: add comments for the intentionally missing break statements
      lib/xz: enable all filters by default in Kconfig

Laura Abbott (1):
      cma: Remove potential deadlock situation

Levente Kurusa (1):
      drivers/w1/w1_int.c: call put_device if device_register fails

Li Zefan (2):
      cgroup: don't destroy the default root
      cgroup: disallow disabled controllers on the default hierarchy

Li Zhong (1):
      memory-hotplug: update documentation to hide information about SECTIONS and remove end_phys_index

Luiz Capitulino (5):
      hugetlb: prep_compound_gigantic_page(): drop __init marker
      hugetlb: add hstate_is_gigantic()
      hugetlb: update_and_free_page(): don't clear PG_reserved bit
      hugetlb: move helpers up in the file
      hugetlb: add support for gigantic page allocation at runtime

Manfred Spraul (10):
      ipc/shm.c: check for ulong overflows in shmat
      ipc/shm.c: check for overflows of shm_tot
      ipc/shm.c: check for integer overflow during shmget.
      ipc/shm.c: increase the defaults for SHMALL, SHMMAX
      ipc/sem.c: bugfix for semctl(,,GETZCNT)
      ipc/sem.c: remove code duplication
      ipc/sem.c: change perform_atomic_semop parameters
      ipc/sem.c: store which operation blocks in perform_atomic_semop()
      ipc/sem.c: make semctl(,,{GETNCNT,GETZCNT}) standard compliant
      ipc/sem.c: add a printk_once for semctl(GETNCNT/GETZCNT)

Marc Carino (1):
      cma: increase CMA_ALIGNMENT upper limit to 12

Mathias Krause (1):
      ipc: constify ipc_ops

Matthew Wilcox (8):
      fs/buffer.c: remove block_write_full_page_endio()
      fs/mpage.c: factor clean_buffers() out of __mpage_writepage()
      fs/mpage.c: factor page_endio() out of mpage_end_io()
      fs/block_dev.c: add bdev_read_page() and bdev_write_page()
      swap: use bdev_read_page() / bdev_write_page()
      brd: add support for rw_page()
      brd: return -ENOSPC rather than -ENOMEM on page allocation failure
      mm/msync.c: sync only the requested range in msync()

Mel Gorman (26):
      x86: require x86-64 for automatic NUMA balancing
      x86: define _PAGE_NUMA by reusing software bits on the PMD and PTE levels
      mm: disable zone_reclaim_mode by default
      mm: page_alloc: do not cache reclaim distances
      mm: vmscan: do not throttle based on pfmemalloc reserves if node has no ZONE_NORMAL
      mm: numa: add migrated transhuge pages to LRU the same way as base pages
      mm: page_alloc: do not update zlc unless the zlc is active
      mm: page_alloc: do not treat a zone that cannot be used for dirty pages as "full"
      include/linux/jump_label.h: expose the reference count
      mm: page_alloc: use jump labels to avoid checking number_of_cpusets
      mm: page_alloc: only check the zone id check if pages are buddies
      mm: page_alloc: only check the alloc flags and gfp_mask for dirty once
      mm: page_alloc: take the ALLOC_NO_WATERMARK check out of the fast path
      mm: page_alloc: use word-based accesses for get/set pageblock bitmaps
      mm: page_alloc: reduce number of times page_to_pfn is called
      mm: page_alloc: lookup pageblock migratetype with IRQs enabled during free
      mm: page_alloc: use unsigned int for order in more places
      mm: page_alloc: convert hot/cold parameter and immediate callers to bool
      mm: shmem: avoid atomic operation during shmem_getpage_gfp
      mm: do not use atomic operations when releasing pages
      mm: do not use unnecessary atomic operations when adding pages to the LRU
      fs: buffer: do not use unnecessary atomic operations when discarding buffers
      mm: non-atomically mark page accessed during page cache allocation where possible
      mm: page_alloc: calculate classzone_idx once from the zonelist ref
      mm: avoid unnecessary atomic operations during end_page_writeback()
      mm: vmscan: use proportional scanning during direct reclaim and full scan at DEF_PRIORITY

Michael Marineau (1):
      kobject: Make support for uevent_helper optional.

Michal Hocko (7):
      memcg: remove tasks/children test from mem_cgroup_force_empty()
      Merge remote-tracking branch 'tj-cgroups/for-3.16' into mmotm
      memcg: do not hang on OOM when killed by userspace OOM access to memory reserves
      vmscan: memcg: always use swappiness of the reclaimed memcg
      mm: memcontrol: remove explicit OOM parameter in charge path
      memcg: deprecate memory.force_empty knob
      Reverted "mm, slab: mark enable_cpucache as init text"

Michal Nazarewicz (1):
      mm: page_alloc: simplify drain_zone_pages by using min()

Minchan Kim (2):
      mm/vmalloc.c: export unmap_kernel_range()
      mm/zsmalloc: make zsmalloc module-buildable

Minfei Huang (1):
      lib/btree.c: fix leak of whole btree nodes

Mitchel Humpherys (1):
      mm: convert some level-less printks to pr_*

Namjae Jeon (6):
      fat: add i_disksize to represent uninitialized size
      fat: add fat_fallocate operation
      fat: zero out seek range on _fat_get_block
      fat: fallback to buffered write in case of fallocated region on direct IO
      fat: permit to return phy block number by fibmap in fallocated region
      Documentation/filesystems/vfat.txt: update the limitation for fat fallocate

Naoya Horiguchi (8):
      hugetlb: restrict hugepage_migration_support() to x86_64
      mm/memory-failure.c: move comment
      hugetlb: rename hugepage_migration_support() to ..._supported()
      mm/memory-failure.c: support use of a dedicated thread to handle SIGBUS(BUS_MCEERR_AO)
      hugetlb: fix copy_hugetlb_page_range() to handle migration/hwpoisoned entry
      mm, hugetlbfs: fix rmapping for anonymous hugepages with page_pgoff()
      mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v2
      mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3

NeilBrown (1):
      mm/vmscan.c: avoid throttling reclaim for loop-back nfsd threads

Oleg Nesterov (6):
      memcg: kill CONFIG_MM_OWNER
      memcg: mm_update_next_owner() should skip kthreads
      memcg: optimize the "Search everything else" loop in mm_update_next_owner()
      memcg: kill start_kernel()->mm_init_owner(&init_mm)
      kthreads: kill CLONE_KERNEL, change kernel_thread(kernel_init) to avoid CLONE_SIGHAND
      uprobes: Add mem_cgroup_charge_anon() into uprobe_write_opcode()

Paul McQuade (2):
      ipc, kernel: use Linux headers
      ipc, kernel: clear whitespace

Peter Zijlstra (30):
      ia64: Fix up smp_mb__{before,after}_clear_bit()
      arch: Prepare for smp_mb__{before,after}_atomic()
      arch,alpha: Convert smp_mb__*() to the asm-generic primitives
      arch,arc: Convert smp_mb__*()
      arch,arm: Convert smp_mb__*()
      arch,arm64: Convert smp_mb__*()
      arch,avr32: Convert smp_mb__*()
      arch,blackfin: Convert smp_mb__*()
      arch,c6x: Convert smp_mb__*()
      arch,cris: Convert smp_mb__*()
      arch,frv: Convert smp_mb__*()
      arch,hexagon: Convert smp_mb__*()
      arch,ia64: Convert smp_mb__*()
      arch,m32r: Convert smp_mb__*()
      arch,m68k: Convert smp_mb__*()
      arch,metag: Convert smp_mb__*()
      arch,mips: Convert smp_mb__*()
      arch,mn10300: Convert smp_mb__*()
      arch,openrisc: Convert smp_mb__*()
      arch,parisc: Convert smp_mb__*()
      arch,powerpc: Convert smp_mb__*()
      arch,s390: Convert smp_mb__*()
      arch,score: Convert smp_mb__*()
      arch,sh: Convert smp_mb__*()
      arch,sparc: Convert smp_mb__*()
      arch,tile: Convert smp_mb__*()
      arch,x86: Convert smp_mb__*()
      arch,xtensa: Convert smp_mb__*()
      arch,doc: Convert smp_mb__*()
      arch: Mass conversion of smp_mb__*()

Petr Mladek (5):
      printk: split code for making free space in the log buffer
      printk: ignore too long messages
      printk: split message size computation
      printk: shrink too long messages
      printk: return really stored message length

Petr Tesarik (1):
      kexec: save PG_head_mask in VMCOREINFO

Philipp Hachtmann (3):
      mm/memblock: Do some refactoring, enhance API
      mm/memblock: add physical memory list
      s390/mm: Convert bootmem to memblock

Prarit Bhargava (1):
      init/main.c: add initcall_blacklist kernel parameter

Qiang Huang (2):
      memcg: fold mem_cgroup_stolen
      memcg: correct comments for __mem_cgroup_begin_update_page_stat

Rasmus Villemoes (2):
      mm: constify nmask argument to mbind()
      mm: constify nmask argument to set_mempolicy()

Richard Weinberger (1):
      MAINTAINERS: adi-buildroot-devel is moderated

Roman Pen (1):
      fs/mpage.c: forgotten WRITE_SYNC in case of data integrity write

Sebastian Ott (1):
      mm/mempool: warn about __GFP_ZERO usage

Steven Miao (1):
      mm: nommu: per-thread vma cache fix

Steven Rostedt (1):
      printk: remove separate printk_sched buffers and use printk buf instead

Suleiman Souhlal (1):
      mm: only force scan in reclaim when none of the LRUs are big enough.

Tang Chen (2):
      mem-hotplug: avoid illegal state prefixed with legal state when changing state of memory_block
      mem-hotplug: introduce MMOP_OFFLINE to replace the hard coding -1

Tejun Heo (74):
      cgroup: cgroup_apply_cftypes() shouldn't skip the default hierarhcy
      cgroup: update cgroup->subsys_mask to ->child_subsys_mask and restore cgroup_root->subsys_mask
      cgroup: introduce effective cgroup_subsys_state
      cgroup: implement cgroup->e_csets[]
      cgroup: make css_next_child() skip missing csses
      cgroup: reorganize css_task_iter
      cgroup: teach css_task_iter about effective csses
      cgroup: cgroup->subsys[] should be cleared after the css is offlined
      cgroup: allow cgroup creation and suppress automatic css creation in the unified hierarchy
      cgroup: add css_set->dfl_cgrp
      cgroup: update subsystem rebind restrictions
      cgroup: prepare migration path for unified hierarchy
      cgroup: implement dynamic subtree controller enable/disable on the default hierarchy
      kernfs: implement kernfs_root->supers list
      kernfs: make kernfs_notify() trigger inotify events too
      Merge branch 'driver-core-next' of git://git.kernel.org/.../gregkh/driver-core into for-3.16
      cgroup: implement cgroup.populated for the default hierarchy
      cgroup: add documentation about unified hierarchy
      cgroup: make flags and subsys_masks unsigned int
      cgroup, memcg: allocate cgroup ID from 1
      cgroup: protect cgroup_root->cgroup_idr with a spinlock
      cgroup: use RCU free in create_css() failure path
      cgroup: update init_css() into init_and_link_css()
      cgroup, memcg: implement css->id and convert css_from_id() to use it
      cgroup: remove unused CGRP_SANE_BEHAVIOR
      percpu-refcount: rename percpu_ref_tryget() to percpu_ref_tryget_live()
      percpu-refcount: implement percpu_ref_tryget()
      Merge branch 'for-3.16' of git://git.kernel.org/.../tj/percpu into for-3.16
      Merge branch 'for-3.15-fixes' of git://git.kernel.org/.../tj/cgroup into for-3.16
      cgroup: fix offlining child waiting in cgroup_subtree_control_write()
      cgroup: cgroup_idr_lock should be bh
      cgroup: css_release() shouldn't clear cgroup->subsys[]
      cgroup: update and fix parsing of "cgroup.subtree_control"
      cgroup: use restart_syscall() for retries after offline waits in cgroup_subtree_control_write()
      cgroup: use release_agent_path_lock in cgroup_release_agent_show()
      cgroup: rename css_tryget*() to css_tryget_online*()
      cgroup: implement cftype->write()
      cgroup: replace cftype->write_string() with cftype->write()
      cgroup: replace cftype->trigger() with cftype->write()
      cgroup: convert "tasks" and "cgroup.procs" handle to use cftype->write()
      cgroup: remove cgroup->control_kn
      cgroup: reorganize cgroup_create()
      cgroup: collapse cgroup_create() into croup_mkdir()
      cgroup: grab cgroup_mutex earlier in cgroup_subtree_control_write()
      cgroup: move cgroup->kn->priv clearing to cgroup_rmdir()
      cgroup: factor out cgroup_kn_lock_live() and cgroup_kn_unlock()
      cgroup: use cgroup_kn_lock_live() in other cgroup kernfs methods
      cgroup: nest kernfs active protection under cgroup_mutex
      cgroup: remove cgroup_tree_mutex
      cgroup: use restart_syscall() for mount retries
      cgroup: rename cgroup->dummy_css to ->self and move it to the top
      cgroup: separate out cgroup_has_live_children() from cgroup_destroy_locked()
      cgroup: move check_for_release(parent) call to the end of cgroup_destroy_locked()
      cgroup: move cgroup->sibling unlinking to cgroup_put()
      cgroup: remove cgroup_destory_css_killed()
      cgroup: bounce css release through css->destroy_work
      cgroup: enable refcnting for root csses
      cgroup: use cgroup->self.refcnt for cgroup refcnting
      cgroup: skip refcnting on normal root csses and cgrp_dfl_root self css
      cgroup: remove css_parent()
      memcg: update memcg_has_children() to use css_next_child()
      device_cgroup: remove direct access to cgroup->children
      cgroup: remove cgroup->parent
      cgroup: move cgroup->sibling and ->children into cgroup_subsys_state
      cgroup: link all cgroup_subsys_states in their sibling lists
      cgroup: move cgroup->serial_nr into cgroup_subsys_state
      cgroup: introduce CSS_RELEASED and reduce css iteration fallback window
      cgroup: iterate cgroup_subsys_states directly
      cgroup: use CSS_ONLINE instead of CGRP_DEAD
      cgroup: convert cgroup_has_live_children() into css_has_online_children()
      device_cgroup: use css_has_online_children() instead of has_children()
      cgroup: implement css_tryget()
      cgroup: clean up MAINTAINERS entries
      cgroup: disallow debug controller on the default hierarchy

Tetsuo Handa (1):
      kthread: fix return value of kthread_create() upon SIGKILL.

Tim Chen (1):
      fs/superblock: avoid locking counting inodes and dentries before reclaiming them

Tony Luck (2):
      mm/memory-failure.c-failure: send right signal code to correct thread
      mm/memory-failure.c: don't let collect_procs() skip over processes for MF_ACTION_REQUIRED

Vladimir Davydov (22):
      sl[au]b: charge slabs to kmemcg explicitly
      mm: get rid of __GFP_KMEMCG
      slab: document kmalloc_order
      memcg: un-export __memcg_kmem_get_cache
      mem-hotplug: implement get/put_online_mems
      slab: get_online_mems for kmem_cache_{create,destroy,shrink}
      Documentation/memcg: warn about incomplete kmemcg state
      memcg, slab: do not schedule cache destruction when last page goes away
      memcg, slab: merge memcg_{bind,release}_pages to memcg_{un}charge_slab
      memcg, slab: simplify synchronization scheme
      memcg: get rid of memcg_create_cache_name
      memcg: memcg_kmem_create_cache: make memcg_name_buf statically allocated
      memcg: cleanup kmem cache creation/destruction functions naming
      slab: delete cache from list after __kmem_cache_shutdown succeeds
      memcg: cleanup memcg_cache_params refcnt usage
      memcg: destroy kmem caches when last slab is freed
      memcg: mark caches that belong to offline memcgs as dead
      slub: don't fail kmem_cache_shrink if slab placement optimization fails
      slub: make slab_free non-preemptable
      memcg: wait for kfree's to finish before destroying cache
      slub: make dead memcg caches discard free slabs immediately
      slab: do not keep free objects/slabs on dead memcg caches

Vlastimil Babka (5):
      mm/page_alloc: prevent MIGRATE_RESERVE pages from being misplaced
      mm/compaction: cleanup isolate_freepages()
      mm/compaction: do not count migratepages when unnecessary
      mm/compaction: avoid rescanning pageblocks in isolate_freepages
      mm, compaction: properly signal and act upon lock and need_sched() contention

Waiman Long (2):
      mm, thp: move invariant bug check out of loop in __split_huge_page_map
      mm, thp: replace smp_mb after atomic_add by smp_mb__after_atomic

Wang Sheng-Hui (1):
      include/linux/bootmem.h: cleanup the comment for BOOTMEM_ flags

Weijie Yang (2):
      zram: correct offset usage in zram_bio_discard
      zsmalloc: fixup trivial zs size classes value in comments

Will Deacon (1):
      printk: report dropping of messages from logbuf

Yasuaki Ishimatsu (2):
      x86,mem-hotplug: pass sync_global_pgds() a correct argument in remove_pagetable()
      x86,mem-hotplug: modify PGD entry when removing memory

Yinghai Lu (1):
      x86, mm: probe memory block size for generic x86 64bit

Zhang Zhen (2):
      mm/page_alloc.c: cleanup add_active_range() related comments
      mm/mem-hotplug: replace simple_strtoull() with kstrtoull()

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
