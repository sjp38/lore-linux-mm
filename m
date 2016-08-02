Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 35B1E6B0253
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 18:54:36 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ag5so322622877pad.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 15:54:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 18si5185542pfk.163.2016.08.02.15.54.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 15:54:35 -0700 (PDT)
Date: Tue, 02 Aug 2016 15:54:34 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2016-08-02-15-53 uploaded
Message-ID: <57a124aa.eJmVCvd1SOHlQ1X8%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-08-02-15-53 has been uploaded to

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
* ocfs2-insure-dlm-lockspace-is-created-by-kernel-module.patch
* ocfs2-retry-on-enospc-if-sufficient-space-in-truncate-log.patch
* ocfs2-dlm-disable-bug_on-when-dlm_lock_res_dropping_ref-is-cleared-before-dlm_deref_lockres_done_handler.patch
* ocfs2-dlm-solve-a-bug-when-deref-failed-in-dlm_drop_lockres_ref.patch
* ocfs2-dlm-continue-to-purge-recovery-lockres-when-recovery-master-goes-down.patch
* mm-fail-prefaulting-if-page-table-allocation-fails.patch
* mm-move-swap-in-anonymous-page-into-active-list.patch
* fix-bitrotted-value-in-tools-testing-radix-tree-linux-gfph.patch
* mm-hugetlb-avoid-soft-lockup-in-set_max_huge_pages.patch
* mm-hugetlb-fix-huge_pte_alloc-bug_on.patch
* memcg-put-soft-limit-reclaim-out-of-way-if-the-excess-tree-is-empty.patch
* mm-kasan-fix-corruptions-and-false-positive-reports.patch
* mm-kasan-dont-reduce-quarantine-in-atomic-contexts.patch
* mm-kasan-slub-dont-disable-interrupts-when-object-leaves-quarantine.patch
* mm-kasan-get-rid-of-alloc_size-in-struct-kasan_alloc_meta.patch
* mm-kasan-get-rid-of-state-in-struct-kasan_alloc_meta.patch
* kasan-improve-double-free-reports.patch
* kasan-avoid-overflowing-quarantine-size-on-low-memory-systems.patch
* radix-tree-account-nodes-to-memcg-only-if-explicitly-requested.patch
* mm-vmscan-fix-memcg-aware-shrinkers-not-called-on-global-reclaim.patch
* sysv-ipc-fix-security-layer-leaking.patch
* ubsan-fix-typo-in-format-string.patch
* cgroup-update-cgroups-document-path.patch
* maintainers-befs-add-new-maintainers.patch
* proc_oom_score-remove-tasklist_lock-and-pid_alive.patch
* procfs-avoid-32-bit-time_t-in-proc-stat.patch
* suppress-warnings-when-compiling-fs-proc-task_mmuc-with-w=1.patch
* make-compile_test-depend-on-uml.patch
* memstick-dont-allocate-unused-major-for-ms_block.patch
* treewide-replace-obsolete-_refok-by-__ref.patch
* uapi-move-forward-declarations-of-internal-structures.patch
* mailmap-add-linus-lussing.patch
* include-mman-use-bool-instead-of-int-for-the-return-value-of-arch_validate_prot.patch
* task_work-use-read_once-lockless_dereference-avoid-pi_lock-if-task_works.patch
* dynamic_debug-only-add-header-when-used.patch
* printk-do-not-include-interrupth.patch
* printk-create-pr_level-functions.patch
* printk-introduce-suppress_message_printing.patch
* printk-include-asm-sectionsh-instead-of-asm-generic-sectionsh.patch
* fbdev-bfin_adv7393fb-move-driver_name-before-its-first-use.patch
* ratelimit-extend-to-print-suppressed-messages-on-release.patch
* printk-add-kernel-parameter-to-control-writes-to-dev-kmsg.patch
* get_maintainerpl-reduce-need-for-command-line-option-f.patch
* lib-iommu-helper-skip-to-next-segment.patch
* crc32-use-ktime_get_ns-for-measurement.patch
* radix-tree-fix-comment-about-exceptional-bits.patch
* firmware-consolidate-kmap-read-write-logic.patch
* firmware-provide-infrastructure-to-make-fw-caching-optional.patch
* firmware-support-loading-into-a-pre-allocated-buffer.patch
* checkpatch-skip-long-lines-that-use-an-efi_guid-macro.patch
* checkpatch-allow-c99-style-comments.patch
* checkpatch-yet-another-commit-id-improvement.patch
* checkpatch-dont-complain-about-bit-macro-in-uapi.patch
* checkpatch-improve-bare-use-of-signed-unsigned-types-warning.patch
* checkpatch-check-signoff-when-reading-stdin.patch
* checkpatch-if-no-filenames-then-read-stdin.patch
* binfmt_elf-fix-calculations-for-bss-padding.patch
* mm-refuse-wrapped-vm_brk-requests.patch
* binfmt_em86-fix-incompatible-pointer-type.patch
* nilfs2-hide-function-name-argument-from-nilfs_error.patch
* nilfs2-add-nilfs_msg-message-interface.patch
* nilfs2-embed-a-back-pointer-to-super-block-instance-in-nilfs-object.patch
* nilfs2-reduce-bare-use-of-printk-with-nilfs_msg.patch
* nilfs2-replace-nilfs_warning-with-nilfs_msg.patch
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
* kdump-arrange-for-paddr_vmcoreinfo_note-to-return-phys_addr_t.patch
* kexec-allow-architectures-to-override-boot-mapping.patch
* arm-keystone-dts-add-psci-command-definition.patch
* arm-kexec-fix-kexec-for-keystone-2.patch
* kexec-use-core_param-for-crash_kexec_post_notifiers-boot-option.patch
* add-a-kexec_crash_loaded-function.patch
* allow-kdump-with-crash_kexec_post_notifiers.patch
* kexec-add-restriction-on-kexec_load-segment-sizes.patch
* rapidio-add-rapidio-channelized-messaging-driver.patch
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
* powerpc-fsl_rio-apply-changes-for-rio-spec-rev-3.patch
* rapidio-switches-add-driver-for-idt-gen3-switches.patch
* w1-remove-need-for-ida-and-use-platform_devid_auto.patch
* w1-add-helper-macro-module_w1_family.patch
* w1-omap_hdq-fix-regression.patch
* init-allow-blacklisting-of-module_init-functions.patch
* relay-add-global-mode-support-for-buffer-only-channels.patch
* ban-config_localversion_auto-with-allmodconfig.patch
* config-add-android-config-fragments.patch
* init-kconfig-add-clarification-for-out-of-tree-modules.patch
* kcov-allow-more-fine-grained-coverage-instrumentation.patch
* ipc-delete-nr_ipc_ns.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* mm-add-restriction-when-memory_hotplug-config-enable.patch
* mm-memcontrol-fix-swap-counter-leak-on-swapout-from-offline-cgroup.patch
* mm-memcontrol-fix-memcg-id-ref-counter-on-swap-charge-move.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* kbuild-simpler-generation-of-assembly-constants.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* kernel-watchdog-use-nmi-registers-snapshot-in-hardlockup-handler.patch
  mm.patch
* mm-memcontrol-add-sanity-checks-for-memcg-idref-on-get-put.patch
* mm-oom-deduplicate-victim-selection-code-for-memcg-and-global-oom.patch
* mm-zsmalloc-add-trace-events-for-zs_compact.patch
* mm-zsmalloc-add-per-class-compact-trace-event.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* proc-relax-proc-tid-timerslack_ns-capability-requirements.patch
* proc-add-lsm-hook-checks-to-proc-tid-timerslack_ns.patch
* lib-add-crc64-ecma-module.patch
* compat-remove-compat_printk.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
  linux-next-rejects.patch
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
* samples-kprobe-convert-the-printk-to-pr_info-pr_err.patch
* samples-jprobe-convert-the-printk-to-pr_info-pr_err.patch
* samples-kretprobe-convert-the-printk-to-pr_info-pr_err.patch
* samples-kretprobe-fix-the-wrong-type.patch
* block-remove-blk_dev_dax-config-option.patch
* maintainers-update-email-and-list-of-samsung-hw-driver-maintainers.patch
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
