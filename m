Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 02A956B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 19:32:08 -0400 (EDT)
Received: by ghbg15 with SMTP id g15so503820ghb.2
        for <linux-mm@kvack.org>; Fri, 20 Jul 2012 16:32:08 -0700 (PDT)
Subject: mmotm 2012-07-20-16-30 uploaded
From: akpm@linux-foundation.org
Date: Fri, 20 Jul 2012 16:32:06 -0700
Message-Id: <20120720233207.5773B100048@wpzn3.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2012-07-20-16-30 has been uploaded to

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
maintained at https://github.com/mstsxfx/memcg-devel.git by Michal Hocko. 
It contains the patches which are between the "#NEXT_PATCHES_START mm" and
"#NEXT_PATCHES_END" markers, from the series file,
http://www.ozlabs.org/~akpm/mmotm/series.


A full copy of the full kernel tree with the linux-next and mmotm patches
already applied is available through git within an hour of the mmotm
release.  Individual mmotm releases are tagged.  The master branch always
points to the latest release, so it's constantly rebasing.

http://git.cmpxchg.org/?p=linux-mmotm.git;a=summary

To develop on top of mmotm git:

  $ git remote add mmotm git://git.cmpxchg.org/linux-mmotm.git
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


This mmotm tree contains the following patches against 3.5-rc7:
(patches marked "*" will be included in linux-next)

  origin.patch
  linux-next.patch
  linux-next-git-rejects.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  thermal-constify-type-argument-for-the-registration-routine.patch
  drivers-base-ddc-debork.patch
* fs-gfs2-filec-fix-32-bit-build.patch
* mm-fix-wrong-argument-of-migrate_huge_pages-in-soft_offline_huge_page.patch
* pcdp-use-early_ioremap-early_iounmap-to-access-pcdp-table.patch
* cciss-fix-incorrect-scsi-status-reporting.patch
* acpi_memhotplugc-fix-memory-leak-when-memory-device-is-unbound-from-the-module-acpi_memhotplug.patch
* acpi_memhotplugc-free-memory-device-if-acpi_memory_enable_device-failed.patch
* acpi_memhotplugc-remove-memory-info-from-list-before-freeing-it.patch
* acpi_memhotplugc-dont-allow-to-eject-the-memory-device-if-it-is-being-used.patch
* acpi_memhotplugc-bind-the-memory-device-when-the-driver-is-being-loaded.patch
* acpi_memhotplugc-auto-bind-the-memory-device-which-is-hotplugged-before-the-driver-is-loaded.patch
* arch-x86-platform-iris-irisc-register-a-platform-device-and-a-platform-driver.patch
* arch-x86-include-asm-spinlockh-fix-comment.patch
* arch-x86-kernel-cpu-perf_event_intel_uncoreh-make-uncore_pmu_hrtimer_interval-64-bit.patch
* mn10300-only-add-mmem-funcs-to-kbuild_cflags-if-gcc-supports-it.patch
* dma-dmaengine-lower-the-priority-of-failed-to-get-dma-channel-message.patch
* prctl-remove-redunant-assignment-of-error-to-zero.patch
  cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* timeconstpl-remove-deprecated-defined-array.patch
* time-dont-inline-export_symbol-functions.patch
* thermal-fix-potential-out-of-bounds-memory-access.patch
* thermal-add-renesas-r-car-thermal-sensor-support.patch
* thermal-add-generic-cpufreq-cooling-implementation.patch
* hwmon-exynos4-move-thermal-sensor-driver-to-driver-thermal-directory.patch
* thermal-exynos5-add-exynos5-thermal-sensor-driver-support.patch
* thermal-exynos-register-the-tmu-sensor-with-the-kernel-thermal-layer.patch
* arm-exynos-add-thermal-sensor-driver-platform-data-support.patch
* ocfs2-use-find_last_bit.patch
* ocfs2-use-bitmap_weight.patch
* drivers-scsi-atp870uc-fix-bad-use-of-udelay.patch
* vfs-increment-iversion-when-a-file-is-truncated.patch
* fs-push-rcu_barrier-from-deactivate_locked_super-to-filesystems.patch
* fs-xattrc-getxattr-improve-handling-of-allocation-failures.patch
* fs-make-dumpable=2-require-fully-qualified-path.patch
* coredump-warn-about-unsafe-suid_dumpable-core_pattern-combo.patch
* xtensa-mm-faultc-port-oom-changes-to-do_page_fault.patch
* mm-slab-remove-duplicate-check.patch
* slab-do-not-call-compound_head-in-page_get_cache.patch
  mm.patch
