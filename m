Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 0313E6B003D
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 19:56:22 -0400 (EDT)
Received: by mail-vb0-f73.google.com with SMTP id e12so267782vbg.4
        for <linux-mm@kvack.org>; Wed, 07 Aug 2013 16:56:21 -0700 (PDT)
Subject: mmotm 2013-08-07-16-55 uploaded
From: akpm@linux-foundation.org
Date: Wed, 07 Aug 2013 16:56:20 -0700
Message-Id: <20130807235621.10FE631C1B7@corp2gmr1-1.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2013-08-07-16-55 has been uploaded to

   http://www.ozlabs.org/~akpm/mmotm/

mmotm-readme.txt says

README for mm-of-the-moment:

http://www.ozlabs.org/~akpm/mmotm/

This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
more than once a week.

You will need quilt to apply these patches to the latest Linus release (3.x
or 3.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
http://ozlabs.org/~akpm/mmotm/series

The file broken-out.tar.gz contains two datestamp files: .DATE and
.DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
followed by the base kernel version against which this patch series is to
be applied.

This tree is partially included in linux-next.  To see which patches are
included in linux-next, consult the `series' file.  Only the patches
within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included in
linux-next.

A git tree which contains the memory management portion of this tree is
maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
by Michal Hocko.  It contains the patches which are between the
"#NEXT_PATCHES_START mm" and "#NEXT_PATCHES_END" markers, from the series
file, http://www.ozlabs.org/~akpm/mmotm/series.


A full copy of the full kernel tree with the linux-next and mmotm patches
already applied is available through git within an hour of the mmotm
release.  Individual mmotm releases are tagged.  The master branch always
points to the latest release, so it's constantly rebasing.

http://git.cmpxchg.org/?p=linux-mmotm.git;a=summary

To develop on top of mmotm git:

  $ git remote add mmotm git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
  $ git remote update mmotm
  $ git checkout -b topic mmotm/master
  <make changes, commit>
  $ git send-email mmotm/master.. [...]

To rebase a branch with older patches to a new mmotm release:

  $ git remote update mmotm
  $ git rebase --onto mmotm/master <topic base> topic




The directory http://www.ozlabs.org/~akpm/mmots/ (mm-of-the-second)
contains daily snapshots of the -mm tree.  It is updated more frequently
than mmotm, and is untested.

A git copy of this tree is available at

	http://git.cmpxchg.org/?p=linux-mmots.git;a=summary

and use of this tree is similar to
http://git.cmpxchg.org/?p=linux-mmotm.git, described above.


This mmotm tree contains the following patches against 3.11-rc4:
(patches marked "*" will be included in linux-next)

  origin.patch
* revert-include-linux-smph-on_each_cpu-switch-back-to-a-macro.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* memcg-dont-initialize-kmem-cache-destroying-work-for-root-caches.patch
* mm-save-soft-dirty-bits-on-swapped-pages.patch
* mm-save-soft-dirty-bits-on-file-pages.patch
* microblaze-fix-clone-syscall.patch
* aoe-adjust-ref-of-head-for-compound-page-tails.patch
* x86-get_unmapped_area-use-proper-mmap-base-for-bottom-up-direction.patch
* ocfs2-fix-null-pointer-dereference-in-ocfs2_dir_foreach_blk_id.patch
* arch-kconfig-add-kernel-kconfigfreezer-to-arch-kconfig.patch
* sh64-kernel-use-usp-instead-of-fn.patch
* sh64-kernel-remove-useless-variable-regs.patch
* x86-make-mem=-option-to-work-for-efi-platform.patch
* drivers-pcmcia-pd6729c-convert-to-module_pci_driver.patch
* drivers-pcmcia-yenta_socketc-convert-to-module_pci_driver.patch
* drm-fb-helper-dont-sleep-for-screen-unblank-when-an-oopps-is-in-progress.patch
* drm-cirrus-correct-register-values-for-16bpp.patch
* drm-nouveau-make-vga_switcheroo-code-depend-on-vga_switcheroo.patch
* drivers-video-acornfbc-remove-dead-code.patch
* cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* include-linux-interrupth-add-dummy-irq_set_irq_wake-for-generic_hardirqs.patch
* hrtimer-one-more-expiry-time-overflow-check-in-hrtimer_interrupt.patch
* timer_list-correct-the-iterator-for-timer_list.patch
* drivers-infiniband-core-cmc-convert-to-using-idr_alloc_cyclic.patch
* scripts-sortextable-support-objects-with-more-than-64k-sections.patch
* drivers-net-ethernet-ibm-ehea-ehea_mainc-add-alias-entry-for-portn-properties.patch
* misdn-add-support-for-group-membership-check.patch
* drivers-atm-he-convert-to-module_pci_driver.patch
* isdn-clean-up-debug-format-string-usage.patch
* ocfs2-should-call-ocfs2_journal_access_di-before-ocfs2_delete_entry-in-ocfs2_orphan_del.patch
* ocfs2-llseek-requires-ocfs2-inode-lock-for-the-file-in-seek_end.patch
* ocfs2-fix-issue-that-ocfs2_setattr-does-not-deal-with-new_i_size==i_size.patch
* ocfs2-fix-issue-that-ocfs2_setattr-does-not-deal-with-new_i_size==i_size-v2.patch
* ocfs2-update-inode-size-after-zeronig-the-hole.patch
* ocfs2-lighten-up-allocate-transaction.patch
* ocfs2-using-i_size_read-to-access-i_size.patch
* ocfs2-dlm_request_all_locks-should-deal-with-the-status-sent-from-target-node.patch
* ocfs2-ac_bits_wanted-should-be-local_alloc_bits-when-returns-enospc.patch
* fs-ocfs2-cluster-tcpc-fix-possible-null-pointer-dereferences.patch
* ocfs2-use-list_for_each_entry-instead-of-list_for_each.patch
* ocfs2-clean-up-dead-code-in-ocfs2_acl_from_xattr.patch
* ocfs2-add-missing-return-value-check-of-ocfs2_get_clusters.patch
* ocfs2-fix-a-memory-leak-in-__ocfs2_move_extents.patch
* include-linux-schedh-dont-use-task-pid-tgid-in-same_thread_group-has_group_leader_pid.patch
* drivers-scsi-a100u2w-convert-to-module_pci_driver.patch
* drivers-scsi-dc395x-convert-to-module_pci_driver.patch
* drivers-scsi-dmx3191d-convert-to-module_pci_driver.patch
* drivers-scsi-initio-convert-to-module_pci_driver.patch
* drivers-scsi-mvumi-convert-to-module_pci_driver.patch
* drivers-net-irda-donauboe-convert-to-module_pci_driver.patch
* block-replace-strict_strtoul-with-kstrtoul.patch
* block-blk-sysfs-replace-strict_strtoul-with-kstrtoul.patch
* block-support-embedded-device-command-line-partition.patch
* block-support-embedded-device-command-line-partition-fix.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* watchdog-update-watchdog-attributes-atomically.patch
* watchdog-update-watchdog_tresh-properly.patch
* watchdog-update-watchdog_tresh-properly-fix.patch
* watchdog-trigger-all-cpu-backtrace-when-locked-up-and-going-to-panic.patch
  mm.patch
* mm-mempolicy-turn-vma_set_policy-into-vma_dup_policy.patch
* mm-madvisec-fix-coding-style-errors.patch
* swap-warn-when-a-swap-area-overflows-the-maximum-size.patch
* swap-warn-when-a-swap-area-overflows-the-maximum-size-fix.patch
* mm-swapfilec-convert-to-pr_foo.patch
* mm-shift-vm_grows-check-from-mmap_region-to-do_mmap_pgoff-v2.patch
* mm-do_mmap_pgoff-cleanup-the-usage-of-file_inode.patch
* mm-mmap_region-kill-correct_wcount-inode-use-allow_write_access.patch
* mm-zswapc-get-swapper-address_space-by-using-macro.patch
* mm-drop-actor-argument-of-do_generic_file_read.patch
* mm-drop-actor-argument-of-do_shmem_file_read.patch
* thp-account-anon-transparent-huge-pages-into-nr_anon_pages.patch
* mm-cleanup-add_to_page_cache_locked.patch
* thp-move-maybe_pmd_mkwrite-out-of-mk_huge_pmd.patch
* thp-do_huge_pmd_anonymous_page-cleanup.patch
* thp-consolidate-code-between-handle_mm_fault-and-do_huge_pmd_anonymous_page.patch
* mm-vmstats-tlb-flush-counters.patch
* mm-vmstats-track-tlb-flush-stats-on-up-too.patch
* mm-vmstats-track-tlb-flush-stats-on-up-too-fix.patch
* mm-replace-strict_strtoul-with-kstrtoul.patch
* mm-fix-negative-left-shift-count-when-page_shift-20.patch
* mm-page_allocc-use-__paginginit-instead-of-__init.patch
* swap-change-block-allocation-algorithm-for-ssd.patch
* swap-make-swap-discard-async.patch
* swap-make-swap-discard-async-checkpatch-fixes.patch
* swap-fix-races-exposed-by-swap-discard.patch
* swap-make-cluster-allocation-per-cpu.patch
* swap-make-cluster-allocation-per-cpu-checkpatch-fixes.patch
* mm-page_allocc-fix-coding-style-and-spelling.patch
* mm-page_alloc-restructure-free-page-stealing-code-and-fix-a-bug.patch
* mm-page_alloc-restructure-free-page-stealing-code-and-fix-a-bug-fix.patch
* mm-fix-the-value-of-fallback_migratetype-in-alloc_extfrag-tracepoint.patch
* mm-kill-one-if-loop-in-__free_pages_bootmem.patch
* mm-fix-potential-null-pointer-dereference.patch
* mm-vmscan-fix-numa-reclaim-balance-problem-in-kswapd.patch
* mm-page_alloc-rearrange-watermark-checking-in-get_page_from_freelist.patch
* mm-page_alloc-fair-zone-allocator-policy.patch
* mm-page_alloc-fair-zone-allocator-policy-v2.patch
* mm-revert-page-writebackc-subtract-min_free_kbytes-from-dirtyable-memory.patch
* mm-hugetlb-move-up-the-code-which-check-availability-of-free-huge-page.patch
* mm-hugetlb-trivial-commenting-fix.patch
* mm-hugetlb-clean-up-alloc_huge_page.patch
* mm-hugetlb-fix-and-clean-up-node-iteration-code-to-alloc-or-free.patch
* mm-hugetlb-remove-redundant-list_empty-check-in-gather_surplus_pages.patch
* mm-hugetlb-do-not-use-a-page-in-page-cache-for-cow-optimization.patch
* mm-hugetlb-add-vm_noreserve-check-in-vma_has_reserves.patch
* mm-hugetlb-remove-decrement_hugepage_resv_vma.patch
* mm-hugetlb-decrement-reserve-count-if-vm_noreserve-alloc-page-cache.patch
* mm-hugetlb-decrement-reserve-count-if-vm_noreserve-alloc-page-cache-fix.patch
* memcg-remove-redundant-code-in-mem_cgroup_force_empty_write.patch
* memcg-vmscan-integrate-soft-reclaim-tighter-with-zone-shrinking-code.patch
* memcg-get-rid-of-soft-limit-tree-infrastructure.patch
* vmscan-memcg-do-softlimit-reclaim-also-for-targeted-reclaim.patch
* memcg-enhance-memcg-iterator-to-support-predicates.patch
* memcg-track-children-in-soft-limit-excess-to-improve-soft-limit.patch
* memcg-vmscan-do-not-attempt-soft-limit-reclaim-if-it-would-not-scan-anything.patch
* memcg-track-all-children-over-limit-in-the-root.patch
* memcg-vmscan-do-not-fall-into-reclaim-all-pass-too-quickly.patch
* memcg-trivial-cleanups.patch
* arch-mm-remove-obsolete-init-oom-protection.patch
* arch-mm-do-not-invoke-oom-killer-on-kernel-fault-oom.patch
* arch-mm-pass-userspace-fault-flag-to-generic-fault-handler.patch
* x86-finish-user-fault-error-path-with-fatal-signal.patch
* mm-memcg-enable-memcg-oom-killer-only-for-user-faults.patch
* mm-memcg-rework-and-document-oom-waiting-and-wakeup.patch
* mm-memcg-do-not-trap-chargers-with-full-callstack-on-oom.patch
* mm-mempolicy-return-null-if-node-is-numa_no_node-in-get_task_policy.patch
* mm-page_alloc-add-unlikely-macro-to-help-compiler-optimization.patch
* mm-move-pgtable-related-functions-to-right-place.patch
* swap-clean-up-ifdef-in-page_mapping.patch
* memcg-correct-resource_max-to-ullong_max.patch
* memcg-rename-resource_max-to-res_counter_max.patch
* memcg-avoid-overflow-caused-by-page_align.patch
* memcg-reduce-function-dereference.patch
* vmstat-create-separate-function-to-fold-per-cpu-diffs-into-local-counters.patch
* vmstat-create-separate-function-to-fold-per-cpu-diffs-into-local-counters-fix.patch
* vmstat-create-fold_diff.patch
* vmstat-use-this_cpu-to-avoid-irqon-off-sequence-in-refresh_cpu_vm_stats.patch
* mm-vmalloc-remove-useless-variable-in-vmap_block.patch
* mm-vmalloc-use-well-defined-find_last_bit-func.patch
* thp-mm-locking-tail-page-is-a-bug.patch
* thp-mm-locking-tail-page-is-a-bug-fix.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead-fix.patch
* drivers-firmware-google-gsmic-replace-strict_strtoul-with-kstrtoul.patch
* kernel-wide-fix-missing-validations-on-__get-__put-__copy_to-__copy_from_user.patch
* kernel-modsign_pubkeyc-fix-init-const-for-module-signing-code.patch
* lto-watchdog-hpwdtc-make-assembler-label-global.patch
* kernel-smpc-free-related-resources-when-failure-occurs-in-hotplug_cfd.patch
* kernel-replace-strict_strto-with-kstrto.patch
* kernel-spinlockc-add-default-arch__relax-definitions-for-generic_lockbreak.patch
* smp-quit-unconditionally-enabling-irq-in-on_each_cpu_mask-and-on_each_cpu_cond.patch
* upc-use-local_irq_saverestore-in-smp_call_function_single.patch
* smph-move-smp-version-of-on_each_cpu-out-of-line.patch
* generic-ipi-fix-misleading-smp_call_function_any-description.patch
* smp-give-warning-when-calling-smp_call_function_many-single-in-serving-irq.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* maintainers-exynos-remove-board-files.patch
* maintainers-arm-omap2-3-remove-unused-clockdomain-files.patch
* maintainers-omap-powerdomain-update-patterns.patch
* maintainers-arm-s3c2410-update-patterns.patch
* maintainers-arm-spear-consolidate-sections.patch
* maintainers-arm-plat-nomadik-update-patterns.patch
* maintainers-arm-s3c24xx-remove-plat-s3c24xx.patch
* maintainers-ghes_edac-update-pattern.patch
* maintainers-update-siano-drivers.patch
* maintainers-si4713-fix-file-pattern.patch
* maintainers-update-it913x-patterns.patch
* maintainers-update-sirf-patterns.patch
* maintainers-update-ssbi-patterns.patch
* maintainers-update-file-pattern-for-arc-uart.patch
* maintainers-update-usb-ehci-platform-pattern.patch
* maintainers-usb-phy-update-patterns.patch
* maintainers-update-gre-demux-patterns.patch
* maintainers-add-mach-bcm-and-drivers.patch
* maintainers-append-to-directory-patterns.patch
* lib-genallocc-correct-dev_get_gen_pool-documentation.patch
* lib-crc32-update-the-comments-of-crc32_bele_generic.patch
* lib-crc32-update-the-comments-of-crc32_bele_generic-checkpatch-fixes.patch
* decompressors-fix-no-limit-output-buffer-length.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-add-a-few-more-fix-corrections.patch
* checkpatch-check-camelcase-by-word-not-by-lval.patch
* checkpatch-enforce-sane-perl-version.patch
* checkpatch-check-for-duplicate-signatures.patch
* checkpatch-warn-when-using-extern-with-function-prototypes-in-h-files.patch
* checkpatch-fix-networking-kernel-doc-block-comment-defect.patch
* checkpatch-add-types-option-to-report-only-specific-message-types.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* firmware-dmi_scan-drop-obsolete-comment.patch
* firmware-dmi_scan-fix-most-checkpatch-errors-and-warnings.patch
* firmware-dmi_scan-constify-strings.patch
* firmware-dmi_scan-drop-oom-messages.patch
* autofs4-allow-autofs-to-work-outside-the-initial-pid-namespace.patch
* autofs4-translate-pids-to-the-right-namespace-for-the-daemon.patch
* drivers-rtc-rtc-hid-sensor-timec-add-module-alias-to-let-the-module-load-automatically.patch
* drivers-rtc-rtc-pcf2127c-remove-empty-function.patch
* rtc-add-moxa-art-rtc-driver.patch
* drivers-rtc-rtc-omapc-add-rtc-wakeup-support-to-alarm-events.patch
* hfsplus-add-necessary-declarations-for-posix-acls-support.patch
* hfsplus-implement-posix-acls-support.patch
* hfsplus-integrate-posix-acls-support-into-driver.patch
* fat-additions-to-support-fat_fallocate.patch
* fat-additions-to-support-fat_fallocate-fix.patch
* documentation-replace-strict_strtoul-with-kstrtoul.patch
* signals-eventpoll-set-saved_sigmask-at-the-start.patch
* move-exit_task_namespaces-outside-of-exit_notify-fix.patch
* procfs-remove-extra-call-of-dir_emit_dots.patch
* exec-introduce-exec_binprm-for-depth-==-0-code.patch
* exec-kill-int-depth-in-search_binary_handler.patch
* exec-proc_exec_connector-should-be-called-only-once.patch
* exec-move-allow_write_access-fput-to-exec_binprm.patch
* exec-kill-load_binary-=-null-check-in-search_binary_handler.patch
* exec-cleanup-the-config_modules-logic.patch
* exec-dont-retry-if-request_module-fails.patch
* exec-cleanup-the-error-handling-in-search_binary_handler.patch
* kexec-remove-unnecessary-return.patch
* vmcore-introduce-elf-header-in-new-memory-feature.patch
* s390-vmcore-use-elf-header-in-new-memory-feature.patch
* vmcore-introduce-remap_oldmem_pfn_range.patch
* vmcore-introduce-remap_oldmem_pfn_range-fix.patch
* s390-vmcore-implement-remap_oldmem_pfn_range-for-s390.patch
* vmcore-enable-proc-vmcore-mmap-for-s390.patch
* s390-vmcore-use-vmcore-for-zfcpdump.patch
* rbtree-add-postorder-iteration-functions.patch
* rbtree-add-rbtree_postorder_for_each_entry_safe-helper.patch
* rbtree_test-add-test-for-postorder-iteration.patch
* rbtree-allow-tests-to-run-as-builtin.patch
* mm-zswap-use-postorder-iteration-when-destroying-rbtree.patch
* aoe-create-and-destroy-debugfs-directory-for-aoe.patch
* aoe-add-aoe-target-files-to-debugfs.patch
* aoe-provide-file-operations-for-debugfs-files.patch
* aoe-fill-in-per-aoe-target-information-for-debugfs-file.patch
* aoe-update-copyright-date.patch
* aoe-update-internal-version-number-to-85.patch
* aoe-remove-custom-implementation-of-kbasename.patch
* aoe-use-min-to-simplify-the-code.patch
* panic-call-panic-handlers-before-kmsg_dump.patch
* pktcdvd-convert-zone-macro-to-static-function-get_zone.patch
* pktcdvd-convert-printk-to-pr_level.patch
* pktcdvd-consolidate-dprintk-and-vprintk-macros.patch
* pktcdvd-add-struct-pktcdvd_device-to-pkt_dbg.patch
* pktcdvd-add-struct-pktcdvd_devicename-to-pr_err-logging-where-possible.patch
* pktcdvd-convert-pr_notice-to-pkt_notice.patch
* pktcdvd-convert-pr_info-to-pkt_info.patch
* pktcdvd-add-struct-pktcdvd_device-to-pkt_dump_sense.patch
* pktcdvd-fix-defective-misuses-of-pkt_level.patch
* memstick-add-support-for-legacy-memorysticks.patch
* w1-replace-strict_strtol-with-kstrtol.patch
* lib-radix-treec-make-radix_tree_node_alloc-work-correctly-within-interrupt.patch
* selftests-add-infrastructure-for-powerpc-selftests.patch
* selftests-add-support-files-for-powerpc-tests.patch
* selftests-add-test-of-pmu-instruction-counting-on-powerpc.patch
* initmpfs-replace-ms_nouser-in-initramfs.patch
* initmpfs-move-bdi-setup-from-init_rootfs-to-init_ramfs.patch
* initmpfs-move-bdi-setup-from-init_rootfs-to-init_ramfs-fix.patch
* initmpfs-move-rootfs-code-from-fs-ramfs-to-init.patch
* initmpfs-make-rootfs-use-tmpfs-when-config_tmpfs-enabled.patch
* initmpfs-use-initramfs-if-rootfstype=-or-root=-specified.patch
* initmpfs-use-initramfs-if-rootfstype=-or-root=-specified-fix.patch
* initmpfs-use-initramfs-if-rootfstype=-or-root=-specified-checkpatch-fixes.patch
* ipcshm-introduce-lockless-functions-to-obtain-the-ipc-object.patch
* ipcshm-shorten-critical-region-in-shmctl_down.patch
* ipc-drop-ipcctl_pre_down.patch
* ipc-drop-ipcctl_pre_down-fix.patch
* ipcshm-introduce-shmctl_nolock.patch
* ipcshm-make-shmctl_nolock-lockless.patch
* ipcshm-make-shmctl_nolock-lockless-checkpatch-fixes.patch
* ipcshm-shorten-critical-region-for-shmctl.patch
* ipcshm-cleanup-do_shmat-pasta.patch
* ipcshm-shorten-critical-region-for-shmat.patch
* ipcshm-shorten-critical-region-for-shmat-fix.patch
* ipc-rename-ids-rw_mutex.patch
* ipcmsg-drop-msg_unlock.patch
* ipc-document-general-ipc-locking-scheme.patch
* ipc-shm-guard-against-non-existant-vma-in-shmdt2.patch
* ipc-drop-ipc_lock_by_ptr.patch
* ipc-shm-drop-shm_lock_check.patch
* ipc-drop-ipc_lock_check.patch
* lz4-fix-compression-decompression-signedness-mismatch.patch
  linux-next.patch
* revert-selinux-do-not-handle-seclabel-as-a-special-flag.patch
* fs-bump-inode-and-dentry-counters-to-long.patch
* super-fix-calculation-of-shrinkable-objects-for-small-numbers.patch
* dcache-convert-dentry_statnr_unused-to-per-cpu-counters.patch
* dentry-move-to-per-sb-lru-locks.patch
* dcache-remove-dentries-from-lru-before-putting-on-dispose-list.patch
* mm-new-shrinker-api.patch
* shrinker-convert-superblock-shrinkers-to-new-api.patch
* shrinker-convert-superblock-shrinkers-to-new-api-fix.patch
* list-add-a-new-lru-list-type.patch
* inode-convert-inode-lru-list-to-generic-lru-list-code.patch
* inode-convert-inode-lru-list-to-generic-lru-list-code-inode-move-inode-to-a-different-list-inside-lock.patch
* dcache-convert-to-use-new-lru-list-infrastructure.patch
* list_lru-per-node-list-infrastructure.patch
* list_lru-per-node-list-infrastructure-fix.patch
* list_lru-per-node-list-infrastructure-fix-broken-lru_retry-behaviour.patch
* list_lru-per-node-api.patch
* list_lru-remove-special-case-function-list_lru_dispose_all.patch
* shrinker-add-node-awareness.patch
* vmscan-per-node-deferred-work.patch
* fs-convert-inode-and-dentry-shrinking-to-be-node-aware.patch
* xfs-convert-buftarg-lru-to-generic-code.patch
* xfs-convert-buftarg-lru-to-generic-code-fix.patch
* xfs-rework-buffer-dispose-list-tracking.patch
* xfs-convert-dquot-cache-lru-to-list_lru.patch
* xfs-convert-dquot-cache-lru-to-list_lru-fix.patch
* xfs-convert-dquot-cache-lru-to-list_lru-fix-dquot-isolation-hang.patch
* fs-convert-fs-shrinkers-to-new-scan-count-api.patch
* fs-convert-fs-shrinkers-to-new-scan-count-api-fix.patch
* fs-convert-fs-shrinkers-to-new-scan-count-api-fix-fix.patch
* drivers-convert-shrinkers-to-new-count-scan-api.patch
* drivers-convert-shrinkers-to-new-count-scan-api-fix.patch
* drivers-convert-shrinkers-to-new-count-scan-api-fix-2.patch
* i915-bail-out-earlier-when-shrinker-cannot-acquire-mutex.patch
* shrinker-convert-remaining-shrinkers-to-count-scan-api.patch
* shrinker-convert-remaining-shrinkers-to-count-scan-api-fix.patch
* hugepage-convert-huge-zero-page-shrinker-to-new-shrinker-api.patch
* hugepage-convert-huge-zero-page-shrinker-to-new-shrinker-api-fix.patch
* shrinker-kill-old-shrink-api.patch
* shrinker-kill-old-shrink-api-fix.patch
* list_lru-dynamically-adjust-node-arrays.patch
* list_lru-dynamically-adjust-node-arrays-super-fix-for-destroy-lrus.patch
* staging-lustre-ldlm-convert-to-shrinkers-to-count-scan-api.patch
* staging-lustre-obdclass-convert-lu_object-shrinker-to-count-scan-api.patch
* staging-lustre-ptlrpc-convert-to-new-shrinker-api.patch
* staging-lustre-libcfs-cleanup-linux-memh.patch
  debugging-keep-track-of-page-owners.patch
  debugging-keep-track-of-page-owners-fix.patch
  debugging-keep-track-of-page-owners-fix-2.patch
  debugging-keep-track-of-page-owners-fix-2-fix.patch
  debugging-keep-track-of-page-owners-fix-2-fix-fix.patch
  debugging-keep-track-of-page-owners-fix-2-fix-fix-fix.patch
  debugging-keep-track-of-page-owner-now-depends-on-stacktrace_support.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  slab-leaks3-default-y.patch
  put_bh-debug.patch
  add-debugging-aid-for-memory-initialisation-problems.patch
  workaround-for-a-pci-restoring-bug.patch
  single_open-seq_release-leak-diagnostics.patch
  add-a-refcount-check-in-dput.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
