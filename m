Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 32C1C6B0279
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 08:36:27 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r103so7664490wrb.0
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 05:36:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 196si2943879wmm.55.2017.07.07.05.36.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Jul 2017 05:36:25 -0700 (PDT)
Date: Fri, 7 Jul 2017 14:36:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: mmotm git tree since-4.12 branch created (was: mmotm
 2017-07-06-16-18 uploaded)
Message-ID: <20170707123620.GA16187@dhcp22.suse.cz>
References: <595ec598.V53/yhRxyLwVdGL8%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <595ec598.V53/yhRxyLwVdGL8%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

I have just created since-4.12 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v4.12 tag in Linus tree and mmotm-2017-07-06-16-18.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1 D22D 48E2 09A2 B310 E347)

I have pulled tip/smp/hotplug and tip/x86-mm-for-linus for dependencies.
I had to revert "x86: fix fortified memcpy" because it fails to compile
on x86 32b.

The shortlog says:
Alexander Levin (1):
      perf/core: Don't release cred_guard_mutex if not taken

Andrea Arcangeli (5):
      ksm: introduce ksm_max_page_sharing per page deduplication limit
      ksm: fix use after free with merge_across_nodes = 0
      ksm: cleanup stable_node chain collapse case
      ksm: swap the two output parameters of chain/chain_prune
      ksm: optimize refile of stable_node_dup at the head of the chain

Andrew Morton (12):
      swap-add-block-io-poll-in-swapin-path-checkpatch-fixes
      mm-vmscan-avoid-thrashing-anon-lru-when-free-file-is-low-fix
      mm-hwpoison-dissolve-in-use-hugepage-in-unrecoverable-memory-error-fix
      mm-hugetlb-warn-the-user-when-issues-arise-on-boot-due-to-hugepages-fix
      mm-improve-readability-of-transparent_hugepage_enabled-fix
      mm-improve-readability-of-transparent_hugepage_enabled-fix-fix
      hugetlb-memory_hotplug-prefer-to-use-reserved-pages-for-migration-fix
      mm-page_allocc-eliminate-unsigned-confusion-in-__rmqueue_fallback-fix
      mm-memory_hotplug-just-build-zonelist-for-new-added-node-fix
      mm-memory_hotplug-just-build-zonelist-for-new-added-node-fix-fix
      mm-zsmalloc-simplify-zs_max_alloc_size-handling-fix
      powerpc-64s-implement-arch-specific-hardlockup-watchdog-checkpatch-fixes

Andrey Ryabinin (4):
      mm/kasan: get rid of speculative shadow checks
      x86/kasan: don't allocate extra shadow memory
      arm64/kasan: don't allocate extra shadow memory
      mm/kasan: add support for memory hotplug

Andrey Vostrikov (1):
      lib/crc-ccitt: add CCITT-FALSE CRC16 variant

Andy Lutomirski (17):
      x86/mm: Reimplement flush_tlb_page() using flush_tlb_mm_range()
      x86/mm: Reduce indentation in flush_tlb_func()
      mm, x86/mm: Make the batched unmap TLB flush API more generic
      x86/mm: Pass flush_tlb_info to flush_tlb_others() etc
      x86/mm: Change the leave_mm() condition for local TLB flushes
      x86/mm: Refactor flush_tlb_mm_range() to merge local and remote cases
      x86/mm: Use new merged flush logic in arch_tlbbatch_flush()
      x86/mm: Remove the UP asm/tlbflush.h code, always use the (formerly) SMP code
      x86/mm: Rework lazy TLB to track the actual loaded mm
      x86/mm: Be more consistent wrt PAGE_SHIFT vs PAGE_SIZE in tlb flush code
      x86/mm, KVM: Teach KVM's VMX code that CR3 isn't a constant
      mm/vmstat: Make NR_TLB_REMOTE_FLUSH_RECEIVED available even on UP
      x86/mm: Split read_cr3() into read_cr3_pa() and __read_cr3()
      x86/ldt: Simplify the LDT switching logic
      x86/mm: Remove reset_lazy_tlbstate()
      x86/mm: Don't reenter flush_tlb_func_common()
      x86/mm: Delete a big outdated comment about TLB flushing

Andy Shevchenko (1):
      zram: use __sysfs_match_string() helper

