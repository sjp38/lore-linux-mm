Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE986B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 15:25:14 -0400 (EDT)
Received: by wgjx7 with SMTP id x7so176595530wgj.2
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 12:25:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cc6si7296137wib.101.2015.07.07.12.25.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Jul 2015 12:25:12 -0700 (PDT)
Date: Tue, 7 Jul 2015 21:25:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mmotm 2015-07-06-16-25 uploaded
Message-ID: <20150707192506.GA3782@dhcp22.suse.cz>
References: <559b0e6e.lK7yCR5YMKIZ9JAq%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <559b0e6e.lK7yCR5YMKIZ9JAq%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au

I have just created since-4.1 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v4.1 tag in Linus tree and mmotm-2015-07-06-16-25.

I have pulled block/core changes as a pre-requisite for Tejun's cgroup
writeback series which is applied on top (I have cherry picked those
because merging it would pull in way too many changes). I have also
pulled cgroup core changes. I hope I haven't forgotten anything.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The shortlog says:
Aleksa Sarai (4):
      cgroup: switch to unsigned long for bitmasks
      cgroup: use bitmask to filter for_each_subsys
      cgroup: replace explicit ss_mask checking with for_each_subsys_which
      cgroup: fix uninitialised iterator in for_each_subsys_which

Alexey Dobriyan (2):
      prctl: more prctl(PR_SET_MM_*) checks
      proc: fix PAGE_SIZE limit of /proc/$PID/cmdline

Andi Kleen (2):
      mm, hwpoison: add comment describing when to add new cases
      mm, hwpoison: remove obsolete "Notebook" todo list

Andrea Arcangeli (30):
      userfaultfd: linux/Documentation/vm/userfaultfd.txt
      userfaultfd: documentation update
      userfaultfd: waitqueue: add nr wake parameter to __wake_up_locked_key
      userfaultfd: uAPI
      userfaultfd: uAPI: add missing include/types.h
      userfaultfd: linux/userfaultfd_k.h
      userfaultfd: add vm_userfaultfd_ctx to the vm_area_struct
      userfaultfd: add VM_UFFD_MISSING and VM_UFFD_WP
      userfaultfd: call handle_userfault() for userfaultfd_missing() faults
      userfaultfd: teach vma_merge to merge across vma->vm_userfaultfd_ctx
      userfaultfd: prevent khugepaged to merge if userfaultfd is armed
      userfaultfd: add new syscall to provide memory externalization
      userfaultfd-add-new-syscall-to-provide-memory-externalization-fix
      userfaultfd: fs/userfaultfd.c add more comments
      userfaultfd: cleanup superfluous _irq locking
      userfaultfd: rename uffd_api.bits into .features fixup
      userfaultfd: change the read API to return a uffd_msg
      userfaultfd: documentation update
      userfaultfd: update the uffd_msg structure to be the same on 32/64bit
      userfaultfd: wake pending userfaults
      userfaultfd: optimize read() and poll() to be O(1)
      userfaultfd: fs/userfaultfd.c add more comments
      userfaultfd: allocate the userfaultfd_ctx cacheline aligned
      userfaultfd: solve the race between UFFDIO_COPY|ZEROPAGE and read
      userfaultfd: buildsystem activation
      userfaultfd: activate syscall
      userfaultfd: UFFDIO_COPY|UFFDIO_ZEROPAGE uAPI
      userfaultfd: mcopy_atomic|mfill_zeropage: UFFDIO_COPY|UFFDIO_ZEROPAGE preparation
      userfaultfd: avoid mmap_sem read recursion in mcopy_atomic
      userfaultfd: UFFDIO_COPY and UFFDIO_ZEROPAGE

Andrew Morton (11):
      openrisc: fix CONFIG_UID16 setting
      slab-infrastructure-for-bulk-object-allocation-and-freeing-v3-fix
      userfaultfd-change-the-read-api-to-return-a-uffd_msg-fix-2-fix
      userfaultfd-avoid-mmap_sem-read-recursion-in-mcopy_atomic-fix
      fs/userfaultfd.c: work around i386 build error
      include/linux/page-flags.h: rename macros to avoid collisions
      x86-add-pmd_-for-thp-fix
      sparc-add-pmd_-for-thp-fix
      mm-support-madvisemadv_free-fix-2
      mm-dont-split-thp-page-when-syscall-is-called-fix-3
      mm-move-lazy-free-pages-to-inactive-list-fix-fix

