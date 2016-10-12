Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 27E116B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 04:14:01 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f193so5030437wmg.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:14:01 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id w1si8975675wjz.107.2016.10.12.01.13.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 01:14:00 -0700 (PDT)
Received: by mail-wm0-f46.google.com with SMTP id o81so15886346wma.1
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:13:59 -0700 (PDT)
Date: Wed, 12 Oct 2016 10:13:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: mmotm git tree since-4.8 branch created (was: mmotm 2016-10-11-15-46
 uploaded)
Message-ID: <20161012081357.GB17128@dhcp22.suse.cz>
References: <57fd6c03.MqL5gLzjGe1u5CBc%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57fd6c03.MqL5gLzjGe1u5CBc%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

I have just created since-4.8 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v4.8 tag in Linus tree and mmotm-2016-10-11-15-46.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

The shortlog says:
Aaron Lu (1):
      thp: reduce usage of huge zero page's atomic counter

Ales Novak (1):
      ptrace: clear TIF_SYSCALL_TRACE on ptrace detach

Alexander Potapenko (3):
      include/linux: provide a safe version of container_of()
      llist: introduce llist_entry_safe()
      kcov: do not instrument lib/stackdepot.c

Alexandre Bounine (1):
      rapidio/rio_cm: use memdup_user() instead of duplicating code