Aneesh Kumar K.V (10):
      mm/hugetlb/migration: use set_huge_pte_at instead of set_pte_at
      mm/follow_page_mask: split follow_page_mask to smaller functions.
      mm/hugetlb: export hugetlb_entry_migration helper
      mm/hugetlb: move default definition of hugepd_t earlier in the header
      mm/follow_page_mask: add support for hugepage directory entry
      powerpc/hugetlb: add follow_huge_pd implementation for ppc64
      powerpc/mm/hugetlb: remove follow_huge_addr for powerpc
      powerpc/hugetlb: enable hugetlb migration for ppc64
      mm/hugetlb: clean up ARCH_HAS_GIGANTIC_PAGE
      powerpc/mm/hugetlb: add support for 1G huge pages

Anshuman Khandual (5):
      mm/vmstat.c: standardize file operations variable names
      mm/madvise: enable (soft|hard) offline of HugeTLB pages at PGD level
      mm/follow_page_mask: add support for hugetlb pgd entries
      mm: hugetlb: soft-offline: dissolve source hugepage after successful migration
      mm/cma.c: warn if the CMA area could not be activated

Arnd Bergmann (4):
      cpu/hotplug: Remove unused check_for_tasks() function
      mm: hugetlb: replace some macros with inline functions
      kernel/watchdog: hide unused function
      x86: fix fortified memcpy

Arvind Yadav (3):
      cpu/hotplug: Constify attribute_group structures
      ocfs2: constify attribute_group structures
      zram: constify attribute_group structures.

Borislav Petkov (1):
      x86/ldt: Rename ldt_struct::size to ::nr_entries

Canjiang Lu (1):
      mm/slab.c: replace open-coded round-up code with ALIGN

Catalin Marinas (3):
      mm: kmemleak: slightly reduce the size of some structures on 64-bit architectures
      mm: kmemleak: factor object reference updating out of scan_block()
      mm: kmemleak: treat vm_struct as alternative reference to vmalloc'ed objects

Colin Ian King (2):
      scripts/spelling.txt: add a bunch more spelling mistakes
      kasan: make get_wild_bug_type() static

Dan Carpenter (1):
      mm/vmpressure.c: free the same pointer we allocated

Dan Williams (2):
      mm: improve readability of transparent_hugepage_enabled()
      mm: always enable thp for dax mappings

Daniel Axtens (2):
      powerpc: don't fortify prom_init
      powerpc: make feature-fixup tests fortify-safe

Daniel Micay (2):
      mm/mmap.c: mark protection_map as __ro_after_init
      include/linux/string.h: add the option of fortified string.h functions

Dave Hansen (1):
      mm, sparsemem: break out of loops early

David Rientjes (3):
      mm, vmscan: avoid thrashing anon lru when free + file is low
      mm, vmpressure: pass-through notification support
      mm, hugetlb: schedule when potentially allocating many hugepages

Dou Liyang (1):
      mm: drop useless local parameters of __register_one_node()

Doug Berger (1):
      cma: fix calculation of aligned offset

Eric Biggers (1):
      fs/buffer.c: make bh_lru_install() more efficient

Fabian Frederick (1):
      ocfs2: use magic.h

Gang He (1):
      ocfs2: fix a static checker warning

Gustavo A. R. Silva (1):
      mm/memory_hotplug.c: add NULL check to avoid potential NULL pointer dereference

Huang Ying (4):
      mm, THP, swap: delay splitting THP during swap out
      mm, THP, swap: check whether THP can be split firstly
      mm, THP, swap: enable THP swap optimization only if has compound map
      mm/swapfile.c: sort swap entries before free

Ingo Molnar (3):
      Merge tag 'v4.12-rc4' into x86/mm, to pick up fixes
      Merge branch 'sched/urgent' into x86/mm, to pick up dependent fix
      Merge branch 'linus' into x86/mm, to pick up fixes

Jan Kara (1):
      mm/truncate.c: fix THP handling in invalidate_mapping_pages()

Jerome Marchand (1):
      mm/zsmalloc: simplify zs_max_alloc_size handling