Aneesh Kumar K.V (3):
      mm/thp: split out pmd collapse flush into separate functions
      powerpc/mm: use generic version of pmdp_clear_flush()
      mm: clarify that the function operates on hugepage pte

Anisse Astier (1):
      mm/page_alloc.c: cleanup obsolete KM_USER*

Arianna Avanzini (1):
      block, cgroup: implement policy-specific per-blkcg data

Arnd Bergmann (1):
      cgroup: add seq_file forward declaration for struct cftype

Catalin Marinas (5):
      mm: kmemleak: allow safe memory scanning during kmemleak disabling
      mm: kmemleak: fix delete_object_*() race when called on the same memory block
      mm: kmemleak: do not acquire scan_mutex in kmemleak_do_cleanup()
      mm: kmemleak: avoid deadlock on the kmemleak object insertion error path
      mm: kmemleak: optimise kmemleak_lock acquiring during kmemleak_scan

Chen Hanxiao (1):
      cgroup: fix some comment typos

Chris Metcalf (3):
      smpboot: allow excluding cpus from the smpboot threads
      watchdog: add watchdog_cpumask sysctl to assist nohz
      procfs: treat parked tasks as sleeping for task state

Christoph Hellwig (11):
      block: rename REQ_TYPE_SPECIAL to REQ_TYPE_DRV_PRIV
      block: move REQ_TYPE_ATA_TASKFILE and REQ_TYPE_ATA_PC to ide.h
      block: move REQ_TYPE_SENSE to the ide driver
      block: remove REQ_TYPE_PM_SHUTDOWN
      block: move PM request support to IDE
      nbd: stop using req->cmd
      block: use an atomic_t for mq_freeze_depth
      block: remove BIO_EOPNOTSUPP
      block: remove unused BIO_RW_BLOCK and BIO_EOF flags
      suspend: simplify block I/O handling
      block, dm: don't copy bios for request clones

Christoph Lameter (2):
      slab: infrastructure for bulk object allocation and freeing
      slub bulk alloc: extract objects from the per cpu slab

Dan Streetman (4):
      frontswap: allow multiple backends
      zswap: runtime enable/disable
      zpool: change pr_info to pr_debug
      zpool: remove zpool_evict()

Daniel Sanders (1):
      slab: correct size_index table before replacing the bootstrap kmem_cache_node

Dave Gordon (3):
      lib/scatterlist.c: fix kerneldoc for sg_pcopy_{to,from}_buffer()
      lib/scatterlist: mark input buffer parameters as 'const'
      drivers/scsi/scsi_debug.c: resolve sg buffer const-ness issue

Davidlohr Bueso (5):
      ipc,shm: move BUG_ON check into shm_lock
      ipc,msg: provide barrier pairings for lockless receive
      ipc: rename ipc_obtain_object
      ipc,sysv: make return -EIDRM when racing with RMID consistent
      ipc,sysv: return -EINVAL upon incorrect id/seqnum

Dominik Dingel (10):
      s390/mm: make hugepages_supported a boot time decision
      mm/hugetlb: remove unused arch hook prepare/release_hugepage
      mm/hugetlb: remove arch_prepare/release_hugepage from arch headers
      s390/hugetlb: remove dead code for sw emulated huge pages
      s390/mm: forward check for huge pmds to pmd_large()
      s390/mm: change HPAGE_SHIFT type to int
      revert "s390/mm: change HPAGE_SHIFT type to int"
      revert "s390/mm: make hugepages_supported a boot time decision"
      mm: hugetlb: allow hugepages_supported to be architecture specific
      s390/hugetlb: add hugepages_supported define

Gavin Guo (1):
      mm/slab_common: support the slub_debug boot option on specific object size

Greg Thelen (1):
      memcg: add per cgroup dirty page accounting

