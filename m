From: Michal Hocko <mhocko@kernel.org>
Subject: mmotm git tree since-4.6 branch created (was: mmotm 2016-05-23-16-51
 uploaded)
Date: Tue, 24 May 2016 11:56:27 +0200
Message-ID: <20160524095626.GE8259@dhcp22.suse.cz>
References: <57439797.36ht8abUxrU5hKGX%akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57439797.36ht8abUxrU5hKGX%akpm@linux-foundation.org>
Sender: linux-next-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org
List-Id: linux-mm.kvack.org

I have just created since-4.6 branch in mm git tree
(http://git.kernel.org/?p=3Dlinux/kernel/git/mhocko/mm.git;a=3Dsummary)=
=2E It
is based on v4.6 tag in Linus tree and mmotm-2016-05-23-16-51.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The shortlog says:
Alexander Kuleshov (1):
      mm/memblock.c: move memblock_{add,reserve}_region into memblock_{=
add,reserve}

Alexander Potapenko (3):
      mm: kasan: initial memory quarantine implementation
      mm, kasan: don't call kasan_krealloc() from ksize().
      mm, kasan: add a ksize() test

Alexey Dobriyan (1):
      seqlock: fix raw_read_seqcount_latch()

Andi Kleen (1):
      kernek/fork.c: allocate idle task for a CPU always on its local n=
ode

Andrea Arcangeli (2):
      mm: thp: microoptimize compound_mapcount()
      mm: thp: split_huge_pmd_address() comment improvement

Andres Lagar-Cavilla (1):
      tmpfs: mem_cgroup charge fault to vm_mm not current mm

Andrew Morton (7):
      include/linux/nodemask.h: create next_node_in() helper
      mm/hugetlb.c: use first_memory_node
      mm/mempolicy.c:offset_il_node() document and clarify
      mm: uninline page_mapped()
      mm-oom_reaper-do-not-mmput-synchronously-from-the-oom-reaper-cont=
ext-fix-fix
      mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites-c=
heckpatch-fixes
      mm-thp-avoid-unnecessary-swapin-in-khugepaged-fix

Andrey Ryabinin (6):
      mm/kasan: print name of mem[set,cpy,move]() caller in report
      mm/kasan: add API to check memory regions
      x86/kasan: instrument user memory access API
      kasan/tests: add tests for user memory access functions
      mm: kasan: remove unused 'reserved' field from struct kasan_alloc=
_meta
      mm: slub: remove unused virt_to_obj()

Andy Shevchenko (11):
      lib/vsprintf: simplify UUID printing
      security/integrity/ima/ima_policy.c: use %pU to output UUID in pr=
intable format
      lib/uuid.c: move generate_random_uuid() to uuid.c
      lib/uuid.c: introduce a few more generic helpers
      lib/uuid.c: remove FSF address
      kernel/sysctl_binary.c: use generic UUID library
      include/linux/efi.h: redefine type, constant, macro from generic =
code
      fs/efivarfs/inode.c: use generic UUID library
      include/linux/genhd.h: move to use generic UUID library
      block/partitions/ldm.c: use generic UUID library
      drivers/platform/x86/wmi.c: use generic UUID library

Arnd Bergmann (1):
      kernel/padata.c: hide unused functions

Borislav Petkov (1):
      locking/rwsem: Fix comment on register clobbering

Chanho Min (1):
      mm/highmem: simplify is_highmem()

Chen Feng (1):
      mm/compaction.c: fix zoneindex in kcompactd()

Chen Gang (2):
      include/linux/hugetlb*.h: clean up code
      include/linux/hugetlb.h: use bool instead of int for hugepage_mig=
ration_supported()

Chen Yucong (1):
      mm/memory-failure.c: replace "MCE" with "Memory failure"

Chris Wilson (1):
      mm/vmalloc: keep a separate lazy-free list

Christoph Lameter (1):
      vmstat: get rid of the ugly cpu_stat_off variable

Corey Minyard (1):
      kdump: fix gdb macros work work with newer and 64-bit kernels

Dan Streetman (3):
      mm/zswap: use workqueue to destroy pool
      mm/zsmalloc: don't fail if can't create debugfs info
      update "mm/zsmalloc: don't fail if can't create debugfs info"

David Rientjes (3):
      mm, hugetlb_cgroup: round limit_in_bytes down to hugepage size
      mm, thp: khugepaged should scan when sleep value is written
      mm, migrate: increment fail count on ENOMEM

Du, Changbin (8):
      debugobjects: make fixup functions return bool instead of int
      debugobjects: correct the usage of fixup call results
      workqueue: update debugobjects fixup callbacks return type
      timer: update debugobjects fixup callbacks return type
      rcu: update debugobjects fixup callbacks return type
      percpu_counter: update debugobjects fixup callbacks return type
      Documentation: update debugobjects doc
      debugobjects: insulate non-fixup logic related to static obj from=
 fixup callbacks

Ebru Akagunduz (4):
      mm: make optimistic check for swapin readahead
      mm: make swapin readahead to improve thp collapse rate
      mm, vmstat: calculate particular vm event
      mm, thp: avoid unnecessary swapin in khugepaged

Eric Dumazet (1):
      mm: tighten fault_in_pages_writeable()

Eric Engestrom (2):
      Documentation: vm: fix spelling mistakes
      MAINTAINERS: remove defunct spear mailing list

Eric Ren (1):
      ocfs2: fix improper handling of return errno

Greg Thelen (1):
      memcg: fix stale mem_cgroup_force_empty() comment

Hugh Dickins (8):
      mm: update_lru_size warn and reset bad lru_size
      mm: update_lru_size do the __mod_zone_page_state
      mm: use __SetPageSwapBacked and dont ClearPageSwapBacked
      tmpfs: preliminary minor tidyups
      mm: /proc/sys/vm/stat_refresh to force vmstat update
      huge mm: move_huge_pmd does not need new_vma
      huge pagecache: extend mremap pmd rmap lockout to files
      arch: fix has_transparent_hugepage()

Janis Danisevskis (1):
      procfs: fix pthread cross-thread naming if !PR_DUMPABLE

Jiri Slaby (6):
      mn10300: let exit_fpu accept a task
      exit_thread: remove empty bodies
      exit_thread: accept a task parameter to be exited
      fork: free thread in copy_process on failure
      MAINTAINERS: remove linux@lists.openrisc.net
      MAINTAINERS: remove Koichi Yasutake

Johannes Weiner (1):
      mm: filemap: only do access activations on reads

Joonsoo Kim (22):
      mm/slab: fix the theoretical race by holding proper lock
      mm/slab: remove BAD_ALIEN_MAGIC again
      mm/slab: drain the free slab as much as possible
      mm/slab: factor out kmem_cache_node initialization code
      mm/slab: clean-up kmem_cache_node setup
      mm/slab: don't keep free slabs if free_objects exceeds free_limit
      mm/slab: racy access/modify the slab color
      mm/slab: make cache_grow() handle the page allocated on arbitrary=
 node
      mm/slab: separate cache_grow() to two parts
      mm/slab: refill cpu cache through a new slab without holding a no=
de lock
      mm/slab: lockless decision to grow cache
      mm/page_ref: use page_ref helper instead of direct modification o=
f _count
      mm: rename _count, field of the struct page, to _refcount
      mm/hugetlb: add same zone check in pfn_range_valid_gigantic()
      mm/memory_hotplug: add comment to some functions related to memor=
y hotplug
      mm/vmstat: add zone range overlapping check
      mm/page_owner: add zone range overlapping check
      power: add zone range overlapping check
      mm/writeback: correct dirty page calculation for highmem
      mm/page_alloc: correct highmem memory statistics
      mm/highmem: make nr_free_highpages() handles all highmem zones by=
 itself
      mm/vmstat: make node_page_state() handles all zones by itself

Julia Lawall (1):
      nilfs2: constify nilfs_sc_operations structures

Kirill A. Shutemov (4):
      mm: make faultaround produce old ptes
      mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix
      khugepaged: __collapse_huge_page_swapin(): drop unused 'pte' para=
meter
      thp: do not hold anon_vma lock during swap in

Konstantin Khlebnikov (4):
      mm/rmap: replace BUG_ON(anon_vma->degree) with VM_WARN_ON
      mm/mmap: kill hook arch_rebalance_pgtables()
      mm: enable RLIMIT_DATA by default with workaround for valgrind
      arch/defconfig: remove CONFIG_RESOURCE_COUNTERS

Li Peng (1):
      mm/slub.c: fix sysfs filename in comment

Li Zhang (1):
      mm/page_alloc: Remove useless parameter of __free_pages_boot_core

Matthew Wilcox (36):
      radix-tree: introduce radix_tree_empty
      radix tree test suite: fix build
      radix tree test suite: add tests for radix_tree_locate_item()
      raxix-tree: introduce CONFIG_RADIX_TREE_MULTIORDER
      radix-tree: add missing sibling entry functionality
      radix-tree: fix sibling entry insertion
      radix-tree: fix deleting a multi-order entry through an alias
      radix-tree: remove restriction on multi-order entries
      radix-tree: introduce radix_tree_load_root()
      radix-tree: fix extending the tree for multi-order entries at off=
set 0
      radix tree test suite: start adding multiorder tests
      radix-tree: fix several shrinking bugs with multiorder entries
      radix-tree: rewrite __radix_tree_lookup
      radix-tree: fix multiorder BUG_ON in radix_tree_insert
      radix-tree: fix radix_tree_create for sibling entries
      radix-tree: rewrite radix_tree_locate_item
      radix-tree: fix radix_tree_range_tag_if_tagged() for multiorder e=
ntries
      radix-tree: add copyright statements
      drivers/hwspinlock: use correct radix tree API
      radix-tree: miscellaneous fixes
      radix-tree: split node->path into offset and height
      radix-tree: replace node->height with node->shift
      radix-tree: remove a use of root->height from delete_node
      radix tree test suite: remove dependencies on height
      radix-tree: remove root->height
      radix-tree: rename INDIRECT_PTR to INTERNAL_NODE
      radix-tree: rename ptr_to_indirect() to node_to_entry()
      radix-tree: rename indirect_to_ptr() to entry_to_node()
      radix-tree: rename radix_tree_is_indirect_ptr()
      radix-tree: change naming conventions in radix_tree_shrink
      radix-tree: tidy up next_chunk
      radix-tree: tidy up range_tag_if_tagged
      radix-tree: tidy up __radix_tree_create()
      radix-tree: introduce radix_tree_replace_clear_tags()
      radix-tree: make radix_tree_descend() more useful
      radix-tree: free up the bottom bit of exceptional entries for reu=
se

Mel Gorman (29):
      mm, page_alloc: only check PageCompound for high-order pages
      mm, page_alloc: use new PageAnonHead helper in the free page fast=
 path
      mm, page_alloc: reduce branches in zone_statistics
      mm, page_alloc: inline zone_statistics
      mm, page_alloc: inline the fast path of the zonelist iterator
      mm, page_alloc: use __dec_zone_state for order-0 page allocation
      mm, page_alloc: avoid unnecessary zone lookups during pageblock o=
perations
      mm, page_alloc: convert alloc_flags to unsigned
      mm, page_alloc: convert nr_fair_skipped to bool
      mm, page_alloc: remove unnecessary local variable in get_page_fro=
m_freelist
      mm, page_alloc: remove unnecessary initialisation in get_page_fro=
m_freelist
      mm, page_alloc: remove unnecessary initialisation from __alloc_pa=
ges_nodemask()
      mm, page_alloc: simplify last cpupid reset
      mm, page_alloc: move __GFP_HARDWALL modifications out of the fast=
path
      mm, page_alloc: check once if a zone has isolated pageblocks
      mm, page_alloc: shorten the page allocator fast path
      mm, page_alloc: reduce cost of fair zone allocation policy retry
      mm, page_alloc: shortcut watermark checks for order-0 pages
      mm, page_alloc: avoid looking up the first zone in a zonelist twi=
ce
      mm, page_alloc: remove field from alloc_context
      mm, page_alloc: check multiple page fields with a single branch
      mm, page_alloc: un-inline the bad part of free_pages_check
      mm, page_alloc: pull out side effects from free_pages_check
      mm, page_alloc: remove unnecessary variable from free_pcppages_bu=
lk
      mm, page_alloc: inline pageblock lookup in page free fast paths
      mm, page_alloc: defer debugging checks of freed pages until a PCP=
 drain
      mm, page_alloc: defer debugging checks of pages allocated from th=
e PCP
      mm, page_alloc: don't duplicate code in free_pcp_prepare
      mm, page_alloc: restore the original nodemask if the fast path al=
location failed

Michal Hocko (52):
      locking/rwsem: Get rid of __down_write_nested()
      locking/rwsem: Drop explicit memory barriers
      locking/rwsem, xtensa: Drop superfluous arch specific implementat=
ion
      locking/rwsem, sh: Drop superfluous arch specific implementation
      locking/rwsem, sparc: Drop superfluous arch specific implementati=
on
      locking/rwsem: Introduce basis for down_write_killable()
      locking/rwsem, alpha: Provide __down_write_killable()
      locking/rwsem, ia64: Provide __down_write_killable()
      locking/rwsem, s390: Provide __down_write_killable()
      locking/rwsem, x86: Provide __down_write_killable()
      locking/rwsem: Provide down_write_killable()
      locking/rwsem, x86: Add frame annotation for call_rwsem_down_writ=
e_failed_killable()
      mm/memcontrol.c:mem_cgroup_select_victim_node(): clarify comment
      mm, oom: move GFP_NOFS check to out_of_memory
      oom, oom_reaper: try to reap tasks which skip regular OOM killer =
path
      mm, oom_reaper: clear TIF_MEMDIE for all tasks queued for oom_rea=
per
      vmscan: consider classzone_idx in compaction_ready
      mm, compaction: change COMPACT_ constants into enum
      mm, compaction: cover all compaction mode in compact_zone
      mm, compaction: distinguish COMPACT_DEFERRED from COMPACT_SKIPPED
      mm, compaction: distinguish between full and partial COMPACT_COMP=
LETE
      mm, compaction: update compaction_result ordering
      mm, compaction: simplify __alloc_pages_direct_compact feedback in=
terface
      mm, compaction: abstract compaction feedback to helpers
      mm, oom: rework oom detection
      mm: throttle on IO only when there are too many dirty and writeba=
ck pages
      mm, oom: protect !costly allocations some more
      mm: consider compaction feedback also for costly allocation
      mm, oom, compaction: prevent from should_compact_retry looping fo=
r ever for costly orders
      mm, oom: protect !costly allocations some more for !CONFIG_COMPAC=
TION
      mm, oom_reaper: hide oom reaped tasks from OOM killer more carefu=
lly
      mm, oom_reaper: do not mmput synchronously from the oom reaper co=
ntext
      oom: consider multi-threaded tasks in task_will_free_mem
      mm: make mmap_sem for write waits killable for mm syscalls
      mm: make vm_mmap killable
      mm: make vm_munmap killable
      mm, aout: handle vm_brk failures
      mm, elf: handle vm_brk error
      mm: make vm_brk killable
      mm, proc: make clear_refs killable
      mm, fork: make dup_mmap wait for mmap_sem for write killable
      ipc, shm: make shmem attach/detach wait for mmap_sem killable
      vdso: make arch_setup_additional_pages wait for mmap_sem for writ=
e killable
      coredump: make coredump_wait wait for mmap_sem for write killable
      aio: make aio_setup_ring killable
      exec: make exec path waiting for mmap_sem killable
      prctl: make PR_SET_THP_DISABLE wait for mmap_sem killable
      uprobes: wait for mmap_sem for write killable
      drm/i915: make i915_gem_mmap_ioctl wait for mmap_sem killable
      drm/radeon: make radeon_mn_get wait for mmap_sem killable
      drm/amdgpu: make amdgpu_mn_get wait for mmap_sem killable
      mm: oom_reaper: remove some bloat

Mike Kravetz (1):
      mm/hugetlb: optimize minimum size (min_size) accounting

Minchan Kim (5):
      mm: disable fault around on emulated access bit architecture
      zsmalloc: use first_page rather than page
      zsmalloc: clean up many BUG_ON
      zsmalloc: reorder function parameters
      zsmalloc: remove unused pool param in obj_free

Minfei Huang (3):
      mm: use existing helper to convert "on"/"off" to boolean
      kexec: make a pair of map/unmap reserved pages in error path
      kexec: do a cleanup for function kexec_load

Ming Li (1):
      mm/swap.c: put activate_page_pvecs and other pagevecs together

Muhammad Falak R Wani (1):
      drivers/memstick/core/mspro_block: use kmemdup

Naoya Horiguchi (1):
      mm: check_new_page_bad() directly returns in __PG_HWPOISON case

NeilBrown (2):
      MM: increase safety margin provided by PF_LESS_THROTTLE
      dax: move RADIX_DAX_ definitions to dax.c

Oleg Nesterov (5):
      userfaultfd: don't pin the user memory in userfaultfd_file_create=
()
      wait/ptrace: assume __WALL if the child is traced
      wait: allow sys_waitid() to accept __WNOTHREAD/__WCLONE/__WALL
      signal: move the "sig < SIGRTMIN" check into siginmask(sig)
      exec: remove the no longer needed remove_arg_zero()->free_arg_pag=
e()

Oleksandr Natalenko (1):
      rtsx_usb_ms: use schedule_timeout_idle() in polling loop

Peter Zijlstra (1):
      locking/rwsem: Fix down_write_killable()

Petr Mladek (4):
      printk/nmi: generic solution for safe printk in NMI
      printk/nmi: warn when some message has been lost in NMI context
      printk/nmi: increase the size of NMI buffer and make it configura=
ble
      printk/nmi: flush NMI messages on the system panic

Ralf Baechle (1):
      ELF/MIPS build fix

Rasmus Villemoes (2):
      compiler.h: add support for malloc attribute
      include/linux: apply __malloc attribute

Ren=E9 Nyffenegger (1):
      include/linux/syscalls.h: use pid_t instead of int

Reza Arbab (3):
      memory-hotplug: add move_pfn_range()
      memory-hotplug: more general validation of zone during online
      memory-hotplug: use zone_can_shift() for sysfs valid_zones attrib=
ute

Rich Felker (1):
      tmpfs/ramfs: fix VM_MAYSHARE mappings for NOMMU

Richard Cochran (1):
      kernel/padata.c: removed unused code

Richard Leitner (1):
      mm/memblock.c: remove unnecessary always-true comparison

Richard W.M. Jones (1):
      procfs: expose umask in /proc/<PID>/status

Rik van Riel (2):
      mm: workingset: only do workingset activations on reads
      mm: vmscan: reduce size of inactive file list

Ross Zwisler (12):
      radix tree test suite: allow testing other fan-out values
      radix tree test suite: keep regression test runs short
      radix tree test suite: rebuild when headers change
      radix-tree: remove unused looping macros
      radix-tree: add support for multi-order iterating
      radix tree test suite: multi-order iteration test
      radix-tree: rewrite radix_tree_tag_set
      radix-tree: rewrite radix_tree_tag_clear
      radix-tree: rewrite radix_tree_tag_get
      radix-tree test suite: add multi-order tag test
      radix-tree: add test for radix_tree_locate_item()
      radix-tree: fix radix_tree_dump() for multi-order entries

Ryusuke Konishi (18):
      nilfs2: fix white space issue in nilfs_mount()
      nilfs2: remove space before comma
      nilfs2: remove FSF mailing address from GPL notices
      nilfs2: clean up old e-mail addresses
      MAINTAINERS: add web link for nilfs project
      nilfs2: clarify permission to replicate the design
      nilfs2: get rid of nilfs_mdt_mark_block_dirty()
      nilfs2: move cleanup code of metadata file from inode routines
      nilfs2: replace __attribute__((packed)) with __packed
      nilfs2: add missing line spacing
      nilfs2: clean trailing semicolons in macros
      nilfs2: do not emit extra newline on nilfs_warning() and nilfs_er=
ror()
      nilfs2: remove space before semicolon
      nilfs2: fix code indent coding style issue
      nilfs2: avoid bare use of 'unsigned'
      nilfs2: remove unnecessary else after return or break
      nilfs2: remove loops of single statement macros
      nilfs2: fix block comments

Salah Triki (9):
      fs/befs/datastream.c:befs_read_datastream(): remove unneeded init=
ialization to NULL
      fs/befs/datastream.c:befs_read_lsymlink(): remove unneeded initia=
lization to NULL
      fs/befs/datastream.c:befs_find_brun_dblindirect(): remove unneede=
d initializations to NULL
      fs/befs/linuxvfs.c:befs_get_block(): remove unneeded initializati=
on to NULL
      fs/befs/linuxvfs.c:befs_iget(): remove unneeded initialization to=
 NULL
      fs/befs/linuxvfs.c:befs_iget(): remove unneeded raw_inode initial=
ization to NULL
      fs/befs/linuxvfs.c:befs_iget(): remove unneeded befs_nio initiali=
zation to NULL
      fs/befs/io.c:befs_bread_iaddr(): remove unneeded initialization t=
o NULL
      fs/befs/io.c:befs_bread(): remove unneeded initialization to NULL

Sergey Senozhatsky (4):
      zsmalloc: require GFP in zs_malloc()
      zram: user per-cpu compression streams
      zram: remove max_comp_streams internals
      zram: introduce per-device debug_stat sysfs node

Stefan Bader (1):
      mm: use phys_addr_t for reserve_bootmem_region() arguments

Sudip Mukherjee (1):
      m32r: fix build failure

Tetsuo Handa (4):
      mm,oom: speed up select_bad_process() loop
      mm,writeback: don't use memory reserves for wb_start_writeback
      signal: make oom_flags a bool
      memcg: fix mem_cgroup_out_of_memory() return value.

Thomas Garnier (1):
      mm: SLAB freelist randomization

Vaishali Thakkar (6):
      mm/hugetlb: introduce hugetlb_bad_size()
      arm64: mm: use hugetlb_bad_size()
      metag: mm: use hugetlb_bad_size()
      powerpc: mm: use hugetlb_bad_size()
      tile: mm: use hugetlb_bad_size()
      x86: mm: use hugetlb_bad_size()

Ville Syrj=E4l=E4 (1):
      dma-debug: avoid spinlock recursion when disabling dma-debug

Vitaly Kuznetsov (2):
      memory_hotplug: introduce CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
      memory_hotplug: introduce memhp_default_state=3D command line par=
ameter

Vitaly Wool (1):
      z3fold: the 3-fold allocator for compressed pages

Vladimir Davydov (3):
      mm/slub.c: replace kick_all_cpus_sync() with synchronize_sched() =
in kmem_cache_shrink()
      mm: memcontrol: fix possible css ref leak on oom
      mm/khugepaged: fix scan not aborted on SCAN_EXCEED_SWAP_PTE

Vlastimil Babka (5):
      mm, compaction: wrap calculating first and last pfn of pageblock
      mm, compaction: reduce spurious pcplist drains
      mm, compaction: skip blocks where isolation fails in async direct=
 compaction
      cpuset: use static key better and convert to new API
      mm, page_alloc: uninline the bad page part of check_new_page()

Wang Xiaoqiang (1):
      kernel/signal.c: convert printk(KERN_<LEVEL> ...) to pr_<level>(.=
=2E.)

Weijie Yang (1):
      mm fix commmets: if SPARSEMEM, pgdata doesn't have page_ext

Xunlei Pang (3):
      kexec: introduce a protection mechanism for the crashkernel reser=
ved memory
      kexec: provide arch_kexec_protect(unprotect)_crashkres()
      s390/kexec: consolidate crash_map/unmap_reserved_pages() and arch=
_kexec_protect(unprotect)_crashkres()

Yang Shi (6):
      mm: slab: remove ZONE_DMA_FLAG
      mm: thp: simplify the implementation of mk_huge_pmd()
      mm: page_is_guard(): return false when page_ext arrays are not al=
located yet
      mm: call page_ext_init() after all struct pages are initialized
      mm: make CONFIG_DEFERRED_STRUCT_PAGE_INIT depends on !FLATMEM exp=
licitly
      mm: check the return value of lookup_page_ext for all call sites

Yaowei Bai (4):
      mm/hugetlb: is_vm_hugetlb_page() can return bool
      mm/memory_hotplug: is_mem_section_removable() can return bool
      mm/vmalloc.c: is_vmalloc_addr() can return bool
      mm/mempolicy.c: vma_migratable() can return bool

Yongji Xie (1):
      mm: fix incorrect pfn passed to untrack_pfn() in remap_pfn_range(=
)

Yu Zhao (1):
      mm: use unsigned long constant for page flags

Zhaoxiu Zeng (1):
      lib/GCD.c: use binary GCD algorithm instead of Euclidean

nimisolo (1):
      mm/memblock.c:memblock_add_range(): if nr_new is 0 just return

seokhoon.yoon (1):
      mm, kasan: fix to call kasan_free_pages() after poisoning page

--=20
Michal Hocko
SUSE Labs