Alexey Dobriyan (5):
      mm: unrig VMA cache hit ratio
      proc: much faster /proc/vmstat
      proc: faster /proc/*/status
      include/linux/ctype.h: make isdigit() table lookupless
      lib/kstrtox.c: smaller _parse_integer()

Andrea Arcangeli (6):
      mm: vm_page_prot: update with WRITE_ONCE/READ_ONCE
      mm: vma_adjust: remove superfluous confusing update in remove_next == 1 case
      mm: vma_merge: fix vm_page_prot SMP race condition against rmap_walk
      mm: vma_adjust: remove superfluous check for next not NULL
      mm: vma_adjust: minor comment correction
      mm: vma_merge: correct false positive from __vma_unlink->validate_mm_rb

Andrew Morton (1):
      mm/page_io.c: replace some BUG_ON()s with VM_BUG_ON_PAGE()

Andrey Konovalov (1):
      kcov: properly check if we are in an interrupt

Aneesh Kumar K.V (1):
      mm: use zonelist name instead of using hardcoded index

Baoyou Xie (1):
      mm: move phys_mem_access_prot_allowed() declaration to pgtable.h

Bart Van Assche (1):
      do_generic_file_read(): fail immediately if killed

Borislav Petkov (1):
      config/android: Remove CONFIG_IPV6_PRIVACY

Catalin Marinas (1):
      mm: kmemleak: avoid using __va() on addresses that don't have a lowmem mapping

Christoph Hellwig (1):
      kprobes: include <asm/sections.h> instead of <asm-generic/sections.h>

Dan Williams (1):
      mm: fix cache mode tracking in vm_insert_mixed()

Darrick J. Wong (3):
      block: invalidate the page cache when issuing BLKZEROOUT
      block: require write_same and discard requests align to logical block size
      block: implement (some of) fallocate for block devices

Davidlohr Bueso (3):
      ipc/msg: batch queue sender wakeups
      ipc/msg: make ss_wakeup() kill arg boolean
      ipc/msg: avoid waking sender upon full queue

Ganesh Mahendran (2):
      mm/zsmalloc: add trace events for zs_compact
      mm/zsmalloc: add per-class compact trace event

Gerald Schaefer (3):
      mm/hugetlb: fix memory offline with hugepage size > memory block size
      mm/hugetlb: check for reserved hugepages during memory offline
      mm/hugetlb: improve locking in dissolve_free_huge_pages()

Hidehiro Kawai (2):
      x86/panic: replace smp_send_stop() with kdump friendly version in panic path
      mips/panic: replace smp_send_stop() with kdump friendly version in panic path

Huang Ying (4):
      mm, swap: add swap_cluster_list
      mm: don't use radix tree writeback tags for pages in swap cache
      mm, swap: use offset of swap entry as key of swap cache
      mm: remove page_file_index

Ian Kent (5):
      autofs: fix autofs4_fill_super() error exit handling
      autofs: remove ino free in autofs4_dir_symlink()
      autofs: fix dev ioctl number range check
      autofs: add autofs_dev_ioctl_version() for AUTOFS_DEV_IOCTL_VERSION_CMD
      autofs4: move linux/auto_dev-ioctl.h to uapi/linux

James Morse (3):
      mm: pagewalk: fix the comment for test_walk
      fs/proc/task_mmu.c: make the task_mmu walk_page_range() limit in clear_refs_write() obvious
      mm/memcontrol.c: make the walk_page_range() limit obvious

Jason Cooper (7):
      random: simplify API for random address requests
      x86: use simpler API for random address requests
      ARM: use simpler API for random address requests
      arm64: use simpler API for random address requests
      tile: use simpler API for random address requests
      unicore32: use simpler API for random address requests
      random: remove unused randomize_range()

Joe Perches (15):
      seq/proc: modify seq_put_decimal_[u]ll to take a const char *, not char
      meminfo: break apart a very long seq_printf with #ifdefs
      checkpatch: see if modified files are marked obsolete in MAINTAINERS
      checkpatch: look for symbolic permissions and suggest octal instead
      checkpatch: test multiple line block comment alignment
      checkpatch: don't test for prefer ether_addr_<foo>
      checkpatch: externalize the structs that should be const
      const_structs.checkpatch: add frequently used from Julia Lawall's list
      checkpatch: speed up checking for filenames in sections marked obsolete
      checkpatch: improve the block comment * alignment test
      checkpatch: add --strict test for macro argument reuse
      checkpatch: add --strict test for precedence challenged macro arguments
      checkpatch: improve MACRO_ARG_PRECEDENCE test
      checkpatch: add warning for unnamed function definition arguments
      checkpatch: improve the octal permissions tests

Johannes Weiner (3):
      mm: filemap: don't plant shadow entries without radix tree node
      mm: filemap: fix mapping->nrpages double accounting in fuse
      mm: memcontrol: consolidate cgroup socket tracking

John Stultz (3):
      proc: relax /proc/<tid>/timerslack_ns capability requirements
      proc: add LSM hook checks to /proc/<tid>/timerslack_ns
      proc: fix timerslack_ns CAP_SYS_NICE check when adjusting self

Joonsoo Kim (7):
      mm/debug_pagealloc.c: clean-up guard page handling code
      mm/debug_pagealloc.c: don't allocate page_ext if we don't use guard page
      mm/page_owner: move page_owner specific function to page_owner.c
      mm/page_ext: rename offset to index
      mm/page_ext: support extra space allocation by page_ext user
      mm/page_owner: don't define fields on struct page_ext by hard-coding
      mm/slab: fix kmemcg cache creation delayed issue

Kirill A. Shutemov (1):
      mm: clarify why we avoid page_mapcount() for slab pages in dump_page()

Maciej S. Szmigiero (1):
      pps: kc: fix non-tickless system config dependency

Manfred Spraul (1):
      ipc/sem.c: fix complex_count vs. simple op race

Mark Rutland (2):
      arm64: arch_timer: simplify accessors
      lib: harden strncpy_from_user

Masahiro Yamada (1):
      treewide: remove redundant #include <linux/kconfig.h>

Mathieu Maret (1):
      scripts/tags.sh: enable code completion in VIM

Mauricio Faria de Oliveira (3):
      dma-mapping: introduce the DMA_ATTR_NO_WARN attribute
      powerpc: implement the DMA_ATTR_NO_WARN attribute
      nvme: use the DMA_ATTR_NO_WARN attribute

Michael Kerrisk (man-pages) (8):
      pipe: relocate round_pipe_size() above pipe_set_size()
      pipe: move limit checking logic into pipe_set_size()
      pipe: refactor argument for account_pipe_buffers()
      pipe: fix limit checking in pipe_set_size()
      pipe: simplify logic in alloc_pipe_info()
      pipe: fix limit checking in alloc_pipe_info()
      pipe: make account_pipe_buffers() return a value, and use it
      pipe: cap initial pipe capacity according to pipe-max-size limit

Michal Hocko (14):
      mm/oom_kill.c: fix task_will_free_mem() comment
      mm, vmscan: get rid of throttle_vm_writeout
      oom: keep mm of the killed task available
      kernel, oom: fix potential pgd_lock deadlock from __mmdrop
      mm, oom: get rid of signal_struct::oom_victims
      oom, suspend: fix oom_killer_disable vs. pm suspend properly
      mm: make sure that kthreads will not refault oom reaped memory
      oom, oom_reaper: allow to reap mm shared by the kthreads
      oom: warn if we go OOM for higher order and compaction is disabled
      oom: print nodemask in the oom report
      mm: consolidate warn_alloc_failed users
      mm: warn about allocations which stall for too long
      fs: use mapping_set_error instead of opencoded set_bit
      mm: split gfp_mask and mapping flags into separate fields

Nikolay Borisov (1):
      ipc/sem.c: add cond_resched in exit_sme

Noam Camus (1):
      lib/bitmap.c: enhance bitmap syntax

Peter Zijlstra (1):
      relay: Use irq_work instead of plain timer for deferred wakeup

Rasmus Villemoes (1):
      mm/shmem.c: constify anon_ops

Reza Arbab (1):
      memory-hotplug: fix store_mem_state() return value

Rob Herring (3):
      config: android: move device mapper options to recommended
      config: android: set SELinux as default security mode
      config: android: enable CONFIG_SECCOMP

Robert Ho (2):
      mm, proc: fix region lost in /proc/self/smaps
      Documentation/filesystems/proc.txt: add more description for maps/smaps

Ross Zwisler (3):
      radix-tree: 'slot' can be NULL in radix_tree_next_slot()
      radix-tree tests: add iteration test
      radix-tree tests: properly initialize mutex

Scott Wood (2):
      arm64: arch_timer: Work around QorIQ Erratum A-008585
      arm/arm64: arch_timer: Use archdata to indicate vdso suitability

Sebastian Andrzej Siewior (1):
      ipc/msg: implement lockless pipelined wakeups

Simon Guo (6):
      mm: mlock: check against vma for actual mlock() size
      mm: mlock: avoid increase mm->locked_vm on mlock() when already mlock2(,MLOCK_ONFAULT)
      selftest: split mlock2_ funcs into separate mlock2.h
      selftests/vm: add test for mlock() when areas are intersected
      selftest: move seek_to_smaps_entry() out of mlock2-tests.c
      selftests: expanding more mlock selftest

Srikar Dronamraju (3):
      mm: introduce arch_reserved_kernel_pages()
      mm/memblock.c: expose total reserved memory
      powerpc: implement arch_reserved_kernel_pages

Tetsuo Handa (4):
      mm,oom_reaper: reduce find_lock_task_mm() usage
      mm,oom_reaper: do not attempt to reap a task twice
      mm, oom: enforce exit_oom_victim on current task
      mm: don't emit warning from pagefault_out_of_memory()

Thomas Garnier (1):
      kdump, vmcoreinfo: report memory sections virtual addresses

Tim Chen (1):
      cpu: fix node state for whether it contains CPU

Tomohiro Kusumi (15):
      autofs: fix typos in Documentation/filesystems/autofs4.txt
      autofs: drop unnecessary extern in autofs_i.h
      autofs: test autofs versions first on sb initialization
      autofs: add WARN_ON(1) for non dir/link inode case
      autofs: use autofs4_free_ino() to kfree dentry data
      autofs: remove obsolete sb fields
      autofs: don't fail to free_dev_ioctl(param)
      autofs: remove AUTOFS_DEVID_LEN
      autofs: fix Documentation regarding devid on ioctl
      autofs: update struct autofs_dev_ioctl in Documentation
      autofs: fix pr_debug() message
      autofs: fix print format for ioctl warning message
      autofs: move inclusion of linux/limits.h to uapi
      autofs: remove possibly misleading /* #define DEBUG */
      autofs: refactor ioctl fn vector in iookup_dev_ioctl()