Gu Zheng (1):
      mm/memory hotplug: init the zone's size when calculating node totalpages

HATAYAMA Daisuke (2):
      kernel/panic: call the 2nd crash_kexec() only if crash_kexec_post_notifiers is enabled
      kernel/panic/kexec: fix "crash_kexec_post_notifiers" option issue in oops path

Iago Lopez Galeiras (1):
      fs, proc: introduce CONFIG_PROC_CHILDREN

James Custer (1):
      mm: fix invalid use of pfn_valid_within in test_pages_in_a_zone

Jarod Wilson (1):
      block: export blkdev_reread_part() and __blkdev_reread_part()

Jeff Moyer (1):
      blk-mq: fix plugging in blk_sq_make_request

Jens Axboe (11):
      bio: skip atomic inc/dec of ->bi_remaining for non-chains
      bio: skip atomic inc/dec of ->bi_cnt for most use cases
      block: collapse bio bit space
      block: only honor SG gap prevention for merges that contain data
      block: don't honor chunk sizes for data-less IO
      block: add blk_set_queue_dying() to blkdev.h
      cfq-iosched: fix the setting of IOPS mode on SSDs
      cfq-iosched: move group scheduling functions under ifdef
      cfq-iosched: fix sysfs oops when attempting to read unconfigured weights
      cfq-iosched: fix other locations where blkcg_to_cfqgd() can return NULL
      buffer: remove unusued 'ret' variable

Jiri Kosina (1):
      thp: cleanup how khugepaged enters freezer

Johannes Weiner (7):
      mm: oom_kill: remove unnecessary locking in oom_enable()
      mm: oom_kill: clean up victim marking and exiting interfaces
      mm: oom_kill: switch test-and-clear of known TIF_MEMDIE to clear
      mm: oom_kill: generalize OOM progress waitqueue
      mm: oom_kill: remove unnecessary locking in exit_oom_victim()
      mm: oom_kill: simplify OOM killer locking
      mm: page_alloc: inline should_alloc_retry()

Josef Bacik (1):
      tmpfs: truncate prealloc blocks past i_size

Josh Triplett (1):
      clone: support passing tls argument via C rather than pt_regs magic

Julia Lawall (1):
      block: fix returnvar.cocci warnings

KarimAllah Ahmed (1):
      x86/kexec: prepend elfcorehdr instead of appending it to the crash-kernel command-line.

Keith Busch (1):
      blk-mq: Shared tag enhancements

Kirill A. Shutemov (19):
      mm: fix mprotect() behaviour on VM_LOCKED VMAs
      mm: drop bogus VM_BUG_ON_PAGE assert in put_page() codepath
      mm: avoid tail page refcounting on non-THP compound pages
      page-flags: trivial cleanup for PageTrans* helpers
      page-flags: introduce page flags policies wrt compound pages
      page-flags: define PG_locked behavior on compound pages
      page-flags: define behavior of FS/IO-related flags on compound pages
      page-flags: define behavior of LRU-related flags on compound pages
      mm,compaction: fix isolate_migratepages_block() for THP=n
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

Larry Finger (1):
      mm: kmemleak_alloc_percpu() should follow the gfp from per_alloc()

Laurent Dufour (3):
      mm: new mm hook framework
      mm: new arch_remap() hook
      powerpc/mm: tracking vDSO remap

Leon Romanovsky (1):
      mm: nommu: refactor debug and warning prints

Lorenzo Stoakes (1):
      gcov: add support for GCC 5.1

Marcin Jabrzyk (2):
      zram: remove obsolete ZRAM_DEBUG option
      zsmalloc: remove obsolete ZSMALLOC_DEBUG

Masanari Iida (1):
      arch/unicore32/kernel/fpu-ucf64.c: remove unnecessary KERN_ERR

Mel Gorman (12):
      mm, memcg: Try charging a page before setting page up to date
      mm: page_alloc: pass PFN to __free_pages_bootmem
      mm: meminit: make __early_pfn_to_nid SMP-safe and introduce meminit_pfn_in_nid
      mm: meminit: inline some helper functions
      mm: meminit: initialise a subset of struct pages if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set
      mm: meminit: initialise remaining struct pages in parallel with kswapd
      mm: meminit: minimise number of pfn->page lookups during initialisation
      x86: mm: enable deferred struct page initialisation on x86-64
      mm: meminit: free pages in large chunks where possible
      mm: meminit: reduce number of times pageblocks are set during struct page init
      mm: meminit: remove mminit_verify_page_links
      mm: meminit: finish initialisation of struct pages before basic setup