Joe Perches (18):
      checkpatch: improve the STORAGE_CLASS test
      ARM: KVM: move asmlinkage before type
      ARM: HP Jornada 7XX: move inline before return type
      CRIS: gpio: move inline before return type
      FRV: tlbflush: move asmlinkage before return type
      ia64: move inline before return type
      ia64: sn: pci: move inline before type
      m68k: coldfire: move inline before return type
      MIPS: SMP: move asmlinkage before return type
      sh: move inline before return type
      x86/efi: move asmlinkage before return type
      drivers: s390: move static and inline before return type
      drivers: tty: serial: move inline before return type
      USB: serial: safe_serial: move __inline__ before return type
      video: fbdev: intelfb: move inline before return type
      video: fbdev: omap: move inline before return type
      ARM: samsung: usb-ohci: move inline before return type
      ALSA: opl4: move inline before return type

Johannes Weiner (5):
      mm: vmstat: move slab statistics from zone to node counters
      mm: memcontrol: use the node-native slab memory counters
      mm: memcontrol: use generic mod_memcg_page_state for kmem pages
      mm: memcontrol: per-lruvec stats infrastructure
      mm: memcontrol: account slab stats per lruvec

John Hubbard (1):
      mm/memory_hotplug.c: remove unused local zone_type from __remove_zone()

Joonsoo Kim (2):
      mm/kasan/kasan_init.c: use kasan_zero_pud for p4d table
      mm/kasan/kasan.c: rename XXX_is_zero to XXX_is_nonzero

Kees Cook (6):
      mm: allow slab_nomerge to be set at build time
      efi: avoid fortify checks in EFI stub
      kexec_file: adjust declaration of kexec_purgatory
      IB/rxe: do not copy extra stack memory to skb
      fortify: avoid panic() in favor of BUG()
      sh: mark end of BUG() implementation as unreachable

Kirill A. Shutemov (16):
      x86/mm/gup: Switch GUP to the generic get_user_page_fast() implementation
      x86/asm: Fix comment in return_from_SYSCALL_64()
      x86/boot/efi: Cleanup initialization of GDT entries
      x86/boot/efi: Fix __KERNEL_CS definition of GDT entry on 64-bit configurations
      x86/boot/efi: Define __KERNEL32_CS GDT on 64-bit configurations
      x86/boot/compressed: Enable 5-level paging during decompression stage
      x86/boot/64: Rewrite startup_64() in C
      x86/boot/64: Rename init_level4_pgt and early_level4_pgt
      x86/boot/64: Add support of additional page table level during early boot
      x86/mm: Add sync_global_pgds() for configuration with 5-level paging
      x86/mm: Make kernel_physical_mapping_init() support 5-level paging
      x86/mm: Add support for 5-level paging for KASLR
      x86/boot/64: Put __startup_64() into .head.text
      x86/ftrace: Exclude functions in head64.c from function-tracing
      x86/KASLR: Fix detection 32/64 bit bootloaders for 5-level paging
      thp, mm: fix crash due race in MADV_FREE handling

Konstantin Khlebnikov (1):
      mm/oom_kill: count global and memory cgroup oom kills

Krzysztof Opasiak (1):
      mm: use dedicated helper to access rlimit value

Laurent Dufour (1):
      mm: skip HWPoisoned pages when onlining pages

Liam R. Howlett (1):
      mm/hugetlb.c: warn the user when issues arise on boot due to hugepages

Logan Gunthorpe (1):
      tile: provide default ioremap declaration

Marcin Nowakowski (1):
      kernel/extable.c: mark core_kernel_text notrace

Markus Elfring (3):
      mm/zswap.c: delete an error message for a failed memory allocation in zswap_pool_create()
      mm/zswap.c: improve a size determination in zswap_frontswap_init()
      mm/zswap.c: delete an error message for a failed memory allocation in zswap_dstmem_prepare()

Matthew Wilcox (1):
      mm/hugetlb.c: replace memfmt with string_get_size

Matthias Kaehlcke (1):
      mm/page_alloc.c: mark bad_range() and meminit_pfn_in_nid() as __maybe_unused

Michael Ellerman (4):
      provide linux/set_memory.h
      kernel/power/snapshot.c: use linux/set_memory.h
      kernel/module.c: use linux/set_memory.h
      include/linux/filter.h: use linux/set_memory.h

