Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 28C77831F4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 07:51:32 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g12so1345050wrg.15
        for <linux-mm@kvack.org>; Thu, 04 May 2017 04:51:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l204si1068943wmf.91.2017.05.04.04.51.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 May 2017 04:51:30 -0700 (PDT)
Date: Thu, 4 May 2017 13:51:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: mmotm git tree since-4.11 branch created (was: mmotm
 2017-05-03-15-16 uploaded)
Message-ID: <20170504115110.GE31540@dhcp22.suse.cz>
References: <590a56eb.l+Eu7L7Jdv9KEqSs%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <590a56eb.l+Eu7L7Jdv9KEqSs%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org


I have just created since-4.11 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v4.11 tag in Linus tree and mmotm-2017-05-03-15-16.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The shortlog says:
Andi Kleen (3):
      kref: remove WARN_ON for NULL release functions
      drivers/scsi/megaraid: remove expensive inline from megasas_return_cmd
      include/linux/uaccess.h: remove expensive WARN_ON in pagefault_disabled_dec

Andrew Morton (4):
      mm-page_alloc-count-movable-pages-when-stealing-from-pageblock-fix
      drm-use-set_memoryh-header-fix
      docs-vm-transhuge-fix-few-trivial-typos-fix
      dax-add-tracepoint-to-dax_writeback_one-fix

Andrey Konovalov (9):
      kasan: introduce helper functions for determining bug type
      kasan: unify report headers
      kasan: change allocation and freeing stack traces headers
      kasan: simplify address description logic
      kasan: change report header
      kasan: improve slab object description
      kasan: print page description after stacks
      kasan: improve double-free report format
      kasan: separate report parts by empty lines

Andrey Ryabinin (4):
      fs: fix data invalidation in the cleancache during direct IO
      fs/block_dev: always invalidate cleancache in invalidate_bdev()
      mm/truncate: bail out early from invalidate_inode_pages2_range() if mapping is empty
      mm/truncate: avoid pointless cleancache_invalidate_inode() calls.

Andrey Vostrikov (1):
      lib/crc-ccitt: add CCITT-FALSE CRC16 variant

Anshuman Khandual (5):
      mm/mmap: replace SHM_HUGE_MASK with MAP_HUGE_MASK inside mmap_pgoff
      mm/madvise.c: clean up MADV_SOFT_OFFLINE and MADV_HWPOISON
      mm/madvise: move up the behavior parameter validation
      mm/memory-failure.c: add page flag description in error paths
      selftests/vm: add a test for virtual address range mapping

Arnd Bergmann (3):
      block, dax: use correct format string in bdev_dax_supported
      mm/gup.c: fix access_ok() argument type
      drivers/misc: aspeed-lpc-ctrl: fix printk format warning again

Colin Ian King (1):
      scripts/spelling.txt: add several more common spelling mistakes

Cyril Bur (2):
      drivers/misc: Add Aspeed LPC control driver
      drivers/misc: Aspeed LPC control fix compile error and warning

Dan Williams (37):
      device-dax: fix cdev leak
      acpi, nfit: fix acpi_get_table leak
      Merge branch 'for-4.11/libnvdimm' into for-4.12/dax
      device-dax: rename 'dax_dev' to 'dev_dax'
      dax: refactor dax-fs into a generic provider of 'struct dax_device' instances
      Revert "libnvdimm: band aid btt vs clear poison locking"
      acpi, nfit: add support for acpi 6.1 dimm state flags
      tools/testing/nvdimm: test acpi 6.1 health state flags
      acpi, nfit: support "map failed" dimms
      acpi, nfit: collate health state flags
      acpi, nfit: limit ->flush_probe() to initialization work
      tools/testing/nvdimm: fix nfit_test shutdown crash
      acpi, nfit: fix module unload vs workqueue shutdown race
      dax: add a facility to lookup a dax device by 'host' device name
      dax: introduce dax_operations
      pmem: add dax_operations support
      axon_ram: add dax_operations support
      brd: add dax_operations support
      dcssblk: add dax_operations support
      block: kill bdev_dax_capable()
      dax: introduce dax_direct_access()
      dm: add dax_device and dax_operations support
      libnvdimm, region: fix flush hint detection crash
      dm: teach dm-targets to use a dax_device + dax_operations
      ext2, ext4, xfs: retrieve dax_device for iomap operations
      Revert "block: use DAX for partition table reads"
      filesystem-dax: convert to dax_direct_access()
      block, dax: convert bdev_dax_supported() to dax_direct_access()
      block: remove block_device_operations ->direct_access()
      x86, dax, pmem: remove indirection around memcpy_from_pmem()
      libnvdimm, region: sysfs trigger for nvdimm_flush()
      acpi, nfit: kill ACPI_NFIT_DEBUG
      libnvdimm: rework region badblocks clearing
      libnvdimm: fix nvdimm_bus_lock() vs device_lock() ordering
      libnvdimm: restore "libnvdimm: band aid btt vs clear poison locking"
      device-dax: fix sysfs attribute deadlock
      Merge branch 'for-4.12/dax' into libnvdimm-for-next

