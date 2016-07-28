Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id C64576B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 19:34:27 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so74624365pad.2
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 16:34:27 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id vs3si14179648pab.2.2016.07.28.16.34.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 16:34:26 -0700 (PDT)
Date: Thu, 28 Jul 2016 16:34:25 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2016-07-28-16-33 uploaded
Message-ID: <579a9681.nQxUz4+tR82h3e/H%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-07-28-16-33 has been uploaded to

   http://www.ozlabs.org/~akpm/mmotm/

mmotm-readme.txt says

README for mm-of-the-moment:

http://www.ozlabs.org/~akpm/mmotm/

This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
more than once a week.

You will need quilt to apply these patches to the latest Linus release (4.x
or 4.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
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

http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/

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

	http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/

and use of this tree is similar to
http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/, described above.


This mmotm tree contains the following patches against 4.7:
(patches marked "*" will be included in linux-next)

  origin.patch
* proc-oom-drop-bogus-task_lock-and-mm-check.patch
* proc-oom-drop-bogus-sighand-lock.patch
* proc-oom_adj-extract-oom_score_adj-setting-into-a-helper.patch
* mm-oom_adj-make-sure-processes-sharing-mm-have-same-view-of-oom_score_adj.patch
* mm-oom-skip-vforked-tasks-from-being-selected.patch
* mm-oom-kill-all-tasks-sharing-the-mm.patch
* mm-oom-fortify-task_will_free_mem.patch
* mm-oom-task_will_free_mem-should-skip-oom_reaped-tasks.patch
* mm-oom_reaper-do-not-attempt-to-reap-a-task-more-than-twice.patch
* mm-oom-hide-mm-which-is-shared-with-kthread-or-global-init.patch
* mm-oom-fortify-task_will_free_mem-fix.patch
* mm-update-the-comment-in-__isolate_free_page.patch
* mm-fix-vm-scalability-regression-in-cgroup-aware-workingset-code.patch
* mm-compaction-remove-unnecessary-order-check-in-try_to_compact_pages.patch
* freezer-oom-check-tif_memdie-on-the-correct-task.patch
* cpuset-mm-fix-tif_memdie-check-in-cpuset_change_task_nodemask.patch
* mm-meminit-remove-early_page_nid_uninitialised.patch
* mm-vmstat-add-infrastructure-for-per-node-vmstats.patch
* mm-vmscan-move-lru_lock-to-the-node.patch
* mm-vmscan-move-lru-lists-to-node.patch
* mm-mmzone-clarify-the-usage-of-zone-padding.patch
* mm-vmscan-begin-reclaiming-pages-on-a-per-node-basis.patch
* mm-vmscan-have-kswapd-only-scan-based-on-the-highest-requested-zone.patch
* mm-vmscan-make-kswapd-reclaim-in-terms-of-nodes.patch
* mm-vmscan-remove-balance-gap.patch
* mm-vmscan-simplify-the-logic-deciding-whether-kswapd-sleeps.patch
* mm-vmscan-by-default-have-direct-reclaim-only-shrink-once-per-node.patch
* mm-vmscan-remove-duplicate-logic-clearing-node-congestion-and-dirty-state.patch
* mm-vmscan-do-not-reclaim-from-kswapd-if-there-is-any-eligible-zone.patch
* mm-vmscan-make-shrink_node-decisions-more-node-centric.patch
* mm-memcg-move-memcg-limit-enforcement-from-zones-to-nodes.patch
* mm-workingset-make-working-set-detection-node-aware.patch
* mm-page_alloc-consider-dirtyable-memory-in-terms-of-nodes.patch
* mm-move-page-mapped-accounting-to-the-node.patch
* mm-rename-nr_anon_pages-to-nr_anon_mapped.patch
* mm-move-most-file-based-accounting-to-the-node.patch
* mm-move-vmscan-writes-and-file-write-accounting-to-the-node.patch
* mm-vmscan-only-wakeup-kswapd-once-per-node-for-the-requested-classzone.patch
* mm-page_alloc-wake-kswapd-based-on-the-highest-eligible-zone.patch
* mm-convert-zone_reclaim-to-node_reclaim.patch
* mm-vmscan-avoid-passing-in-classzone_idx-unnecessarily-to-shrink_node.patch
* mm-vmscan-avoid-passing-in-classzone_idx-unnecessarily-to-compaction_ready.patch
* mm-vmscan-avoid-passing-in-remaining-unnecessarily-to-prepare_kswapd_sleep.patch
* mm-vmscan-have-kswapd-reclaim-from-all-zones-if-reclaiming-and-buffer_heads_over_limit.patch
* mm-vmscan-add-classzone-information-to-tracepoints.patch
* mm-page_alloc-remove-fair-zone-allocation-policy.patch
* mm-page_alloc-cache-the-last-node-whose-dirty-limit-is-reached.patch
* mm-vmstat-replace-__count_zone_vm_events-with-a-zone-id-equivalent.patch
* mm-vmstat-account-per-zone-stalls-and-pages-skipped-during-reclaim.patch
* mm-vmstat-print-node-based-stats-in-zoneinfo-file.patch
* mm-vmstat-remove-zone-and-node-double-accounting-by-approximating-retries.patch
* mm-page_alloc-fix-dirtyable-highmem-calculation.patch
* mm-pagevec-release-reacquire-lru_lock-on-pgdat-change.patch
* mm-show-node_pages_scanned-per-node-not-zone.patch
* mm-vmscan-update-all-zone-lru-sizes-before-updating-memcg.patch
* mm-vmscan-remove-redundant-check-in-shrink_zones.patch
* mm-vmscan-release-reacquire-lru_lock-on-pgdat-change.patch
* mm-add-per-zone-lru-list-stat.patch
* mm-vmscan-remove-highmem_file_pages.patch
* mm-remove-reclaim-and-compaction-retry-approximations.patch
* mm-consider-whether-to-decivate-based-on-eligible-zones-inactive-ratio.patch
* mm-vmscan-account-for-skipped-pages-as-a-partial-scan.patch
* mm-bail-out-in-shrin_inactive_list.patch
* mm-zsmalloc-use-obj_index-to-keep-consistent-with-others.patch
* mm-zsmalloc-take-obj-index-back-from-find_alloced_obj.patch
* mm-zsmalloc-use-class-objs_per_zspage-to-get-num-of-max-objects.patch
* mm-zsmalloc-avoid-calculate-max-objects-of-zspage-twice.patch
* mm-zsmalloc-keep-comments-consistent-with-code.patch
* mm-zsmalloc-add-__init__exit-attribute.patch
* mm-zsmalloc-use-helper-to-clear-page-flags-bit.patch
* mm-thp-clean-up-return-value-of-madvise_free_huge_pmd.patch
* memblock-include-asm-sectionsh-instead-of-asm-generic-sectionsh.patch
* mm-config_zone_device-stop-depending-on-config_expert.patch
* mm-cleanup-ifdef-guards-for-vmem_altmap.patch
* mm-track-nr_kernel_stack-in-kib-instead-of-number-of-stacks.patch
* mm-fix-memcg-stack-accounting-for-sub-page-stacks.patch
* kdb-use-task_cpu-instead-of-task_thread_info-cpu.patch
* printk-when-dumping-regs-show-the-stack-not-thread_info.patch
* mm-memblock-add-new-infrastructure-to-address-the-mem-limit-issue.patch
* arm64-acpi-fix-the-acpi-alignment-exception-when-mem=-specified.patch
* kmemleak-dont-hang-if-user-disables-scanning-early.patch
* make-__section_nr-more-efficient.patch
* mm-hwpoison-remove-incorrect-comment.patch
* mm-compaction-dont-isolate-pagewriteback-pages-in-migrate_sync_light-mode.patch
* revert-mm-mempool-only-set-__gfp_nomemalloc-if-there-are-free-elements.patch
* mm-add-cond_resched-to-generic_swapfile_activate.patch
* mm-optimize-copy_page_to-from_iter_iovec.patch
* mem-hotplug-alloc-new-page-from-a-nearest-neighbor-node-when-mem-offline.patch
* mm-memblockc-fix-index-adjustment-error-in-__next_mem_range_rev.patch
* zsmalloc-delete-an-unnecessary-check-before-the-function-call-iput.patch
* mm-fix-use-after-free-if-memory-allocation-failed-in-vma_adjust.patch
* mm-kasan-account-for-object-redzone-in-slubs-nearest_obj.patch
* mm-kasan-switch-slub-to-stackdepot-enable-memory-quarantine-for-slub.patch
* lib-stackdepotc-use-__gfp_nowarn-for-stack-allocations.patch
* mm-page_alloc-set-alloc_flags-only-once-in-slowpath.patch
* mm-page_alloc-dont-retry-initial-attempt-in-slowpath.patch
* mm-page_alloc-restructure-direct-compaction-handling-in-slowpath.patch
* mm-page_alloc-make-thp-specific-decisions-more-generic.patch
* mm-thp-remove-__gfp_noretry-from-khugepaged-and-madvised-allocations.patch
* mm-compaction-introduce-direct-compaction-priority.patch
* mm-compaction-simplify-contended-compaction-handling.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* mm-hugetlb-fix-race-when-migrate-pages.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* kbuild-simpler-generation-of-assembly-constants.patch
* ocfs2-insure-dlm-lockspace-is-created-by-kernel-module.patch
* ocfs2-retry-on-enospc-if-sufficient-space-in-truncate-log.patch
* ocfs2-dlm-disable-bug_on-when-dlm_lock_res_dropping_ref-is-cleared-before-dlm_deref_lockres_done_handler.patch
* ocfs2-dlm-solve-a-bug-when-deref-failed-in-dlm_drop_lockres_ref.patch
* ocfs2-dlm-continue-to-purge-recovery-lockres-when-recovery-master-goes-down.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* kernel-watchdog-use-nmi-registers-snapshot-in-hardlockup-handler.patch
  mm.patch
* mm-zsmalloc-add-trace-events-for-zs_compact.patch
* mm-zsmalloc-add-per-class-compact-trace-event.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* proc_oom_score-remove-tasklist_lock-and-pid_alive.patch
* procfs-avoid-32-bit-time_t-in-proc-stat.patch
* proc-relax-proc-tid-timerslack_ns-capability-requirements.patch
* proc-add-lsm-hook-checks-to-proc-tid-timerslack_ns.patch
* make-compile_test-depend-on-uml.patch
* memstick-dont-allocate-unused-major-for-ms_block.patch
* treewide-replace-obsolete-_refok-by-__ref.patch
* treewide-replace-obsolete-_refok-by-__ref-checkpatch-fixes.patch
* uapi-move-forward-declarations-of-internal-structures.patch
* mailmap-add-linus-lussing.patch
* include-mman-use-bool-instead-of-int-for-the-return-value-of-arch_validate_prot.patch
* task_work-use-read_once-lockless_dereference-avoid-pi_lock-if-task_works.patch
* dynamic_debug-only-add-header-when-used.patch
* dynamic_debug-only-add-header-when-used-fix.patch
* printk-do-not-include-interrupth.patch
* printk-create-pr_level-functions.patch
* printk-create-pr_level-functions-fix.patch
* printk-introduce-suppress_message_printing.patch
* printk-include-asm-sectionsh-instead-of-asm-generic-sectionsh.patch
* ratelimit-extend-to-print-suppressed-messages-on-release.patch
* printk-add-kernel-parameter-to-control-writes-to-dev-kmsg.patch
* printk-add-kernel-parameter-to-control-writes-to-dev-kmsg-update.patch
* maintainers-befs-add-new-maintainers.patch
* lib-iommu-helper-skip-to-next-segment.patch
* crc32-use-ktime_get_ns-for-measurement.patch
* radix-tree-fix-comment-about-exceptional-bits.patch
* lib-add-crc64-ecma-module.patch
* compat-remove-compat_printk.patch
* firmware-consolidate-kmap-read-write-logic.patch
* firmware-provide-infrastructure-to-make-fw-caching-optional.patch
* firmware-support-loading-into-a-pre-allocated-buffer.patch
* firmware-support-loading-into-a-pre-allocated-buffer-fix.patch
* checkpatch-skip-long-lines-that-use-an-efi_guid-macro.patch
* checkpatch-allow-c99-style-comments.patch
* checkpatch-yet-another-commit-id-improvement.patch
* checkpatch-dont-complain-about-bit-macro-in-uapi.patch
* checkpatch-improve-bare-use-of-signed-unsigned-types-warning.patch
* binfmt_elf-fix-calculations-for-bss-padding.patch
* mm-refuse-wrapped-vm_brk-requests.patch
* binfmt_em86-fix-incompatible-pointer-type.patch
* fs-befs-move-useless-assignment.patch
* fs-befs-check-silent-flag-before-logging-errors.patch
* fs-befs-remove-useless-pr_err.patch
* fs-befs-remove-useless-befs_error.patch
* fs-befs-remove-useless-pr_err-in-befs_init_inodecache.patch
* befs-check-return-of-sb_min_blocksize.patch
* befs-fix-function-name-in-documentation.patch
* befs-remove-unused-functions.patch
* fs-befs-replace-befs_bread-by-sb_bread.patch
* nilfs2-hide-function-name-argument-from-nilfs_error.patch
* nilfs2-add-nilfs_msg-message-interface.patch
* nilfs2-embed-a-back-pointer-to-super-block-instance-in-nilfs-object.patch
* nilfs2-reduce-bare-use-of-printk-with-nilfs_msg.patch
* nilfs2-replace-nilfs_warning-with-nilfs_msg.patch
* nilfs2-replace-nilfs_warning-with-nilfs_msg-fix.patch
* nilfs2-emit-error-message-when-i-o-error-is-detected.patch
* nilfs2-do-not-use-yield.patch
* nilfs2-refactor-parser-of-snapshot-mount-option.patch
* nilfs2-fix-misuse-of-a-semaphore-in-sysfs-code.patch
* nilfs2-use-bit-macro.patch
* nilfs2-move-ioctl-interface-and-disk-layout-to-uapi-separately.patch
* reiserfs-fix-new_insert_key-may-be-used-uninitialized.patch
* signal-consolidate-tstlf_restore_sigmask-code.patch
* exit-quieten-greatest-stack-depth-printk.patch
* cpumask-fix-code-comment.patch
* kexec-return-error-number-directly.patch
* arm-kdump-advertise-boot-aliased-crash-kernel-resource.patch
* arm-kexec-advertise-location-of-bootable-ram.patch
* kexec-dont-invoke-oom-killer-for-control-page-allocation.patch
* kexec-ensure-user-memory-sizes-do-not-wrap.patch
* kexec-ensure-user-memory-sizes-do-not-wrap-fix.patch
* kdump-arrange-for-paddr_vmcoreinfo_note-to-return-phys_addr_t.patch
* kexec-allow-architectures-to-override-boot-mapping.patch
* kexec-allow-architectures-to-override-boot-mapping-fix.patch
* arm-keystone-dts-add-psci-command-definition.patch
* arm-kexec-fix-kexec-for-keystone-2.patch
* kexec-use-core_param-for-crash_kexec_post_notifiers-boot-option.patch
* add-a-kexec_crash_loaded-function.patch
* allow-kdump-with-crash_kexec_post_notifiers.patch
* allow-kdump-with-crash_kexec_post_notifiers-fix.patch
* kexec-add-restriction-on-kexec_load-segment-sizes.patch
* kexec-add-restriction-on-kexec_load-segment-sizes-fix.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* rapidio-add-rapidio-channelized-messaging-driver.patch
* rapidio-add-rapidio-channelized-messaging-driver-fix-return-value-check-in-riocm_init.patch
* rapidio-remove-unnecessary-0x-prefixes-before-%pa-extension-uses.patch
* rapidio-documentation-fix-mangled-paragraph-in-mport_cdev.patch
* rapidio-fix-return-value-description-for-dma_prep-functions.patch
* rapidio-tsi721_dma-add-channel-mask-and-queue-size-parameters.patch
* rapidio-tsi721-add-pcie-mrrs-override-parameter.patch
* rapidio-tsi721-add-messaging-mbox-selector-parameter.patch
* rapidio-tsi721_dma-advance-queue-processing-from-transfer-submit-call.patch
* rapidio-fix-error-handling-in-mbox-request-release-functions.patch
* rapidio-idt_gen2-fix-locking-warning.patch
* rapidio-change-inbound-window-size-type-to-u64.patch
* rapidio-modify-for-rev3-specification-changes.patch
* rapidio-modify-for-rev3-specification-changes-fix-docbook-warning-for-gen3-update.patch
* powerpc-fsl_rio-apply-changes-for-rio-spec-rev-3.patch
* powerpc-fsl_rio-apply-changes-for-rio-spec-rev-3-fix.patch
* rapidio-switches-add-driver-for-idt-gen3-switches.patch
* rapidio-switches-add-driver-for-idt-gen3-switches-fix.patch
* w1-remove-need-for-ida-and-use-platform_devid_auto.patch
* w1-add-helper-macro-module_w1_family.patch
* w1-omap_hdq-fix-regression.patch
* init-allow-blacklisting-of-module_init-functions.patch
* relay-add-global-mode-support-for-buffer-only-channels.patch
* ban-config_localversion_auto-with-allmodconfig.patch
* config-add-android-config-fragments.patch
* kcov-allow-more-fine-grained-coverage-instrumentation.patch
* ipc-delete-nr_ipc_ns.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
  linux-next-git-rejects.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* fpga-zynq-fpga-fix-build-failure.patch
* tree-wide-replace-config_enabled-with-is_enabled.patch
* bitmap-bitmap_equal-memcmp-optimization-fix.patch
* powerpc-add-explicit-include-asm-asm-compath-for-jump-label.patch
* sparc-support-static_key-usage-in-non-module-__exit-sections.patch
* tile-support-static_key-usage-in-non-module-__exit-sections.patch
* arm-jump-label-may-reference-text-in-__exit.patch
* jump_label-remove-bugh-atomich-dependencies-for-have_jump_label.patch
* dynamic_debug-add-jump-label-support.patch
* ipc-semc-fix-complex_count-vs-simple-op-race.patch
* media-mtk-vcodec-remove-unused-dma_attrs.patch
* dma-mapping-use-unsigned-long-for-dma_attrs.patch
* alpha-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* arc-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* arm-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* arm64-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* avr32-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* blackfin-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* c6x-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* cris-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* frv-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* drm-exynos-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* drm-mediatek-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* drm-msm-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* drm-nouveau-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* drm-rockship-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* infiniband-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* iommu-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* media-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* xen-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* swiotlb-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* powerpc-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* video-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* x86-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* iommu-intel-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* h8300-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* hexagon-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* ia64-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* m68k-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* metag-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* microblaze-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* mips-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* mn10300-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* nios2-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* openrisc-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* parisc-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* misc-mic-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* s390-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* sh-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* sparc-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* tile-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* unicore32-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* xtensa-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* remoteproc-qcom-use-unsigned-long-for-dma_attrs.patch
* dma-mapping-remove-dma_get_attr.patch
* dma-mapping-document-the-dma-attributes-next-to-the-declaration.patch
* pnpbios-add-header-file-to-fix-build-errors.patch
* samples-kprobe-convert-the-printk-to-pr_info-pr_err.patch
* samples-jprobe-convert-the-printk-to-pr_info-pr_err.patch
* samples-kretprobe-convert-the-printk-to-pr_info-pr_err.patch
* samples-kretprobe-fix-the-wrong-type.patch
  mm-add-strictlimit-knob-v2.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  slab-leaks3-default-y.patch
  add-debugging-aid-for-memory-initialisation-problems.patch
  workaround-for-a-pci-restoring-bug.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