* vmalloc-walk-vmap_areas-by-sorted-list-instead-of-rb_next.patch
* mm-make-vb_alloc-more-foolproof.patch
* mm-make-vb_alloc-more-foolproof-fix.patch
* memcg-rename-mem_cgroup_stat_swapout-as-mem_cgroup_stat_swap.patch
* memcg-rename-mem_cgroup_charge_type_mapped-as-mem_cgroup_charge_type_anon.patch
* memcg-remove-mem_cgroup_charge_type_force.patch
* swap-allow-swap-readahead-to-be-merged.patch
* documentation-update-how-page-cluster-affects-swap-i-o.patch
* mm-account-the-total_vm-in-the-vm_stat_account.patch
* mm-buddy-cleanup-on-should_fail_alloc_page.patch
* mm-prepare-for-removal-of-obsolete-proc-sys-vm-nr_pdflush_threads.patch
* hugetlb-rename-max_hstate-to-hugetlb_max_hstate.patch
* hugetlb-dont-use-err_ptr-with-vm_fault-values.patch
* hugetlb-add-an-inline-helper-for-finding-hstate-index.patch
* hugetlb-use-mmu_gather-instead-of-a-temporary-linked-list-for-accumulating-pages.patch
* hugetlb-avoid-taking-i_mmap_mutex-in-unmap_single_vma-for-hugetlb.patch
* hugetlb-simplify-migrate_huge_page.patch
* hugetlb-add-a-list-for-tracking-in-use-hugetlb-pages.patch
* hugetlb-make-some-static-variables-global.patch
* hugetlb-make-some-static-variables-global-mark-hugelb_max_hstate-__read_mostly.patch
* mm-hugetlb-add-new-hugetlb-cgroup.patch
* mm-hugetlb-add-new-hugetlb-cgroup-fix.patch
* mm-hugetlb-add-new-hugetlb-cgroup-fix-fix.patch
* mm-hugetlb-add-new-hugetlb-cgroup-fix-3.patch
* mm-hugetlb-add-new-hugetlb-cgroup-mark-root_h_cgroup-static.patch
* hugetlb-cgroup-add-the-cgroup-pointer-to-page-lru.patch
* hugetlb-cgroup-add-charge-uncharge-routines-for-hugetlb-cgroup.patch
* hugetlb-cgroup-add-charge-uncharge-routines-for-hugetlb-cgroup-fix.patch
* hugetlb-cgroup-add-charge-uncharge-routines-for-hugetlb-cgroup-add-huge_page_order-check-to-avoid-incorrectly-uncharge.patch
* hugetlb-cgroup-add-support-for-cgroup-removal.patch
* hugetlb-cgroup-add-hugetlb-cgroup-control-files.patch
* hugetlb-cgroup-add-hugetlb-cgroup-control-files-fix.patch
* hugetlb-cgroup-add-hugetlb-cgroup-control-files-fix-fix.patch
* hugetlb-cgroup-migrate-hugetlb-cgroup-info-from-oldpage-to-new-page-during-migration.patch
* hugetlb-cgroup-add-hugetlb-controller-documentation.patch
* hugetlb-move-all-the-in-use-pages-to-active-list.patch
* hugetlb-cgroup-assign-the-page-hugetlb-cgroup-when-we-move-the-page-to-active-list.patch
* hugetlb-cgroup-remove-exclude-and-wakeup-rmdir-calls-from-migrate.patch
* mm-oom-do-not-schedule-if-current-has-been-killed.patch
* mm-memblockc-memblock_double_array-cosmetic-cleanups.patch
* memcg-remove-check-for-signal_pending-during-rmdir.patch
* memcg-clean-up-force_empty_list-return-value-check.patch
* memcg-mem_cgroup_move_parent-doesnt-need-gfp_mask.patch
* memcg-make-mem_cgroup_force_empty_list-return-bool.patch
* memcg-make-mem_cgroup_force_empty_list-return-bool-fix.patch
* mm-compaction-cleanup-on-compaction_deferred.patch
* mm-fadvise-dont-return-einval-when-filesystem-cannot-implement-fadvise.patch
* mm-fadvise-dont-return-einval-when-filesystem-cannot-implement-fadvise-checkpatch-fixes.patch
* mm-clear-pages_scanned-only-if-draining-a-pcp-adds-pages-to-the-buddy-allocator-again.patch
* mm-oom-fix-potential-killing-of-thread-that-is-disabled-from-oom-killing.patch
* mm-oom-replace-some-information-in-tasklist-dump.patch
* mm-do-not-use-page_count-without-a-page-pin.patch
* mm-clean-up-__count_immobile_pages.patch
* memcg-rename-config-variables.patch
* memcg-rename-config-variables-fix.patch
* memcg-rename-config-variables-fix-fix.patch
* mm-remove-unused-lru_all_evictable.patch
* memcg-fix-bad-behavior-in-use_hierarchy-file.patch
* memcg-rename-mem_control_xxx-to-memcg_xxx.patch
* mm-have-order-0-compaction-start-off-where-it-left.patch
* mm-have-order-0-compaction-start-off-where-it-left-checkpatch-fixes.patch
* mm-have-order-0-compaction-start-off-where-it-left-v3.patch
* mm-have-order-0-compaction-start-off-where-it-left-v3-typo.patch
* mm-config_have_memblock_node-config_have_memblock_node_map.patch
* vmscan-remove-obsolete-shrink_control-comment.patch
* mm-memoryc-print_vma_addr-call-up_readmm-mmap_sem-directly.patch
* mm-setup-pageblock_order-before-its-used-by-sparsemem.patch
* mm-memcg-complete-documentation-for-tcp-memcg-files.patch
* mm-memcg-mem_cgroup_relize_xxx_limit-can-guarantee-memcg-reslimit-=-memcg-memswlimit.patch
* mm-memcg-replace-inexistence-move_lock_page_cgroup-by-move_lock_mem_cgroup-in-comment.patch
* mm-hotplug-correctly-setup-fallback-zonelists-when-creating-new-pgdat.patch
* mm-hotplug-correctly-add-new-zone-to-all-other-nodes-zone-lists.patch
* mm-hotplug-free-zone-pageset-when-a-zone-becomes-empty.patch
* mm-hotplug-mark-memory-hotplug-code-in-page_allocc-as-__meminit.patch
* mm-oom-move-declaration-for-mem_cgroup_out_of_memory-to-oomh.patch
* mm-oom-introduce-helper-function-to-process-threads-during-scan.patch
* mm-memcg-introduce-own-oom-handler-to-iterate-only-over-its-own-threads.patch
* mm-oom-reduce-dependency-on-tasklist_lock.patch
* mm-oom-reduce-dependency-on-tasklist_lock-fix.patch
* mm-memcg-move-all-oom-handling-to-memcontrolc.patch
* mm-factor-out-memory-isolate-functions.patch
* mm-bug-fix-free-page-check-in-zone_watermark_ok.patch
* memory-hotplug-fix-kswapd-looping-forever-problem.patch
* memory-hotplug-fix-kswapd-looping-forever-problem-fix.patch
* memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix.patch
* mm-slb-add-knowledge-of-pfmemalloc-reserve-pages.patch
* mm-slub-optimise-the-slub-fast-path-to-avoid-pfmemalloc-checks.patch
* mm-introduce-__gfp_memalloc-to-allow-access-to-emergency-reserves.patch
* mm-allow-pf_memalloc-from-softirq-context.patch
* mm-only-set-page-pfmemalloc-when-alloc_no_watermarks-was-used.patch
* mm-ignore-mempolicies-when-using-alloc_no_watermark.patch
* net-introduce-sk_gfp_atomic-to-allow-addition-of-gfp-flags-depending-on-the-individual-socket.patch
* netvm-allow-the-use-of-__gfp_memalloc-by-specific-sockets.patch
* netvm-allow-skb-allocation-to-use-pfmemalloc-reserves.patch
* netvm-propagate-page-pfmemalloc-to-skb.patch
* netvm-propagate-page-pfmemalloc-from-skb_alloc_page-to-skb.patch
* netvm-propagate-page-pfmemalloc-from-skb_alloc_page-to-skb-fix.patch
* netvm-set-pf_memalloc-as-appropriate-during-skb-processing.patch
* mm-micro-optimise-slab-to-avoid-a-function-call.patch
* nbd-set-sock_memalloc-for-access-to-pfmemalloc-reserves.patch
* mm-throttle-direct-reclaimers-if-pf_memalloc-reserves-are-low-and-swap-is-backed-by-network-storage.patch
* mm-account-for-the-number-of-times-direct-reclaimers-get-throttled.patch
* netvm-prevent-a-stream-specific-deadlock.patch
* selinux-tag-avc-cache-alloc-as-non-critical.patch
* mm-methods-for-teaching-filesystems-about-pg_swapcache-pages.patch
* mm-add-support-for-a-filesystem-to-activate-swap-files-and-use-direct_io-for-writing-swap-pages.patch
* mm-swap-implement-generic-handler-for-swap_activate.patch
* mm-add-get_kernel_page-for-pinning-of-kernel-addresses-for-i-o.patch
* mm-add-support-for-direct_io-to-highmem-pages.patch
* nfs-teach-the-nfs-client-how-to-treat-pg_swapcache-pages.patch
* nfs-disable-data-cache-revalidation-for-swapfiles.patch
* nfs-enable-swap-on-nfs.patch
* nfs-prevent-page-allocator-recursions-with-swap-over-nfs.patch
* swapfile-avoid-dereferencing-bd_disk-during-swap_entry_free-for-network-storage.patch
* mm-memcg-fix-compaction-migration-failing-due-to-memcg-limits.patch
* mm-memcg-fix-compaction-migration-failing-due-to-memcg-limits-checkpatch-fixes.patch
* mm-swapfile-clean-up-unuse_pte-race-handling.patch
* mm-memcg-push-down-pageswapcache-check-into-uncharge-entry-functions.patch
* mm-memcg-only-check-for-pageswapcache-when-uncharging-anon.patch
* mm-memcg-move-swapin-charge-functions-above-callsites.patch
* mm-memcg-remove-unneeded-shmem-charge-type.patch
* mm-memcg-remove-needless-mm-fixup-to-init_mm-when-charging.patch
* mm-memcg-split-swapin-charge-function-into-private-and-public-part.patch
* mm-memcg-only-check-swap-cache-pages-for-repeated-charging.patch
* mm-memcg-only-check-anon-swapin-page-charges-for-swap-cache.patch
* mm-mmu_notifier-fix-freed-page-still-mapped-in-secondary-mmu.patch
* memcg-prevent-oom-with-too-many-dirty-pages.patch
* memcg-further-prevent-oom-with-too-many-dirty-pages.patch
* memcg-add-mem_cgroup_from_css-helper.patch
* memcg-add-mem_cgroup_from_css-helper-fix.patch
* shmem-provide-vm_ops-when-also-providing-a-mem-policy.patch
* tmpfs-interleave-the-starting-node-of-dev-shmem.patch
* frv-kill-used-but-uninitialized-variable.patch
* alpha-remove-mysterious-if-zero-ed-out-includes.patch
* avr32-mm-faultc-port-oom-changes-to-do_page_fault.patch
* avr32-mm-faultc-port-oom-changes-to-do_page_fault-fix.patch
* clk-add-non-config_have_clk-routines.patch
* clk-remove-redundant-depends-on-from-drivers-kconfig.patch
* i2c-i2c-pxa-remove-conditional-compilation-of-clk-code.patch
* usb-marvell-remove-conditional-compilation-of-clk-code.patch
* usb-musb-remove-conditional-compilation-of-clk-code.patch
* ata-pata_arasan-remove-conditional-compilation-of-clk-code.patch
* net-c_can-remove-conditional-compilation-of-clk-code.patch
* net-stmmac-remove-conditional-compilation-of-clk-code.patch
* gadget-m66592-remove-conditional-compilation-of-clk-code.patch
* gadget-r8a66597-remove-conditional-compilation-of-clk-code.patch
* usb-host-r8a66597-remove-conditional-compilation-of-clk-code.patch
* arch-arm-mach-netx-fbc-reuse-dummy-clk-routines-for-config_have_clk=n.patch
* clk-validate-pointer-in-__clk_disable.patch
* panic-fix-a-possible-deadlock-in-panic.patch
* nmi-watchdog-fix-for-lockup-detector-breakage-on-resume.patch
* kernel-sysc-avoid-argv_freenull.patch
* kmsg-dev-kmsg-properly-return-possible-copy_from_user-failure.patch
* printk-add-generic-functions-to-find-kern_level-headers.patch
* printk-add-generic-functions-to-find-kern_level-headers-fix.patch
* printk-add-kern_levelsh-to-make-kern_level-available-for-asm-use.patch
* arch-remove-direct-definitions-of-kern_level-uses.patch
* btrfs-use-printk_get_level-and-printk_skip_level-add-__printf-fix-fallout.patch
* btrfs-use-printk_get_level-and-printk_skip_level-add-__printf-fix-fallout-fix.patch
* btrfs-use-printk_get_level-and-printk_skip_level-add-__printf-fix-fallout-checkpatch-fixes.patch
* sound-use-printk_get_level-and-printk_skip_level.patch
* printk-convert-the-format-for-kern_level-to-a-2-byte-pattern.patch
* printk-only-look-for-prefix-levels-in-kernel-messages.patch
* printk-remove-the-now-unnecessary-c-annotation-for-kern_cont.patch
* vsprintf-add-%pmr-for-bluetooth-mac-address.patch
* vsprintf-add-%pmr-for-bluetooth-mac-address-fix.patch
* lib-vsprintfc-remind-people-to-update-documentation-printk-formatstxt-when-adding-printk-formats.patch
* lib-vsprintfc-kptr_restrict-fix-pk-error-in-sysrq-show-all-timersq.patch
* maintainers-update-exynos-dp-driver-f-patterns.patch
* drivers-video-backlight-atmel-pwm-blc-use-devm_-functions.patch
* drivers-video-backlight-ot200_blc-use-devm_-functions.patch
* drivers-video-backlight-lm3533_blc-use-devm_-functions.patch
* backlight-atmel-pwm-bl-use-devm_gpio_request.patch
* backlight-ot200_bl-use-devm_gpio_request.patch
* backlight-tosa_lcd-use-devm_gpio_request.patch
* backlight-tosa_bl-use-devm_gpio_request.patch
* backlight-lms283gf05-use-devm_gpio_request.patch
* backlight-corgi_lcd-use-devm_gpio_request.patch
* backlight-l4f00242t03-use-devm_gpio_request_one.patch
* backlight-move-register-definitions-from-header-to-source.patch
* backlight-move-lp855x-header-into-platform_data-directory.patch
* string-introduce-memweight.patch
* string-introduce-memweight-fix.patch
* string-introduce-memweight-fix-build-error-caused-by-memweight-introduction.patch
* qnx4fs-use-memweight.patch
* dm-use-memweight.patch
* affs-use-memweight.patch
* video-uvc-use-memweight.patch
* ocfs2-use-memweight.patch
* ext2-use-memweight.patch
* ext3-use-memweight.patch
* ext4-use-memweight.patch
* ipc-mqueue-remove-unnecessary-rb_init_node-calls.patch
* rbtree-reference-documentation-rbtreetxt-for-usage-instructions.patch
* rbtree-empty-nodes-have-no-color.patch
* rbtree-fix-incorrect-rbtree-node-insertion-in-fs-proc-proc_sysctlc.patch
* rbtree-move-some-implementation-details-from-rbtreeh-to-rbtreec.patch
* rbtree-move-some-implementation-details-from-rbtreeh-to-rbtreec-fix.patch
* rbtree-performance-and-correctness-test.patch
* rbtree-break-out-of-rb_insert_color-loop-after-tree-rotation.patch
* rbtree-adjust-root-color-in-rb_insert_color-only-when-necessary.patch
* rbtree-low-level-optimizations-in-rb_insert_color.patch
* rbtree-adjust-node-color-in-__rb_erase_color-only-when-necessary.patch
* rbtree-optimize-case-selection-logic-in-__rb_erase_color.patch
* rbtree-low-level-optimizations-in-__rb_erase_color.patch
* rbtree-coding-style-adjustments.patch
* rbtree-rb_erase-updates-and-comments.patch
* rbtree-optimize-fetching-of-sibling-node.patch
* atomic64_test-simplify-the-ifdef-for-atomic64_dec_if_positive-test.patch
* checkpatch-update-alignment-check.patch
* checkpatch-test-for-non-standard-signatures.patch
* checkpatch-check-usleep_range-arguments.patch
* checkpatch-add-check-for-use-of-sizeof-without-parenthesis.patch
* checkpatch-add-check-for-use-of-sizeof-without-parenthesis-v2.patch
* checkpatch-add-checks-for-do-while-0-macro-misuses.patch
* nsproxy-move-free_nsproxy-out-of-do_exit-path.patch
* drivers-message-i2o-i2o_procc-the-pointer-returned-from-chtostr-points-to-an-array-which-is-no-longer-valid.patch
* drivers-rtc-rtc-coh901331c-use-clk_prepare-unprepare.patch
* drivers-rtc-rtc-coh901331c-use-devm-allocation.patch
* rtc-pl031-encapsulate-per-vendor-ops.patch
* rtc-pl031-use-per-vendor-variables-for-special-init.patch
* rtc-pl031-fix-up-irq-flags.patch
* drivers-rtc-rtc-ab8500c-use-uie-emulation.patch
* drivers-rtc-rtc-ab8500c-use-uie-emulation-checkpatch-fixes.patch
* drivers-rtc-rtc-ab8500c-remove-fix-for-ab8500-ed-version.patch
* drivers-rtc-rtc-r9701c-avoid-second-call-to-rtc_valid_tm.patch
* drivers-rtc-rtc-r9701c-check-that-r9701_set_datetime-succeeded.patch
* rtc-rtc-s3c-replace-include-header-files-from-asm-to-linux.patch
* rtc-mc13xxx-use-module_device_table-instead-of-module_alias.patch
* rtc-mc13xxx-add-support-for-the-rtc-in-the-mc34708-pmic.patch
* rtc-rtc-88pm80x-assign-ret-only-when-rtc_register_driver-fails.patch
* rtc-rtc-88pm80x-remove-unneed-devm_kfree.patch
* rtc-rtc-da9052-remove-unneed-devm_kfree-call.patch
* nilfs2-add-omitted-comment-for-ns_mount_state-field-of-the_nilfs-structure.patch
* nilfs2-remove-references-to-long-gone-super-operations.patch
* nilfs2-fix-timing-issue-between-rmcp-and-chcp-ioctls.patch
* nilfs2-fix-deadlock-issue-between-chcp-and-thaw-ioctls.patch
* nilfs2-add-omitted-comments-for-structures-in-nilfs2_fsh.patch
* nilfs2-add-omitted-comments-for-different-structures-in-driver-implementation.patch
* hfsplus-use-enomem-when-kzalloc-fails.patch
* fat-accessors-for-msdos_dir_entry-start-fields.patch
* fat-refactor-shortname-parsing.patch
* fat-exportfs-move-nfs-support-code.patch
* fat-exportfs-fix-dentry-reconnection.patch
* kernel-kmodc-document-call_usermodehelper_fns-a-bit.patch
* kmod-avoid-deadlock-from-recursive-kmod-call.patch
* coredump-fix-wrong-comments-on-core-limits-of-pipe-coredump-case.patch
* fork-use-vma_pages-to-simplify-the-code.patch
* fork-use-vma_pages-to-simplify-the-code-fix.patch
* revert-sched-fix-fork-error-path-to-not-crash.patch
* fork-fix-error-handling-in-dup_task.patch
* kdump-append-newline-to-the-last-lien-of-vmcoreinfo-note.patch
* ipc-add-compat_shmlba-support.patch
* ipc-allow-compat-ipc-version-field-parsing-if-arch_want_old_compat_ipc.patch
* ipc-compat-use-signed-size_t-types-for-msgsnd-and-msgrcv.patch
* ipc-use-kconfig-options-for-__arch_want_ipc_parse_version.patch
* ipc-semc-alternatives-to-preempt_disable.patch
* sysctl-suppress-kmemleak-messages.patch
* pps-return-ptr_err-on-error-in-device_create.patch
* fs-cachefiles-add-support-for-large-files-in-filesystem-caching.patch
* fs-cachefiles-add-support-for-large-files-in-filesystem-caching-fix.patch
* include-linux-aioh-cpp-c-conversions.patch
* resource-make-sure-requested-range-is-included-in-the-root-range.patch
* c-r-fcntl-add-f_getowner_uids-option.patch
* fault-injection-notifier-error-injection.patch
* fault-injection-notifier-error-injection-doc.patch
* cpu-rewrite-cpu-notifier-error-inject-module.patch
* pm-pm-notifier-error-injection-module.patch
* memory-memory-notifier-error-injection-module.patch
* memory-memory-notifier-error-injection-module-fix.patch
* powerpc-pseries-reconfig-notifier-error-injection-module.patch
* fault-injection-add-selftests-for-cpu-and-memory-hotplug.patch
* fault-injection-add-tool-to-run-command-with-failslab-or-fail_page_alloc.patch
* fault-injection-add-tool-to-run-command-with-failslab-or-fail_page_alloc-doc.patch
* lib-scatterlist-do-not-re-write-gfp_flags-in-__sg_alloc_table.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  mutex-subsystem-synchro-test-module.patch
  mutex-subsystem-synchro-test-module-fix.patch
  slab-leaks3-default-y.patch
  put_bh-debug.patch
  add-debugging-aid-for-memory-initialisation-problems.patch
  workaround-for-a-pci-restoring-bug.patch
  prio_tree-debugging-patch.patch
  single_open-seq_release-leak-diagnostics.patch
  add-a-refcount-check-in-dput.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