Dave Jiang (5):
      libnvdimm: add mechanism to publish badblocks at the region level
      libnvdimm: Add 'resource' sysfs attribute to regions
      libnvdimm: add support for clear poison list and badblocks for device dax
      device-dax, tools/testing/nvdimm: enable device-dax with mock resources
      libnvdimm: fix clear poison locking with spinlock and GFP_NOWAIT allocation

David Rientjes (2):
      mm, vmstat: print non-populated zones in zoneinfo
      mm, vmstat: suppress pcp stats for unpopulated zones in zoneinfo

Deepa Dinamani (2):
      fs: f2fs: use ktime_get_real_seconds for sit_info times
      trace: make trace_hwlat timestamp y2038 safe

Dinh Nguyen (1):
      fpga: fix sparse warnings in fpga-mgr and fpga-bridge

Dmitry Torokhov (2):
      rapidio: use is_visible() to hide switch-specific attributes
      zorro: stop creating attributes by hand

Florian Fainelli (2):
      FPGA: Add TS-7300 FPGA manager
      ARM: ep93xx: Register ts73xx-fpga manager driver for TS-7300

Geert Uytterhoeven (5):
      auxdisplay: charlcd: Extract character LCD core from misc/panel
      auxdisplay: charlcd: Add support for 4-bit interfaces
      auxdisplay: charlcd: Add support for displays with more than two lines
      dt-bindings: auxdisplay: Add bindings for Hitachi HD44780
      auxdisplay: Add HD44780 Character LCD support

Geliang Tang (3):
      fs/ocfs2/cluster: use setup_timer
      fs/ocfs2/cluster: use offset_in_page() macro
      mm/page-writeback.c: use setup_deferrable_timer

Gerald Schaefer (1):
      brd: fix uninitialized use of brd->dax_dev

Greg Thelen (1):
      slab: avoid IPIs when creating kmem caches

Hao Lee (1):
      mm: fix spelling error

Huang Ying (7):
      mm, swap: Fix a race in free_swap_and_cache()
      mm, swap: fix comment in __read_swap_cache_async
      mm, swap: improve readability via make spin_lock/unlock balanced
      mm, swap: avoid lock swap_avail_lock when held cluster lock
      mm, swap: remove unused function prototype
      mm/swapfile.c: fix swap space leak in error path of swap_free_entries()
      mm, swap: use kvzalloc to allocate some swap data structures

Joe Perches (1):
      drivers/char: Convert remaining use of pr_warning to pr_warn

Joel Holdsworth (2):
      Documentation: Add binding document for Lattice iCE40 FPGA manager
      fpga: Add support for Lattice iCE40 FPGAs

Johannes Weiner (16):
      mm: fix 100% CPU kswapd busyloop on unreclaimable nodes
      mm: fix check for reclaimable pages in PF_MEMALLOC reclaim throttling
      mm: remove seemingly spurious reclaimability check from laptop_mode gating
      mm: remove unnecessary reclaimability check from NUMA balancing target
      mm: don't avoid high-priority reclaim on unreclaimable nodes
      mm: don't avoid high-priority reclaim on memcg limit reclaim
      mm: delete NR_PAGES_SCANNED and pgdat_reclaimable()
      Revert "mm, vmscan: account for skipped pages as a partial scan"
      mm: remove unnecessary back-off function when retrying page reclaim
      mm: memcontrol: provide shmem statistics
      mm: page_alloc: __GFP_NOWARN shouldn't suppress stall warnings
      mm: vmscan: fix IO/refault regression in cache workingset transition
      mm: memcontrol: clean up memory.events counting function
      mm: memcontrol: re-use global VM event enum
      mm: memcontrol: re-use node VM page state enum
      mm: memcontrol: use node page state naming scheme for memcg

Junxiao Bi (1):
      ocfs2: o2hb: revert hb threshold to keep compatible

K. Y. Srinivasan (2):
      Drivers: hv: Fix a typo
      Drivers: hv: Base autoeoi enablement based on hypervisor hints

Kees Cook (2):
      mm: remove rodata_test_data export, add pr_fmt
      format-security: move static strings to const

Laura Abbott (15):
      treewide: move set_memory_* functions away from cacheflush.h
      arm: use set_memory.h header
      arm64: use set_memory.h header
      s390: use set_memory.h header
      x86: use set_memory.h header
      agp: use set_memory.h header
      drm: use set_memory.h header
      drivers/hwtracing/intel_th/msu.c: use set_memory.h header
      drivers/watchdog/hpwdt.c: use set_memory.h header
      include/linux/filter.h: use set_memory.h header
      kernel/module.c: use set_memory.h header
      kernel/power/snapshot.c: use set_memory.h header
      alsa: use set_memory.h header
      drivers/misc/sram-exec.c: use set_memory.h header
      drivers/video/fbdev/vermilion/vermilion.c: use set_memory.h header