Michal Hocko (47):
      x86/mmap, ASLR: Do not treat unlimited-stack tasks as legacy mmap
      fs/file.c: replace alloc_fdmem() with kvmalloc() alternative
      mm: remove return value from init_currently_empty_zone
      mm, memory_hotplug: use node instead of zone in can_online_high_movable
      mm: drop page_initialized check from get_nid_for_pfn
      mm, memory_hotplug: get rid of is_zone_device_section
      mm, memory_hotplug: split up register_one_node()
      mm, memory_hotplug: consider offline memblocks removable
      mm: consider zone which is not fully populated to have holes
      mm, compaction: skip over holes in __reset_isolation_suitable
      mm: __first_valid_page skip over offline pages
      mm, vmstat: skip reporting offline pages in pagetypeinfo
      mm, memory_hotplug: do not associate hotadded memory to zones until online
      mm, memory_hotplug: fix MMOP_ONLINE_KEEP behavior
      mm, memory_hotplug: do not assume ZONE_NORMAL is default kernel zone
      mm, memory_hotplug: replace for_device by want_memblock in arch_add_memory
      mm, memory_hotplug: fix the section mismatch warning
      mm, memory_hotplug: remove unused cruft after memory hotplug rework
      mm, memory_hotplug: drop artificial restriction on online/offline
      mm, memory_hotplug: drop CONFIG_MOVABLE_NODE
      mm, memory_hotplug: move movable_node to the hotplug proper
      mm: make PR_SET_THP_DISABLE immediately active
      mm, memory_hotplug: support movable_node for hotpluggable nodes
      mm, memory_hotplug: simplify empty node mask handling in new_node_page
      hugetlb, memory_hotplug: prefer to use reserved pages for migration
      mm: unify new_node_page and alloc_migrate_target
      mm, memcg: fix potential undefined behavior in mem_cgroup_event_ratelimit()
      mm, hugetlb: unclutter hugetlb allocation layers
      hugetlb: add support for preferred node to alloc_huge_page_nodemask
      mm, hugetlb, soft_offline: use new_page_nodemask for soft offline migration
      mm: document highmem_is_dirtyable sysctl
      mm/mmap.c: do not blow on PROT_NONE MAP_FIXED holes in the stack
      mm: disallow early_pfn_to_nid on configurations which do not implement it
      net/netfilter/x_tables.c: use kvmalloc() in xt_alloc_table_info()
      MIPS: do not use __GFP_REPEAT for order-0 request
      mm, tree wide: replace __GFP_REPEAT by __GFP_RETRY_MAYFAIL with more useful semantic
      mm-tree-wide-replace-__gfp_repeat-by-__gfp_retry_mayfail-with-more-useful-semantic-fix
      mm-tree-wide-replace-__gfp_repeat-by-__gfp_retry_mayfail-with-more-useful-semantic-fix-3
      xfs: map KM_MAYFAIL to __GFP_RETRY_MAYFAIL
      mm: kvmalloc support __GFP_RETRY_MAYFAIL for all sizes
      drm/i915: use __GFP_RETRY_MAYFAIL
      mm, migration: do not trigger OOM killer when migrating memory
      Merge remote-tracking branch 'tip/smp/hotplug' into mmotm-4.12
      Merge remote-tracking branch 'tip/x86-mm-for-linus' into mmotm-4.12
      Revert "x86: fix fortified memcpy"
      Revert "fortify: avoid panic() in favor of BUG()"
      Revert "include/linux/string.h: add the option of fortified string.h functions"

Mike Rapoport (3):
      kernel/exit.c: don't include unused userfaultfd_k.h
      fs/userfaultfd.c: drop dead code
      userfaultfd: non-cooperative: add madvise() event for MADV_FREE request

Minchan Kim (3):
      zram: count same page write as page_stored
      mm, THP, swap: unify swap slot free functions to put_swap_page
      mm, THP, swap: move anonymous THP split logic to vmscan

Naoya Horiguchi (9):
      mm: drop NULL return check of pte_offset_map_lock()
      mm: hugetlb: prevent reuse of hwpoisoned free hugepages
      mm: hugetlb: return immediately for hugetlb page in __delete_from_page_cache()
      mm: hwpoison: change PageHWPoison behavior on hugetlb pages
      mm: soft-offline: dissolve free hugepage if soft-offlined
      mm: hwpoison: introduce memory_failure_hugetlb()
      mm: hwpoison: dissolve in-use hugepage in unrecoverable memory error
      mm: hugetlb: delete dequeue_hwpoisoned_huge_page()
      mm: hwpoison: introduce idenfity_page_state