Toshi Kani (2):
      thp, dax: add thp_get_unmapped_area for pmd mappings
      ext2/4, xfs: call thp_get_unmapped_area() for pmd mappings

Vineet Gupta (2):
      ia64: implement atomic64_dec_if_positive
      atomic64: no need for CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE

Vladimir Davydov (2):
      mm: oom: deduplicate victim selection code for memcg and global oom
      mm: memcontrol: add sanity checks for memcg->id.ref on get/put

Vlastimil Babka (18):
      mm, compaction: make whole_zone flag ignore cached scanner positions
      mm, compaction: cleanup unused functions
      mm, compaction: rename COMPACT_PARTIAL to COMPACT_SUCCESS
      mm, compaction: don't recheck watermarks after COMPACT_SUCCESS
      mm, compaction: add the ultimate direct compaction priority
      mm, compaction: use correct watermark when checking compaction success
      mm, compaction: create compact_gap wrapper
      mm, compaction: use proper alloc_flags in __compaction_suitable()
      mm, compaction: require only min watermarks for non-costly orders
      mm, vmscan: make compaction_ready() more accurate and readable
      Revert "mm, oom: prevent premature OOM killer invocation for high order request"
      mm, compaction: more reliably increase direct compaction priority
      mm, compaction: restrict full priority to non-costly orders
      mm, compaction: make full priority ignore pageblock suitability
      mm, page_alloc: pull no_progress_loops update to should_reclaim_retry()
      mm, compaction: ignore fragindex from compaction_zonelist_suitable()
      mm, compaction: restrict fragindex to costly orders
      fs/select: add vmalloc fallback for select(2)

Wanlong Gao (1):
      mm: nobootmem: move the comment of free_all_bootmem

Wei Fang (1):
      vfs,mm: fix a dead loop in truncate_inode_pages_range()

Xishi Qiu (2):
      mem-hotplug: fix node spanned pages when we have a movable node
      mm: fix set pageblock migratetype in deferred struct page init

Yisheng Xie (3):
      mm/page_isolation: fix typo: "paes" -> "pages"
      mm/hugetlb: introduce ARCH_HAS_GIGANTIC_PAGE
      arm64 Kconfig: select gigantic page

zhong jiang (4):
      mm,ksm: add __GFP_HIGH to the allocation in alloc_stable_node()
      mm: remove unnecessary condition in remove_inode_hugepages
      mm/page_owner: align with pageblock_nr pages
      mm/vmstat.c: walk the zone in pageblock_nr_pages steps

zijun_hu (4):
      mm/vmalloc.c: fix align value calculation error
      mm/nobootmem.c: remove duplicate macro ARCH_LOW_ADDRESS_LIMIT statements
      mm/bootmem.c: replace kzalloc() by kzalloc_node()
      linux/mm.h: canonicalize macro PAGE_ALIGNED() definition


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