Michal Hocko (5):
      hugetlb: do not account hugetlb pages as NR_FILE_PAGES
      Documentation/vm/unevictable-lru.txt: clarify MAP_LOCKED behavior
      mm: do not ignore mapping_gfp_mask in page cache allocation paths
      Merge branch 'for-4.2/core' of git://git.kernel.dk/linux-block
      Merge remote-tracking branch 'cgroups/for-4.2' into mmotm

Mike Kravetz (3):
      mm/hugetlb: document the reserve map/region tracking routines
      mm/hugetlb: compute/return the number of regions added by region_add()
      mm/hugetlb: handle races in alloc_huge_page and hugetlb_reserve_pages

Mike Snitzer (1):
      block: remove management of bi_remaining when restoring original bi_end_io

Minchan Kim (13):
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

Ming Lei (1):
      block: replace trylock with mutex_lock in blkdev_reread_part()

Naoya Horiguchi (5):
      mm/memory-failure: split thp earlier in memory error handling
      mm/memory-failure: introduce get_hwpoison_page() for consistent refcount handling
      mm: soft-offline: don't free target page in successful page migration
      mm/memory-failure: me_huge_page() does nothing for thp
      mm/hugetlb: introduce minimum hugepage order

Nathan Zimmer (1):
      mm: meminit: only set page reserved in the memblock region

Nishanth Aravamudan (1):
      mm: vmscan: do not throttle based on pfmemalloc reserves if node has no reclaimable pages

Paul Bolle (1):
      mm: Fix comment typo "CONFIG_TRANSPARNTE_HUGE"

Pavel Emelyanov (1):
      userfaultfd: Rename uffd_api.bits into .features

Pekka Enberg (10):
      ipc/util.c: use kvfree() in ipc_rcu_free()
      kernel/relay.c: use kvfree() in relay_free_page_array()
      cxgb3: use kvfree() in cxgb_free_mem()
      cxgb4: use kvfree() in t4_free_mem()
      drm: use kvfree() in drm_free_large()
      drm/nouveau/gem: use kvfree() in u_free()
      IB/ehca: use kvfree() in ipz_queue_{cd}tor()
      target: use kvfree() in session alloc and free
      libcxgbi: use kvfree() in cxgbi_free_big_mem()
      bcache: use kvfree() in various places

Piotr Kwapulinski (1):
      mm/mmap.c: optimization of do_mmap_pgoff function

Quentin Lambert (1):
      memstick: remove deprecated use of pci api

Rasmus Villemoes (2):
      linux/slab.h: fix three off-by-one typos in comment
      mm: only define hashdist variable when needed

Robin Holt (2):
      memblock: introduce a for_each_reserved_mem_region iterator
      mm: meminit: move page initialization into a separate function

Roman Pen (1):
      fs/mpage.c: forgotten WRITE_SYNC in case of data integrity write