Nicholas Piggin (9):
      kernel/watchdog: remove unused declaration
      kernel/watchdog: introduce arch_touch_nmi_watchdog()
      kernel/watchdog: split up config options
      watchdog-split-up-config-options-fix
      kernel/watchdog: provide watchdog_nmi_reconfigure() for arch watchdogs
      watchdog-provide-watchdog_reconfigure-for-arch-watchdogs-fix
      powerpc/64s: implement arch-specific hardlockup watchdog
      powerpc/64s: watchdog honor watchdog disable at boot/hotplug
      powerpc/64s: watchdog false positive warning at CPU unplug

Nick Desaulniers (2):
      mm/vmscan.c: fix unsequenced modification and access warning
      mm/zsmalloc.c: fix -Wunneeded-internal-declaration warning

Nikolay Borisov (2):
      include/linux/mmzone.h: remove ancient/ambiguous comment
      include/linux/backing-dev.h: simplify wb_stat_sum

Oleg Nesterov (1):
      mm/mmap.c: expand_downwards: don't require the gap if !vm_prev

Pavel Tatashin (4):
      mm: zero hash tables in allocator
      mm: update callers to use HASH_ZERO flag
      mm: adaptive hash table scaling
      sparc64: NG4 memset 32 bits overflow

Punit Agrawal (5):
      mm, gup: ensure real head page is ref-counted when using hugepages
      mm/hugetlb: add size parameter to huge_pte_offset()
      mm/hugetlb: allow architectures to override huge_pte_clear()
      mm/hugetlb: introduce set_huge_swap_pte_at() helper
      mm: rmap: use correct helper when poisoning hugepages

Rasmus Villemoes (1):
      mm/page_alloc.c: eliminate unsigned confusion in __rmqueue_fallback

Rik van Riel (8):
      random,stackprotect: introduce get_random_canary function
      fork,random: use get_random_canary() to set tsk->stack_canary
      x86: ascii armor the x86_64 boot init stack canary
      arm64: ascii armor the arm64 boot init stack canary
      sh64: ascii armor the sh64 boot init stack canary
      x86/mmap: properly account for stack randomization in mmap_base
      arm64/mmap: properly account for stack randomization in mmap_base
      powerpc,mmap: properly account for stack randomization in mmap_base

Rob Landley (2):
      scripts/gen_initramfs_list.sh: teach INITRAMFS_ROOT_UID and INITRAMFS_ROOT_GID that -1 means "current user".
      ramfs: clarify help text that compression applies to ramfs as well as legacy ramdisk.

Roman Gushchin (2):
      mm: per-cgroup memory reclaim stats
      mm/oom_kill.c: add tracepoints for oom reaper-related events

SF Markus Elfring (1):
      drivers/sh/intc/virq.c: delete an error message for a failed memory allocation in add_virq_to_pirq()

Sahitya Tummala (2):
      mm/list_lru.c: fix list_lru_count_node() to be race free
      fs/dcache.c: fix spin lockup issue on nlru->lock

Sean Christopherson (1):
      mm/memcontrol: exclude @root from checks in mem_cgroup_low

Sebastian Andrzej Siewior (15):
      cpu/hotplug: Provide cpuhp_setup/remove_state[_nocalls]_cpuslocked()
      stop_machine: Provide stop_machine_cpuslocked()
      padata: Avoid nested calls to cpus_read_lock() in pcrypt_init_padata()
      x86/mtrr: Remove get_online_cpus() from mtrr_save_state()
      cpufreq: Use cpuhp_setup_state_nocalls_cpuslocked()
      KVM/PPC/Book3S HV: Use cpuhp_setup_state_nocalls_cpuslocked()
      hwtracing/coresight-etm3x: Use cpuhp_setup_state_nocalls_cpuslocked()
      hwtracing/coresight-etm4x: Use cpuhp_setup_state_nocalls_cpuslocked()
      perf/x86/intel/cqm: Use cpuhp_setup_state_cpuslocked()
      ARM/hw_breakpoint: Use cpuhp_setup_state_cpuslocked()
      s390/kernel: Use stop_machine_cpuslocked()
      powerpc/powernv: Use stop_machine_cpuslocked()
      cpu/hotplug: Use stop_machine_cpuslocked() in takedown_cpu()
      perf/x86/intel: Drop get_online_cpus() in intel_snb_check_microcode()
      mm/swap_slots.c: don't disable preemption while taking the per-CPU cache

