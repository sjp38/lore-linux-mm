Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 10B646B0069
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 08:52:34 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xy5so37276107wjc.0
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 05:52:34 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id m9si49414564wjr.174.2016.12.13.05.52.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 05:52:32 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id m203so18484776wma.3
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 05:52:31 -0800 (PST)
Date: Tue, 13 Dec 2016 14:52:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: mmotm git tree since-4.9 branch created (was: mmotm 2016-12-12-17-02
 uploaded)
Message-ID: <20161213135229.GB7803@dhcp22.suse.cz>
References: <584f48d9.dfBrttZ3CZ8rJ1M2%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <584f48d9.dfBrttZ3CZ8rJ1M2%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

I have just created since-4.9 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v4.9 tag in Linus tree and mmotm-2016-12-12-17-02.

Tracking all the dax related changes was quite challenging but I hope I
have it all. I have pulled from
	- Dave's tree: dax-4.10-iomap-pmd, xfs-4.10-misc-fixes-2,
	  iomap-4.10-directio
	- Ted's tree: dev
	- Dan's tree: libnvdimm-for-next

Let me know if I am missing anything, please.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The shortlog says:
Alexey Dobriyan (8):
      proc: make struct pid_entry::len unsigned
      proc: make struct struct map_files_info::len unsigned int
      proc: just list_del() struct pde_opener
      proc: fix type of struct pde_opener::closing field
      proc: kmalloc struct pde_opener
      proc: tweak comments about 2 stage open and everything
      fs/proc/base.c: save decrement during lookup/readdir in /proc/$PID
      fs/proc: calculate /proc/* and /proc/*/task/* nlink at init time

Andi Kleen (1):
      mm/mprotect.c: don't touch single threaded PTEs which are on the right node

Andreas Platschek (1):
      kmemleak: fix reference to Documentation

Andrew Morton (7):
      include/linux/backing-dev-defs.h: shrink struct backing_dev_info
      scripts/checkpatch.pl: fix spelling
      mm-compaction-allow-compaction-for-gfp_nofs-requests-fix
      ipc-sem-rework-task-wakeups-checkpatch-fixes
      ipc-sem-optimize-perform_atomic_semop-checkpatch-fixes
      ipc-sem-simplify-wait-wake-loop-checkpatch-fixes
      mm-unexport-__get_user_pages_unlocked-checkpatch-fixes

Andrey Ryabinin (4):
      mm: add vfree_atomic()
      kernel/fork: use vfree_atomic() to free thread stack
      x86/ldt: use vfree_atomic() to free ldt entries
      kasan: turn on -fsanitize-address-use-after-scope

Aneesh Kumar K.V (9):
      mm/hugetlb.c: use the right pte val for compare in hugetlb_cow
      mm/hugetlb.c: use huge_pte_lock instead of opencoding the lock
      mm: use the correct page size when removing the page
      mm: update mmu_gather range correctly
      mm/hugetlb: add tlb_remove_hugetlb_entry for handling hugetlb pages
      mm: add tlb_remove_check_page_size_change to track page size change
      mm: remove the page size change check in tlb_remove_page
      mm: move vma_is_anonymous check within pmd_move_must_withdraw
      mm: THP page cache support for ppc64

Arnd Bergmann (2):
      slub: avoid false-postive warning
      shmem: avoid maybe-uninitialized warning

Babu Moger (3):
      kernel/watchdog.c: move shared definitions to nmi.h
      kernel/watchdog.c: move hardlockup detector to separate file
      sparc: implement watchdog_nmi_enable and watchdog_nmi_disable

Benjamin Peterson (1):
      compiler-gcc.h: use "proved" instead of "proofed"

Bhumika Goyal (2):
      fs: xfs: xfs_icreate_item: constify xfs_item_ops structure
      fs: xfs: libxfs: constify xfs_nameops structures

Brian Foster (6):
      xfs: don't skip cow forks w/ delalloc blocks in cowblocks scan
      xfs: don't BUG() on mixed direct and mapped I/O
      xfs: fix unbalanced inode reclaim flush locking
      xfs: track preallocation separately in xfs_bmapi_reserve_delalloc()
      xfs: clean up cow fork reservation and tag inodes correctly
      xfs: pass post-eof speculative prealloc blocks to bmapi

Chandan Rajendra (2):
      ext4: fix mballoc breakage with 64k block size
      ext4: fix stack memory corruption with 64k block size

Christoph Hellwig (23):
      xfs: new inode extent list lookup helpers
      xfs: cleanup xfs_bmap_last_before
      xfs: use new extent lookup helpers in xfs_bmapi_read
      xfs: use new extent lookup helpers in xfs_bmapi_write
      xfs: use new extent lookup helpers in __xfs_bunmapi
      xfs: remove prev argument to xfs_bmapi_reserve_delalloc
      xfs: use new extent lookup helpers xfs_file_iomap_begin_delay
      xfs: use new extent lookup helpers in __xfs_reflink_reserve_cow
      xfs: cleanup xfs_reflink_find_cow_mapping
      xfs: use new extent lookup helpers in xfs_reflink_trim_irec_to_next_cow
      xfs: use new extent lookup helpers in xfs_reflink_cancel_cow_blocks
      xfs: use new extent lookup helpers in xfs_reflink_end_cow
      xfs: remove xfs_bmap_search_extents
      xfs: remove NULLEXTNUM
      xfs: remove i_iolock and use i_rwsem in the VFS inode instead
      fs: make sb_init_dio_done_wq available outside of direct-io.c
      iomap: implement direct I/O
      xfs: use iomap_dio_rw
      mm: remove free_unmap_vmap_area_noflush()
      mm: remove free_unmap_vmap_area_addr()
      mm: refactor __purge_vmap_area_lazy()
      mm: mark all calls into the vmalloc subsystem as potentially sleeping
      mm: turn vmap_purge_lock into a mutex

Colin Ian King (1):
      ipc/sem: ensure we left shift a ULL rather than a 32 bit integer

Daeho Jeong (1):
      ext4: fix inode checksum calculation problem if i_extra_size is small

Dan Carpenter (2):
      ext4: remove another test in ext4_alloc_file_blocks()
      ext4: return -ENOMEM instead of success

Dan Williams (15):
      libnvdimm: allow a platform to force enable label support
      tools/testing/nvdimm: dynamic label support
      libnvdimm: use consistent naming for request_mem_region()
      dax: add region-available-size attribute
      dax: add region 'id', 'size', and 'align' attributes
      dax: register seed device
      dax: use multi-order radix for resource lookup
      dax: refactor locking out of size calculation routines
      dax: sub-division support
      dax: add / remove dax devices after provisioning
      dax: add debug for region available_size
      libnvdimm, pfn: fix align attribute
      Merge branch 'for-4.10/libnvdimm' into libnvdimm-for-next
      Merge branch 'for-4.10/dax' into libnvdimm-for-next
      mm: disable numa migration faults for dax vmas

Daniel Vetter (1):
      lib/ida: document locking requirements a bit better

Darrick J. Wong (3):
      xfs: factor rmap btree size into the indlen calculations
      xfs: always succeed when deduping zero bytes
      ext4: reject inodes with negative size

Dave Chinner (1):
      Merge branch 'xfs-4.10-misc-fixes-2' into iomap-4.10-directio

Dave Jiang (1):
      libnvdimm: check and clear poison before writing to pmem

Dave Young (1):
      lib/Kconfig.debug: make CONFIG_STRICT_DEVMEM depend on CONFIG_DEVMEM

David Gstir (11):
      fscrypt: Add in-place encryption mode
      fscrypt: Allow fscrypt_decrypt_page() to function with non-writeback pages
      fscrypt: Enable partial page encryption
      fscrypt: Constify struct inode pointer
      fscrypt: Let fs select encryption index/tweak
      fscrypt: Use correct index in decrypt path.
      fscrypt: Never allocate fscrypt_ctx on in-place encryption
      fscrypt: Cleanup fscrypt_{decrypt,encrypt}_page()
      fscrypt: Cleanup page locking requirements for fscrypt_{decrypt,encrypt}_page()
      fscrypt: Delay bounce page pool allocation until needed
      fscrypt: Rename FS_WRITE_PATH_FL to FS_CTX_HAS_BOUNCE_BUFFER_FL

David Rientjes (2):
      mm, slab: maintain total slab count instead of active count
      mm, thp: avoid unlikely branches for split_huge_pmd

Davidlohr Bueso (7):
      ipc/sem: do not call wake_sem_queue_do() prematurely
      ipc/sem: rework task wakeups
      ipc/sem: optimize perform_atomic_semop()
      ipc/sem: explicitly inline check_restart
      ipc/sem: use proper list api for pending_list wakeups
      ipc/sem: simplify wait-wake loop
      ipc/sem: avoid idr tree lookup for interrupted semop

Deepa Dinamani (1):
      ext4: use current_time() for inode timestamps

Dmitry Vyukov (2):
      kasan: support panic_on_warn
      kasan: eliminate long stalls during quarantine reduction

Eric Biggers (16):
      fscrypto: don't use on-stack buffer for filename encryption
      fscrypto: don't use on-stack buffer for key derivation
      ext4: avoid lockdep warning when inheriting encryption context
      ext4: get rid of ext4_sb_has_crypto()
      ext4: disable pwsalt ioctl when encryption disabled by config
      ext4: forbid i_extra_isize not divisible by 4
      ext4: don't read out of bounds when checking for in-inode xattrs
      ext4: correctly detect when an xattr value has an invalid size
      mbcache: correctly handle 'e_referenced' bit
      mbcache: don't BUG() if entry cache cannot be allocated
      mbcache: remove unnecessary module_get/module_put
      mbcache: use consistent type for entry count
      mbcache: document that "find" functions only return reusable entries
      MAINTAINERS: fscrypto: recommend linux-fsdevel for fscrypto patches
      fscrypto: remove unneeded Kconfig dependencies
      fscrypto: move ioctl processing more fully into common code

Eric Sandeen (4):
      xfs: fix up xfs_swap_extent_forks inline extent handling
      xfs: provide helper for counting extents from if_bytes
      ext4: fix mmp use after free during unmount
      xfs: add XBF_XBF_NO_IOACCT to buf trace output

Eric Whitney (2):
      ext4: allow inode expansion for nojournal file systems
      ext4: remove parameter from ext4_xattr_ibody_set()

Eryu Guan (1):
      ext4: validate s_first_meta_bg at mount time

Fabian Frederick (4):
      Documentation: fix description of ext4's block_validity mount option
      libnvdimm: remove else after return in nsio_rw_bytes()
      libnvdimm, namespace: avoid multiple sector calculations
      libnvdimm, namespace: use octal for permissions

Greg Thelen (1):
      mm, slab: faster active and free stats

Heiko Carstens (1):
      mm/pkeys: generate pkey system call code only if ARCH_HAS_PKEYS is selected

Hugh Dickins (3):
      mm: add three more cond_resched() in swapoff
      mm: add cond_resched() in gather_pte_stats()
      mm: make transparent hugepage size public

Jan Kara (37):
      dax: Introduce IOMAP_FAULT flag
      ext4: factor out checks from ext4_file_write_iter()
      ext4: only set S_DAX if DAX is really supported
      ext4: convert DAX reads to iomap infrastructure
      ext4: use iomap for zeroing blocks in DAX mode
      ext4: DAX iomap write support
      ext4: avoid split extents for DAX writes
      ext4: convert DAX faults to iomap infrastructure
      ext4: rip out DAX handling from direct IO path
      ext2: use iomap_zero_range() for zeroing truncated page in DAX path
      dax: rip out get_block based IO support
      ext4: Add select for CONFIG_FS_IOMAP
      ext4: add EXT4_JOURNAL_DATA_FL and EXT4_EXTENTS_FL to modifiable mask
      ext4: be more strict when verifying flags set via SETFLAGS ioctls
      ext4: warn when page is dirtied without buffers
      ext4: fix checks for data=ordered and journal_async_commit options
      dax: Fix sleep in atomic contex in grab_mapping_entry()
      mm: join struct fault_env and vm_fault
      mm: use vmf->address instead of of vmf->virtual_address
      mm: use pgoff in struct vm_fault instead of passing it separately
      mm: use passed vm_fault structure in __do_fault()
      mm: trim __do_fault() arguments
      mm: use passed vm_fault structure for in wp_pfn_shared()
      mm: add orig_pte field into vm_fault
      mm: allow full handling of COW faults in ->fault handlers
      mm: factor out functionality to finish page faults
      mm: move handling of COW faults into DAX code
      mm: factor out common parts of write fault handling
      mm: pass vm_fault structure into do_page_mkwrite()
      mm: use vmf->page during WP faults
      mm: move part of wp_page_reuse() into the single call site
      mm: provide helper for finishing mkwrite faults
      mm: change return values of finish_mkwrite_fault()
      mm: export follow_pte()
      dax: make cache flushing protected by entry lock
      dax: protect PTE modification on WP fault by radix tree entry lock
      dax: clear dirty entry tags on cache flush

Jason Baron (1):
      binfmt_elf: use vmalloc() for allocation of vma_filesz

Jens Axboe (1):
      mm: don't cap request size based on read-ahead setting

Jie Chen (1):
      lib/rbtree.c: fix typo in comment of ____rb_erase_color

Joe Perches (1):
      get_maintainer: look for arbitrary letter prefixes in sections

Joel Fernandes (1):
      mm: add preempt points into __purge_vmap_area_lazy()

Johannes Thumshirn (1):
      libnvdimm, e820: use module_platform_driver

Johannes Weiner (10):
      mm: khugepaged: close use-after-free race during shmem collapsing
      mm: khugepaged: fix radix tree node leak in shmem collapse error path
      mm: workingset: turn shadow node shrinker bugs into warnings
      lib: radix-tree: native accounting of exceptional entries
      lib: radix-tree: check accounting of existing slot replacement users
      lib: radix-tree: add entry deletion support to __radix_tree_replace()
      lib: radix-tree: update callback for changing leaf nodes
      mm: workingset: move shadow entry tracking to radix tree exceptional tracking
      mm: workingset: restore refault tracking for single-page files
      mm: workingset: update shadow limit to reflect bigger active list

Jungseung Lee (1):
      init: reduce rootwait polling interval time to 5ms

Jeremy Lefaure (1):
      shmem: fix compilation warnings on unused functions

Kees Cook (1):
      proc: report no_new_privs state

Kent Overstreet (1):
      block: add bio_iov_iter_get_pages()

Kirill A. Shutemov (1):
      mm/filemap.c: add comment for confusing logic in page_cache_tree_insert()

Konstantin Khlebnikov (2):
      kernel/watchdog: use nmi registers snapshot in hardlockup handler
      radix tree test suite: benchmark for iterator

Lorenzo Stoakes (3):
      mm: fix up get_user_pages* comments
      mm: add locked parameter to get_user_pages_remote()
      mm: unexport __get_user_pages_unlocked()

Matthew Wilcox (31):
      tools: add WARN_ON_ONCE
      radix tree test suite: allow GFP_ATOMIC allocations to fail
      radix tree test suite: track preempt_count
      radix tree test suite: free preallocated nodes
      radix tree test suite: make runs more reproducible
      radix tree test suite: iteration test misuses RCU
      radix tree test suite: use rcu_barrier
      radix tree test suite: handle exceptional entries
      radix tree test suite: record order in each item
      tools: add more bitmap functions
      radix tree test suite: use common find-bit code
      radix-tree: fix typo
      radix-tree: move rcu_head into a union with private_list
      radix-tree: create node_tag_set()
      radix-tree: make radix_tree_find_next_bit more useful
      radix-tree: improve dump output
      btrfs: fix race in btrfs_free_dummy_fs_info()
      radix-tree: improve multiorder iterators
      radix-tree: delete radix_tree_locate_item()
      radix-tree: delete radix_tree_range_tag_if_tagged()
      radix-tree: add radix_tree_join
      radix-tree: add radix_tree_split
      radix-tree: add radix_tree_split_preload()
      radix-tree: fix replacement for multiorder entries
      radix tree test suite: check multiorder iteration
      idr: add ida_is_empty
      tpm: use idr_find(), not idr_find_slowpath()
      rxrpc: abstract away knowledge of IDR internals
      idr: reduce the number of bits per level from 8 to 6
      radix tree test suite: add some more functionality
      reimplement IDR and IDA using the radix tree

Mel Gorman (1):
      mm, page_alloc: keep pcp count and list contents in sync if struct page is corrupted

Michal Hocko (7):
      mm, mempolicy: clean up __GFP_THISNODE confusion in policy_zonelist
      mm, compaction: allow compaction for GFP_NOFS requests
      Merge remote-tracking branch 'nvdim/libnvdimm-for-next' into mmotm-base
      Merge remote-tracking branch 'xfs-tree/dax-4.10-iomap-pmd' into mmotm-base
      Merge remote-tracking branch 'ext-tree/dev' into mmotm-next
      Merge remote-tracking branch 'xfs-tree/xfs-4.10-misc-fixes-2' into mmotm-next
      Merge remote-tracking branch 'xfs-tree/iomap-4.10-directio' into mmotm-next

Minchan Kim (4):
      mm: don't steal highatomic pageblock
      mm: prevent double decrease of nr_reserved_highatomic
      mm: try to exhaust highatomic reserve before the OOM
      mm: make unreserve highatomic functions reliable

Ming Ling (1):
      mm, compaction: fix NR_ISOLATED_* stats for pfn based migration

Nicolas Iooss (3):
      nvdimm: use the right length of "pmem"
      libnvdimm, namespace: fix the type of name variable
      kthread: add __printf attributes

Pavel Machek (1):
      ktest.pl: fix english

Peter Zijlstra (1):
      locking/lockdep: Provide a type check for lock_is_held

Piotr Kwapulinski (1):
      mm/mempolicy.c: forbid static or relative flags for local NUMA mode

Rasmus Villemoes (1):
      fs/proc/array.c: slightly improve render_sigset_t

Reza Arbab (3):
      powerpc/mm: allow memory hotplug into a memoryless node
      mm: remove x86-only restriction of movable_node
      mm: enable CONFIG_MOVABLE_NODE on non-x86 arches

Ross Zwisler (17):
      ext4: tell DAX the size of allocation holes
      dax: remove buffer_size_valid()
      ext2: remove support for DAX PMD faults
      dax: make 'wait_table' global variable static
      dax: remove the last BUG_ON() from fs/dax.c
      dax: consistent variable naming for DAX entries
      dax: coordinate locking for offsets in PMD range
      dax: remove dax_pmd_fault()
      dax: correct dax iomap code namespace
      dax: add dax_iomap_sector() helper function
      dax: dax_iomap_fault() needs to call iomap_end()
      dax: move RADIX_DAX_* defines to dax.h
      dax: move put_(un)locked_mapping_entry() in dax.c
      dax: add struct iomap based DAX PMD support
      xfs: use struct iomap based DAX PMD fault path
      dax: remove "depends on BROKEN" from FS_DAX_PMD
      ext4: remove unused function ext4_aligned_io()

Sergey Karamov (1):
      ext4: do not perform data journaling when data is encrypted

Shaohua Li (1):
      mm/vmscan.c: set correct defer count for shrinker

Stanislav Kinsburskiy (1):
      prctl: remove one-shot limitation for changing exe link

Stephen Rothwell (1):
      ipc/sem: merge fix for WAKE_Q to DEFINE_WAKE_Q rename

Sudip Mukherjee (2):
      m32r: add simple dma
      m32r: fix build warning

Tahsin Erdogan (1):
      fs/fs-writeback.c: remove redundant if check

Theodore Ts'o (15):
      Merge branch 'dax-4.10-iomap-pmd' into origin
      Merge branch 'fscrypt' into origin
      ext4: allow ext4_truncate() to return an error
      ext4: allow ext4_ext_truncate() to return an error
      ext4: don't lock buffer in ext4_commit_super if holding spinlock
      ext4: sanity check the block and cluster size at mount time
      ext4: fix in-superblock mount options processing
      ext4: use more strict checks for inodes_per_block on mount
      ext4: add sanity checking to count_overhead()
      ext4: fix reading new encrypted symlinks on no-journal file systems
      fscrypt: rename get_crypt_info() to fscrypt_get_crypt_info()
      fscrypt: unexport fscrypt_initialize()
      fscrypt: move non-public structures and constants to fscrypt_private.h
      fscrypt: move the policy flags and encryption mode definitions to uapi header
      Merge branch 'fscrypt' into dev

Thierry Reding (1):
      mm: cma: make linux/cma.h standalone includible

Thomas Garnier (1):
      mm/slab_common.c: check kmem_create_cache flags are common

Tobias Klauser (1):
      mm/gup.c: make unnecessarily global vma_permits_fault() static

Toshi Kani (1):
      libnvdimm: use generic iostat interfaces

Vitaly Wool (6):
      mm/z3fold.c: make pages_nr atomic
      mm/z3fold.c: extend compaction function
      z3fold: use per-page spinlock
      z3fold: discourage use of pages that weren't compacted
      z3fold: fix header size related issues
      z3fold: fix locking issues

Vladimir Davydov (2):
      mm: memcontrol: use special workqueue for creating per-memcg caches
      slub: move synchronize_sched out of slab_mutex on shrink

Vlastimil Babka (2):
      mm, debug: print raw struct page data in __dump_page()
      mm, rmap: handle anon_vma_prepare() common case inline

Waiman Long (1):
      sched/wake_q: Rename WAKE_Q to DEFINE_WAKE_Q

zhong jiang (3):
      mm/z3fold.c: limit first_num to the actual range of possible buddy indexes
      mm/page_owner: align with pageblock_nr pages
      mm/vmstat.c: walk the zone in pageblock_nr_pages steps

zijun_hu (2):
      mm/vmalloc.c: simplify /proc/vmallocinfo implementation
      mm/percpu.c: fix panic triggered by BUG_ON() falsely

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
