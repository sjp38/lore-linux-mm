Date: Wed, 2 May 2007 15:02:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: incoming
Message-Id: <20070502150252.7ddf67ac.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@engr.sgi.com>, "David S. Miller" <davem@davemloft.net>, Andi Kleen <ak@suse.de>, "Luck, Tony" <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

So this is what I have lined up for the first mm->2.6.22 batch.  I won't be
sending it off for another 12-24 hours yet.  To give people time for final
comment and to give me time to see if it actually works.



- A few serial bits.

- A few pcmcia bits.

- Some of the MM queue.  Includes:

  - An enhancement to /proc/pid/smaps to permit monitoring of a running
    program's working set.

    There's another patchset which builds on this quite a lot from Matt
    Mackall, but it's not quite ready yet.

  - The SLUB allocator.  It's pretty green but I do want to push ahead
    with this pretty aggressively with a view to replacing slab altogether.

    If it ends up not working out then we should remove slub altogether
    again, but I doubt if that will occur.

    If SLUB isn't in good shape by 2.6.22 we should hide it in Kconfig
    to prevent people from hitting known problems.  It'll remain
    EXPERIMENTAL.

  - generic pagetable quicklist management.  We have x86_64 and ia64
    and sparc64 implementations, but I'll only include David's sparc64
    implementation here.  I'll send the x86_64 and ia64 implementations
    through maintainers.

  - Various random MM bits

  - Benh's teach-get_unmapped_area-about-MAP_FIXED changes

  - madvise(MADV_FREE)



  This means I'm holding back Mel's page allocator work, and Andy's
  lumpy-reclaim.

  A shame in a way - I have high hopes for lumpy reclaim against the
  moveable zone, but these things are not to be done lightly.

  A few MM things have been held back awaiting subsystem tree merges
  (probably x86 - I didn't check).


- One little security patch

- the blackfin architecture

- small h8300 update

- small alpha update

- swsusp updates

- m68k bits

- cris udpates

- Lots of UML updates

- v850, xtensa



slab-introduce-krealloc.patch
at91_cf-minor-fix.patch
add-new_id-to-pcmcia-drivers.patch
ide-cs-recognize-2gb-compactflash-from-transcend.patch
serial-driver-pmc-msp71xx.patch
rm9000-serial-driver.patch
serial-define-fixed_port-flag-for-serial_core.patch
serial-use-resource_size_t-for-serial-port-io-addresses.patch
mpsc-serial-driver-tx-locking.patch
8250_pci-fix-pci-must_checks.patch
serial-serial_core-use-pr_debug.patch
add-apply_to_page_range-which-applies-a-function-to-a-pte-range.patch
safer-nr_node_ids-and-nr_node_ids-determination-and-initial.patch
use-zvc-counters-to-establish-exact-size-of-dirtyable-pages.patch
proper-prototype-for-hugetlb_get_unmapped_area.patch
mm-remove-gcc-workaround.patch
slab-ensure-cache_alloc_refill-terminates.patch
mm-make-read_cache_page-synchronous.patch
fs-buffer-dont-pageuptodate-without-page-locked.patch
allow-oom_adj-of-saintly-processes.patch
introduce-config_has_dma.patch
mm-slabc-proper-prototypes.patch
add-pfn_valid_within-helper-for-sub-max_order-hole-detection.patch
mm-simplify-filemap_nopage.patch
add-unitialized_var-macro-for-suppressing-gcc-warnings.patch
i386-add-ptep_test_and_clear_dirtyyoung.patch
i386-use-pte_update_defer-in-ptep_test_and_clear_dirtyyoung.patch
smaps-extract-pmd-walker-from-smaps-code.patch
smaps-add-pages-referenced-count-to-smaps.patch
smaps-add-clear_refs-file-to-clear-reference.patch
readahead-improve-heuristic-detecting-sequential-reads.patch
readahead-code-cleanup.patch
slab-use-num_possible_cpus-in-enable_cpucache.patch
slab-dont-allocate-empty-shared-caches.patch
slab-numa-kmem_cache-diet.patch
do-not-disable-interrupts-when-reading-min_free_kbytes.patch
slab-mark-set_up_list3s-__init.patch
cpusets-allow-tif_memdie-threads-to-allocate-anywhere.patch
i386-use-page-allocator-to-allocate-thread_info-structure.patch
slub-core.patch
make-page-private-usable-in-compound-pages-v1.patch
optimize-compound_head-by-avoiding-a-shared-page.patch
add-virt_to_head_page-and-consolidate-code-in-slab-and-slub.patch
slub-fix-object-tracking.patch
slub-enable-tracking-of-full-slabs.patch
slub-validation-of-slabs-metadata-and-guard-zones.patch
slub-add-min_partial.patch
slub-add-ability-to-list-alloc--free-callers-per-slab.patch
slub-free-slabs-and-sort-partial-slab-lists-in-kmem_cache_shrink.patch
slub-remove-object-activities-out-of-checking-functions.patch
slub-user-documentation.patch
slub-add-slabinfo-tool.patch
quicklists-for-page-table-pages.patch
quicklist-support-for-sparc64.patch
slob-handle-slab_panic-flag.patch
include-kern_-constant-in-printk-calls-in-mm-slabc.patch
mm-madvise-avoid-exclusive-mmap_sem.patch
mm-remove-destroy_dirty_buffers-from-invalidate_bdev.patch
mm-optimize-kill_bdev.patch
mm-optimize-acorn-partition-truncate.patch
slab-allocators-remove-obsolete-slab_must_hwcache_align.patch
kmem_cache-simplify-slab-cache-creation.patch
slab-allocators-remove-multiple-alignment-specifications.patch
fault-injection-fix-failslab-with-config_numa.patch
mm-fix-handling-of-panic_on_oom-when-cpusets-are-in-use.patch
oom-fix-constraint-deadlock.patch
get_unmapped_area-handles-map_fixed-on-powerpc.patch
get_unmapped_area-handles-map_fixed-on-alpha.patch
get_unmapped_area-handles-map_fixed-on-arm.patch
get_unmapped_area-handles-map_fixed-on-frv.patch
get_unmapped_area-handles-map_fixed-on-i386.patch
get_unmapped_area-handles-map_fixed-on-ia64.patch
get_unmapped_area-handles-map_fixed-on-parisc.patch
get_unmapped_area-handles-map_fixed-on-sparc64.patch
get_unmapped_area-handles-map_fixed-on-x86_64.patch
get_unmapped_area-handles-map_fixed-in-hugetlbfs.patch
get_unmapped_area-handles-map_fixed-in-generic-code.patch
get_unmapped_area-doesnt-need-hugetlbfs-hacks-anymore.patch
slab-allocators-remove-slab_debug_initial-flag.patch
slab-allocators-remove-slab_ctor_atomic.patch
slab-allocators-remove-useless-__gfp_no_grow-flag.patch
lazy-freeing-of-memory-through-madv_free.patch
restore-madv_dontneed-to-its-original-linux-behaviour.patch
hugetlbfs-add-null-check-in-hugetlb_zero_setup.patch
slob-fix-page-order-calculation-on-not-4kb-page.patch
page-migration-only-migrate-pages-if-allocation-in-the-highest-zone-is-possible.patch
return-eperm-not-echild-on-security_task_wait-failure.patch
blackfin-arch.patch
driver_bfin_serial_core.patch
blackfin-on-chip-ethernet-mac-controller-driver.patch
blackfin-patch-add-blackfin-support-in-smc91x.patch
blackfin-on-chip-rtc-controller-driver.patch
blackfin-blackfin-on-chip-spi-controller-driver.patch
convert-h8-300-to-generic-timekeeping.patch
h8300-generic-irq.patch
h8300-add-zimage-support.patch
round_up-macro-cleanup-in-arch-alpha-kernel-osf_sysc.patch
alpha-fix-bootp-image-creation.patch
alpha-prctl-macros.patch
srmcons-fix-kmallocgfp_kernel-inside-spinlock.patch
arm26-remove-useless-config-option-generic_bust_spinlock.patch
fix-refrigerator-vs-thaw_process-race.patch
swsusp-use-inline-functions-for-changing-page-flags.patch
swsusp-do-not-use-page-flags.patch
mm-remove-unused-page-flags.patch
swsusp-fix-error-paths-in-snapshot_open.patch
swsusp-use-gfp_kernel-for-creating-basic-data-structures.patch
freezer-remove-pf_nofreeze-from-handle_initrd.patch
swsusp-use-rbtree-for-tracking-allocated-swap.patch
freezer-fix-racy-usage-of-try_to_freeze-in-kswapd.patch
remove-software_suspend.patch
power-management-change-sys-power-disk-display.patch
kconfig-mentioneds-hibernation-not-just-swsusp.patch
swsusp-fix-snapshot_release.patch
swsusp-free-more-memory.patch
remove-unused-header-file-arch-m68k-atari-atasoundh.patch
spin_lock_unlocked-cleanup-in-arch-m68k.patch
remove-unused-header-file-drivers-serial-crisv10h.patch
cris-check-for-memory-allocation.patch
cris-remove-code-related-to-pre-22-kernel.patch
uml-delete-unused-code.patch
uml-formatting-fixes.patch
uml-host_info-tidying.patch
uml-mark-tt-mode-code-for-future-removal.patch
uml-print-coredump-limits.patch
uml-handle-block-device-hotplug-errors.patch
uml-driver-formatting-fixes.patch
uml-driver-formatting-fixes-fix.patch
uml-network-interface-hotplug-error-handling.patch
array_size-check-for-type.patch
uml-move-sigio-testing-to-sigioc.patch
uml-create-archh.patch
uml-create-as-layouth.patch
uml-move-remaining-useful-contents-of-user_utilh.patch
uml-remove-user_utilh.patch
uml-add-missing-__init-declarations.patch
remove-unused-header-file-arch-um-kernel-tt-include-mode_kern-tth.patch
uml-improve-checking-and-diagnostics-of-ethernet-macs.patch
uml-eliminate-temporary-buffer-in-eth_configure.patch
uml-replace-one-element-array-with-zero-element-array.patch
uml-fix-umid-in-xterm-titles.patch
uml-speed-up-exec.patch
uml-no-locking-needed-in-tlsc.patch
uml-tidy-processc.patch
uml-remove-page_size.patch
uml-kernel_thread-shouldnt-panic.patch
uml-tidy-fault-code.patch
uml-kernel-segfaults-should-dump-proper-registers.patch
uml-comment-early-boot-locking.patch
uml-irq-locking-commentary.patch
uml-delete-host_frame_size.patch
uml-drivers-get-release-methods.patch
uml-dump-registers-on-ptrace-or-wait-failure.patch
uml-speed-up-page-table-walking.patch
uml-remove-unused-x86_64-code.patch
uml-start-fixing-os_read_file-and-os_write_file.patch
uml-tidy-libc-code.patch
uml-convert-libc-layer-to-call-read-and-write.patch
uml-batch-i-o-requests.patch
uml-send-pointers-instead-of-structures-to-i-o-thread.patch
uml-send-pointers-instead-of-structures-to-i-o-thread-fix.patch
uml-dump-core-on-panic.patch
uml-dont-try-to-handle-signals-on-initial-process-stack.patch
uml-change-remaining-callers-of-os_read_write_file.patch
uml-formatting-fixes-around-os_read_write_file-callers.patch
uml-remove-debugging-remnants.patch
uml-rename-os_read_write_file_k-back-to-os_read_write_file.patch
uml-aio-deadlock-avoidance.patch
uml-speed-page-fault-path.patch
uml-eliminate-a-piece-of-debugging-code.patch
uml-more-page-fault-path-trimming.patch
uml-only-flush-areas-covered-by-vma.patch
uml-out-of-tmpfs-space-error-clarification.patch
uml-virtualized-time-fix.patch
uml-fix-prototypes.patch
v850-generic-timekeeping-conversion.patch
xtensa-strlcpy-is-smart-enough.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