Shaohua Li (1):
      swap: add block io poll in swapin path

Steve Capper (2):
      arm64: hugetlb: refactor find_num_contig()
      arm64: hugetlb: remove spurious calls to huge_ptep_offset()

Steven Rostedt (VMware) (1):
      oom, trace: remove ENUM evaluation of COMPACTION_FEEDBACK

Thiago Jung Bauermann (1):
      powerpc: Only obtain cpu_hotplug_lock if called by rtasd

Thomas Gleixner (20):
      cpu/hotplug: Provide cpus_read|write_[un]lock()
      cpu/hotplug: Provide lockdep_assert_cpus_held()
      cpu/hotplug: Add __cpuhp_state_add_instance_cpuslocked()
      padata: Make padata_alloc() static
      x86/perf: Drop EXPORT of perf_check_microcode
      PCI: Use cpu_hotplug_disable() instead of get_online_cpus()
      PCI: Replace the racy recursion prevention
      ACPI/processor: Use cpu_hotplug_disable() instead of get_online_cpus()
      perf/tracing/cpuhotplug: Fix locking order
      jump_label: Reorder hotplug lock and jump_label_lock
      kprobes: Cure hotplug lock ordering issues
      arm64: Prevent cpu hotplug rwsem recursion
      arm: Prevent hotplug rwsem recursion
      s390: Prevent hotplug rwsem recursion
      cpu/hotplug: Convert hotplug locking to percpu rwsem
      sched: Provide is_percpu_thread() helper
      acpi/processor: Prevent cpu hotplug deadlock
      cpuhotplug: Link lock stacks for hotplug callbacks
      mm: swap: provide lru_add_drain_all_cpuslocked()
      mm/memory-hotplug: switch locking to a percpu rwsem

Tobias Klauser (3):
      mn10300: remove wrapper header for asm/device.h
      mn10300: use generic fb.h
      xtensa: use generic fb.h

Tony Lindgren (1):
      ARM/hw_breakpoint: Fix possible recursive locking for arch_hw_breakpoint_init

Vasily Averin (1):
      fs/proc/task_mmu.c: remove obsolete comment in show_map_vma()

Vinayak Menon (2):
      mm: avoid taking zone lock in pagetypeinfo_showmixed()
      mm: vmscan: do not pass reclaimed slab to vmpressure

Vlastimil Babka (7):
      mm, page_alloc: fix more premature OOM due to race with cpuset update
      mm, mempolicy: stop adjusting current->il_next in mpol_rebind_nodemask()
      mm, page_alloc: pass preferred nid instead of zonelist to allocator
      mm, mempolicy: simplify rebinding mempolicies when updating cpusets
      mm, cpuset: always use seqlock when changing task's nodemask
      mm, mempolicy: don't check cpuset seqlock where it doesn't matter
      mm, page_alloc: fallback to smallest page when not stealing whole pageblock

Wei Yang (8):
      mm/slub.c: remove a redundant assignment in ___slab_alloc()
      mm/slub: reset cpu_slab's pointer in deactivate_slab()
      mm/slub.c: pack red_left_pad with another int to save a word
      mm/slub.c: wrap cpu_slab->partial in CONFIG_SLUB_CPU_PARTIAL
      mm/slub.c: wrap kmem_cache->cpu_partial in config CONFIG_SLUB_CPU_PARTIAL
      mm/nobootmem.c: return 0 when start_pfn equals end_pfn
      mm/memory_hotplug: just build zonelist for newly added node
      mm/page_alloc: return 0 in case this node has no page within the zone

Will Deacon (3):
      mm, gup: remove broken VM_BUG_ON_PAGE compound check for hugepages
      include/linux/page_ref.h: ensure page_ref_unfreeze is ordered against prior accesses
      mm/migrate.c: stabilise page count when migrating transparent hugepages

Yevgen Pronenko (1):
      mm/memory.c: convert to DEFINE_DEBUGFS_ATTRIBUTE

Yisheng Xie (1):
      vmalloc: show lazy-purged vma info in vmallocinfo

piaojun (1):
      ocfs2: free 'dummy_sc' in sc_fop_release() to prevent memory leak

zhenwei.pi (1):
      mm/balloon_compaction.c: enqueue zero page to balloon device

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