Laurent Dufour (2):
      mm: uncharge poisoned pages
      mm: skip HWPoisoned pages when onlining pages

Linda Knippers (3):
      acpi, nfit: allow override of built-in bitmasks for nvdimm DSMs
      acpi, nfit: allow specifying a default DSM family
      acpi, nfit: remove unnecessary newline

Logan Gunthorpe (2):
      chardev: add helper function to register char devs with a struct device
      device-dax: utilize new cdev_device_add helper function

Mariusz Bialonczyk (4):
      w1: add missing DS2413 documentation
      w1: add support for DS2438 Smart Battery Monitor
      w1: add documentation for w1_ds2438
      w1: w1_ds2760.h: fix defines indentation

Martyn Welch (2):
      docs: Add kernel-doc comments to VME driver API
      docs: Update VME documentation to include kerneldoc comments

Masahiro Yamada (1):
      blackfin: bf609: let clk_disable() return immediately if clk is NULL

Matt Ranostay (2):
      pps: add ioctl_compat function to correct ioctl definitions
      pps: fix padding issue with PPS_FETCH for ioctl_compat

Matthew Wilcox (1):
      mm: tighten up the fault path a little

Matthias Kaehlcke (1):
      hpet: Make cmd parameter of hpet_ioctl_common() unsigned

Mel Gorman (2):
      mm, vmscan: only clear pgdat congested/dirty/writeback state when balanced
      mm, vmscan: prevent kswapd sleeping prematurely due to mismatched classzone_idx

Michal Hocko (19):
      Merge remote-tracking branch 'nvdim/libnvdimm-for-next' into mmotm-since-4.11
      lockdep: allow to disable reclaim lockup detection
      xfs: abstract PF_FSTRANS to PF_MEMALLOC_NOFS
      mm: introduce memalloc_nofs_{save,restore} API
      xfs: use memalloc_nofs_{save,restore} instead of memalloc_noio*
      jbd2: mark the transaction context with the scope GFP_NOFS context
      jbd2: make the whole kjournald2 kthread NOFS safe
      oom: improve oom disable handling
      mm: introduce kv[mz]alloc helpers
      mm, vmalloc: properly track vmalloc users
      mm: support __GFP_REPEAT in kvmalloc_node for >32kB
      lib/rhashtable.c: simplify a strange allocation pattern
      net/ipv6/ila/ila_xlat.c: simplify a strange allocation pattern
      fs/xattr.c: zero out memory copied to userspace in getxattr
      treewide: use kv[mz]alloc* rather than opencoded variants
      net: use kvmalloc with __GFP_REPEAT rather than open coded variant
      drivers/md/dm-ioctl.c: use kvmalloc rather than opencoded variant
      drivers/md/bcache/super.c: use kvmalloc
      mm, vmalloc: use __GFP_HIGHMEM implicitly

Mike Kravetz (1):
      Documentation: vm, add hugetlbfs reservation overview

Mike Rapoport (1):
      userfaultfd: selftest: combine all cases into a single executable

Minchan Kim (18):
      mm: fix lazyfree BUG_ON check in try_to_unmap_one()
      mm: do not use double negation for testing page flags
      mm: remove unncessary ret in page_referenced
      mm: remove SWAP_DIRTY in ttu
      mm: remove SWAP_MLOCK check for SWAP_SUCCESS in ttu
      mm: make try_to_munlock() return void
      mm: remove SWAP_MLOCK in ttu
      mm: remove SWAP_AGAIN in ttu
      mm: make ttu's return boolean
      mm: make rmap_walk() return void
      mm: make rmap_one boolean function
      mm: remove SWAP_[SUCCESS|AGAIN|FAIL]
      zram: handle multiple pages attached bio's bvec
      zram: partial IO refactoring
      zram: use zram_slot_lock instead of raw bit_spin_lock op
      zram: remove zram_meta structure
      zram: introduce zram data accessor
      zram: use zram_free_page instead of open-coded

Ming Lei (1):
      MAINTAINERS: update firmware loader entry

Moritz Fischer (4):
      fpga: Add flag to indicate bitstream needs decrypting
      fpga: zynq: Add support for encrypted bitstreams
      fpga: region: Add fpga-region property 'encrypted-fpga-config'
      fpga: bridge: Replace open-coded list_for_each + list_entry

Naoya Horiguchi (2):
      mm: hwpoison: call shake_page() unconditionally
      mm: hwpoison: call shake_page() after try_to_unmap() for mlocked page