Sergey Senozhatsky (13):
      zram: add `compact` sysfs entry to documentation
      zram: cosmetic ZRAM_ATTR_RO code formatting tweak
      zram: use idr instead of `zram_devices' array
      zram: reorganize code layout
      zram: remove max_num_devices limitation
      zram: report every added and removed device
      zram: trivial: correct flag operations comment
      zram: return zram device_id from zram_add()
      zram: close race by open overriding
      zram: add dynamic device add/remove functionality
      zram: cosmetic zram_bvec_write() cleanup
      zram: cut trailing newline in algorithm name
      zram: check comp algorithm availability earlier

Shailendra Verma (1):
      mm/cma.c: fix typos in comments

Shaohua Li (5):
      blk: clean up plug
      sched: always use blk_schedule_flush_plug in io_schedule_out
      blk-mq: avoid re-initialize request which is failed in direct dispatch
      blk-mq: do limited block plug for multiple queue case
      blk-mq: make plug work for mutiple disks and queues

Stephen Rothwell (1):
      userfaultfd: activate syscall fix

Steven Rostedt (1):
      blktrace: Add blktrace.c to BLOCK LAYER in MAINTAINERS file

Tahsin Erdogan (1):
      block: Make CFQ default to IOPS mode on SSDs

Tejun Heo (95):
      cgroup: separate out include/linux/cgroup-defs.h
      cgroup: reorganize include/linux/cgroup.h
      sched, cgroup: reorganize threadgroup locking
      sched, cgroup: replace signal_struct->group_rwsem with a global percpu_rwsem
      cgroup: simplify threadgroup locking
      MAINTAINERS: add a cgroup core co-maintainer
      kernfs: make kernfs_get_inode() public
      cgroup: separate out cgroup_procs_write_permission() from __cgroup_procs_write()
      cgroup: require write perm on common ancestor when moving processes on the default hierarchy
      cgroup: add delegation section to unified hierarchy documentation
      memcg: remove unused mem_cgroup->oom_wakeups
      memcg: convert mem_cgroup->under_oom from atomic_t to int
      page_writeback: revive cancel_dirty_page() in a restricted form
      blkcg: move block/blk-cgroup.h to include/linux/blk-cgroup.h
      update !CONFIG_BLK_CGROUP dummies in include/linux/blk-cgroup.h
      blkcg: always create the blkcg_gq for the root blkcg
      memcg: add mem_cgroup_root_css
      blkcg: add blkcg_root_css
      cgroup, block: implement task_get_css() and use it in bio_associate_current()
      blkcg: implement task_get_blkcg_css()
      blkcg: implement bio_associate_blkcg()
      memcg: implement mem_cgroup_css_from_page()
      writeback: move backing_dev_info->state into bdi_writeback
      writeback: move backing_dev_info->bdi_stat[] into bdi_writeback
      writeback: move bandwidth related fields from backing_dev_info into bdi_writeback
      writeback: s/bdi/wb/ in mm/page-writeback.c
      writeback: move backing_dev_info->wb_lock and ->worklist into bdi_writeback
      writeback: reorganize mm/backing-dev.c
      writeback: separate out include/linux/backing-dev-defs.h
      bdi: make inode_to_bdi() inline
      writeback: add @gfp to wb_init()
      bdi: separate out congested state into a separate struct
      writeback: add {CONFIG|BDI_CAP|FS}_CGROUP_WRITEBACK
      writeback: make backing_dev_info host cgroup-specific bdi_writebacks
      writeback, blkcg: associate each blkcg_gq with the corresponding bdi_writeback_congested
      writeback: attribute stats to the matching per-cgroup bdi_writeback
      writeback: let balance_dirty_pages() work on the matching cgroup bdi_writeback
      writeback: make congestion functions per bdi_writeback
      writeback, blkcg: restructure blk_{set|clear}_queue_congested()
      writeback, blkcg: propagate non-root blkcg congestion state
      writeback: implement and use inode_congested()
      writeback: implement WB_has_dirty_io wb_state flag
      writeback: implement backing_dev_info->tot_write_bandwidth
      writeback: make bdi_has_dirty_io() take multiple bdi_writeback's into account
      writeback: don't issue wb_writeback_work if clean
      writeback: make bdi->min/max_ratio handling cgroup writeback aware
      writeback: implement bdi_for_each_wb()
      writeback: remove bdi_start_writeback()
      writeback: make laptop_mode_timer_fn() handle multiple bdi_writeback's
      writeback: make writeback_in_progress() take bdi_writeback instead of backing_dev_info
      writeback: make bdi_start_background_writeback() take bdi_writeback instead of backing_dev_info
      writeback: make wakeup_flusher_threads() handle multiple bdi_writeback's
      writeback: make wakeup_dirtytime_writeback() handle multiple bdi_writeback's
      writeback: add wb_writeback_work->auto_free
      writeback: implement bdi_wait_for_completion()
      writeback: implement wb_wait_for_single_work()
      writeback: restructure try_writeback_inodes_sb[_nr]()
      writeback: make writeback initiation functions handle multiple bdi_writeback's
      writeback: dirty inodes against their matching cgroup bdi_writeback's
      buffer, writeback: make __block_write_full_page() honor cgroup writeback
      mpage: make __mpage_writepage() honor cgroup writeback
      ext2: enable cgroup writeback support
      memcg: make mem_cgroup_read_{stat|event}() iterate possible cpus instead of online
      writeback: clean up wb_dirty_limit()
      writeback: reorganize [__]wb_update_bandwidth()
      writeback: implement wb_domain
      writeback: move global_dirty_limit into wb_domain
      writeback: consolidate dirty throttle parameters into dirty_throttle_control
      writeback: add dirty_throttle_control->wb_bg_thresh
      writeback: make __wb_calc_thresh() take dirty_throttle_control
      writeback: add dirty_throttle_control->pos_ratio
      writeback: add dirty_throttle_control->wb_completions
      writeback: add dirty_throttle_control->dom
      writeback: make __wb_writeout_inc() and hard_dirty_limit() take wb_domaas a parameter
      writeback: separate out domain_dirty_limits()
      writeback: move over_bground_thresh() to mm/page-writeback.c
      writeback: update wb_over_bg_thresh() to use wb_domain aware operations
      writeback: implement memcg wb_domain
      writeback: reset wb_domain->dirty_limit[_tstmp] when memcg domain size changes
      writeback: implement memcg writeback domain based throttling
      mm: vmscan: disable memcg direct reclaim stalling if cgroup writeback support is in use
      writeback: relocate wb[_try]_get(), wb_put(), inode_{attach|detach}_wb()
      writeback: make writeback_control track the inode being written back
      writeback: implement foreign cgroup inode detection
      writeback: implement [locked_]inode_to_wb_and_lock_list()
      writeback: implement unlocked_inode_to_wb transaction and use it for stat updates
      writeback: use unlocked_inode_to_wb transaction in inode_congested()
      writeback: add lockdep annotation to inode_to_wb()
      writeback: implement foreign cgroup inode bdi_writeback switching
      writeback: disassociate inodes from dying bdi_writebacks
      bdi: fix wrong error return value in cgwb_create()
      v9fs: fix error handling in v9fs_session_init()
      writeback: do foreign inode detection iff cgroup writeback is enabled
      vfs, writeback: replace FS_CGROUP_WRITEBACK with SB_I_CGROUPWB
      writeback, blkio: add documentation for cgroup writeback support

Tobias Klauser (1):
      frv: remove unused inline function is_in_rom()

Tony Luck (3):
      mm/memblock: add extra "flags" to memblock to allow selection of memory based on attribute
      mm/memblock: allocate boot time data structures from mirrored memory
      x86, mirror: x86 enabling - find mirrored memory ranges

Vinayak Menon (1):
      mm: vmscan: fix the page state calculation in too_many_isolated

Vladimir Davydov (1):
      rmap: fix theoretical race between do_wp_page and shrink_active_list

Vlastimil Babka (2):
      mm, thp: respect MPOL_PREFERRED policy with non-local node
      page-flags-define-behavior-of-lru-related-flags-on-compound-pages-fix-fix

Wang Long (1):
      mm/oom_kill.c: print points as unsigned int

Weijie Yang (1):
      mm: page_isolation: check pfn validity before access

Xie XiuQi (3):
      memory-failure: export page_type and action result
      memory-failure: change type of action_result's param 3 to enum
      tracing: add trace event for memory-failure

Yann Droneaud (3):
      fs: use seq_open_private() for proc_mounts
      fs: allocate structure unconditionally in seq_open()
      fs: document seq_open()'s usage of file->private_data

Zhang Zhen (2):
      mm/hugetlb: reduce arch dependent code about huge_pmd_unshare
      mm/hugetlb: reduce arch dependent code about hugetlb_prefault_arch_hook

Zhihui Zhang (1):
      mm: rename RECLAIM_SWAP to RECLAIM_UNMAP

Zhu Guihua (1):
      mm/memory hotplug: print the last vmemmap region at the end of hot add memory

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