Nikolay Borisov (1):
      lockdep: teach lockdep about memalloc_noio_save

Oliver O'Halloran (3):
      device-dax: improve fault handler debug output
      mm/huge_memory.c.c: use zap_deposited_table() more
      mm/huge_memory.c: deposit a pgtable for DAX PMD faults when required

Pankaj Gupta (1):
      lib/dma-debug.c: make locking work for RT

Pavel Tatashin (4):
      sparc64: NG4 memset 32 bits overflow
      mm: zero hash tables in allocator
      mm: update callers to use HASH_ZERO flag
      mm: adaptive hash table scaling

Pushkar Jambhlekar (2):
      device-dax: fix dax_dev_huge_fault() unknown fault size handling
      include/linux/migrate.h: add arg names to prototype

Rob Herring (1):
      binder: Add 'hwbinder' to the default devices

Ross Zwisler (7):
      dax: add tracepoints to dax_iomap_pte_fault()
      dax: add tracepoints to dax_pfn_mkwrite()
      dax: add tracepoints to dax_load_hole()
      dax: add tracepoints to dax_writeback_mapping_range()
      dax: fix regression in dax_writeback_mapping_range()
      dax: add tracepoint to dax_writeback_one()
      dax: add tracepoint to dax_insert_mapping()

Sangwoo Park (1):
      zram: reduce load operation in page_same_filled

SeongJae Park (1):
      Documentation/vm/transhuge.txt: fix trivial typos

Shantanu Goel (1):
      mm, vmscan: fix zone balance check in prepare_kswapd_sleep

Shaohua Li (6):
      mm: delete unnecessary TTU_* flags
      mm: don't assume anonymous pages have SwapBacked flag
      mm: move MADV_FREE pages into LRU_INACTIVE_FILE list
      mm: reclaim MADV_FREE pages
      mm: enable MADV_FREE for swapless system
      proc: show MADV_FREE pages info in smaps

Stephen Boyd (2):
      scripts/spelling.txt: add "memory" pattern and fix typos
      scripts/spelling.txt: Add regsiter -> register spelling mistake

Stephen Hemminger (9):
      vmbus: only reschedule tasklet if time limit exceeded
      hyperv: fix warning about missing prototype
      vmbus: remove useless return's
      vmbus: remove unnecessary initialization
      vmbus: fix spelling errors
      hyperv: remove unnecessary return variable
      vmbus: make channel_message table constant
      vmbus: cleanup header file style
      vmbus: expose debug info for drivers

Stephen Rothwell (2):
      mm: introduce kv[mz]alloc helpers - f2fs fix up
      kprobes/x86: merge fix for set_memory.h decoupling

Tetsuo Handa (2):
      mm, page_alloc: remove debug_guardpage_minorder() test in warn_alloc()
      fs: semove set but not checked AOP_FLAG_UNINTERRUPTIBLE flag

Tim Chen (1):
      mm/swap_slots.c: add warning if swap slots cache failed to initialize

Toshi Kani (3):
      libnvdimm: fix phys_addr for nvdimm_clear_poison
      libnvdimm, pmem: fix a NULL pointer BUG in nd_pmem_notify
      libnvdimm: fix clear length of nvdimm_forget_poison()

Vinayak Menon (2):
      mm: enable page poisoning early at boot
      mm: vmscan: do not pass reclaimed slab to vmpressure

Vlastimil Babka (14):
      mm, compaction: reorder fields in struct compact_control
      mm, compaction: remove redundant watermark check in compact_finished()
      mm, page_alloc: split smallest stolen page in fallback
      mm-page_alloc-split-smallest-stolen-page-in-fallback-fix
      mm, page_alloc: count movable pages when stealing from pageblock
      mm, compaction: change migrate_async_suitable() to suitable_migration_source()
      mm, compaction: add migratetype to compact_control
      mm, compaction: restrict async compaction to pageblocks of same migratetype
      mm, compaction: finish whole pageblock to reduce fragmentation
      mm: prevent potential recursive reclaim due to clearing PF_MEMALLOC
      mm: introduce memalloc_noreclaim_{save,restore}
      treewide: convert PF_MEMALLOC manipulations to new helpers
      treewide-convert-pf_memalloc-manipulations-to-new-helpers-fix
      mtd: nand: nandsim: convert to memalloc_noreclaim_*()

Wei Yang (2):
      mm/sparse: refine usemap_size() a little
      mm/page_alloc: return 0 in case this node has no page within the zone

Xishi Qiu (2):
      mm: use is_migrate_highatomic() to simplify the code
      mm: use is_migrate_isolate_page() to simplify the code

Yisheng Xie (2):
      mm/compaction: ignore block suitable after check large free page
      mm/vmscan: more restrictive condition for retry in do_try_to_free_pages

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
