Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id D49F06B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 16:51:00 -0500 (EST)
Message-ID: <509D88C6.8030700@infradead.org>
Date: Fri, 09 Nov 2012 14:50:46 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: mmotm 2012-11-08-15-17 uploaded (include/linux/shm.h)
References: <20121108231753.E6B7A100047@wpzn3.hot.corp.google.com>
In-Reply-To: <20121108231753.E6B7A100047@wpzn3.hot.corp.google.com>
Content-Type: multipart/mixed;
 boundary="------------040206060302080906000102"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org

This is a multi-part message in MIME format.
--------------040206060302080906000102
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 11/08/2012 03:17 PM, akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2012-11-08-15-17 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 
> You will need quilt to apply these patches to the latest Linus release (3.x
> or 3.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> http://ozlabs.org/~akpm/mmotm/series
> 
> The file broken-out.tar.gz contains two datestamp files: .DATE and
> .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
> followed by the base kernel version against which this patch series is to
> be applied.
> 
> This tree is partially included in linux-next.  To see which patches are
> included in linux-next, consult the `series' file.  Only the patches
> within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included in
> linux-next.
> 
> A git tree which contains the memory management portion of this tree is
> maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> by Michal Hocko.  It contains the patches which are between the
> "#NEXT_PATCHES_START mm" and "#NEXT_PATCHES_END" markers, from the series
> file, http://www.ozlabs.org/~akpm/mmotm/series.
> 
> 
> A full copy of the full kernel tree with the linux-next and mmotm patches
> already applied is available through git within an hour of the mmotm
> release.  Individual mmotm releases are tagged.  The master branch always
> points to the latest release, so it's constantly rebasing.
> 
> http://git.cmpxchg.org/?p=linux-mmotm.git;a=summary
> 
> To develop on top of mmotm git:
> 
>   $ git remote add mmotm git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
>   $ git remote update mmotm
>   $ git checkout -b topic mmotm/master
>   <make changes, commit>
>   $ git send-email mmotm/master.. [...]
> 
> To rebase a branch with older patches to a new mmotm release:
> 
>   $ git remote update mmotm
>   $ git rebase --onto mmotm/master <topic base> topic
> 
> 
> 
> 
> The directory http://www.ozlabs.org/~akpm/mmots/ (mm-of-the-second)
> contains daily snapshots of the -mm tree.  It is updated more frequently
> than mmotm, and is untested.
> 
> A git copy of this tree is available at
> 
> 	http://git.cmpxchg.org/?p=linux-mmots.git;a=summary
> 
> and use of this tree is similar to
> http://git.cmpxchg.org/?p=linux-mmotm.git, described above.
> 
> 
> This mmotm tree contains the following patches against 3.7-rc4:
> (patches marked "*" will be included in linux-next)
> 
>   origin.patch
> * checkpatch-improve-network-block-comment-style-checking.patch
> * revert-tools-testing-selftests-epoll-test_epollc-fix-build.patch
> * revert-epoll-support-for-disabling-items-and-a-self-test-app.patch
> * fanotify-fix-missing-break.patch
> * mm-bugfix-set-current-reclaim_state-to-null-while-returning-from-kswapd.patch
> * h8300-add-missing-l1_cache_shift.patch
>   linux-next.patch
>   i-need-old-gcc.patch
>   arch-alpha-kernel-systblss-remove-debug-check.patch
> * tmpfs-fix-shmem_getpage_gfp-vm_bug_on.patch
> * tmpfs-change-final-i_blocks-bug-to-warning.patch
> * mm-add-anon_vma_lock-to-validate_mm.patch
> * mm-fix-build-warning-for-uninitialized-value.patch
> * memcg-oom-fix-totalpages-calculation-for-memoryswappiness==0.patch
> * memcg-oom-fix-totalpages-calculation-for-memoryswappiness==0-fix.patch
> * mm-fix-a-regression-with-highmem-introduced-by-changeset-7f1290f2f2a4d.patch
> * mm-vmscan-scale-number-of-pages-reclaimed-by-reclaim-compaction-only-in-direct-reclaim.patch
> * proc-check-vma-vm_file-before-dereferencing.patch
> * memstick-remove-unused-field-from-state-struct.patch
> * memstick-ms_block-fix-complile-issue.patch
> * memstick-use-after-free-in-msb_disk_release.patch
> * memstick-memory-leak-on-error-in-msb_ftl_scan.patch
> * cris-fix-i-o-macros.patch
> * selinux-fix-sel_netnode_insert-suspicious-rcu-dereference.patch
> * vfs-d_obtain_alias-needs-to-use-as-default-name.patch
> * fs-block_devc-page-cache-wrongly-left-invalidated-after-revalidate_disk.patch
> * cpu_hotplug-unmap-cpu2node-when-the-cpu-is-hotremoved.patch
> * cpu_hotplug-unmap-cpu2node-when-the-cpu-is-hotremoved-fix.patch
> * arch-x86-platform-iris-irisc-register-a-platform-device-and-a-platform-driver.patch
> * x86-numa-dont-check-if-node-is-numa_no_node.patch
> * arch-x86-tools-insn_sanityc-identify-source-of-messages.patch
> * uv-fix-incorrect-tlb-flush-all-issue.patch
> * olpc-fix-olpc-xo1-scic-build-errors.patch
> * fs-debugsfs-remove-unnecessary-inode-i_private-initialization.patch
> * pcmcia-move-unbind-rebind-into-dev_pm_opscomplete.patch
> * drm-i915-optimize-div_round_closest-call.patch
>   cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
> * irq-tsk-comm-is-an-array.patch
> * irq-tsk-comm-is-an-array-fix.patch
> * timeconstpl-remove-deprecated-defined-array.patch
> * time-dont-inline-export_symbol-functions.patch
> * fs-pstore-ramc-fix-up-section-annotations.patch
> * h8300-select-generic-atomic64_t-support.patch
> * drivers-tty-serial-serial_corec-fix-uart_get_attr_port-shift.patch
> * tasklet-ignore-disabled-tasklet-in-tasklet_action.patch
> * tasklet-ignore-disabled-tasklet-in-tasklet_action-v2.patch
> * drivers-message-fusion-mptscsihc-missing-break.patch
> * hptiop-support-highpoint-rr4520-rr4522-hba.patch
> * cciss-cleanup-bitops-usage.patch
> * cciss-use-check_signature.patch
> * block-store-partition_meta_infouuid-as-a-string.patch
> * init-reduce-partuuid-min-length-to-1-from-36.patch
> * block-partition-msdos-provide-uuids-for-partitions.patch
> * drbd-use-copy_highpage.patch
> * vfs-increment-iversion-when-a-file-is-truncated.patch
> * fs-change-return-values-from-eacces-to-eperm.patch
> * fs-block_devc-need-not-to-check-inode-i_bdev-in-bd_forget.patch
> * mm-slab-remove-duplicate-check.patch
>   mm.patch
> * writeback-remove-nr_pages_dirtied-arg-from-balance_dirty_pages_ratelimited_nr.patch
> * mm-show-migration-types-in-show_mem.patch
> * mm-memcg-make-mem_cgroup_out_of_memory-static.patch
> * mm-use-is_enabledconfig_numa-instead-of-numa_build.patch
> * mm-use-is_enabledconfig_compaction-instead-of-compaction_build.patch
> * thp-clean-up-__collapse_huge_page_isolate.patch
> * thp-clean-up-__collapse_huge_page_isolate-v2.patch
> * mm-introduce-mm_find_pmd.patch
> * mm-introduce-mm_find_pmd-fix.patch
> * thp-introduce-hugepage_vma_check.patch
> * thp-cleanup-introduce-mk_huge_pmd.patch
> * memory-hotplug-suppress-device-memoryx-does-not-have-a-release-function-warning.patch
> * memory-hotplug-skip-hwpoisoned-page-when-offlining-pages.patch
> * memory-hotplug-update-mce_bad_pages-when-removing-the-memory.patch
> * memory-hotplug-update-mce_bad_pages-when-removing-the-memory-fix.patch
> * memory-hotplug-auto-offline-page_cgroup-when-onlining-memory-block-failed.patch
> * memory-hotplug-fix-nr_free_pages-mismatch.patch
> * memory-hotplug-fix-nr_free_pages-mismatch-fix.patch
> * numa-convert-static-memory-to-dynamically-allocated-memory-for-per-node-device.patch
> * memory-hotplug-suppress-device-nodex-does-not-have-a-release-function-warning.patch
> * memory-hotplug-mm-sparsec-clear-the-memory-to-store-struct-page.patch
> * memory-hotplug-allocate-zones-pcp-before-onlining-pages.patch
> * memory-hotplug-allocate-zones-pcp-before-onlining-pages-fix.patch
> * memory-hotplug-allocate-zones-pcp-before-onlining-pages-fix-2.patch
> * memory_hotplug-fix-possible-incorrect-node_states.patch
> * slub-hotplug-ignore-unrelated-nodes-hot-adding-and-hot-removing.patch
> * mm-memory_hotplugc-update-start_pfn-in-zone-and-pg_data-when-spanned_pages-==-0.patch
> * mm-add-comment-on-storage-key-dirty-bit-semantics.patch
> * mmvmscan-only-evict-file-pages-when-we-have-plenty.patch
> * mmvmscan-only-evict-file-pages-when-we-have-plenty-fix.patch
> * mm-refactor-reinsert-of-swap_info-in-sys_swapoff.patch
> * mm-do-not-call-frontswap_init-during-swapoff.patch
> * mm-highmem-use-pkmap_nr-to-calculate-an-index-of-pkmap.patch
> * mm-highmem-remove-useless-pool_lock.patch
> * mm-highmem-remove-page_address_pool-list.patch
> * mm-highmem-remove-page_address_pool-list-v2.patch
> * mm-highmem-makes-flush_all_zero_pkmaps-return-index-of-last-flushed-entry.patch
> * mm-highmem-makes-flush_all_zero_pkmaps-return-index-of-last-flushed-entry-v2.patch
> * mm-highmem-get-virtual-address-of-the-page-using-pkmap_addr.patch
> * mm-thp-set-the-accessed-flag-for-old-pages-on-access-fault.patch
> * mm-memmap_init_zone-performance-improvement.patch
> * documentation-cgroups-memorytxt-s-mem_cgroup_charge-mem_cgroup_change_common.patch
> * mm-oom-allow-exiting-threads-to-have-access-to-memory-reserves.patch
> * memcg-make-it-possible-to-use-the-stock-for-more-than-one-page.patch
> * memcg-reclaim-when-more-than-one-page-needed.patch
> * memcg-change-defines-to-an-enum.patch
> * memcg-kmem-accounting-basic-infrastructure.patch
> * mm-add-a-__gfp_kmemcg-flag.patch
> * memcg-kmem-controller-infrastructure.patch
> * mm-allocate-kernel-pages-to-the-right-memcg.patch
> * res_counter-return-amount-of-charges-after-res_counter_uncharge.patch
> * memcg-kmem-accounting-lifecycle-management.patch
> * memcg-use-static-branches-when-code-not-in-use.patch
> * memcg-allow-a-memcg-with-kmem-charges-to-be-destructed.patch
> * memcg-execute-the-whole-memcg-freeing-in-free_worker.patch
> * fork-protect-architectures-where-thread_size-=-page_size-against-fork-bombs.patch
> * memcg-add-documentation-about-the-kmem-controller.patch
> * slab-slub-struct-memcg_params.patch
> * slab-annotate-on-slab-caches-nodelist-locks.patch
> * slab-slub-consider-a-memcg-parameter-in-kmem_create_cache.patch
> * memcg-allocate-memory-for-memcg-caches-whenever-a-new-memcg-appears.patch
> * memcg-infrastructure-to-match-an-allocation-to-the-right-cache.patch
> * memcg-skip-memcg-kmem-allocations-in-specified-code-regions.patch
> * slb-always-get-the-cache-from-its-page-in-kmem_cache_free.patch
> * slb-allocate-objects-from-memcg-cache.patch
> * memcg-destroy-memcg-caches.patch
> * memcg-slb-track-all-the-memcg-children-of-a-kmem_cache.patch
> * memcg-slb-shrink-dead-caches.patch
> * memcg-aggregate-memcg-cache-values-in-slabinfo.patch
> * slab-propagate-tunable-values.patch
> * slub-slub-specific-propagation-changes.patch
> * slub-slub-specific-propagation-changes-fix.patch
> * kmem-add-slab-specific-documentation-about-the-kmem-controller.patch
> * dmapool-make-dmapool_debug-detect-corruption-of-free-marker.patch
> * dmapool-make-dmapool_debug-detect-corruption-of-free-marker-fix.patch
> * hwpoison-fix-action_result-to-print-out-dirty-clean.patch
> * mm-print-out-information-of-file-affected-by-memory-error.patch
> * mm-support-more-pagesizes-for-map_hugetlb-shm_hugetlb-v7.patch
> * mm-support-more-pagesizes-for-map_hugetlb-shm_hugetlb-v7-fix.patch
> * mm-support-more-pagesizes-for-map_hugetlb-shm_hugetlb-v7-fix-fix.patch
> * selftests-add-a-test-program-for-variable-huge-page-sizes-in-mmap-shmget.patch
> * mm-augment-vma-rbtree-with-rb_subtree_gap.patch
> * mm-check-rb_subtree_gap-correctness.patch
> * mm-check-rb_subtree_gap-correctness-fix.patch
> * mm-rearrange-vm_area_struct-for-fewer-cache-misses.patch
> * mm-rearrange-vm_area_struct-for-fewer-cache-misses-checkpatch-fixes.patch
> * mm-vm_unmapped_area-lookup-function.patch
> * mm-vm_unmapped_area-lookup-function-checkpatch-fixes.patch
> * mm-use-vm_unmapped_area-on-x86_64-architecture.patch
> * mm-fix-cache-coloring-on-x86_64-architecture.patch
> * mm-use-vm_unmapped_area-in-hugetlbfs.patch
> * mm-use-vm_unmapped_area-in-hugetlbfs-on-i386-architecture.patch
> * mm-use-vm_unmapped_area-on-mips-architecture.patch
> * mm-use-vm_unmapped_area-on-mips-architecture-fix.patch
> * mm-use-vm_unmapped_area-on-arm-architecture.patch
> * mm-use-vm_unmapped_area-on-arm-architecture-fix.patch
> * mm-use-vm_unmapped_area-on-sh-architecture.patch
> * mm-use-vm_unmapped_area-on-sh-architecture-fix.patch
> * mm-use-vm_unmapped_area-on-sparc64-architecture.patch
> * mm-use-vm_unmapped_area-on-sparc64-architecture-fix.patch
> * mm-use-vm_unmapped_area-in-hugetlbfs-on-sparc64-architecture.patch
> * mm-use-vm_unmapped_area-on-sparc32-architecture.patch
> * mm-use-vm_unmapped_area-in-hugetlbfs-on-tile-architecture.patch
> * mm-vmscanc-try_to_freeze-returns-boolean.patch
> * mm-mempolicy-remove-duplicate-code.patch
> * mm-adjust-address_space_operationsmigratepage-return-code.patch
> * mm-adjust-address_space_operationsmigratepage-return-code-fix.patch
> * mm-redefine-address_spaceassoc_mapping.patch
> * mm-introduce-a-common-interface-for-balloon-pages-mobility.patch
> * mm-introduce-a-common-interface-for-balloon-pages-mobility-fix.patch
> * mm-introduce-a-common-interface-for-balloon-pages-mobility-fix-fix.patch
> * mm-introduce-compaction-and-migration-for-ballooned-pages.patch
> * virtio_balloon-introduce-migration-primitives-to-balloon-pages.patch
> * mm-introduce-putback_movable_pages.patch
> * mm-add-vm-event-counters-for-balloon-pages-compaction.patch
> * mm-fix-slabc-kernel-doc-warnings.patch
> * mm-cleanup-register_node.patch
> * mm-oom-change-type-of-oom_score_adj-to-short.patch
> * mm-oom-fix-race-when-specifying-a-thread-as-the-oom-origin.patch
> * mm-cma-skip-watermarks-check-for-already-isolated-blocks-in-split_free_page.patch
> * mm-cma-remove-watermark-hacks.patch
> * drop_caches-add-some-documentation-and-info-messsge.patch
> * drop_caches-add-some-documentation-and-info-messsge-checkpatch-fixes.patch
> * swap-add-a-simple-detector-for-inappropriate-swapin-readahead.patch
> * swap-add-a-simple-detector-for-inappropriate-swapin-readahead-fix.patch
> * mm-memblock-reduce-overhead-in-binary-search.patch
> * scripts-pnmtologo-fix-for-plain-pbm.patch
> * scripts-pnmtologo-fix-for-plain-pbm-checkpatch-fixes.patch
> * documentation-kernel-parameterstxt-update-mem=-options-spec-according-to-its-implementation.patch
> * include-linux-inith-use-the-stringify-operator-for-the-__define_initcall-macro.patch
> * scripts-tagssh-add-magic-for-declarations-of-popular-kernel-type.patch
> * documentation-remove-reference-to-feature-removal-scheduletxt.patch
> * kernel-remove-reference-to-feature-removal-scheduletxt.patch
> * sound-remove-reference-to-feature-removal-scheduletxt.patch
> * drivers-remove-reference-to-feature-removal-scheduletxt.patch
> * backlight-da903x_bl-use-dev_get_drvdata-instead-of-platform_get_drvdata.patch
> * backlight-88pm860x_bl-fix-checkpatch-warning.patch
> * backlight-atmel-pwm-bl-fix-checkpatch-warning.patch
> * backlight-corgi_lcd-fix-checkpatch-error-and-warning.patch
> * backlight-da903x_bl-fix-checkpatch-warning.patch
> * backlight-generic_bl-fix-checkpatch-warning.patch
> * backlight-hp680_bl-fix-checkpatch-error-and-warning.patch
> * backlight-ili9320-fix-checkpatch-error-and-warning.patch
> * backlight-jornada720-fix-checkpatch-error-and-warning.patch
> * backlight-l4f00242t03-fix-checkpatch-warning.patch
> * backlight-lm3630-fix-checkpatch-warning.patch
> * backlight-locomolcd-fix-checkpatch-error-and-warning.patch
> * backlight-omap1-fix-checkpatch-warning.patch
> * backlight-pcf50633-fix-checkpatch-warning.patch
> * backlight-platform_lcd-fix-checkpatch-error.patch
> * backlight-tdo24m-fix-checkpatch-warning.patch
> * backlight-tosa-fix-checkpatch-error-and-warning.patch
> * backlight-vgg2432a4-fix-checkpatch-warning.patch
> * backlight-lms283gf05-use-devm_gpio_request_one.patch
> * backlight-tosa-use-devm_gpio_request_one.patch
> * drivers-video-backlight-lp855x_blc-use-generic-pwm-functions.patch
> * drivers-video-backlight-lp855x_blc-use-generic-pwm-functions-fix.patch
> * drivers-video-backlight-lp855x_blc-remove-unnecessary-mutex-code.patch
> * drivers-video-backlight-da9052_blc-add-missing-const.patch
> * drivers-video-backlight-lms283gf05c-add-missing-const.patch
> * drivers-video-backlight-tdo24mc-add-missing-const.patch
> * drivers-video-backlight-vgg2432a4c-add-missing-const.patch
> * drivers-video-backlight-s6e63m0c-remove-unnecessary-cast-of-void-pointer.patch
> * drivers-video-backlight-88pm860x_blc-drop-devm_kfree-of-devm_kzallocd-data.patch
> * drivers-video-backlight-max8925_blc-drop-devm_kfree-of-devm_kzallocd-data.patch
> * drivers-video-backlight-lm3639_blc-fix-up-world-writable-sysfs-file.patch
> * drivers-video-backlight-ep93xx_blc-fix-section-mismatch.patch
> * drivers-video-backlight-hp680_blc-add-missing-__devexit-macros-for-remove.patch
> * drivers-video-backlight-ili9320c-add-missing-__devexit-macros-for-remove.patch
> * string-introduce-helper-to-get-base-file-name-from-given-path.patch
> * lib-dynamic_debug-use-kbasename.patch
> * mm-use-kbasename.patch
> * procfs-use-kbasename.patch
> * procfs-use-kbasename-fix.patch
> * trace-use-kbasename.patch
> * drivers-of-fdtc-re-use-kernels-kbasename.patch
> * sscanf-dont-ignore-field-widths-for-numeric-conversions.patch
> * percpu_rw_semaphore-reimplement-to-not-block-the-readers-unnecessarily.patch
> * compat-generic-compat_sys_sched_rr_get_interval-implementation.patch
> * drivers-firmware-dmi_scanc-check-dmi-version-when-get-system-uuid.patch
> * drivers-firmware-dmi_scanc-check-dmi-version-when-get-system-uuid-fix.patch
> * drivers-firmware-dmi_scanc-fetch-dmi-version-from-smbios-if-it-exists.patch
> * drivers-firmware-dmi_scanc-fetch-dmi-version-from-smbios-if-it-exists-checkpatch-fixes.patch
> * checkpatch-warn-on-unnecessary-line-continuations.patch
> * epoll-support-for-disabling-items-and-a-self-test-app.patch
> * binfmt_elf-fix-corner-case-kfree-of-uninitialized-data.patch
> * binfmt_elf-fix-corner-case-kfree-of-uninitialized-data-checkpatch-fixes.patch
> * rtc-omap-kicker-mechanism-support.patch
> * arm-davinci-remove-rtc-kicker-release.patch
> * rtc-omap-dt-support.patch
> * rtc-omap-depend-on-am33xx.patch
> * rtc-omap-add-runtime-pm-support.patch
> * rtc-imxdi-support-for-imx53.patch
> * rtc-imxdi-add-devicetree-support.patch
> * arm-mach-imx-support-for-dryice-rtc-in-imx53.patch
> * drivers-rtc-rtc-vt8500c-convert-to-use-devm_kzalloc.patch
> * rtc-avoid-calling-platform_device_put-twice-in-test_init.patch
> * rtc-avoid-calling-platform_device_put-twice-in-test_init-fix.patch
> * rtc-rtc-spear-use-devm_-routines.patch
> * rtc-rtc-spear-add-clk_unprepare-support.patch
> * rtc-rtc-spear-provide-flag-for-no-support-of-uie-mode.patch
> * hfsplus-add-on-disk-layout-declarations-related-to-attributes-tree.patch
> * hfsplus-add-functionality-of-manipulating-by-records-in-attributes-tree.patch
> * hfsplus-rework-functionality-of-getting-setting-and-deleting-of-extended-attributes.patch
> * hfsplus-add-support-of-manipulation-by-attributes-file.patch
> * hfsplus-add-support-of-manipulation-by-attributes-file-checkpatch-fixes.patch
> * hfsplus-code-style-fixes-reworked-support-of-extended-attributes.patch
> * documentation-dma-api-howtotxt-minor-grammar-corrections.patch
> * documentation-fixed-documentation-security-00-index.patch
> * kstrto-add-documentation.patch
> * simple_strto-annotate-function-as-obsolete.patch
> * proc-dont-show-nonexistent-capabilities.patch
> * procfs-add-vmflags-field-in-smaps-output-v4.patch
> * procfs-add-vmflags-field-in-smaps-output-v4-fix.patch
> * proc-pid-status-add-seccomp-field.patch
> * fork-unshare-remove-dead-code.patch
> * ipc-remove-forced-assignment-of-selected-message.patch
> * ipc-add-sysctl-to-specify-desired-next-object-id.patch
> * ipc-add-sysctl-to-specify-desired-next-object-id-checkpatch-fixes.patch
> * ipc-add-sysctl-to-specify-desired-next-object-id-wrap-new-sysctls-for-criu-inside-config_checkpoint_restore.patch
> * ipc-add-sysctl-to-specify-desired-next-object-id-documentation-update-sysctl-kerneltxt.patch
> * ipc-message-queue-receive-cleanup.patch
> * ipc-message-queue-receive-cleanup-checkpatch-fixes.patch
> * ipc-message-queue-copy-feature-introduced.patch
> * ipc-message-queue-copy-feature-introduced-remove-redundant-msg_copy-check.patch
> * ipc-message-queue-copy-feature-introduced-cleanup-do_msgrcv-aroung-msg_copy-feature.patch
> * selftests-ipc-message-queue-copy-feature-test.patch
> * selftests-ipc-message-queue-copy-feature-test-update.patch
> * ipc-simplify-free_copy-call.patch
> * ipc-convert-prepare_copy-from-macro-to-function.patch
> * ipc-convert-prepare_copy-from-macro-to-function-fix.patch
> * ipc-simplify-message-copying.patch
> * ipc-add-more-comments-to-message-copying-related-code.patch
> * ipc-semc-alternatives-to-preempt_disable.patch
> * binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
> * binfmt_elfc-use-get_random_int-to-fix-entropy-depleting-fix.patch
> * linux-compilerh-add-__must_hold-macro-for-functions-called-with-a-lock-held.patch
> * documentation-sparsetxt-document-context-annotations-for-lock-checking.patch
> * aoe-describe-the-behavior-of-the-err-character-device.patch
> * aoe-print-warning-regarding-a-common-reason-for-dropped-transmits.patch
> * aoe-print-warning-regarding-a-common-reason-for-dropped-transmits-v2.patch
> * aoe-print-warning-regarding-a-common-reason-for-dropped-transmits-fix.patch
> * aoe-update-cap-on-outstanding-commands-based-on-config-query-response.patch
> * aoe-support-the-forgetting-flushing-of-a-user-specified-aoe-target.patch
> * aoe-support-larger-i-o-requests-via-aoe_maxsectors-module-param.patch
> * aoe-payload-sysfs-file-exports-per-aoe-command-data-transfer-size.patch
> * aoe-cleanup-remove-unused-ata_scnt-function.patch
> * aoe-whitespace-cleanup.patch
> * aoe-update-driver-internal-version-number-to-60.patch
> * aoe-avoid-running-request-handler-on-plugged-queue.patch
> * aoe-provide-ata-identify-device-content-to-user-on-request.patch
> * aoe-improve-network-congestion-handling.patch
> * aoe-err-device-include-mac-addresses-for-unexpected-responses.patch
> * aoe-manipulate-aoedev-network-stats-under-lock.patch
> * aoe-use-high-resolution-rtts-with-fallback-to-low-res.patch
> * aoe-commands-in-retransmit-queue-use-new-destination-on-failure.patch
> * aoe-update-driver-internal-version-to-64.patch
> * dma-debug-new-interfaces-to-debug-dma-mapping-errors-fix-fix.patch
> * tools-testing-selftests-kcmp-kcmp_testc-print-reason-for-failure-in-kcmp_test.patch
>   make-sure-nobodys-leaking-resources.patch
>   journal_add_journal_head-debug.patch
>   releasing-resources-with-children.patch
>   make-frame_pointer-default=y.patch
>   kernel-forkc-export-kernel_thread-to-modules.patch
>   mutex-subsystem-synchro-test-module.patch
>   mutex-subsystem-synchro-test-module-fix.patch
>   mutex-subsystem-synchro-test-module-fix-2.patch
>   mutex-subsystem-synchro-test-module-fix-3.patch
>   slab-leaks3-default-y.patch
>   put_bh-debug.patch
>   add-debugging-aid-for-memory-initialisation-problems.patch
>   workaround-for-a-pci-restoring-bug.patch
>   single_open-seq_release-leak-diagnostics.patch
>   add-a-refcount-check-in-dput.patch
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



on x86_64:

In file included from mm/mprotect.c:13:0:
include/linux/shm.h:57:20: error: redefinition of 'do_shmat'
include/linux/shm.h:57:20: note: previous definition of 'do_shmat' was here
include/linux/shm.h:63:19: error: redefinition of 'is_file_shm_hugepages'
include/linux/shm.h:63:19: note: previous definition of 'is_file_shm_hugepages' was here
include/linux/shm.h:67:20: error: redefinition of 'exit_shm'
include/linux/shm.h:67:20: note: previous definition of 'exit_shm' was here

In file included from include/linux/hugetlb.h:16:0,
                 from mm/mmap.c:23:
include/linux/shm.h:57:20: error: redefinition of 'do_shmat'
include/linux/shm.h:57:20: note: previous definition of 'do_shmat' was here
include/linux/shm.h:63:19: error: redefinition of 'is_file_shm_hugepages'
include/linux/shm.h:63:19: note: previous definition of 'is_file_shm_hugepages' was here
include/linux/shm.h:67:20: error: redefinition of 'exit_shm'
include/linux/shm.h:67:20: note: previous definition of 'exit_shm' was here
make[2]: *** [mm/mprotect.o] Error 1


Full randconfig file is attached.

-- 
~Randy

--------------040206060302080906000102
Content-Type: text/plain;
 name="config-r8641"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="config-r8641"

IwojIEF1dG9tYXRpY2FsbHkgZ2VuZXJhdGVkIGZpbGU7IERPIE5PVCBFRElULgojIExpbnV4
L3g4Nl82NCAzLjcuMC1yYzQtbW0xIEtlcm5lbCBDb25maWd1cmF0aW9uCiMKQ09ORklHXzY0
QklUPXkKQ09ORklHX1g4Nl82ND15CkNPTkZJR19YODY9eQpDT05GSUdfSU5TVFJVQ1RJT05f
REVDT0RFUj15CkNPTkZJR19PVVRQVVRfRk9STUFUPSJlbGY2NC14ODYtNjQiCkNPTkZJR19B
UkNIX0RFRkNPTkZJRz0iYXJjaC94ODYvY29uZmlncy94ODZfNjRfZGVmY29uZmlnIgpDT05G
SUdfTE9DS0RFUF9TVVBQT1JUPXkKQ09ORklHX1NUQUNLVFJBQ0VfU1VQUE9SVD15CkNPTkZJ
R19IQVZFX0xBVEVOQ1lUT1BfU1VQUE9SVD15CkNPTkZJR19NTVU9eQpDT05GSUdfTkVFRF9E
TUFfTUFQX1NUQVRFPXkKQ09ORklHX05FRURfU0dfRE1BX0xFTkdUSD15CkNPTkZJR19HRU5F
UklDX0JVRz15CkNPTkZJR19HRU5FUklDX0JVR19SRUxBVElWRV9QT0lOVEVSUz15CkNPTkZJ
R19HRU5FUklDX0hXRUlHSFQ9eQpDT05GSUdfUldTRU1fWENIR0FERF9BTEdPUklUSE09eQpD
T05GSUdfR0VORVJJQ19DQUxJQlJBVEVfREVMQVk9eQpDT05GSUdfQVJDSF9IQVNfQ1BVX1JF
TEFYPXkKQ09ORklHX0FSQ0hfSEFTX0RFRkFVTFRfSURMRT15CkNPTkZJR19BUkNIX0hBU19D
QUNIRV9MSU5FX1NJWkU9eQpDT05GSUdfQVJDSF9IQVNfQ1BVX0FVVE9QUk9CRT15CkNPTkZJ
R19IQVZFX1NFVFVQX1BFUl9DUFVfQVJFQT15CkNPTkZJR19ORUVEX1BFUl9DUFVfRU1CRURf
RklSU1RfQ0hVTks9eQpDT05GSUdfTkVFRF9QRVJfQ1BVX1BBR0VfRklSU1RfQ0hVTks9eQpD
T05GSUdfQVJDSF9ISUJFUk5BVElPTl9QT1NTSUJMRT15CkNPTkZJR19BUkNIX1NVU1BFTkRf
UE9TU0lCTEU9eQpDT05GSUdfWk9ORV9ETUEzMj15CkNPTkZJR19BVURJVF9BUkNIPXkKQ09O
RklHX0FSQ0hfU1VQUE9SVFNfT1BUSU1JWkVEX0lOTElOSU5HPXkKQ09ORklHX0FSQ0hfU1VQ
UE9SVFNfREVCVUdfUEFHRUFMTE9DPXkKQ09ORklHX1g4Nl82NF9TTVA9eQpDT05GSUdfWDg2
X0hUPXkKQ09ORklHX0FSQ0hfSFdFSUdIVF9DRkxBR1M9Ii1mY2FsbC1zYXZlZC1yZGkgLWZj
YWxsLXNhdmVkLXJzaSAtZmNhbGwtc2F2ZWQtcmR4IC1mY2FsbC1zYXZlZC1yY3ggLWZjYWxs
LXNhdmVkLXI4IC1mY2FsbC1zYXZlZC1yOSAtZmNhbGwtc2F2ZWQtcjEwIC1mY2FsbC1zYXZl
ZC1yMTEiCkNPTkZJR19BUkNIX0NQVV9QUk9CRV9SRUxFQVNFPXkKQ09ORklHX0FSQ0hfU1VQ
UE9SVFNfVVBST0JFUz15CkNPTkZJR19ERUZDT05GSUdfTElTVD0iL2xpYi9tb2R1bGVzLyRV
TkFNRV9SRUxFQVNFLy5jb25maWciCkNPTkZJR19DT05TVFJVQ1RPUlM9eQpDT05GSUdfSEFW
RV9JUlFfV09SSz15CkNPTkZJR19JUlFfV09SSz15CkNPTkZJR19CVUlMRFRJTUVfRVhUQUJM
RV9TT1JUPXkKCiMKIyBHZW5lcmFsIHNldHVwCiMKQ09ORklHX0VYUEVSSU1FTlRBTD15CkNP
TkZJR19JTklUX0VOVl9BUkdfTElNSVQ9MzIKQ09ORklHX0NST1NTX0NPTVBJTEU9IiIKQ09O
RklHX0xPQ0FMVkVSU0lPTj0iIgojIENPTkZJR19MT0NBTFZFUlNJT05fQVVUTyBpcyBub3Qg
c2V0CkNPTkZJR19IQVZFX0tFUk5FTF9HWklQPXkKQ09ORklHX0hBVkVfS0VSTkVMX0JaSVAy
PXkKQ09ORklHX0hBVkVfS0VSTkVMX0xaTUE9eQpDT05GSUdfSEFWRV9LRVJORUxfWFo9eQpD
T05GSUdfSEFWRV9LRVJORUxfTFpPPXkKIyBDT05GSUdfS0VSTkVMX0daSVAgaXMgbm90IHNl
dApDT05GSUdfS0VSTkVMX0JaSVAyPXkKIyBDT05GSUdfS0VSTkVMX0xaTUEgaXMgbm90IHNl
dAojIENPTkZJR19LRVJORUxfWFogaXMgbm90IHNldAojIENPTkZJR19LRVJORUxfTFpPIGlz
IG5vdCBzZXQKQ09ORklHX0RFRkFVTFRfSE9TVE5BTUU9Iihub25lKSIKQ09ORklHX1NXQVA9
eQojIENPTkZJR19TWVNWSVBDIGlzIG5vdCBzZXQKIyBDT05GSUdfUE9TSVhfTVFVRVVFIGlz
IG5vdCBzZXQKIyBDT05GSUdfRkhBTkRMRSBpcyBub3Qgc2V0CiMgQ09ORklHX0FVRElUIGlz
IG5vdCBzZXQKQ09ORklHX0hBVkVfR0VORVJJQ19IQVJESVJRUz15CgojCiMgSVJRIHN1YnN5
c3RlbQojCkNPTkZJR19HRU5FUklDX0hBUkRJUlFTPXkKQ09ORklHX0dFTkVSSUNfSVJRX1BS
T0JFPXkKQ09ORklHX0dFTkVSSUNfSVJRX1NIT1c9eQpDT05GSUdfR0VORVJJQ19QRU5ESU5H
X0lSUT15CkNPTkZJR19JUlFfRE9NQUlOPXkKIyBDT05GSUdfSVJRX0RPTUFJTl9ERUJVRyBp
cyBub3Qgc2V0CkNPTkZJR19JUlFfRk9SQ0VEX1RIUkVBRElORz15CkNPTkZJR19TUEFSU0Vf
SVJRPXkKQ09ORklHX0NMT0NLU09VUkNFX1dBVENIRE9HPXkKQ09ORklHX0FSQ0hfQ0xPQ0tT
T1VSQ0VfREFUQT15CkNPTkZJR19HRU5FUklDX1RJTUVfVlNZU0NBTEw9eQpDT05GSUdfR0VO
RVJJQ19DTE9DS0VWRU5UUz15CkNPTkZJR19HRU5FUklDX0NMT0NLRVZFTlRTX0JVSUxEPXkK
Q09ORklHX0dFTkVSSUNfQ0xPQ0tFVkVOVFNfQlJPQURDQVNUPXkKQ09ORklHX0dFTkVSSUNf
Q0xPQ0tFVkVOVFNfTUlOX0FESlVTVD15CkNPTkZJR19HRU5FUklDX0NNT1NfVVBEQVRFPXkK
CiMKIyBUaW1lcnMgc3Vic3lzdGVtCiMKQ09ORklHX1RJQ0tfT05FU0hPVD15CkNPTkZJR19O
T19IWj15CiMgQ09ORklHX0hJR0hfUkVTX1RJTUVSUyBpcyBub3Qgc2V0CgojCiMgQ1BVL1Rh
c2sgdGltZSBhbmQgc3RhdHMgYWNjb3VudGluZwojCkNPTkZJR19USUNLX0NQVV9BQ0NPVU5U
SU5HPXkKIyBDT05GSUdfSVJRX1RJTUVfQUNDT1VOVElORyBpcyBub3Qgc2V0CiMgQ09ORklH
X0JTRF9QUk9DRVNTX0FDQ1QgaXMgbm90IHNldAojIENPTkZJR19UQVNLU1RBVFMgaXMgbm90
IHNldAoKIwojIFJDVSBTdWJzeXN0ZW0KIwpDT05GSUdfVFJFRV9SQ1U9eQojIENPTkZJR19Q
UkVFTVBUX1JDVSBpcyBub3Qgc2V0CiMgQ09ORklHX1JDVV9VU0VSX1FTIGlzIG5vdCBzZXQK
Q09ORklHX1JDVV9GQU5PVVQ9NjQKQ09ORklHX1JDVV9GQU5PVVRfTEVBRj0xNgojIENPTkZJ
R19SQ1VfRkFOT1VUX0VYQUNUIGlzIG5vdCBzZXQKIyBDT05GSUdfUkNVX0ZBU1RfTk9fSFog
aXMgbm90IHNldApDT05GSUdfVFJFRV9SQ1VfVFJBQ0U9eQojIENPTkZJR19JS0NPTkZJRyBp
cyBub3Qgc2V0CkNPTkZJR19MT0dfQlVGX1NISUZUPTE3CkNPTkZJR19IQVZFX1VOU1RBQkxF
X1NDSEVEX0NMT0NLPXkKQ09ORklHX0NHUk9VUFM9eQojIENPTkZJR19DR1JPVVBfREVCVUcg
aXMgbm90IHNldAojIENPTkZJR19DR1JPVVBfRlJFRVpFUiBpcyBub3Qgc2V0CkNPTkZJR19D
R1JPVVBfREVWSUNFPXkKIyBDT05GSUdfQ1BVU0VUUyBpcyBub3Qgc2V0CkNPTkZJR19DR1JP
VVBfQ1BVQUNDVD15CiMgQ09ORklHX1JFU09VUkNFX0NPVU5URVJTIGlzIG5vdCBzZXQKIyBD
T05GSUdfQ0dST1VQX1BFUkYgaXMgbm90IHNldApDT05GSUdfQ0dST1VQX1NDSEVEPXkKQ09O
RklHX0ZBSVJfR1JPVVBfU0NIRUQ9eQpDT05GSUdfQ0ZTX0JBTkRXSURUSD15CiMgQ09ORklH
X1JUX0dST1VQX1NDSEVEIGlzIG5vdCBzZXQKQ09ORklHX0JMS19DR1JPVVA9eQpDT05GSUdf
REVCVUdfQkxLX0NHUk9VUD15CiMgQ09ORklHX0NIRUNLUE9JTlRfUkVTVE9SRSBpcyBub3Qg
c2V0CiMgQ09ORklHX05BTUVTUEFDRVMgaXMgbm90IHNldApDT05GSUdfU0NIRURfQVVUT0dS
T1VQPXkKQ09ORklHX1NZU0ZTX0RFUFJFQ0FURUQ9eQpDT05GSUdfU1lTRlNfREVQUkVDQVRF
RF9WMj15CiMgQ09ORklHX1JFTEFZIGlzIG5vdCBzZXQKQ09ORklHX0JMS19ERVZfSU5JVFJE
PXkKQ09ORklHX0lOSVRSQU1GU19TT1VSQ0U9IiIKIyBDT05GSUdfUkRfR1pJUCBpcyBub3Qg
c2V0CiMgQ09ORklHX1JEX0JaSVAyIGlzIG5vdCBzZXQKQ09ORklHX1JEX0xaTUE9eQojIENP
TkZJR19SRF9YWiBpcyBub3Qgc2V0CiMgQ09ORklHX1JEX0xaTyBpcyBub3Qgc2V0CkNPTkZJ
R19DQ19PUFRJTUlaRV9GT1JfU0laRT15CkNPTkZJR19BTk9OX0lOT0RFUz15CkNPTkZJR19F
WFBFUlQ9eQpDT05GSUdfSEFWRV9VSUQxNj15CkNPTkZJR19VSUQxNj15CkNPTkZJR19TWVND
VExfRVhDRVBUSU9OX1RSQUNFPXkKQ09ORklHX0tBTExTWU1TPXkKQ09ORklHX0tBTExTWU1T
X0FMTD15CkNPTkZJR19IT1RQTFVHPXkKIyBDT05GSUdfUFJJTlRLIGlzIG5vdCBzZXQKQ09O
RklHX0JVRz15CkNPTkZJR19FTEZfQ09SRT15CkNPTkZJR19QQ1NQS1JfUExBVEZPUk09eQpD
T05GSUdfSEFWRV9QQ1NQS1JfUExBVEZPUk09eQojIENPTkZJR19CQVNFX0ZVTEwgaXMgbm90
IHNldApDT05GSUdfRlVURVg9eQojIENPTkZJR19FUE9MTCBpcyBub3Qgc2V0CiMgQ09ORklH
X1NJR05BTEZEIGlzIG5vdCBzZXQKQ09ORklHX1RJTUVSRkQ9eQpDT05GSUdfRVZFTlRGRD15
CiMgQ09ORklHX1NITUVNIGlzIG5vdCBzZXQKIyBDT05GSUdfQUlPIGlzIG5vdCBzZXQKQ09O
RklHX0VNQkVEREVEPXkKQ09ORklHX0hBVkVfUEVSRl9FVkVOVFM9eQoKIwojIEtlcm5lbCBQ
ZXJmb3JtYW5jZSBFdmVudHMgQW5kIENvdW50ZXJzCiMKQ09ORklHX1BFUkZfRVZFTlRTPXkK
IyBDT05GSUdfREVCVUdfUEVSRl9VU0VfVk1BTExPQyBpcyBub3Qgc2V0CiMgQ09ORklHX1ZN
X0VWRU5UX0NPVU5URVJTIGlzIG5vdCBzZXQKIyBDT05GSUdfUENJX1FVSVJLUyBpcyBub3Qg
c2V0CiMgQ09ORklHX1NMVUJfREVCVUcgaXMgbm90IHNldApDT05GSUdfQ09NUEFUX0JSSz15
CiMgQ09ORklHX1NMQUIgaXMgbm90IHNldApDT05GSUdfU0xVQj15CiMgQ09ORklHX1NMT0Ig
aXMgbm90IHNldAojIENPTkZJR19QUk9GSUxJTkcgaXMgbm90IHNldApDT05GSUdfSEFWRV9P
UFJPRklMRT15CkNPTkZJR19PUFJPRklMRV9OTUlfVElNRVI9eQpDT05GSUdfSlVNUF9MQUJF
TD15CkNPTkZJR19IQVZFX0VGRklDSUVOVF9VTkFMSUdORURfQUNDRVNTPXkKQ09ORklHX0hB
VkVfSU9SRU1BUF9QUk9UPXkKQ09ORklHX0hBVkVfS1BST0JFUz15CkNPTkZJR19IQVZFX0tS
RVRQUk9CRVM9eQpDT05GSUdfSEFWRV9PUFRQUk9CRVM9eQpDT05GSUdfSEFWRV9BUkNIX1RS
QUNFSE9PSz15CkNPTkZJR19IQVZFX0RNQV9BVFRSUz15CkNPTkZJR19VU0VfR0VORVJJQ19T
TVBfSEVMUEVSUz15CkNPTkZJR19HRU5FUklDX1NNUF9JRExFX1RIUkVBRD15CkNPTkZJR19I
QVZFX1JFR1NfQU5EX1NUQUNLX0FDQ0VTU19BUEk9eQpDT05GSUdfSEFWRV9ETUFfQVBJX0RF
QlVHPXkKQ09ORklHX0hBVkVfSFdfQlJFQUtQT0lOVD15CkNPTkZJR19IQVZFX01JWEVEX0JS
RUFLUE9JTlRTX1JFR1M9eQpDT05GSUdfSEFWRV9VU0VSX1JFVFVSTl9OT1RJRklFUj15CkNP
TkZJR19IQVZFX1BFUkZfRVZFTlRTX05NST15CkNPTkZJR19IQVZFX1BFUkZfUkVHUz15CkNP
TkZJR19IQVZFX1BFUkZfVVNFUl9TVEFDS19EVU1QPXkKQ09ORklHX0hBVkVfQVJDSF9KVU1Q
X0xBQkVMPXkKQ09ORklHX0FSQ0hfSEFWRV9OTUlfU0FGRV9DTVBYQ0hHPXkKQ09ORklHX0hB
VkVfQUxJR05FRF9TVFJVQ1RfUEFHRT15CkNPTkZJR19IQVZFX0NNUFhDSEdfTE9DQUw9eQpD
T05GSUdfSEFWRV9DTVBYQ0hHX0RPVUJMRT15CkNPTkZJR19BUkNIX1dBTlRfQ09NUEFUX0lQ
Q19QQVJTRV9WRVJTSU9OPXkKQ09ORklHX0FSQ0hfV0FOVF9PTERfQ09NUEFUX0lQQz15CkNP
TkZJR19HRU5FUklDX0tFUk5FTF9USFJFQUQ9eQpDT05GSUdfR0VORVJJQ19LRVJORUxfRVhF
Q1ZFPXkKQ09ORklHX0hBVkVfQVJDSF9TRUNDT01QX0ZJTFRFUj15CkNPTkZJR19TRUNDT01Q
X0ZJTFRFUj15CkNPTkZJR19IQVZFX1JDVV9VU0VSX1FTPXkKQ09ORklHX0hBVkVfSVJRX1RJ
TUVfQUNDT1VOVElORz15CkNPTkZJR19IQVZFX0FSQ0hfVFJBTlNQQVJFTlRfSFVHRVBBR0U9
eQpDT05GSUdfTU9EVUxFU19VU0VfRUxGX1JFTEE9eQoKIwojIEdDT1YtYmFzZWQga2VybmVs
IHByb2ZpbGluZwojCkNPTkZJR19HQ09WX0tFUk5FTD15CkNPTkZJR19HQ09WX1BST0ZJTEVf
QUxMPXkKIyBDT05GSUdfSEFWRV9HRU5FUklDX0RNQV9DT0hFUkVOVCBpcyBub3Qgc2V0CkNP
TkZJR19SVF9NVVRFWEVTPXkKQ09ORklHX0JBU0VfU01BTEw9MQojIENPTkZJR19NT0RVTEVT
IGlzIG5vdCBzZXQKQ09ORklHX1NUT1BfTUFDSElORT15CkNPTkZJR19CTE9DSz15CkNPTkZJ
R19CTEtfREVWX0JTRz15CkNPTkZJR19CTEtfREVWX0JTR0xJQj15CiMgQ09ORklHX0JMS19E
RVZfSU5URUdSSVRZIGlzIG5vdCBzZXQKQ09ORklHX0JMS19ERVZfVEhST1RUTElORz15Cgoj
CiMgUGFydGl0aW9uIFR5cGVzCiMKQ09ORklHX1BBUlRJVElPTl9BRFZBTkNFRD15CkNPTkZJ
R19BQ09STl9QQVJUSVRJT049eQpDT05GSUdfQUNPUk5fUEFSVElUSU9OX0NVTUFOQT15CiMg
Q09ORklHX0FDT1JOX1BBUlRJVElPTl9FRVNPWCBpcyBub3Qgc2V0CkNPTkZJR19BQ09STl9Q
QVJUSVRJT05fSUNTPXkKQ09ORklHX0FDT1JOX1BBUlRJVElPTl9BREZTPXkKIyBDT05GSUdf
QUNPUk5fUEFSVElUSU9OX1BPV0VSVEVDIGlzIG5vdCBzZXQKQ09ORklHX0FDT1JOX1BBUlRJ
VElPTl9SSVNDSVg9eQojIENPTkZJR19PU0ZfUEFSVElUSU9OIGlzIG5vdCBzZXQKIyBDT05G
SUdfQU1JR0FfUEFSVElUSU9OIGlzIG5vdCBzZXQKIyBDT05GSUdfQVRBUklfUEFSVElUSU9O
IGlzIG5vdCBzZXQKIyBDT05GSUdfTUFDX1BBUlRJVElPTiBpcyBub3Qgc2V0CiMgQ09ORklH
X01TRE9TX1BBUlRJVElPTiBpcyBub3Qgc2V0CkNPTkZJR19MRE1fUEFSVElUSU9OPXkKQ09O
RklHX0xETV9ERUJVRz15CiMgQ09ORklHX1NHSV9QQVJUSVRJT04gaXMgbm90IHNldAojIENP
TkZJR19VTFRSSVhfUEFSVElUSU9OIGlzIG5vdCBzZXQKQ09ORklHX1NVTl9QQVJUSVRJT049
eQpDT05GSUdfS0FSTUFfUEFSVElUSU9OPXkKIyBDT05GSUdfRUZJX1BBUlRJVElPTiBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NZU1Y2OF9QQVJUSVRJT04gaXMgbm90IHNldApDT05GSUdfQkxP
Q0tfQ09NUEFUPXkKCiMKIyBJTyBTY2hlZHVsZXJzCiMKQ09ORklHX0lPU0NIRURfTk9PUD15
CiMgQ09ORklHX0lPU0NIRURfREVBRExJTkUgaXMgbm90IHNldAojIENPTkZJR19JT1NDSEVE
X0NGUSBpcyBub3Qgc2V0CkNPTkZJR19ERUZBVUxUX05PT1A9eQpDT05GSUdfREVGQVVMVF9J
T1NDSEVEPSJub29wIgpDT05GSUdfUEFEQVRBPXkKQ09ORklHX1VOSU5MSU5FX1NQSU5fVU5M
T0NLPXkKQ09ORklHX0ZSRUVaRVI9eQoKIwojIFByb2Nlc3NvciB0eXBlIGFuZCBmZWF0dXJl
cwojCkNPTkZJR19aT05FX0RNQT15CkNPTkZJR19TTVA9eQojIENPTkZJR19YODZfTVBQQVJT
RSBpcyBub3Qgc2V0CkNPTkZJR19YODZfRVhURU5ERURfUExBVEZPUk09eQpDT05GSUdfWDg2
X1ZTTVA9eQojIENPTkZJR19TQ0hFRF9PTUlUX0ZSQU1FX1BPSU5URVIgaXMgbm90IHNldAoj
IENPTkZJR19LVk1UT09MX1RFU1RfRU5BQkxFIGlzIG5vdCBzZXQKQ09ORklHX1BBUkFWSVJU
X0dVRVNUPXkKIyBDT05GSUdfUEFSQVZJUlRfVElNRV9BQ0NPVU5USU5HIGlzIG5vdCBzZXQK
Q09ORklHX1hFTj15CkNPTkZJR19YRU5fRE9NMD15CkNPTkZJR19YRU5fUFJJVklMRUdFRF9H
VUVTVD15CkNPTkZJR19YRU5fUFZIVk09eQpDT05GSUdfWEVOX01BWF9ET01BSU5fTUVNT1JZ
PTUwMApDT05GSUdfWEVOX1NBVkVfUkVTVE9SRT15CkNPTkZJR19YRU5fREVCVUdfRlM9eQoj
IENPTkZJR19YRU5fWDg2X1BWSCBpcyBub3Qgc2V0CkNPTkZJR19LVk1fR1VFU1Q9eQpDT05G
SUdfUEFSQVZJUlQ9eQpDT05GSUdfUEFSQVZJUlRfU1BJTkxPQ0tTPXkKQ09ORklHX1BBUkFW
SVJUX0NMT0NLPXkKQ09ORklHX1BBUkFWSVJUX0RFQlVHPXkKQ09ORklHX05PX0JPT1RNRU09
eQpDT05GSUdfTUVNVEVTVD15CiMgQ09ORklHX01LOCBpcyBub3Qgc2V0CiMgQ09ORklHX01Q
U0MgaXMgbm90IHNldAojIENPTkZJR19NQ09SRTIgaXMgbm90IHNldAojIENPTkZJR19NQVRP
TSBpcyBub3Qgc2V0CkNPTkZJR19HRU5FUklDX0NQVT15CkNPTkZJR19YODZfSU5URVJOT0RF
X0NBQ0hFX1NISUZUPTEyCkNPTkZJR19YODZfQ01QWENIRz15CkNPTkZJR19YODZfTDFfQ0FD
SEVfU0hJRlQ9NgpDT05GSUdfWDg2X1hBREQ9eQpDT05GSUdfWDg2X1dQX1dPUktTX09LPXkK
Q09ORklHX1g4Nl9UU0M9eQpDT05GSUdfWDg2X0NNUFhDSEc2ND15CkNPTkZJR19YODZfQ01P
Vj15CkNPTkZJR19YODZfTUlOSU1VTV9DUFVfRkFNSUxZPTY0CkNPTkZJR19YODZfREVCVUdD
VExNU1I9eQpDT05GSUdfUFJPQ0VTU09SX1NFTEVDVD15CiMgQ09ORklHX0NQVV9TVVBfSU5U
RUwgaXMgbm90IHNldAojIENPTkZJR19DUFVfU1VQX0FNRCBpcyBub3Qgc2V0CkNPTkZJR19D
UFVfU1VQX0NFTlRBVVI9eQpDT05GSUdfSFBFVF9USU1FUj15CkNPTkZJR19IUEVUX0VNVUxB
VEVfUlRDPXkKIyBDT05GSUdfRE1JIGlzIG5vdCBzZXQKQ09ORklHX0NBTEdBUllfSU9NTVU9
eQpDT05GSUdfQ0FMR0FSWV9JT01NVV9FTkFCTEVEX0JZX0RFRkFVTFQ9eQpDT05GSUdfU1dJ
T1RMQj15CkNPTkZJR19JT01NVV9IRUxQRVI9eQojIENPTkZJR19NQVhTTVAgaXMgbm90IHNl
dApDT05GSUdfTlJfQ1BVUz04CiMgQ09ORklHX1NDSEVEX1NNVCBpcyBub3Qgc2V0CkNPTkZJ
R19TQ0hFRF9NQz15CkNPTkZJR19QUkVFTVBUX05PTkU9eQojIENPTkZJR19QUkVFTVBUX1ZP
TFVOVEFSWSBpcyBub3Qgc2V0CiMgQ09ORklHX1BSRUVNUFQgaXMgbm90IHNldApDT05GSUdf
WDg2X0xPQ0FMX0FQSUM9eQpDT05GSUdfWDg2X0lPX0FQSUM9eQpDT05GSUdfWDg2X1JFUk9V
VEVfRk9SX0JST0tFTl9CT09UX0lSUVM9eQojIENPTkZJR19YODZfTUNFIGlzIG5vdCBzZXQK
Q09ORklHX0k4Sz15CiMgQ09ORklHX01JQ1JPQ09ERSBpcyBub3Qgc2V0CiMgQ09ORklHX1g4
Nl9NU1IgaXMgbm90IHNldApDT05GSUdfWDg2X0NQVUlEPXkKQ09ORklHX0FSQ0hfUEhZU19B
RERSX1RfNjRCSVQ9eQpDT05GSUdfQVJDSF9ETUFfQUREUl9UXzY0QklUPXkKIyBDT05GSUdf
RElSRUNUX0dCUEFHRVMgaXMgbm90IHNldAojIENPTkZJR19OVU1BIGlzIG5vdCBzZXQKQ09O
RklHX0FSQ0hfU1BBUlNFTUVNX0VOQUJMRT15CkNPTkZJR19BUkNIX1NQQVJTRU1FTV9ERUZB
VUxUPXkKQ09ORklHX0FSQ0hfU0VMRUNUX01FTU9SWV9NT0RFTD15CkNPTkZJR19BUkNIX01F
TU9SWV9QUk9CRT15CkNPTkZJR19JTExFR0FMX1BPSU5URVJfVkFMVUU9MHhkZWFkMDAwMDAw
MDAwMDAwCkNPTkZJR19TRUxFQ1RfTUVNT1JZX01PREVMPXkKQ09ORklHX1NQQVJTRU1FTV9N
QU5VQUw9eQpDT05GSUdfU1BBUlNFTUVNPXkKQ09ORklHX0hBVkVfTUVNT1JZX1BSRVNFTlQ9
eQpDT05GSUdfU1BBUlNFTUVNX0VYVFJFTUU9eQpDT05GSUdfU1BBUlNFTUVNX1ZNRU1NQVBf
RU5BQkxFPXkKQ09ORklHX1NQQVJTRU1FTV9BTExPQ19NRU1fTUFQX1RPR0VUSEVSPXkKIyBD
T05GSUdfU1BBUlNFTUVNX1ZNRU1NQVAgaXMgbm90IHNldApDT05GSUdfSEFWRV9NRU1CTE9D
Sz15CkNPTkZJR19IQVZFX01FTUJMT0NLX05PREVfTUFQPXkKQ09ORklHX0FSQ0hfRElTQ0FS
RF9NRU1CTE9DSz15CkNPTkZJR19NRU1PUllfSVNPTEFUSU9OPXkKQ09ORklHX01FTU9SWV9I
T1RQTFVHPXkKQ09ORklHX01FTU9SWV9IT1RQTFVHX1NQQVJTRT15CiMgQ09ORklHX01FTU9S
WV9IT1RSRU1PVkUgaXMgbm90IHNldApDT05GSUdfUEFHRUZMQUdTX0VYVEVOREVEPXkKQ09O
RklHX1NQTElUX1BUTE9DS19DUFVTPTk5OTk5OQojIENPTkZJR19CQUxMT09OX0NPTVBBQ1RJ
T04gaXMgbm90IHNldApDT05GSUdfQ09NUEFDVElPTj15CkNPTkZJR19NSUdSQVRJT049eQpD
T05GSUdfUEhZU19BRERSX1RfNjRCSVQ9eQpDT05GSUdfWk9ORV9ETUFfRkxBRz0xCkNPTkZJ
R19CT1VOQ0U9eQpDT05GSUdfVklSVF9UT19CVVM9eQpDT05GSUdfS1NNPXkKQ09ORklHX0RF
RkFVTFRfTU1BUF9NSU5fQUREUj00MDk2CiMgQ09ORklHX1RSQU5TUEFSRU5UX0hVR0VQQUdF
IGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JPU1NfTUVNT1JZX0FUVEFDSCBpcyBub3Qgc2V0CkNP
TkZJR19DTEVBTkNBQ0hFPXkKQ09ORklHX0ZST05UU1dBUD15CkNPTkZJR19YODZfQ0hFQ0tf
QklPU19DT1JSVVBUSU9OPXkKIyBDT05GSUdfWDg2X0JPT1RQQVJBTV9NRU1PUllfQ09SUlVQ
VElPTl9DSEVDSyBpcyBub3Qgc2V0CkNPTkZJR19YODZfUkVTRVJWRV9MT1c9NjQKQ09ORklH
X01UUlI9eQojIENPTkZJR19NVFJSX1NBTklUSVpFUiBpcyBub3Qgc2V0CiMgQ09ORklHX1g4
Nl9QQVQgaXMgbm90IHNldAojIENPTkZJR19BUkNIX1JBTkRPTSBpcyBub3Qgc2V0CiMgQ09O
RklHX1g4Nl9TTUFQIGlzIG5vdCBzZXQKQ09ORklHX0VGST15CiMgQ09ORklHX0VGSV9TVFVC
IGlzIG5vdCBzZXQKQ09ORklHX1NFQ0NPTVA9eQojIENPTkZJR19DQ19TVEFDS1BST1RFQ1RP
UiBpcyBub3Qgc2V0CiMgQ09ORklHX0haXzEwMCBpcyBub3Qgc2V0CiMgQ09ORklHX0haXzI1
MCBpcyBub3Qgc2V0CiMgQ09ORklHX0haXzMwMCBpcyBub3Qgc2V0CkNPTkZJR19IWl8xMDAw
PXkKQ09ORklHX0haPTEwMDAKIyBDT05GSUdfU0NIRURfSFJUSUNLIGlzIG5vdCBzZXQKIyBD
T05GSUdfS0VYRUMgaXMgbm90IHNldAojIENPTkZJR19DUkFTSF9EVU1QIGlzIG5vdCBzZXQK
Q09ORklHX1BIWVNJQ0FMX1NUQVJUPTB4MTAwMDAwMAojIENPTkZJR19SRUxPQ0FUQUJMRSBp
cyBub3Qgc2V0CkNPTkZJR19QSFlTSUNBTF9BTElHTj0weDEwMDAwMDAKQ09ORklHX0hPVFBM
VUdfQ1BVPXkKIyBDT05GSUdfQ09NUEFUX1ZEU08gaXMgbm90IHNldApDT05GSUdfQ01ETElO
RV9CT09MPXkKQ09ORklHX0NNRExJTkU9IiIKQ09ORklHX0NNRExJTkVfT1ZFUlJJREU9eQpD
T05GSUdfQVJDSF9FTkFCTEVfTUVNT1JZX0hPVFBMVUc9eQpDT05GSUdfQVJDSF9FTkFCTEVf
TUVNT1JZX0hPVFJFTU9WRT15CgojCiMgUG93ZXIgbWFuYWdlbWVudCBhbmQgQUNQSSBvcHRp
b25zCiMKQ09ORklHX0FSQ0hfSElCRVJOQVRJT05fSEVBREVSPXkKQ09ORklHX1NVU1BFTkQ9
eQpDT05GSUdfU1VTUEVORF9GUkVFWkVSPXkKQ09ORklHX0hJQkVSTkFURV9DQUxMQkFDS1M9
eQpDT05GSUdfSElCRVJOQVRJT049eQpDT05GSUdfUE1fU1REX1BBUlRJVElPTj0iIgpDT05G
SUdfUE1fU0xFRVA9eQpDT05GSUdfUE1fU0xFRVBfU01QPXkKQ09ORklHX1BNX0FVVE9TTEVF
UD15CkNPTkZJR19QTV9XQUtFTE9DS1M9eQpDT05GSUdfUE1fV0FLRUxPQ0tTX0xJTUlUPTEw
MApDT05GSUdfUE1fV0FLRUxPQ0tTX0dDPXkKQ09ORklHX1BNX1JVTlRJTUU9eQpDT05GSUdf
UE09eQojIENPTkZJR19QTV9ERUJVRyBpcyBub3Qgc2V0CkNPTkZJR19BQ1BJPXkKQ09ORklH
X0FDUElfU0xFRVA9eQpDT05GSUdfQUNQSV9FQ19ERUJVR0ZTPXkKIyBDT05GSUdfQUNQSV9B
QyBpcyBub3Qgc2V0CiMgQ09ORklHX0FDUElfQkFUVEVSWSBpcyBub3Qgc2V0CkNPTkZJR19B
Q1BJX0ZBTj15CiMgQ09ORklHX0FDUElfRE9DSyBpcyBub3Qgc2V0CiMgQ09ORklHX0FDUElf
UFJPQ0VTU09SIGlzIG5vdCBzZXQKIyBDT05GSUdfQUNQSV9JUE1JIGlzIG5vdCBzZXQKIyBD
T05GSUdfQUNQSV9DVVNUT01fRFNEVCBpcyBub3Qgc2V0CkNPTkZJR19BQ1BJX0lOSVRSRF9U
QUJMRV9PVkVSUklERT15CkNPTkZJR19BQ1BJX0JMQUNLTElTVF9ZRUFSPTAKQ09ORklHX0FD
UElfREVCVUc9eQpDT05GSUdfQUNQSV9ERUJVR19GVU5DX1RSQUNFPXkKQ09ORklHX0FDUElf
UENJX1NMT1Q9eQpDT05GSUdfWDg2X1BNX1RJTUVSPXkKIyBDT05GSUdfQUNQSV9DT05UQUlO
RVIgaXMgbm90IHNldApDT05GSUdfQUNQSV9IT1RQTFVHX01FTU9SWT15CkNPTkZJR19BQ1BJ
X1NCUz15CkNPTkZJR19BQ1BJX0hFRD15CkNPTkZJR19BQ1BJX0NVU1RPTV9NRVRIT0Q9eQpD
T05GSUdfQUNQSV9CR1JUPXkKQ09ORklHX0FDUElfQVBFST15CiMgQ09ORklHX0FDUElfQVBF
SV9HSEVTIGlzIG5vdCBzZXQKQ09ORklHX0FDUElfQVBFSV9FSU5KPXkKIyBDT05GSUdfQUNQ
SV9BUEVJX0VSU1RfREVCVUcgaXMgbm90IHNldAojIENPTkZJR19TRkkgaXMgbm90IHNldAoK
IwojIENQVSBGcmVxdWVuY3kgc2NhbGluZwojCiMgQ09ORklHX0NQVV9GUkVRIGlzIG5vdCBz
ZXQKIyBDT05GSUdfQ1BVX0lETEUgaXMgbm90IHNldAojIENPTkZJR19BUkNIX05FRURTX0NQ
VV9JRExFX0NPVVBMRUQgaXMgbm90IHNldAoKIwojIE1lbW9yeSBwb3dlciBzYXZpbmdzCiMK
Q09ORklHX0k3MzAwX0lETEVfSU9BVF9DSEFOTkVMPXkKQ09ORklHX0k3MzAwX0lETEU9eQoK
IwojIEJ1cyBvcHRpb25zIChQQ0kgZXRjLikKIwpDT05GSUdfUENJPXkKQ09ORklHX1BDSV9E
SVJFQ1Q9eQojIENPTkZJR19QQ0lfTU1DT05GSUcgaXMgbm90IHNldApDT05GSUdfUENJX1hF
Tj15CkNPTkZJR19QQ0lfRE9NQUlOUz15CiMgQ09ORklHX1BDSV9DTkIyMExFX1FVSVJLIGlz
IG5vdCBzZXQKIyBDT05GSUdfUENJRVBPUlRCVVMgaXMgbm90IHNldApDT05GSUdfQVJDSF9T
VVBQT1JUU19NU0k9eQojIENPTkZJR19QQ0lfTVNJIGlzIG5vdCBzZXQKIyBDT05GSUdfUENJ
X0RFQlVHIGlzIG5vdCBzZXQKQ09ORklHX1BDSV9SRUFMTE9DX0VOQUJMRV9BVVRPPXkKIyBD
T05GSUdfUENJX1NUVUIgaXMgbm90IHNldApDT05GSUdfWEVOX1BDSURFVl9GUk9OVEVORD15
CiMgQ09ORklHX0hUX0lSUSBpcyBub3Qgc2V0CkNPTkZJR19QQ0lfQVRTPXkKQ09ORklHX1BD
SV9JT1Y9eQpDT05GSUdfUENJX1BSST15CiMgQ09ORklHX1BDSV9QQVNJRCBpcyBub3Qgc2V0
CiMgQ09ORklHX1BDSV9JT0FQSUMgaXMgbm90IHNldApDT05GSUdfUENJX0xBQkVMPXkKIyBD
T05GSUdfSVNBX0RNQV9BUEkgaXMgbm90IHNldApDT05GSUdfUENDQVJEPXkKQ09ORklHX1BD
TUNJQT15CiMgQ09ORklHX1BDTUNJQV9MT0FEX0NJUyBpcyBub3Qgc2V0CkNPTkZJR19DQVJE
QlVTPXkKCiMKIyBQQy1jYXJkIGJyaWRnZXMKIwojIENPTkZJR19ZRU5UQSBpcyBub3Qgc2V0
CiMgQ09ORklHX1BENjcyOSBpcyBub3Qgc2V0CkNPTkZJR19JODIwOTI9eQpDT05GSUdfUEND
QVJEX05PTlNUQVRJQz15CkNPTkZJR19IT1RQTFVHX1BDST15CiMgQ09ORklHX0hPVFBMVUdf
UENJX0FDUEkgaXMgbm90IHNldAojIENPTkZJR19IT1RQTFVHX1BDSV9DUENJIGlzIG5vdCBz
ZXQKIyBDT05GSUdfSE9UUExVR19QQ0lfU0hQQyBpcyBub3Qgc2V0CiMgQ09ORklHX1JBUElE
SU8gaXMgbm90IHNldAoKIwojIEV4ZWN1dGFibGUgZmlsZSBmb3JtYXRzIC8gRW11bGF0aW9u
cwojCkNPTkZJR19CSU5GTVRfRUxGPXkKQ09ORklHX0NPTVBBVF9CSU5GTVRfRUxGPXkKQ09O
RklHX0FSQ0hfQklORk1UX0VMRl9SQU5ET01JWkVfUElFPXkKIyBDT05GSUdfQ09SRV9EVU1Q
X0RFRkFVTFRfRUxGX0hFQURFUlMgaXMgbm90IHNldAojIENPTkZJR19IQVZFX0FPVVQgaXMg
bm90IHNldApDT05GSUdfQklORk1UX01JU0M9eQpDT05GSUdfQ09SRURVTVA9eQpDT05GSUdf
SUEzMl9FTVVMQVRJT049eQpDT05GSUdfSUEzMl9BT1VUPXkKIyBDT05GSUdfWDg2X1gzMiBp
cyBub3Qgc2V0CkNPTkZJR19DT01QQVQ9eQpDT05GSUdfQ09NUEFUX0ZPUl9VNjRfQUxJR05N
RU5UPXkKQ09ORklHX0tFWVNfQ09NUEFUPXkKQ09ORklHX0hBVkVfVEVYVF9QT0tFX1NNUD15
CkNPTkZJR19YODZfREVWX0RNQV9PUFM9eQpDT05GSUdfTkVUPXkKQ09ORklHX0NPTVBBVF9O
RVRMSU5LX01FU1NBR0VTPXkKCiMKIyBOZXR3b3JraW5nIG9wdGlvbnMKIwojIENPTkZJR19Q
QUNLRVQgaXMgbm90IHNldApDT05GSUdfVU5JWD15CiMgQ09ORklHX1VOSVhfRElBRyBpcyBu
b3Qgc2V0CkNPTkZJR19YRlJNPXkKQ09ORklHX1hGUk1fQUxHTz15CkNPTkZJR19YRlJNX1VT
RVI9eQpDT05GSUdfWEZSTV9TVUJfUE9MSUNZPXkKQ09ORklHX1hGUk1fTUlHUkFURT15CkNP
TkZJR19YRlJNX0lQQ09NUD15CkNPTkZJR19ORVRfS0VZPXkKQ09ORklHX05FVF9LRVlfTUlH
UkFURT15CkNPTkZJR19JTkVUPXkKIyBDT05GSUdfSVBfTVVMVElDQVNUIGlzIG5vdCBzZXQK
IyBDT05GSUdfSVBfQURWQU5DRURfUk9VVEVSIGlzIG5vdCBzZXQKQ09ORklHX0lQX1JPVVRF
X0NMQVNTSUQ9eQpDT05GSUdfSVBfUE5QPXkKIyBDT05GSUdfSVBfUE5QX0RIQ1AgaXMgbm90
IHNldApDT05GSUdfSVBfUE5QX0JPT1RQPXkKQ09ORklHX0lQX1BOUF9SQVJQPXkKQ09ORklH
X05FVF9JUElQPXkKQ09ORklHX05FVF9JUEdSRV9ERU1VWD15CiMgQ09ORklHX05FVF9JUEdS
RSBpcyBub3Qgc2V0CkNPTkZJR19BUlBEPXkKIyBDT05GSUdfU1lOX0NPT0tJRVMgaXMgbm90
IHNldApDT05GSUdfSU5FVF9BSD15CkNPTkZJR19JTkVUX0VTUD15CkNPTkZJR19JTkVUX0lQ
Q09NUD15CkNPTkZJR19JTkVUX1hGUk1fVFVOTkVMPXkKQ09ORklHX0lORVRfVFVOTkVMPXkK
Q09ORklHX0lORVRfWEZSTV9NT0RFX1RSQU5TUE9SVD15CiMgQ09ORklHX0lORVRfWEZSTV9N
T0RFX1RVTk5FTCBpcyBub3Qgc2V0CkNPTkZJR19JTkVUX1hGUk1fTU9ERV9CRUVUPXkKQ09O
RklHX0lORVRfTFJPPXkKIyBDT05GSUdfSU5FVF9ESUFHIGlzIG5vdCBzZXQKIyBDT05GSUdf
VENQX0NPTkdfQURWQU5DRUQgaXMgbm90IHNldApDT05GSUdfVENQX0NPTkdfQ1VCSUM9eQpD
T05GSUdfREVGQVVMVF9UQ1BfQ09ORz0iY3ViaWMiCkNPTkZJR19UQ1BfTUQ1U0lHPXkKQ09O
RklHX0lQVjY9eQojIENPTkZJR19JUFY2X1BSSVZBQ1kgaXMgbm90IHNldAojIENPTkZJR19J
UFY2X1JPVVRFUl9QUkVGIGlzIG5vdCBzZXQKQ09ORklHX0lQVjZfT1BUSU1JU1RJQ19EQUQ9
eQojIENPTkZJR19JTkVUNl9BSCBpcyBub3Qgc2V0CiMgQ09ORklHX0lORVQ2X0VTUCBpcyBu
b3Qgc2V0CkNPTkZJR19JTkVUNl9JUENPTVA9eQpDT05GSUdfSVBWNl9NSVA2PXkKQ09ORklH
X0lORVQ2X1hGUk1fVFVOTkVMPXkKQ09ORklHX0lORVQ2X1RVTk5FTD15CiMgQ09ORklHX0lO
RVQ2X1hGUk1fTU9ERV9UUkFOU1BPUlQgaXMgbm90IHNldAojIENPTkZJR19JTkVUNl9YRlJN
X01PREVfVFVOTkVMIGlzIG5vdCBzZXQKQ09ORklHX0lORVQ2X1hGUk1fTU9ERV9CRUVUPXkK
Q09ORklHX0lORVQ2X1hGUk1fTU9ERV9ST1VURU9QVElNSVpBVElPTj15CiMgQ09ORklHX0lQ
VjZfU0lUIGlzIG5vdCBzZXQKQ09ORklHX0lQVjZfVFVOTkVMPXkKIyBDT05GSUdfSVBWNl9H
UkUgaXMgbm90IHNldApDT05GSUdfSVBWNl9NVUxUSVBMRV9UQUJMRVM9eQpDT05GSUdfSVBW
Nl9TVUJUUkVFUz15CkNPTkZJR19JUFY2X01ST1VURT15CkNPTkZJR19JUFY2X01ST1VURV9N
VUxUSVBMRV9UQUJMRVM9eQojIENPTkZJR19JUFY2X1BJTVNNX1YyIGlzIG5vdCBzZXQKQ09O
RklHX05FVFdPUktfU0VDTUFSSz15CiMgQ09ORklHX05FVFdPUktfUEhZX1RJTUVTVEFNUElO
RyBpcyBub3Qgc2V0CkNPTkZJR19ORVRGSUxURVI9eQojIENPTkZJR19ORVRGSUxURVJfREVC
VUcgaXMgbm90IHNldApDT05GSUdfTkVURklMVEVSX0FEVkFOQ0VEPXkKCiMKIyBDb3JlIE5l
dGZpbHRlciBDb25maWd1cmF0aW9uCiMKQ09ORklHX05FVEZJTFRFUl9ORVRMSU5LPXkKQ09O
RklHX05FVEZJTFRFUl9ORVRMSU5LX0FDQ1Q9eQpDT05GSUdfTkVURklMVEVSX05FVExJTktf
UVVFVUU9eQpDT05GSUdfTkVURklMVEVSX05FVExJTktfTE9HPXkKIyBDT05GSUdfTkZfQ09O
TlRSQUNLIGlzIG5vdCBzZXQKQ09ORklHX05FVEZJTFRFUl9YVEFCTEVTPXkKCiMKIyBYdGFi
bGVzIGNvbWJpbmVkIG1vZHVsZXMKIwpDT05GSUdfTkVURklMVEVSX1hUX01BUks9eQojIENP
TkZJR19ORVRGSUxURVJfWFRfU0VUIGlzIG5vdCBzZXQKCiMKIyBYdGFibGVzIHRhcmdldHMK
IwpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9DSEVDS1NVTT15CiMgQ09ORklHX05FVEZJ
TFRFUl9YVF9UQVJHRVRfQ0xBU1NJRlkgaXMgbm90IHNldApDT05GSUdfTkVURklMVEVSX1hU
X1RBUkdFVF9EU0NQPXkKIyBDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9ITCBpcyBub3Qg
c2V0CkNPTkZJR19ORVRGSUxURVJfWFRfVEFSR0VUX0hNQVJLPXkKIyBDT05GSUdfTkVURklM
VEVSX1hUX1RBUkdFVF9JRExFVElNRVIgaXMgbm90IHNldAojIENPTkZJR19ORVRGSUxURVJf
WFRfVEFSR0VUX0xPRyBpcyBub3Qgc2V0CiMgQ09ORklHX05FVEZJTFRFUl9YVF9UQVJHRVRf
TUFSSyBpcyBub3Qgc2V0CkNPTkZJR19ORVRGSUxURVJfWFRfVEFSR0VUX05GTE9HPXkKQ09O
RklHX05FVEZJTFRFUl9YVF9UQVJHRVRfTkZRVUVVRT15CkNPTkZJR19ORVRGSUxURVJfWFRf
VEFSR0VUX1JBVEVFU1Q9eQojIENPTkZJR19ORVRGSUxURVJfWFRfVEFSR0VUX1RFRSBpcyBu
b3Qgc2V0CkNPTkZJR19ORVRGSUxURVJfWFRfVEFSR0VUX1RSQUNFPXkKIyBDT05GSUdfTkVU
RklMVEVSX1hUX1RBUkdFVF9TRUNNQVJLIGlzIG5vdCBzZXQKQ09ORklHX05FVEZJTFRFUl9Y
VF9UQVJHRVRfVENQTVNTPXkKIyBDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9UQ1BPUFRT
VFJJUCBpcyBub3Qgc2V0CgojCiMgWHRhYmxlcyBtYXRjaGVzCiMKQ09ORklHX05FVEZJTFRF
Ul9YVF9NQVRDSF9BRERSVFlQRT15CkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfQ09NTUVO
VD15CiMgQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9DUFUgaXMgbm90IHNldApDT05GSUdf
TkVURklMVEVSX1hUX01BVENIX0RDQ1A9eQojIENPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hf
REVWR1JPVVAgaXMgbm90IHNldApDT05GSUdfTkVURklMVEVSX1hUX01BVENIX0RTQ1A9eQoj
IENPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfRUNOIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVU
RklMVEVSX1hUX01BVENIX0VTUCBpcyBub3Qgc2V0CkNPTkZJR19ORVRGSUxURVJfWFRfTUFU
Q0hfSEFTSExJTUlUPXkKQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9ITD15CiMgQ09ORklH
X05FVEZJTFRFUl9YVF9NQVRDSF9JUFJBTkdFIGlzIG5vdCBzZXQKQ09ORklHX05FVEZJTFRF
Ul9YVF9NQVRDSF9MRU5HVEg9eQojIENPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfTElNSVQg
aXMgbm90IHNldApDT05GSUdfTkVURklMVEVSX1hUX01BVENIX01BQz15CkNPTkZJR19ORVRG
SUxURVJfWFRfTUFUQ0hfTUFSSz15CkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfTVVMVElQ
T1JUPXkKQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9ORkFDQ1Q9eQpDT05GSUdfTkVURklM
VEVSX1hUX01BVENIX09TRj15CiMgQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9PV05FUiBp
cyBub3Qgc2V0CkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfUE9MSUNZPXkKIyBDT05GSUdf
TkVURklMVEVSX1hUX01BVENIX1BLVFRZUEUgaXMgbm90IHNldApDT05GSUdfTkVURklMVEVS
X1hUX01BVENIX1FVT1RBPXkKQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9SQVRFRVNUPXkK
Q09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9SRUFMTT15CkNPTkZJR19ORVRGSUxURVJfWFRf
TUFUQ0hfUkVDRU5UPXkKIyBDT05GSUdfTkVURklMVEVSX1hUX01BVENIX1NDVFAgaXMgbm90
IHNldAojIENPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfU1RBVElTVElDIGlzIG5vdCBzZXQK
IyBDT05GSUdfTkVURklMVEVSX1hUX01BVENIX1NUUklORyBpcyBub3Qgc2V0CiMgQ09ORklH
X05FVEZJTFRFUl9YVF9NQVRDSF9UQ1BNU1MgaXMgbm90IHNldApDT05GSUdfTkVURklMVEVS
X1hUX01BVENIX1RJTUU9eQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX1UzMj15CkNPTkZJ
R19JUF9TRVQ9eQpDT05GSUdfSVBfU0VUX01BWD0yNTYKQ09ORklHX0lQX1NFVF9CSVRNQVBf
SVA9eQojIENPTkZJR19JUF9TRVRfQklUTUFQX0lQTUFDIGlzIG5vdCBzZXQKIyBDT05GSUdf
SVBfU0VUX0JJVE1BUF9QT1JUIGlzIG5vdCBzZXQKIyBDT05GSUdfSVBfU0VUX0hBU0hfSVAg
aXMgbm90IHNldApDT05GSUdfSVBfU0VUX0hBU0hfSVBQT1JUPXkKIyBDT05GSUdfSVBfU0VU
X0hBU0hfSVBQT1JUSVAgaXMgbm90IHNldAojIENPTkZJR19JUF9TRVRfSEFTSF9JUFBPUlRO
RVQgaXMgbm90IHNldAojIENPTkZJR19JUF9TRVRfSEFTSF9ORVQgaXMgbm90IHNldAojIENP
TkZJR19JUF9TRVRfSEFTSF9ORVRQT1JUIGlzIG5vdCBzZXQKIyBDT05GSUdfSVBfU0VUX0hB
U0hfTkVUSUZBQ0UgaXMgbm90IHNldApDT05GSUdfSVBfU0VUX0xJU1RfU0VUPXkKQ09ORklH
X0lQX1ZTPXkKIyBDT05GSUdfSVBfVlNfSVBWNiBpcyBub3Qgc2V0CiMgQ09ORklHX0lQX1ZT
X0RFQlVHIGlzIG5vdCBzZXQKQ09ORklHX0lQX1ZTX1RBQl9CSVRTPTEyCgojCiMgSVBWUyB0
cmFuc3BvcnQgcHJvdG9jb2wgbG9hZCBiYWxhbmNpbmcgc3VwcG9ydAojCkNPTkZJR19JUF9W
U19QUk9UT19UQ1A9eQojIENPTkZJR19JUF9WU19QUk9UT19VRFAgaXMgbm90IHNldApDT05G
SUdfSVBfVlNfUFJPVE9fQUhfRVNQPXkKQ09ORklHX0lQX1ZTX1BST1RPX0VTUD15CiMgQ09O
RklHX0lQX1ZTX1BST1RPX0FIIGlzIG5vdCBzZXQKIyBDT05GSUdfSVBfVlNfUFJPVE9fU0NU
UCBpcyBub3Qgc2V0CgojCiMgSVBWUyBzY2hlZHVsZXIKIwpDT05GSUdfSVBfVlNfUlI9eQoj
IENPTkZJR19JUF9WU19XUlIgaXMgbm90IHNldApDT05GSUdfSVBfVlNfTEM9eQojIENPTkZJ
R19JUF9WU19XTEMgaXMgbm90IHNldApDT05GSUdfSVBfVlNfTEJMQz15CiMgQ09ORklHX0lQ
X1ZTX0xCTENSIGlzIG5vdCBzZXQKQ09ORklHX0lQX1ZTX0RIPXkKQ09ORklHX0lQX1ZTX1NI
PXkKIyBDT05GSUdfSVBfVlNfU0VEIGlzIG5vdCBzZXQKIyBDT05GSUdfSVBfVlNfTlEgaXMg
bm90IHNldAoKIwojIElQVlMgU0ggc2NoZWR1bGVyCiMKQ09ORklHX0lQX1ZTX1NIX1RBQl9C
SVRTPTgKCiMKIyBJUFZTIGFwcGxpY2F0aW9uIGhlbHBlcgojCgojCiMgSVA6IE5ldGZpbHRl
ciBDb25maWd1cmF0aW9uCiMKIyBDT05GSUdfTkZfREVGUkFHX0lQVjQgaXMgbm90IHNldAoj
IENPTkZJR19JUF9ORl9RVUVVRSBpcyBub3Qgc2V0CiMgQ09ORklHX0lQX05GX0lQVEFCTEVT
IGlzIG5vdCBzZXQKQ09ORklHX0lQX05GX0FSUFRBQkxFUz15CiMgQ09ORklHX0lQX05GX0FS
UEZJTFRFUiBpcyBub3Qgc2V0CkNPTkZJR19JUF9ORl9BUlBfTUFOR0xFPXkKCiMKIyBJUHY2
OiBOZXRmaWx0ZXIgQ29uZmlndXJhdGlvbgojCiMgQ09ORklHX05GX0RFRlJBR19JUFY2IGlz
IG5vdCBzZXQKQ09ORklHX0lQNl9ORl9JUFRBQkxFUz15CiMgQ09ORklHX0lQNl9ORl9NQVRD
SF9BSCBpcyBub3Qgc2V0CkNPTkZJR19JUDZfTkZfTUFUQ0hfRVVJNjQ9eQpDT05GSUdfSVA2
X05GX01BVENIX0ZSQUc9eQpDT05GSUdfSVA2X05GX01BVENIX09QVFM9eQpDT05GSUdfSVA2
X05GX01BVENIX0hMPXkKQ09ORklHX0lQNl9ORl9NQVRDSF9JUFY2SEVBREVSPXkKIyBDT05G
SUdfSVA2X05GX01BVENIX01IIGlzIG5vdCBzZXQKIyBDT05GSUdfSVA2X05GX01BVENIX1JQ
RklMVEVSIGlzIG5vdCBzZXQKQ09ORklHX0lQNl9ORl9NQVRDSF9SVD15CiMgQ09ORklHX0lQ
Nl9ORl9UQVJHRVRfSEwgaXMgbm90IHNldApDT05GSUdfSVA2X05GX0ZJTFRFUj15CkNPTkZJ
R19JUDZfTkZfVEFSR0VUX1JFSkVDVD15CkNPTkZJR19JUDZfTkZfTUFOR0xFPXkKQ09ORklH
X0lQNl9ORl9SQVc9eQojIENPTkZJR19JUF9EQ0NQIGlzIG5vdCBzZXQKIyBDT05GSUdfSVBf
U0NUUCBpcyBub3Qgc2V0CkNPTkZJR19SRFM9eQpDT05GSUdfUkRTX1JETUE9eQpDT05GSUdf
UkRTX1RDUD15CkNPTkZJR19SRFNfREVCVUc9eQpDT05GSUdfVElQQz15CiMgQ09ORklHX1RJ
UENfQURWQU5DRUQgaXMgbm90IHNldApDT05GSUdfQVRNPXkKQ09ORklHX0FUTV9DTElQPXkK
IyBDT05GSUdfQVRNX0NMSVBfTk9fSUNNUCBpcyBub3Qgc2V0CkNPTkZJR19BVE1fTEFORT15
CiMgQ09ORklHX0FUTV9NUE9BIGlzIG5vdCBzZXQKQ09ORklHX0FUTV9CUjI2ODQ9eQojIENP
TkZJR19BVE1fQlIyNjg0X0lQRklMVEVSIGlzIG5vdCBzZXQKIyBDT05GSUdfTDJUUCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0JSSURHRSBpcyBub3Qgc2V0CkNPTkZJR19ORVRfRFNBPXkKIyBD
T05GSUdfTkVUX0RTQV9UQUdfRFNBIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX0RTQV9UQUdf
RURTQSBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9EU0FfVEFHX1RSQUlMRVIgaXMgbm90IHNl
dAojIENPTkZJR19WTEFOXzgwMjFRIGlzIG5vdCBzZXQKIyBDT05GSUdfREVDTkVUIGlzIG5v
dCBzZXQKQ09ORklHX0xMQz15CiMgQ09ORklHX0xMQzIgaXMgbm90IHNldAojIENPTkZJR19J
UFggaXMgbm90IHNldApDT05GSUdfQVRBTEs9eQojIENPTkZJR19ERVZfQVBQTEVUQUxLIGlz
IG5vdCBzZXQKIyBDT05GSUdfWDI1IGlzIG5vdCBzZXQKIyBDT05GSUdfTEFQQiBpcyBub3Qg
c2V0CkNPTkZJR19XQU5fUk9VVEVSPXkKIyBDT05GSUdfUEhPTkVUIGlzIG5vdCBzZXQKQ09O
RklHX0lFRUU4MDIxNTQ9eQpDT05GSUdfSUVFRTgwMjE1NF82TE9XUEFOPXkKIyBDT05GSUdf
TUFDODAyMTU0IGlzIG5vdCBzZXQKQ09ORklHX05FVF9TQ0hFRD15CgojCiMgUXVldWVpbmcv
U2NoZWR1bGluZwojCkNPTkZJR19ORVRfU0NIX0NCUT15CiMgQ09ORklHX05FVF9TQ0hfSFRC
IGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1NDSF9IRlNDIGlzIG5vdCBzZXQKIyBDT05GSUdf
TkVUX1NDSF9BVE0gaXMgbm90IHNldAojIENPTkZJR19ORVRfU0NIX1BSSU8gaXMgbm90IHNl
dAojIENPTkZJR19ORVRfU0NIX01VTFRJUSBpcyBub3Qgc2V0CkNPTkZJR19ORVRfU0NIX1JF
RD15CiMgQ09ORklHX05FVF9TQ0hfU0ZCIGlzIG5vdCBzZXQKQ09ORklHX05FVF9TQ0hfU0ZR
PXkKIyBDT05GSUdfTkVUX1NDSF9URVFMIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1NDSF9U
QkYgaXMgbm90IHNldAojIENPTkZJR19ORVRfU0NIX0dSRUQgaXMgbm90IHNldAojIENPTkZJ
R19ORVRfU0NIX0RTTUFSSyBpcyBub3Qgc2V0CkNPTkZJR19ORVRfU0NIX05FVEVNPXkKIyBD
T05GSUdfTkVUX1NDSF9EUlIgaXMgbm90IHNldApDT05GSUdfTkVUX1NDSF9NUVBSSU89eQoj
IENPTkZJR19ORVRfU0NIX0NIT0tFIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1NDSF9RRlEg
aXMgbm90IHNldApDT05GSUdfTkVUX1NDSF9DT0RFTD15CkNPTkZJR19ORVRfU0NIX0ZRX0NP
REVMPXkKIyBDT05GSUdfTkVUX1NDSF9JTkdSRVNTIGlzIG5vdCBzZXQKQ09ORklHX05FVF9T
Q0hfUExVRz15CgojCiMgQ2xhc3NpZmljYXRpb24KIwpDT05GSUdfTkVUX0NMUz15CiMgQ09O
RklHX05FVF9DTFNfQkFTSUMgaXMgbm90IHNldAojIENPTkZJR19ORVRfQ0xTX1RDSU5ERVgg
aXMgbm90IHNldAojIENPTkZJR19ORVRfQ0xTX1JPVVRFNCBpcyBub3Qgc2V0CiMgQ09ORklH
X05FVF9DTFNfRlcgaXMgbm90IHNldAojIENPTkZJR19ORVRfQ0xTX1UzMiBpcyBub3Qgc2V0
CkNPTkZJR19ORVRfQ0xTX1JTVlA9eQojIENPTkZJR19ORVRfQ0xTX1JTVlA2IGlzIG5vdCBz
ZXQKQ09ORklHX05FVF9DTFNfRkxPVz15CiMgQ09ORklHX05FVF9DTFNfQ0dST1VQIGlzIG5v
dCBzZXQKIyBDT05GSUdfTkVUX0VNQVRDSCBpcyBub3Qgc2V0CkNPTkZJR19ORVRfQ0xTX0FD
VD15CkNPTkZJR19ORVRfQUNUX1BPTElDRT15CkNPTkZJR19ORVRfQUNUX0dBQ1Q9eQojIENP
TkZJR19HQUNUX1BST0IgaXMgbm90IHNldAojIENPTkZJR19ORVRfQUNUX01JUlJFRCBpcyBu
b3Qgc2V0CkNPTkZJR19ORVRfQUNUX05BVD15CkNPTkZJR19ORVRfQUNUX1BFRElUPXkKQ09O
RklHX05FVF9BQ1RfU0lNUD15CiMgQ09ORklHX05FVF9BQ1RfU0tCRURJVCBpcyBub3Qgc2V0
CkNPTkZJR19ORVRfQUNUX0NTVU09eQpDT05GSUdfTkVUX1NDSF9GSUZPPXkKIyBDT05GSUdf
RENCIGlzIG5vdCBzZXQKQ09ORklHX0ROU19SRVNPTFZFUj15CiMgQ09ORklHX0JBVE1BTl9B
RFYgaXMgbm90IHNldAojIENPTkZJR19PUEVOVlNXSVRDSCBpcyBub3Qgc2V0CkNPTkZJR19S
UFM9eQpDT05GSUdfUkZTX0FDQ0VMPXkKQ09ORklHX1hQUz15CiMgQ09ORklHX05FVFBSSU9f
Q0dST1VQIGlzIG5vdCBzZXQKQ09ORklHX0JRTD15CgojCiMgTmV0d29yayB0ZXN0aW5nCiMK
Q09ORklHX0hBTVJBRElPPXkKCiMKIyBQYWNrZXQgUmFkaW8gcHJvdG9jb2xzCiMKQ09ORklH
X0FYMjU9eQojIENPTkZJR19BWDI1X0RBTUFfU0xBVkUgaXMgbm90IHNldApDT05GSUdfTkVU
Uk9NPXkKQ09ORklHX1JPU0U9eQoKIwojIEFYLjI1IG5ldHdvcmsgZGV2aWNlIGRyaXZlcnMK
IwpDT05GSUdfTUtJU1M9eQpDT05GSUdfNlBBQ0s9eQpDT05GSUdfQlBRRVRIRVI9eQpDT05G
SUdfQkFZQ09NX1NFUl9GRFg9eQpDT05GSUdfQkFZQ09NX1NFUl9IRFg9eQojIENPTkZJR19C
QVlDT01fUEFSIGlzIG5vdCBzZXQKIyBDT05GSUdfWUFNIGlzIG5vdCBzZXQKIyBDT05GSUdf
Q0FOIGlzIG5vdCBzZXQKQ09ORklHX0lSREE9eQoKIwojIElyREEgcHJvdG9jb2xzCiMKIyBD
T05GSUdfSVJMQU4gaXMgbm90IHNldAojIENPTkZJR19JUk5FVCBpcyBub3Qgc2V0CiMgQ09O
RklHX0lSQ09NTSBpcyBub3Qgc2V0CkNPTkZJR19JUkRBX1VMVFJBPXkKCiMKIyBJckRBIG9w
dGlvbnMKIwojIENPTkZJR19JUkRBX0NBQ0hFX0xBU1RfTFNBUCBpcyBub3Qgc2V0CkNPTkZJ
R19JUkRBX0ZBU1RfUlI9eQpDT05GSUdfSVJEQV9ERUJVRz15CgojCiMgSW5mcmFyZWQtcG9y
dCBkZXZpY2UgZHJpdmVycwojCgojCiMgU0lSIGRldmljZSBkcml2ZXJzCiMKIyBDT05GSUdf
SVJUVFlfU0lSIGlzIG5vdCBzZXQKCiMKIyBEb25nbGUgc3VwcG9ydAojCiMgQ09ORklHX0tJ
TkdTVU5fRE9OR0xFIGlzIG5vdCBzZXQKIyBDT05GSUdfS1NEQVpaTEVfRE9OR0xFIGlzIG5v
dCBzZXQKQ09ORklHX0tTOTU5X0RPTkdMRT15CgojCiMgRklSIGRldmljZSBkcml2ZXJzCiMK
IyBDT05GSUdfVVNCX0lSREEgaXMgbm90IHNldAojIENPTkZJR19TSUdNQVRFTF9GSVIgaXMg
bm90IHNldAojIENPTkZJR19WTFNJX0ZJUiBpcyBub3Qgc2V0CkNPTkZJR19NQ1NfRklSPXkK
IyBDT05GSUdfQlQgaXMgbm90IHNldApDT05GSUdfQUZfUlhSUEM9eQpDT05GSUdfQUZfUlhS
UENfREVCVUc9eQpDT05GSUdfUlhLQUQ9eQpDT05GSUdfRklCX1JVTEVTPXkKQ09ORklHX1dJ
UkVMRVNTPXkKQ09ORklHX1dJUkVMRVNTX0VYVD15CkNPTkZJR19XRVhUX0NPUkU9eQpDT05G
SUdfV0VYVF9TUFk9eQpDT05GSUdfV0VYVF9QUklWPXkKQ09ORklHX0NGRzgwMjExPXkKIyBD
T05GSUdfTkw4MDIxMV9URVNUTU9ERSBpcyBub3Qgc2V0CkNPTkZJR19DRkc4MDIxMV9ERVZF
TE9QRVJfV0FSTklOR1M9eQojIENPTkZJR19DRkc4MDIxMV9SRUdfREVCVUcgaXMgbm90IHNl
dApDT05GSUdfQ0ZHODAyMTFfQ0VSVElGSUNBVElPTl9PTlVTPXkKQ09ORklHX0NGRzgwMjEx
X0RFRkFVTFRfUFM9eQojIENPTkZJR19DRkc4MDIxMV9ERUJVR0ZTIGlzIG5vdCBzZXQKIyBD
T05GSUdfQ0ZHODAyMTFfSU5URVJOQUxfUkVHREIgaXMgbm90IHNldAojIENPTkZJR19DRkc4
MDIxMV9XRVhUIGlzIG5vdCBzZXQKQ09ORklHX0xJQjgwMjExPXkKQ09ORklHX0xJQjgwMjEx
X0NSWVBUX1dFUD15CkNPTkZJR19MSUI4MDIxMV9DUllQVF9DQ01QPXkKQ09ORklHX0xJQjgw
MjExX0NSWVBUX1RLSVA9eQojIENPTkZJR19MSUI4MDIxMV9ERUJVRyBpcyBub3Qgc2V0CiMg
Q09ORklHX01BQzgwMjExIGlzIG5vdCBzZXQKIyBDT05GSUdfV0lNQVggaXMgbm90IHNldApD
T05GSUdfUkZLSUxMPXkKIyBDT05GSUdfUkZLSUxMX1JFR1VMQVRPUiBpcyBub3Qgc2V0CiMg
Q09ORklHX05FVF85UCBpcyBub3Qgc2V0CiMgQ09ORklHX0NBSUYgaXMgbm90IHNldApDT05G
SUdfQ0VQSF9MSUI9eQojIENPTkZJR19DRVBIX0xJQl9QUkVUVFlERUJVRyBpcyBub3Qgc2V0
CkNPTkZJR19DRVBIX0xJQl9VU0VfRE5TX1JFU09MVkVSPXkKQ09ORklHX05GQz15CiMgQ09O
RklHX05GQ19OQ0kgaXMgbm90IHNldApDT05GSUdfTkZDX0hDST15CiMgQ09ORklHX05GQ19T
SERMQyBpcyBub3Qgc2V0CiMgQ09ORklHX05GQ19MTENQIGlzIG5vdCBzZXQKCiMKIyBOZWFy
IEZpZWxkIENvbW11bmljYXRpb24gKE5GQykgZGV2aWNlcwojCkNPTkZJR19ORkNfUE41MzM9
eQpDT05GSUdfSEFWRV9CUEZfSklUPXkKCiMKIyBEZXZpY2UgRHJpdmVycwojCgojCiMgR2Vu
ZXJpYyBEcml2ZXIgT3B0aW9ucwojCkNPTkZJR19VRVZFTlRfSEVMUEVSX1BBVEg9IiIKIyBD
T05GSUdfREVWVE1QRlMgaXMgbm90IHNldApDT05GSUdfU1RBTkRBTE9ORT15CkNPTkZJR19Q
UkVWRU5UX0ZJUk1XQVJFX0JVSUxEPXkKQ09ORklHX0ZXX0xPQURFUj15CkNPTkZJR19GSVJN
V0FSRV9JTl9LRVJORUw9eQpDT05GSUdfRVhUUkFfRklSTVdBUkU9IiIKQ09ORklHX0RFQlVH
X0RSSVZFUj15CkNPTkZJR19ERUJVR19ERVZSRVM9eQpDT05GSUdfU1lTX0hZUEVSVklTT1I9
eQojIENPTkZJR19HRU5FUklDX0NQVV9ERVZJQ0VTIGlzIG5vdCBzZXQKQ09ORklHX1JFR01B
UD15CkNPTkZJR19SRUdNQVBfSTJDPXkKQ09ORklHX1JFR01BUF9TUEk9eQpDT05GSUdfUkVH
TUFQX01NSU89eQpDT05GSUdfUkVHTUFQX0lSUT15CkNPTkZJR19ETUFfU0hBUkVEX0JVRkZF
Uj15CgojCiMgQnVzIGRldmljZXMKIwpDT05GSUdfT01BUF9PQ1AyU0NQPXkKIyBDT05GSUdf
Q09OTkVDVE9SIGlzIG5vdCBzZXQKIyBDT05GSUdfTVREIGlzIG5vdCBzZXQKQ09ORklHX1BB
UlBPUlQ9eQpDT05GSUdfUEFSUE9SVF9QQz15CiMgQ09ORklHX1BBUlBPUlRfU0VSSUFMIGlz
IG5vdCBzZXQKIyBDT05GSUdfUEFSUE9SVF9QQ19GSUZPIGlzIG5vdCBzZXQKQ09ORklHX1BB
UlBPUlRfUENfU1VQRVJJTz15CkNPTkZJR19QQVJQT1JUX1BDX1BDTUNJQT15CiMgQ09ORklH
X1BBUlBPUlRfR1NDIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFSUE9SVF9BWDg4Nzk2IGlzIG5v
dCBzZXQKIyBDT05GSUdfUEFSUE9SVF8xMjg0IGlzIG5vdCBzZXQKQ09ORklHX1BOUD15CkNP
TkZJR19QTlBfREVCVUdfTUVTU0FHRVM9eQoKIwojIFByb3RvY29scwojCkNPTkZJR19QTlBB
Q1BJPXkKQ09ORklHX0JMS19ERVY9eQojIENPTkZJR19QQVJJREUgaXMgbm90IHNldAojIENP
TkZJR19CTEtfREVWX1BDSUVTU0RfTVRJUDMyWFggaXMgbm90IHNldAojIENPTkZJR19CTEtf
Q1BRX0RBIGlzIG5vdCBzZXQKQ09ORklHX0JMS19DUFFfQ0lTU19EQT15CkNPTkZJR19CTEtf
REVWX0RBQzk2MD15CiMgQ09ORklHX0JMS19ERVZfVU1FTSBpcyBub3Qgc2V0CiMgQ09ORklH
X0JMS19ERVZfQ09XX0NPTU1PTiBpcyBub3Qgc2V0CiMgQ09ORklHX0JMS19ERVZfTE9PUCBp
cyBub3Qgc2V0CgojCiMgRFJCRCBkaXNhYmxlZCBiZWNhdXNlIFBST0NfRlMsIElORVQgb3Ig
Q09OTkVDVE9SIG5vdCBzZWxlY3RlZAojCkNPTkZJR19CTEtfREVWX05CRD15CkNPTkZJR19C
TEtfREVWX05WTUU9eQojIENPTkZJR19CTEtfREVWX09TRCBpcyBub3Qgc2V0CiMgQ09ORklH
X0JMS19ERVZfU1g4IGlzIG5vdCBzZXQKIyBDT05GSUdfQkxLX0RFVl9SQU0gaXMgbm90IHNl
dAojIENPTkZJR19DRFJPTV9QS1RDRFZEIGlzIG5vdCBzZXQKQ09ORklHX0FUQV9PVkVSX0VU
SD15CiMgQ09ORklHX1hFTl9CTEtERVZfRlJPTlRFTkQgaXMgbm90IHNldAojIENPTkZJR19Y
RU5fQkxLREVWX0JBQ0tFTkQgaXMgbm90IHNldApDT05GSUdfVklSVElPX0JMSz15CkNPTkZJ
R19CTEtfREVWX0hEPXkKQ09ORklHX0JMS19ERVZfUkJEPXkKCiMKIyBNaXNjIGRldmljZXMK
IwpDT05GSUdfQUQ1MjVYX0RQT1Q9eQojIENPTkZJR19BRDUyNVhfRFBPVF9JMkMgaXMgbm90
IHNldAojIENPTkZJR19BRDUyNVhfRFBPVF9TUEkgaXMgbm90IHNldAojIENPTkZJR19QSEFO
VE9NIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5URUxfTUlEX1BUSSBpcyBub3Qgc2V0CiMgQ09O
RklHX1NHSV9JT0M0IGlzIG5vdCBzZXQKQ09ORklHX1RJRk1fQ09SRT15CkNPTkZJR19USUZN
XzdYWDE9eQojIENPTkZJR19JQ1M5MzJTNDAxIGlzIG5vdCBzZXQKQ09ORklHX0VOQ0xPU1VS
RV9TRVJWSUNFUz15CiMgQ09ORklHX0NTNTUzNV9NRkdQVCBpcyBub3Qgc2V0CiMgQ09ORklH
X0hQX0lMTyBpcyBub3Qgc2V0CiMgQ09ORklHX0FQRFM5ODAyQUxTIGlzIG5vdCBzZXQKQ09O
RklHX0lTTDI5MDAzPXkKIyBDT05GSUdfSVNMMjkwMjAgaXMgbm90IHNldApDT05GSUdfU0VO
U09SU19UU0wyNTUwPXkKQ09ORklHX1NFTlNPUlNfQkgxNzgwPXkKIyBDT05GSUdfU0VOU09S
U19CSDE3NzAgaXMgbm90IHNldApDT05GSUdfU0VOU09SU19BUERTOTkwWD15CkNPTkZJR19I
TUM2MzUyPXkKQ09ORklHX0RTMTY4Mj15CiMgQ09ORklHX1RJX0RBQzc1MTIgaXMgbm90IHNl
dAojIENPTkZJR19WTVdBUkVfQkFMTE9PTiBpcyBub3Qgc2V0CkNPTkZJR19CTVAwODU9eQoj
IENPTkZJR19CTVAwODVfSTJDIGlzIG5vdCBzZXQKQ09ORklHX0JNUDA4NV9TUEk9eQojIENP
TkZJR19QQ0hfUEhVQiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TV0lUQ0hfRlNBOTQ4MCBp
cyBub3Qgc2V0CkNPTkZJR19DMlBPUlQ9eQojIENPTkZJR19DMlBPUlRfRFVSQU1BUl8yMTUw
IGlzIG5vdCBzZXQKCiMKIyBFRVBST00gc3VwcG9ydAojCiMgQ09ORklHX0VFUFJPTV9BVDI0
IGlzIG5vdCBzZXQKIyBDT05GSUdfRUVQUk9NX0FUMjUgaXMgbm90IHNldAojIENPTkZJR19F
RVBST01fTEVHQUNZIGlzIG5vdCBzZXQKIyBDT05GSUdfRUVQUk9NX01BWDY4NzUgaXMgbm90
IHNldAojIENPTkZJR19FRVBST01fOTNDWDYgaXMgbm90IHNldApDT05GSUdfRUVQUk9NXzkz
WFg0Nj15CkNPTkZJR19DQjcxMF9DT1JFPXkKIyBDT05GSUdfQ0I3MTBfREVCVUcgaXMgbm90
IHNldApDT05GSUdfQ0I3MTBfREVCVUdfQVNTVU1QVElPTlM9eQoKIwojIFRleGFzIEluc3Ry
dW1lbnRzIHNoYXJlZCB0cmFuc3BvcnQgbGluZSBkaXNjaXBsaW5lCiMKCiMKIyBBbHRlcmEg
RlBHQSBmaXJtd2FyZSBkb3dubG9hZCBtb2R1bGUKIwojIENPTkZJR19BTFRFUkFfU1RBUEwg
aXMgbm90IHNldApDT05GSUdfSEFWRV9JREU9eQojIENPTkZJR19JREUgaXMgbm90IHNldAoK
IwojIFNDU0kgZGV2aWNlIHN1cHBvcnQKIwpDT05GSUdfU0NTSV9NT0Q9eQojIENPTkZJR19S
QUlEX0FUVFJTIGlzIG5vdCBzZXQKQ09ORklHX1NDU0k9eQpDT05GSUdfU0NTSV9ETUE9eQpD
T05GSUdfU0NTSV9UR1Q9eQpDT05GSUdfU0NTSV9ORVRMSU5LPXkKCiMKIyBTQ1NJIHN1cHBv
cnQgdHlwZSAoZGlzaywgdGFwZSwgQ0QtUk9NKQojCkNPTkZJR19CTEtfREVWX1NEPXkKQ09O
RklHX0NIUl9ERVZfU1Q9eQpDT05GSUdfQ0hSX0RFVl9PU1NUPXkKIyBDT05GSUdfQkxLX0RF
Vl9TUiBpcyBub3Qgc2V0CiMgQ09ORklHX0NIUl9ERVZfU0cgaXMgbm90IHNldAojIENPTkZJ
R19DSFJfREVWX1NDSCBpcyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfRU5DTE9TVVJFIGlzIG5v
dCBzZXQKIyBDT05GSUdfU0NTSV9NVUxUSV9MVU4gaXMgbm90IHNldAojIENPTkZJR19TQ1NJ
X0NPTlNUQU5UUyBpcyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfTE9HR0lORyBpcyBub3Qgc2V0
CkNPTkZJR19TQ1NJX1NDQU5fQVNZTkM9eQoKIwojIFNDU0kgVHJhbnNwb3J0cwojCkNPTkZJ
R19TQ1NJX1NQSV9BVFRSUz15CkNPTkZJR19TQ1NJX0ZDX0FUVFJTPXkKQ09ORklHX1NDU0lf
RkNfVEdUX0FUVFJTPXkKQ09ORklHX1NDU0lfSVNDU0lfQVRUUlM9eQpDT05GSUdfU0NTSV9T
QVNfQVRUUlM9eQojIENPTkZJR19TQ1NJX1NBU19MSUJTQVMgaXMgbm90IHNldApDT05GSUdf
U0NTSV9TUlBfQVRUUlM9eQpDT05GSUdfU0NTSV9TUlBfVEdUX0FUVFJTPXkKQ09ORklHX1ND
U0lfTE9XTEVWRUw9eQpDT05GSUdfSVNDU0lfVENQPXkKIyBDT05GSUdfSVNDU0lfQk9PVF9T
WVNGUyBpcyBub3Qgc2V0CkNPTkZJR19TQ1NJX0NYR0IzX0lTQ1NJPXkKQ09ORklHX1NDU0lf
Q1hHQjRfSVNDU0k9eQpDT05GSUdfU0NTSV9CTlgyX0lTQ1NJPXkKIyBDT05GSUdfU0NTSV9C
TlgyWF9GQ09FIGlzIG5vdCBzZXQKIyBDT05GSUdfQkUySVNDU0kgaXMgbm90IHNldAojIENP
TkZJR19CTEtfREVWXzNXX1hYWFhfUkFJRCBpcyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfSFBT
QSBpcyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfM1dfOVhYWCBpcyBub3Qgc2V0CkNPTkZJR19T
Q1NJXzNXX1NBUz15CkNPTkZJR19TQ1NJX0FDQVJEPXkKIyBDT05GSUdfU0NTSV9BQUNSQUlE
IGlzIG5vdCBzZXQKQ09ORklHX1NDU0lfQUlDN1hYWD15CkNPTkZJR19BSUM3WFhYX0NNRFNf
UEVSX0RFVklDRT0zMgpDT05GSUdfQUlDN1hYWF9SRVNFVF9ERUxBWV9NUz01MDAwCiMgQ09O
RklHX0FJQzdYWFhfREVCVUdfRU5BQkxFIGlzIG5vdCBzZXQKQ09ORklHX0FJQzdYWFhfREVC
VUdfTUFTSz0wCiMgQ09ORklHX0FJQzdYWFhfUkVHX1BSRVRUWV9QUklOVCBpcyBub3Qgc2V0
CiMgQ09ORklHX1NDU0lfQUlDN1hYWF9PTEQgaXMgbm90IHNldAojIENPTkZJR19TQ1NJX0FJ
Qzc5WFggaXMgbm90IHNldAojIENPTkZJR19TQ1NJX0FJQzk0WFggaXMgbm90IHNldAojIENP
TkZJR19TQ1NJX01WU0FTIGlzIG5vdCBzZXQKQ09ORklHX1NDU0lfTVZVTUk9eQpDT05GSUdf
U0NTSV9EUFRfSTJPPXkKIyBDT05GSUdfU0NTSV9BRFZBTlNZUyBpcyBub3Qgc2V0CiMgQ09O
RklHX1NDU0lfQVJDTVNSIGlzIG5vdCBzZXQKQ09ORklHX01FR0FSQUlEX05FV0dFTj15CiMg
Q09ORklHX01FR0FSQUlEX01NIGlzIG5vdCBzZXQKQ09ORklHX01FR0FSQUlEX0xFR0FDWT15
CiMgQ09ORklHX01FR0FSQUlEX1NBUyBpcyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfTVBUMlNB
UyBpcyBub3Qgc2V0CkNPTkZJR19TQ1NJX1VGU0hDRD15CiMgQ09ORklHX1NDU0lfSFBUSU9Q
IGlzIG5vdCBzZXQKIyBDT05GSUdfVk1XQVJFX1BWU0NTSSBpcyBub3Qgc2V0CkNPTkZJR19M
SUJGQz15CkNPTkZJR19MSUJGQ09FPXkKIyBDT05GSUdfRkNPRSBpcyBub3Qgc2V0CiMgQ09O
RklHX0ZDT0VfRk5JQyBpcyBub3Qgc2V0CkNPTkZJR19TQ1NJX0RNWDMxOTFEPXkKIyBDT05G
SUdfU0NTSV9GVVRVUkVfRE9NQUlOIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9JU0NJIGlz
IG5vdCBzZXQKIyBDT05GSUdfU0NTSV9JUFMgaXMgbm90IHNldAojIENPTkZJR19TQ1NJX0lO
SVRJTyBpcyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfSU5JQTEwMCBpcyBub3Qgc2V0CkNPTkZJ
R19TQ1NJX1BQQT15CiMgQ09ORklHX1NDU0lfSU1NIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NT
SV9JWklQX0VQUDE2IGlzIG5vdCBzZXQKQ09ORklHX1NDU0lfSVpJUF9TTE9XX0NUUj15CiMg
Q09ORklHX1NDU0lfU1RFWCBpcyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfU1lNNTNDOFhYXzIg
aXMgbm90IHNldAojIENPTkZJR19TQ1NJX0lQUiBpcyBub3Qgc2V0CkNPTkZJR19TQ1NJX1FM
T0dJQ18xMjgwPXkKIyBDT05GSUdfU0NTSV9RTEFfRkMgaXMgbm90IHNldAojIENPTkZJR19T
Q1NJX1FMQV9JU0NTSSBpcyBub3Qgc2V0CkNPTkZJR19TQ1NJX0xQRkM9eQojIENPTkZJR19T
Q1NJX0xQRkNfREVCVUdfRlMgaXMgbm90IHNldAojIENPTkZJR19TQ1NJX0RDMzk1eCBpcyBu
b3Qgc2V0CkNPTkZJR19TQ1NJX0RDMzkwVD15CiMgQ09ORklHX1NDU0lfREVCVUcgaXMgbm90
IHNldApDT05GSUdfU0NTSV9QTUNSQUlEPXkKIyBDT05GSUdfU0NTSV9QTTgwMDEgaXMgbm90
IHNldApDT05GSUdfU0NTSV9TUlA9eQpDT05GSUdfU0NTSV9CRkFfRkM9eQojIENPTkZJR19T
Q1NJX1ZJUlRJTyBpcyBub3Qgc2V0CkNPTkZJR19TQ1NJX0xPV0xFVkVMX1BDTUNJQT15CiMg
Q09ORklHX1NDU0lfREggaXMgbm90IHNldApDT05GSUdfU0NTSV9PU0RfSU5JVElBVE9SPXkK
Q09ORklHX1NDU0lfT1NEX1VMRD15CkNPTkZJR19TQ1NJX09TRF9EUFJJTlRfU0VOU0U9MQpD
T05GSUdfU0NTSV9PU0RfREVCVUc9eQpDT05GSUdfQVRBPXkKIyBDT05GSUdfQVRBX05PTlNU
QU5EQVJEIGlzIG5vdCBzZXQKQ09ORklHX0FUQV9WRVJCT1NFX0VSUk9SPXkKIyBDT05GSUdf
QVRBX0FDUEkgaXMgbm90IHNldApDT05GSUdfU0FUQV9QTVA9eQoKIwojIENvbnRyb2xsZXJz
IHdpdGggbm9uLVNGRiBuYXRpdmUgaW50ZXJmYWNlCiMKIyBDT05GSUdfU0FUQV9BSENJIGlz
IG5vdCBzZXQKIyBDT05GSUdfU0FUQV9BSENJX1BMQVRGT1JNIGlzIG5vdCBzZXQKIyBDT05G
SUdfU0FUQV9JTklDMTYyWCBpcyBub3Qgc2V0CiMgQ09ORklHX1NBVEFfQUNBUkRfQUhDSSBp
cyBub3Qgc2V0CiMgQ09ORklHX1NBVEFfU0lMMjQgaXMgbm90IHNldAojIENPTkZJR19BVEFf
U0ZGIGlzIG5vdCBzZXQKIyBDT05GSUdfTUQgaXMgbm90IHNldAojIENPTkZJR19UQVJHRVRf
Q09SRSBpcyBub3Qgc2V0CkNPTkZJR19GVVNJT049eQojIENPTkZJR19GVVNJT05fU1BJIGlz
IG5vdCBzZXQKQ09ORklHX0ZVU0lPTl9GQz15CkNPTkZJR19GVVNJT05fU0FTPXkKQ09ORklH
X0ZVU0lPTl9NQVhfU0dFPTEyOApDT05GSUdfRlVTSU9OX0NUTD15CkNPTkZJR19GVVNJT05f
TE9HR0lORz15CgojCiMgSUVFRSAxMzk0IChGaXJlV2lyZSkgc3VwcG9ydAojCkNPTkZJR19G
SVJFV0lSRT15CiMgQ09ORklHX0ZJUkVXSVJFX09IQ0kgaXMgbm90IHNldAojIENPTkZJR19G
SVJFV0lSRV9TQlAyIGlzIG5vdCBzZXQKQ09ORklHX0ZJUkVXSVJFX05FVD15CiMgQ09ORklH
X0ZJUkVXSVJFX05PU1kgaXMgbm90IHNldAojIENPTkZJR19JMk8gaXMgbm90IHNldAojIENP
TkZJR19NQUNJTlRPU0hfRFJJVkVSUyBpcyBub3Qgc2V0CkNPTkZJR19ORVRERVZJQ0VTPXkK
Q09ORklHX05FVF9DT1JFPXkKQ09ORklHX0JPTkRJTkc9eQpDT05GSUdfRFVNTVk9eQojIENP
TkZJR19FUVVBTElaRVIgaXMgbm90IHNldAojIENPTkZJR19ORVRfRkMgaXMgbm90IHNldApD
T05GSUdfTUlJPXkKIyBDT05GSUdfSUZCIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1RFQU0g
aXMgbm90IHNldAojIENPTkZJR19NQUNWTEFOIGlzIG5vdCBzZXQKQ09ORklHX1ZYTEFOPXkK
IyBDT05GSUdfTkVUQ09OU09MRSBpcyBub3Qgc2V0CiMgQ09ORklHX05FVFBPTEwgaXMgbm90
IHNldAojIENPTkZJR19ORVRfUE9MTF9DT05UUk9MTEVSIGlzIG5vdCBzZXQKQ09ORklHX1RV
Tj15CkNPTkZJR19WRVRIPXkKQ09ORklHX1ZJUlRJT19ORVQ9eQpDT05GSUdfQVJDTkVUPXkK
IyBDT05GSUdfQVJDTkVUXzEyMDEgaXMgbm90IHNldApDT05GSUdfQVJDTkVUXzEwNTE9eQoj
IENPTkZJR19BUkNORVRfUkFXIGlzIG5vdCBzZXQKIyBDT05GSUdfQVJDTkVUX0NBUCBpcyBu
b3Qgc2V0CkNPTkZJR19BUkNORVRfQ09NOTB4eD15CiMgQ09ORklHX0FSQ05FVF9DT005MHh4
SU8gaXMgbm90IHNldApDT05GSUdfQVJDTkVUX1JJTV9JPXkKQ09ORklHX0FSQ05FVF9DT00y
MDAyMD15CiMgQ09ORklHX0FSQ05FVF9DT00yMDAyMF9QQ0kgaXMgbm90IHNldApDT05GSUdf
QVJDTkVUX0NPTTIwMDIwX0NTPXkKIyBDT05GSUdfQVRNX0RSSVZFUlMgaXMgbm90IHNldAoK
IwojIENBSUYgdHJhbnNwb3J0IGRyaXZlcnMKIwoKIwojIERpc3RyaWJ1dGVkIFN3aXRjaCBB
cmNoaXRlY3R1cmUgZHJpdmVycwojCiMgQ09ORklHX05FVF9EU0FfTVY4OEU2WFhYIGlzIG5v
dCBzZXQKIyBDT05GSUdfTkVUX0RTQV9NVjg4RTYwNjAgaXMgbm90IHNldAojIENPTkZJR19O
RVRfRFNBX01WODhFNlhYWF9ORUVEX1BQVSBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9EU0Ff
TVY4OEU2MTMxIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX0RTQV9NVjg4RTYxMjNfNjFfNjUg
aXMgbm90IHNldApDT05GSUdfRVRIRVJORVQ9eQpDT05GSUdfTURJTz15CiMgQ09ORklHX05F
VF9WRU5ET1JfM0NPTSBpcyBub3Qgc2V0CkNPTkZJR19ORVRfVkVORE9SX0FEQVBURUM9eQpD
T05GSUdfQURBUFRFQ19TVEFSRklSRT15CkNPTkZJR19ORVRfVkVORE9SX0FMVEVPTj15CkNP
TkZJR19BQ0VOSUM9eQpDT05GSUdfQUNFTklDX09NSVRfVElHT05fST15CiMgQ09ORklHX05F
VF9WRU5ET1JfQU1EIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfQVRIRVJPUz15CiMg
Q09ORklHX0FUTDIgaXMgbm90IHNldApDT05GSUdfQVRMMT15CiMgQ09ORklHX0FUTDFFIGlz
IG5vdCBzZXQKQ09ORklHX0FUTDFDPXkKIyBDT05GSUdfTkVUX0NBREVOQ0UgaXMgbm90IHNl
dApDT05GSUdfTkVUX1ZFTkRPUl9CUk9BRENPTT15CiMgQ09ORklHX0I0NCBpcyBub3Qgc2V0
CkNPTkZJR19CTlgyPXkKQ09ORklHX0NOSUM9eQojIENPTkZJR19USUdPTjMgaXMgbm90IHNl
dAojIENPTkZJR19CTlgyWCBpcyBub3Qgc2V0CkNPTkZJR19ORVRfVkVORE9SX0JST0NBREU9
eQpDT05GSUdfQk5BPXkKQ09ORklHX05FVF9DQUxYRURBX1hHTUFDPXkKQ09ORklHX05FVF9W
RU5ET1JfQ0hFTFNJTz15CkNPTkZJR19DSEVMU0lPX1QxPXkKQ09ORklHX0NIRUxTSU9fVDFf
MUc9eQpDT05GSUdfQ0hFTFNJT19UMz15CkNPTkZJR19DSEVMU0lPX1Q0PXkKQ09ORklHX0NI
RUxTSU9fVDRWRj15CiMgQ09ORklHX05FVF9WRU5ET1JfQ0lTQ08gaXMgbm90IHNldApDT05G
SUdfRE5FVD15CkNPTkZJR19ORVRfVkVORE9SX0RFQz15CkNPTkZJR19ORVRfVFVMSVA9eQpD
T05GSUdfREUyMTA0WD15CkNPTkZJR19ERTIxMDRYX0RTTD0wCkNPTkZJR19UVUxJUD15CiMg
Q09ORklHX1RVTElQX01XSSBpcyBub3Qgc2V0CiMgQ09ORklHX1RVTElQX01NSU8gaXMgbm90
IHNldAojIENPTkZJR19UVUxJUF9OQVBJIGlzIG5vdCBzZXQKQ09ORklHX0RFNFg1PXkKQ09O
RklHX1dJTkJPTkRfODQwPXkKIyBDT05GSUdfRE05MTAyIGlzIG5vdCBzZXQKIyBDT05GSUdf
VUxJNTI2WCBpcyBub3Qgc2V0CkNPTkZJR19QQ01DSUFfWElSQ09NPXkKIyBDT05GSUdfTkVU
X1ZFTkRPUl9ETElOSyBpcyBub3Qgc2V0CkNPTkZJR19ORVRfVkVORE9SX0VNVUxFWD15CkNP
TkZJR19CRTJORVQ9eQojIENPTkZJR19ORVRfVkVORE9SX0VYQVIgaXMgbm90IHNldApDT05G
SUdfTkVUX1ZFTkRPUl9GVUpJVFNVPXkKIyBDT05GSUdfUENNQ0lBX0ZNVkoxOFggaXMgbm90
IHNldApDT05GSUdfTkVUX1ZFTkRPUl9IUD15CkNPTkZJR19IUDEwMD15CiMgQ09ORklHX05F
VF9WRU5ET1JfSU5URUwgaXMgbm90IHNldApDT05GSUdfSVAxMDAwPXkKQ09ORklHX0pNRT15
CiMgQ09ORklHX05FVF9WRU5ET1JfTUFSVkVMTCBpcyBub3Qgc2V0CkNPTkZJR19ORVRfVkVO
RE9SX01FTExBTk9YPXkKQ09ORklHX01MWDRfRU49eQpDT05GSUdfTUxYNF9DT1JFPXkKQ09O
RklHX01MWDRfREVCVUc9eQojIENPTkZJR19ORVRfVkVORE9SX01JQ1JFTCBpcyBub3Qgc2V0
CiMgQ09ORklHX05FVF9WRU5ET1JfTUlDUk9DSElQIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVU
X1ZFTkRPUl9NWVJJIGlzIG5vdCBzZXQKQ09ORklHX0ZFQUxOWD15CiMgQ09ORklHX05FVF9W
RU5ET1JfTkFUU0VNSSBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5ET1JfTlZJRElBIGlz
IG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9PS0kgaXMgbm90IHNldAojIENPTkZJR19F
VEhPQyBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9QQUNLRVRfRU5HSU5FIGlzIG5vdCBzZXQK
IyBDT05GSUdfTkVUX1ZFTkRPUl9RTE9HSUMgaXMgbm90IHNldAojIENPTkZJR19ORVRfVkVO
RE9SX1JFQUxURUsgaXMgbm90IHNldAojIENPTkZJR19ORVRfVkVORE9SX1JEQyBpcyBub3Qg
c2V0CkNPTkZJR19ORVRfVkVORE9SX1NFRVE9eQpDT05GSUdfU0VFUTgwMDU9eQojIENPTkZJ
R19ORVRfVkVORE9SX1NJTEFOIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfU0lTPXkK
IyBDT05GSUdfU0lTOTAwIGlzIG5vdCBzZXQKIyBDT05GSUdfU0lTMTkwIGlzIG5vdCBzZXQK
IyBDT05GSUdfU0ZDIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfU01TQz15CkNPTkZJ
R19QQ01DSUFfU01DOTFDOTI9eQpDT05GSUdfRVBJQzEwMD15CiMgQ09ORklHX1NNU0M5NDIw
IGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9TVE1JQ1JPIGlzIG5vdCBzZXQKQ09O
RklHX05FVF9WRU5ET1JfU1VOPXkKQ09ORklHX0hBUFBZTUVBTD15CiMgQ09ORklHX1NVTkdF
TSBpcyBub3Qgc2V0CiMgQ09ORklHX0NBU1NJTkkgaXMgbm90IHNldAojIENPTkZJR19OSVUg
aXMgbm90IHNldApDT05GSUdfTkVUX1ZFTkRPUl9URUhVVEk9eQojIENPTkZJR19URUhVVEkg
aXMgbm90IHNldApDT05GSUdfTkVUX1ZFTkRPUl9UST15CkNPTkZJR19USV9DUFRTPXkKQ09O
RklHX1RMQU49eQpDT05GSUdfTkVUX1ZFTkRPUl9WSUE9eQojIENPTkZJR19WSUFfUkhJTkUg
aXMgbm90IHNldAojIENPTkZJR19WSUFfVkVMT0NJVFkgaXMgbm90IHNldApDT05GSUdfTkVU
X1ZFTkRPUl9XSVpORVQ9eQpDT05GSUdfV0laTkVUX1c1MTAwPXkKIyBDT05GSUdfV0laTkVU
X1c1MzAwIGlzIG5vdCBzZXQKIyBDT05GSUdfV0laTkVUX0JVU19ESVJFQ1QgaXMgbm90IHNl
dApDT05GSUdfV0laTkVUX0JVU19JTkRJUkVDVD15CiMgQ09ORklHX1dJWk5FVF9CVVNfQU5Z
IGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9YSVJDT00gaXMgbm90IHNldApDT05G
SUdfRkREST15CiMgQ09ORklHX0RFRlhYIGlzIG5vdCBzZXQKQ09ORklHX1NLRlA9eQojIENP
TkZJR19ISVBQSSBpcyBub3Qgc2V0CkNPTkZJR19ORVRfU0IxMDAwPXkKQ09ORklHX1BIWUxJ
Qj15CgojCiMgTUlJIFBIWSBkZXZpY2UgZHJpdmVycwojCkNPTkZJR19BVDgwM1hfUEhZPXkK
Q09ORklHX0FNRF9QSFk9eQojIENPTkZJR19NQVJWRUxMX1BIWSBpcyBub3Qgc2V0CkNPTkZJ
R19EQVZJQ09NX1BIWT15CkNPTkZJR19RU0VNSV9QSFk9eQojIENPTkZJR19MWFRfUEhZIGlz
IG5vdCBzZXQKQ09ORklHX0NJQ0FEQV9QSFk9eQojIENPTkZJR19WSVRFU1NFX1BIWSBpcyBu
b3Qgc2V0CkNPTkZJR19TTVNDX1BIWT15CiMgQ09ORklHX0JST0FEQ09NX1BIWSBpcyBub3Qg
c2V0CkNPTkZJR19CQ004N1hYX1BIWT15CiMgQ09ORklHX0lDUExVU19QSFkgaXMgbm90IHNl
dApDT05GSUdfUkVBTFRFS19QSFk9eQojIENPTkZJR19OQVRJT05BTF9QSFkgaXMgbm90IHNl
dAojIENPTkZJR19TVEUxMFhQIGlzIG5vdCBzZXQKIyBDT05GSUdfTFNJX0VUMTAxMUNfUEhZ
IGlzIG5vdCBzZXQKQ09ORklHX01JQ1JFTF9QSFk9eQpDT05GSUdfRklYRURfUEhZPXkKIyBD
T05GSUdfTURJT19CSVRCQU5HIGlzIG5vdCBzZXQKQ09ORklHX01JQ1JFTF9LUzg5OTVNQT15
CkNPTkZJR19QTElQPXkKQ09ORklHX1BQUD15CiMgQ09ORklHX1BQUF9CU0RDT01QIGlzIG5v
dCBzZXQKIyBDT05GSUdfUFBQX0RFRkxBVEUgaXMgbm90IHNldApDT05GSUdfUFBQX0ZJTFRF
Uj15CiMgQ09ORklHX1BQUF9NUFBFIGlzIG5vdCBzZXQKIyBDT05GSUdfUFBQX01VTFRJTElO
SyBpcyBub3Qgc2V0CkNPTkZJR19QUFBPQVRNPXkKQ09ORklHX1BQUE9FPXkKIyBDT05GSUdf
UFBUUCBpcyBub3Qgc2V0CiMgQ09ORklHX1BQUF9BU1lOQyBpcyBub3Qgc2V0CkNPTkZJR19Q
UFBfU1lOQ19UVFk9eQpDT05GSUdfU0xJUD15CkNPTkZJR19TTEhDPXkKIyBDT05GSUdfU0xJ
UF9DT01QUkVTU0VEIGlzIG5vdCBzZXQKQ09ORklHX1NMSVBfU01BUlQ9eQpDT05GSUdfU0xJ
UF9NT0RFX1NMSVA2PXkKCiMKIyBVU0IgTmV0d29yayBBZGFwdGVycwojCiMgQ09ORklHX1VT
Ql9DQVRDIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0tBV0VUSCBpcyBub3Qgc2V0CiMgQ09O
RklHX1VTQl9QRUdBU1VTIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1JUTDgxNTAgaXMgbm90
IHNldAojIENPTkZJR19VU0JfVVNCTkVUIGlzIG5vdCBzZXQKQ09ORklHX1VTQl9IU089eQoj
IENPTkZJR19VU0JfSVBIRVRIIGlzIG5vdCBzZXQKQ09ORklHX1dMQU49eQojIENPTkZJR19Q
Q01DSUFfUkFZQ1MgaXMgbm90IHNldApDT05GSUdfQVRNRUw9eQpDT05GSUdfUENJX0FUTUVM
PXkKQ09ORklHX1BDTUNJQV9BVE1FTD15CkNPTkZJR19BSVJPX0NTPXkKIyBDT05GSUdfUENN
Q0lBX1dMMzUwMSBpcyBub3Qgc2V0CkNPTkZJR19QUklTTTU0PXkKQ09ORklHX1VTQl9aRDEy
MDE9eQojIENPTkZJR19VU0JfTkVUX1JORElTX1dMQU4gaXMgbm90IHNldAojIENPTkZJR19B
VEhfQ09NTU9OIGlzIG5vdCBzZXQKQ09ORklHX0JSQ01VVElMPXkKQ09ORklHX0JSQ01GTUFD
PXkKQ09ORklHX0JSQ01GTUFDX1VTQj15CiMgQ09ORklHX0JSQ01JU0NBTiBpcyBub3Qgc2V0
CkNPTkZJR19CUkNNREJHPXkKIyBDT05GSUdfSE9TVEFQIGlzIG5vdCBzZXQKQ09ORklHX0lQ
VzIxMDA9eQpDT05GSUdfSVBXMjEwMF9NT05JVE9SPXkKQ09ORklHX0lQVzIxMDBfREVCVUc9
eQpDT05GSUdfTElCSVBXPXkKQ09ORklHX0xJQklQV19ERUJVRz15CkNPTkZJR19MSUJFUlRB
Uz15CiMgQ09ORklHX0xJQkVSVEFTX1VTQiBpcyBub3Qgc2V0CiMgQ09ORklHX0xJQkVSVEFT
X0NTIGlzIG5vdCBzZXQKIyBDT05GSUdfTElCRVJUQVNfU1BJIGlzIG5vdCBzZXQKIyBDT05G
SUdfTElCRVJUQVNfREVCVUcgaXMgbm90IHNldApDT05GSUdfTElCRVJUQVNfTUVTSD15CiMg
Q09ORklHX1dMX1RJIGlzIG5vdCBzZXQKIyBDT05GSUdfTVdJRklFWCBpcyBub3Qgc2V0Cgoj
CiMgRW5hYmxlIFdpTUFYIChOZXR3b3JraW5nIG9wdGlvbnMpIHRvIHNlZSB0aGUgV2lNQVgg
ZHJpdmVycwojCkNPTkZJR19XQU49eQojIENPTkZJR19IRExDIGlzIG5vdCBzZXQKQ09ORklH
X0RMQ0k9eQpDT05GSUdfRExDSV9NQVg9OAojIENPTkZJR19XQU5fUk9VVEVSX0RSSVZFUlMg
aXMgbm90IHNldApDT05GSUdfU0JOST15CkNPTkZJR19TQk5JX01VTFRJTElORT15CkNPTkZJ
R19JRUVFODAyMTU0X0RSSVZFUlM9eQpDT05GSUdfSUVFRTgwMjE1NF9GQUtFSEFSRD15CiMg
Q09ORklHX1hFTl9ORVRERVZfRlJPTlRFTkQgaXMgbm90IHNldAojIENPTkZJR19YRU5fTkVU
REVWX0JBQ0tFTkQgaXMgbm90IHNldAojIENPTkZJR19WTVhORVQzIGlzIG5vdCBzZXQKIyBD
T05GSUdfSVNETiBpcyBub3Qgc2V0CgojCiMgSW5wdXQgZGV2aWNlIHN1cHBvcnQKIwojIENP
TkZJR19JTlBVVCBpcyBub3Qgc2V0CkNPTkZJR19JTlBVVF9YRU5fS0JEREVWX0ZST05URU5E
PXkKCiMKIyBIYXJkd2FyZSBJL08gcG9ydHMKIwpDT05GSUdfU0VSSU89eQpDT05GSUdfU0VS
SU9fSTgwNDI9eQpDT05GSUdfU0VSSU9fU0VSUE9SVD15CiMgQ09ORklHX1NFUklPX0NUODJD
NzEwIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VSSU9fUEFSS0JEIGlzIG5vdCBzZXQKQ09ORklH
X1NFUklPX1BDSVBTMj15CkNPTkZJR19TRVJJT19MSUJQUzI9eQojIENPTkZJR19TRVJJT19S
QVcgaXMgbm90IHNldApDT05GSUdfU0VSSU9fQUxURVJBX1BTMj15CkNPTkZJR19TRVJJT19Q
UzJNVUxUPXkKIyBDT05GSUdfU0VSSU9fQVJDX1BTMiBpcyBub3Qgc2V0CiMgQ09ORklHX0dB
TUVQT1JUIGlzIG5vdCBzZXQKCiMKIyBDaGFyYWN0ZXIgZGV2aWNlcwojCiMgQ09ORklHX1ZU
IGlzIG5vdCBzZXQKIyBDT05GSUdfVU5JWDk4X1BUWVMgaXMgbm90IHNldAojIENPTkZJR19M
RUdBQ1lfUFRZUyBpcyBub3Qgc2V0CiMgQ09ORklHX1NFUklBTF9OT05TVEFOREFSRCBpcyBu
b3Qgc2V0CkNPTkZJR19OT1pPTUk9eQojIENPTkZJR19OX0dTTSBpcyBub3Qgc2V0CiMgQ09O
RklHX1RSQUNFX1JPVVRFUiBpcyBub3Qgc2V0CkNPTkZJR19UUkFDRV9TSU5LPXkKIyBDT05G
SUdfREVWS01FTSBpcyBub3Qgc2V0CgojCiMgU2VyaWFsIGRyaXZlcnMKIwpDT05GSUdfU0VS
SUFMXzgyNTA9eQpDT05GSUdfU0VSSUFMXzgyNTBfUE5QPXkKQ09ORklHX1NFUklBTF84MjUw
X0NPTlNPTEU9eQpDT05GSUdfRklYX0VBUkxZQ09OX01FTT15CkNPTkZJR19TRVJJQUxfODI1
MF9QQ0k9eQojIENPTkZJR19TRVJJQUxfODI1MF9DUyBpcyBub3Qgc2V0CkNPTkZJR19TRVJJ
QUxfODI1MF9OUl9VQVJUUz00CkNPTkZJR19TRVJJQUxfODI1MF9SVU5USU1FX1VBUlRTPTQK
Q09ORklHX1NFUklBTF84MjUwX0VYVEVOREVEPXkKQ09ORklHX1NFUklBTF84MjUwX01BTllf
UE9SVFM9eQpDT05GSUdfU0VSSUFMXzgyNTBfU0hBUkVfSVJRPXkKQ09ORklHX1NFUklBTF84
MjUwX0RFVEVDVF9JUlE9eQojIENPTkZJR19TRVJJQUxfODI1MF9SU0EgaXMgbm90IHNldAoK
IwojIE5vbi04MjUwIHNlcmlhbCBwb3J0IHN1cHBvcnQKIwojIENPTkZJR19TRVJJQUxfTUFY
MzEwMCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFUklBTF9NQVgzMTBYIGlzIG5vdCBzZXQKIyBD
T05GSUdfU0VSSUFMX01GRF9IU1UgaXMgbm90IHNldApDT05GSUdfU0VSSUFMX0NPUkU9eQpD
T05GSUdfU0VSSUFMX0NPUkVfQ09OU09MRT15CkNPTkZJR19TRVJJQUxfSlNNPXkKIyBDT05G
SUdfU0VSSUFMX1NDQ05YUCBpcyBub3Qgc2V0CkNPTkZJR19TRVJJQUxfVElNQkVSREFMRT15
CiMgQ09ORklHX1NFUklBTF9BTFRFUkFfSlRBR1VBUlQgaXMgbm90IHNldAojIENPTkZJR19T
RVJJQUxfQUxURVJBX1VBUlQgaXMgbm90IHNldApDT05GSUdfU0VSSUFMX1BDSF9VQVJUPXkK
Q09ORklHX1NFUklBTF9QQ0hfVUFSVF9DT05TT0xFPXkKQ09ORklHX1NFUklBTF9YSUxJTlhf
UFNfVUFSVD15CkNPTkZJR19TRVJJQUxfWElMSU5YX1BTX1VBUlRfQ09OU09MRT15CiMgQ09O
RklHX1NFUklBTF9BUkMgaXMgbm90IHNldApDT05GSUdfVFRZX1BSSU5USz15CiMgQ09ORklH
X1BSSU5URVIgaXMgbm90IHNldApDT05GSUdfUFBERVY9eQpDT05GSUdfSFZDX0RSSVZFUj15
CiMgQ09ORklHX0hWQ19YRU4gaXMgbm90IHNldApDT05GSUdfVklSVElPX0NPTlNPTEU9eQpD
T05GSUdfSVBNSV9IQU5ETEVSPXkKQ09ORklHX0lQTUlfUEFOSUNfRVZFTlQ9eQojIENPTkZJ
R19JUE1JX1BBTklDX1NUUklORyBpcyBub3Qgc2V0CiMgQ09ORklHX0lQTUlfREVWSUNFX0lO
VEVSRkFDRSBpcyBub3Qgc2V0CkNPTkZJR19JUE1JX1NJPXkKIyBDT05GSUdfSVBNSV9XQVRD
SERPRyBpcyBub3Qgc2V0CkNPTkZJR19JUE1JX1BPV0VST0ZGPXkKQ09ORklHX0hXX1JBTkRP
TT15CiMgQ09ORklHX0hXX1JBTkRPTV9USU1FUklPTUVNIGlzIG5vdCBzZXQKQ09ORklHX0hX
X1JBTkRPTV9JTlRFTD15CkNPTkZJR19IV19SQU5ET01fQU1EPXkKQ09ORklHX0hXX1JBTkRP
TV9WSUE9eQojIENPTkZJR19IV19SQU5ET01fVklSVElPIGlzIG5vdCBzZXQKIyBDT05GSUdf
TlZSQU0gaXMgbm90IHNldApDT05GSUdfUlRDPXkKQ09ORklHX1IzOTY0PXkKQ09ORklHX0FQ
UExJQ09NPXkKCiMKIyBQQ01DSUEgY2hhcmFjdGVyIGRldmljZXMKIwojIENPTkZJR19TWU5D
TElOS19DUyBpcyBub3Qgc2V0CkNPTkZJR19DQVJETUFOXzQwMDA9eQojIENPTkZJR19DQVJE
TUFOXzQwNDAgaXMgbm90IHNldAojIENPTkZJR19JUFdJUkVMRVNTIGlzIG5vdCBzZXQKQ09O
RklHX01XQVZFPXkKQ09ORklHX1JBV19EUklWRVI9eQpDT05GSUdfTUFYX1JBV19ERVZTPTI1
NgpDT05GSUdfSFBFVD15CkNPTkZJR19IUEVUX01NQVA9eQojIENPTkZJR19IQU5HQ0hFQ0tf
VElNRVIgaXMgbm90IHNldAojIENPTkZJR19UQ0dfVFBNIGlzIG5vdCBzZXQKIyBDT05GSUdf
VEVMQ0xPQ0sgaXMgbm90IHNldApDT05GSUdfREVWUE9SVD15CkNPTkZJR19JMkM9eQpDT05G
SUdfSTJDX0JPQVJESU5GTz15CkNPTkZJR19JMkNfQ09NUEFUPXkKQ09ORklHX0kyQ19DSEFS
REVWPXkKQ09ORklHX0kyQ19NVVg9eQoKIwojIE11bHRpcGxleGVyIEkyQyBDaGlwIHN1cHBv
cnQKIwojIENPTkZJR19JMkNfTVVYX1BDQTk1NDEgaXMgbm90IHNldApDT05GSUdfSTJDX01V
WF9QQ0E5NTR4PXkKIyBDT05GSUdfSTJDX0hFTFBFUl9BVVRPIGlzIG5vdCBzZXQKQ09ORklH
X0kyQ19TTUJVUz15CgojCiMgSTJDIEFsZ29yaXRobXMKIwpDT05GSUdfSTJDX0FMR09CSVQ9
eQpDT05GSUdfSTJDX0FMR09QQ0Y9eQpDT05GSUdfSTJDX0FMR09QQ0E9eQoKIwojIEkyQyBI
YXJkd2FyZSBCdXMgc3VwcG9ydAojCgojCiMgUEMgU01CdXMgaG9zdCBjb250cm9sbGVyIGRy
aXZlcnMKIwojIENPTkZJR19JMkNfQUxJMTUzNSBpcyBub3Qgc2V0CkNPTkZJR19JMkNfQUxJ
MTU2Mz15CiMgQ09ORklHX0kyQ19BTEkxNVgzIGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX0FN
RDc1NiBpcyBub3Qgc2V0CkNPTkZJR19JMkNfQU1EODExMT15CiMgQ09ORklHX0kyQ19JODAx
IGlzIG5vdCBzZXQKQ09ORklHX0kyQ19JU0NIPXkKIyBDT05GSUdfSTJDX1BJSVg0IGlzIG5v
dCBzZXQKQ09ORklHX0kyQ19ORk9SQ0UyPXkKIyBDT05GSUdfSTJDX05GT1JDRTJfUzQ5ODUg
aXMgbm90IHNldAojIENPTkZJR19JMkNfU0lTNTU5NSBpcyBub3Qgc2V0CiMgQ09ORklHX0ky
Q19TSVM2MzAgaXMgbm90IHNldApDT05GSUdfSTJDX1NJUzk2WD15CkNPTkZJR19JMkNfVklB
PXkKIyBDT05GSUdfSTJDX1ZJQVBSTyBpcyBub3Qgc2V0CgojCiMgQUNQSSBkcml2ZXJzCiMK
IyBDT05GSUdfSTJDX1NDTUkgaXMgbm90IHNldAoKIwojIEkyQyBzeXN0ZW0gYnVzIGRyaXZl
cnMgKG1vc3RseSBlbWJlZGRlZCAvIHN5c3RlbS1vbi1jaGlwKQojCiMgQ09ORklHX0kyQ19E
RVNJR05XQVJFX1BDSSBpcyBub3Qgc2V0CiMgQ09ORklHX0kyQ19FRzIwVCBpcyBub3Qgc2V0
CkNPTkZJR19JMkNfSU5URUxfTUlEPXkKQ09ORklHX0kyQ19PQ09SRVM9eQpDT05GSUdfSTJD
X1BDQV9QTEFURk9STT15CiMgQ09ORklHX0kyQ19QWEFfUENJIGlzIG5vdCBzZXQKQ09ORklH
X0kyQ19TSU1URUM9eQpDT05GSUdfSTJDX1hJTElOWD15CgojCiMgRXh0ZXJuYWwgSTJDL1NN
QnVzIGFkYXB0ZXIgZHJpdmVycwojCkNPTkZJR19JMkNfRElPTEFOX1UyQz15CiMgQ09ORklH
X0kyQ19QQVJQT1JUIGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX1BBUlBPUlRfTElHSFQgaXMg
bm90IHNldApDT05GSUdfSTJDX1RBT1NfRVZNPXkKIyBDT05GSUdfSTJDX1RJTllfVVNCIGlz
IG5vdCBzZXQKCiMKIyBPdGhlciBJMkMvU01CdXMgYnVzIGRyaXZlcnMKIwojIENPTkZJR19J
MkNfREVCVUdfQ09SRSBpcyBub3Qgc2V0CiMgQ09ORklHX0kyQ19ERUJVR19BTEdPIGlzIG5v
dCBzZXQKIyBDT05GSUdfSTJDX0RFQlVHX0JVUyBpcyBub3Qgc2V0CkNPTkZJR19TUEk9eQoj
IENPTkZJR19TUElfREVCVUcgaXMgbm90IHNldApDT05GSUdfU1BJX01BU1RFUj15CgojCiMg
U1BJIE1hc3RlciBDb250cm9sbGVyIERyaXZlcnMKIwojIENPTkZJR19TUElfQUxURVJBIGlz
IG5vdCBzZXQKIyBDT05GSUdfU1BJX0JJVEJBTkcgaXMgbm90IHNldAojIENPTkZJR19TUElf
QlVUVEVSRkxZIGlzIG5vdCBzZXQKIyBDT05GSUdfU1BJX0xNNzBfTExQIGlzIG5vdCBzZXQK
IyBDT05GSUdfU1BJX1BYQTJYWF9QQ0kgaXMgbm90IHNldAojIENPTkZJR19TUElfU0MxOElT
NjAyIGlzIG5vdCBzZXQKQ09ORklHX1NQSV9UT1BDTElGRl9QQ0g9eQojIENPTkZJR19TUElf
WENPTU0gaXMgbm90IHNldAojIENPTkZJR19TUElfWElMSU5YIGlzIG5vdCBzZXQKIyBDT05G
SUdfU1BJX0RFU0lHTldBUkUgaXMgbm90IHNldAoKIwojIFNQSSBQcm90b2NvbCBNYXN0ZXJz
CiMKIyBDT05GSUdfU1BJX1NQSURFViBpcyBub3Qgc2V0CkNPTkZJR19TUElfVExFNjJYMD15
CiMgQ09ORklHX0hTSSBpcyBub3Qgc2V0CgojCiMgUFBTIHN1cHBvcnQKIwpDT05GSUdfUFBT
PXkKIyBDT05GSUdfUFBTX0RFQlVHIGlzIG5vdCBzZXQKCiMKIyBQUFMgY2xpZW50cyBzdXBw
b3J0CiMKQ09ORklHX1BQU19DTElFTlRfS1RJTUVSPXkKQ09ORklHX1BQU19DTElFTlRfTERJ
U0M9eQojIENPTkZJR19QUFNfQ0xJRU5UX1BBUlBPUlQgaXMgbm90IHNldAojIENPTkZJR19Q
UFNfQ0xJRU5UX0dQSU8gaXMgbm90IHNldAoKIwojIFBQUyBnZW5lcmF0b3JzIHN1cHBvcnQK
IwoKIwojIFBUUCBjbG9jayBzdXBwb3J0CiMKQ09ORklHX1BUUF8xNTg4X0NMT0NLPXkKCiMK
IyBFbmFibGUgUEhZTElCIGFuZCBORVRXT1JLX1BIWV9USU1FU1RBTVBJTkcgdG8gc2VlIHRo
ZSBhZGRpdGlvbmFsIGNsb2Nrcy4KIwpDT05GSUdfQVJDSF9XQU5UX09QVElPTkFMX0dQSU9M
SUI9eQojIENPTkZJR19HUElPTElCIGlzIG5vdCBzZXQKQ09ORklHX1cxPXkKCiMKIyAxLXdp
cmUgQnVzIE1hc3RlcnMKIwpDT05GSUdfVzFfTUFTVEVSX01BVFJPWD15CkNPTkZJR19XMV9N
QVNURVJfRFMyNDkwPXkKQ09ORklHX1cxX01BU1RFUl9EUzI0ODI9eQpDT05GSUdfVzFfTUFT
VEVSX0RTMVdNPXkKQ09ORklHX0hEUV9NQVNURVJfT01BUD15CgojCiMgMS13aXJlIFNsYXZl
cwojCkNPTkZJR19XMV9TTEFWRV9USEVSTT15CiMgQ09ORklHX1cxX1NMQVZFX1NNRU0gaXMg
bm90IHNldAojIENPTkZJR19XMV9TTEFWRV9EUzI0MDggaXMgbm90IHNldApDT05GSUdfVzFf
U0xBVkVfRFMyNDIzPXkKIyBDT05GSUdfVzFfU0xBVkVfRFMyNDMxIGlzIG5vdCBzZXQKIyBD
T05GSUdfVzFfU0xBVkVfRFMyNDMzIGlzIG5vdCBzZXQKIyBDT05GSUdfVzFfU0xBVkVfRFMy
NzYwIGlzIG5vdCBzZXQKQ09ORklHX1cxX1NMQVZFX0RTMjc4MD15CkNPTkZJR19XMV9TTEFW
RV9EUzI3ODE9eQojIENPTkZJR19XMV9TTEFWRV9EUzI4RTA0IGlzIG5vdCBzZXQKQ09ORklH
X1cxX1NMQVZFX0JRMjcwMDA9eQpDT05GSUdfUE9XRVJfU1VQUExZPXkKIyBDT05GSUdfUE9X
RVJfU1VQUExZX0RFQlVHIGlzIG5vdCBzZXQKIyBDT05GSUdfUERBX1BPV0VSIGlzIG5vdCBz
ZXQKIyBDT05GSUdfTUFYODkyNV9QT1dFUiBpcyBub3Qgc2V0CkNPTkZJR19XTTgzMVhfQkFD
S1VQPXkKQ09ORklHX1dNODMxWF9QT1dFUj15CkNPTkZJR19URVNUX1BPV0VSPXkKIyBDT05G
SUdfQkFUVEVSWV84OFBNODYwWCBpcyBub3Qgc2V0CiMgQ09ORklHX0JBVFRFUllfRFMyNzgw
IGlzIG5vdCBzZXQKQ09ORklHX0JBVFRFUllfRFMyNzgxPXkKQ09ORklHX0JBVFRFUllfRFMy
NzgyPXkKIyBDT05GSUdfQkFUVEVSWV9TQlMgaXMgbm90IHNldAojIENPTkZJR19CQVRURVJZ
X0JRMjd4MDAgaXMgbm90IHNldApDT05GSUdfQkFUVEVSWV9NQVgxNzA0MD15CiMgQ09ORklH
X0JBVFRFUllfTUFYMTcwNDIgaXMgbm90IHNldAojIENPTkZJR19DSEFSR0VSX1BDRjUwNjMz
IGlzIG5vdCBzZXQKIyBDT05GSUdfQ0hBUkdFUl9NQVg4OTAzIGlzIG5vdCBzZXQKIyBDT05G
SUdfQ0hBUkdFUl9MUDg3MjcgaXMgbm90IHNldAojIENPTkZJR19DSEFSR0VSX1NNQjM0NyBp
cyBub3Qgc2V0CiMgQ09ORklHX1BPV0VSX0FWUyBpcyBub3Qgc2V0CkNPTkZJR19IV01PTj15
CkNPTkZJR19IV01PTl9WSUQ9eQpDT05GSUdfSFdNT05fREVCVUdfQ0hJUD15CgojCiMgTmF0
aXZlIGRyaXZlcnMKIwojIENPTkZJR19TRU5TT1JTX0FENzMxNCBpcyBub3Qgc2V0CiMgQ09O
RklHX1NFTlNPUlNfQUQ3NDE0IGlzIG5vdCBzZXQKQ09ORklHX1NFTlNPUlNfQUQ3NDE4PXkK
Q09ORklHX1NFTlNPUlNfQURDWFg9eQpDT05GSUdfU0VOU09SU19BRE0xMDIxPXkKIyBDT05G
SUdfU0VOU09SU19BRE0xMDI1IGlzIG5vdCBzZXQKQ09ORklHX1NFTlNPUlNfQURNMTAyNj15
CiMgQ09ORklHX1NFTlNPUlNfQURNMTAyOSBpcyBub3Qgc2V0CkNPTkZJR19TRU5TT1JTX0FE
TTEwMzE9eQojIENPTkZJR19TRU5TT1JTX0FETTkyNDAgaXMgbm90IHNldAojIENPTkZJR19T
RU5TT1JTX0FEVDc0MTAgaXMgbm90IHNldApDT05GSUdfU0VOU09SU19BRFQ3NDExPXkKQ09O
RklHX1NFTlNPUlNfQURUNzQ2Mj15CiMgQ09ORklHX1NFTlNPUlNfQURUNzQ3MCBpcyBub3Qg
c2V0CiMgQ09ORklHX1NFTlNPUlNfQURUNzQ3NSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNP
UlNfQVNDNzYyMSBpcyBub3Qgc2V0CkNPTkZJR19TRU5TT1JTX0s4VEVNUD15CiMgQ09ORklH
X1NFTlNPUlNfSzEwVEVNUCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfRkFNMTVIX1BP
V0VSIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19BU0IxMDAgaXMgbm90IHNldAojIENP
TkZJR19TRU5TT1JTX0FUWFAxIGlzIG5vdCBzZXQKQ09ORklHX1NFTlNPUlNfRFM2MjA9eQoj
IENPTkZJR19TRU5TT1JTX0RTMTYyMSBpcyBub3Qgc2V0CkNPTkZJR19TRU5TT1JTX0k1S19B
TUI9eQpDT05GSUdfU0VOU09SU19GNzE4MDVGPXkKIyBDT05GSUdfU0VOU09SU19GNzE4ODJG
RyBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfRjc1Mzc1UyBpcyBub3Qgc2V0CkNPTkZJ
R19TRU5TT1JTX0ZTQ0hNRD15CkNPTkZJR19TRU5TT1JTX0c3NjBBPXkKIyBDT05GSUdfU0VO
U09SU19HTDUxOFNNIGlzIG5vdCBzZXQKQ09ORklHX1NFTlNPUlNfR0w1MjBTTT15CkNPTkZJ
R19TRU5TT1JTX0hJSDYxMzA9eQojIENPTkZJR19TRU5TT1JTX0NPUkVURU1QIGlzIG5vdCBz
ZXQKQ09ORklHX1NFTlNPUlNfSUJNQUVNPXkKIyBDT05GSUdfU0VOU09SU19JQk1QRVggaXMg
bm90IHNldApDT05GSUdfU0VOU09SU19JVDg3PXkKIyBDT05GSUdfU0VOU09SU19KQzQyIGlz
IG5vdCBzZXQKQ09ORklHX1NFTlNPUlNfTElORUFHRT15CkNPTkZJR19TRU5TT1JTX0xNNjM9
eQojIENPTkZJR19TRU5TT1JTX0xNNzAgaXMgbm90IHNldApDT05GSUdfU0VOU09SU19MTTcz
PXkKIyBDT05GSUdfU0VOU09SU19MTTc1IGlzIG5vdCBzZXQKQ09ORklHX1NFTlNPUlNfTE03
Nz15CiMgQ09ORklHX1NFTlNPUlNfTE03OCBpcyBub3Qgc2V0CkNPTkZJR19TRU5TT1JTX0xN
ODA9eQojIENPTkZJR19TRU5TT1JTX0xNODMgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JT
X0xNODUgaXMgbm90IHNldApDT05GSUdfU0VOU09SU19MTTg3PXkKQ09ORklHX1NFTlNPUlNf
TE05MD15CkNPTkZJR19TRU5TT1JTX0xNOTI9eQojIENPTkZJR19TRU5TT1JTX0xNOTMgaXMg
bm90IHNldAojIENPTkZJR19TRU5TT1JTX0xUQzQxNTEgaXMgbm90IHNldAojIENPTkZJR19T
RU5TT1JTX0xUQzQyMTUgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0xUQzQyNDUgaXMg
bm90IHNldAojIENPTkZJR19TRU5TT1JTX0xUQzQyNjEgaXMgbm90IHNldApDT05GSUdfU0VO
U09SU19MTTk1MjQxPXkKQ09ORklHX1NFTlNPUlNfTE05NTI0NT15CiMgQ09ORklHX1NFTlNP
UlNfTUFYMTExMSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfTUFYMTYwNjUgaXMgbm90
IHNldApDT05GSUdfU0VOU09SU19NQVgxNjE5PXkKIyBDT05GSUdfU0VOU09SU19NQVgxNjY4
IGlzIG5vdCBzZXQKQ09ORklHX1NFTlNPUlNfTUFYMTk3PXkKQ09ORklHX1NFTlNPUlNfTUFY
NjYzOT15CkNPTkZJR19TRU5TT1JTX01BWDY2NDI9eQpDT05GSUdfU0VOU09SU19NQVg2NjUw
PXkKQ09ORklHX1NFTlNPUlNfTUNQMzAyMT15CkNPTkZJR19TRU5TT1JTX05UQ19USEVSTUlT
VE9SPXkKIyBDT05GSUdfU0VOU09SU19QQzg3MzYwIGlzIG5vdCBzZXQKQ09ORklHX1NFTlNP
UlNfUEM4NzQyNz15CkNPTkZJR19TRU5TT1JTX1BDRjg1OTE9eQpDT05GSUdfUE1CVVM9eQpD
T05GSUdfU0VOU09SU19QTUJVUz15CiMgQ09ORklHX1NFTlNPUlNfQURNMTI3NSBpcyBub3Qg
c2V0CkNPTkZJR19TRU5TT1JTX0xNMjUwNjY9eQojIENPTkZJR19TRU5TT1JTX0xUQzI5Nzgg
aXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX01BWDE2MDY0IGlzIG5vdCBzZXQKQ09ORklH
X1NFTlNPUlNfTUFYMzQ0NDA9eQojIENPTkZJR19TRU5TT1JTX01BWDg2ODggaXMgbm90IHNl
dAojIENPTkZJR19TRU5TT1JTX1VDRDkwMDAgaXMgbm90IHNldApDT05GSUdfU0VOU09SU19V
Q0Q5MjAwPXkKIyBDT05GSUdfU0VOU09SU19aTDYxMDAgaXMgbm90IHNldApDT05GSUdfU0VO
U09SU19TSFQyMT15CiMgQ09ORklHX1NFTlNPUlNfU0lTNTU5NSBpcyBub3Qgc2V0CiMgQ09O
RklHX1NFTlNPUlNfU01NNjY1IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19ETUUxNzM3
IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19FTUMxNDAzIGlzIG5vdCBzZXQKQ09ORklH
X1NFTlNPUlNfRU1DMjEwMz15CkNPTkZJR19TRU5TT1JTX0VNQzZXMjAxPXkKIyBDT05GSUdf
U0VOU09SU19TTVNDNDdNMSBpcyBub3Qgc2V0CkNPTkZJR19TRU5TT1JTX1NNU0M0N00xOTI9
eQpDT05GSUdfU0VOU09SU19TTVNDNDdCMzk3PXkKIyBDT05GSUdfU0VOU09SU19TQ0g1NlhY
X0NPTU1PTiBpcyBub3Qgc2V0CkNPTkZJR19TRU5TT1JTX0FEUzEwMTU9eQpDT05GSUdfU0VO
U09SU19BRFM3ODI4PXkKQ09ORklHX1NFTlNPUlNfQURTNzg3MT15CkNPTkZJR19TRU5TT1JT
X0FNQzY4MjE9eQpDT05GSUdfU0VOU09SU19JTkEyWFg9eQojIENPTkZJR19TRU5TT1JTX1RI
TUM1MCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfVE1QMTAyIGlzIG5vdCBzZXQKQ09O
RklHX1NFTlNPUlNfVE1QNDAxPXkKQ09ORklHX1NFTlNPUlNfVE1QNDIxPXkKIyBDT05GSUdf
U0VOU09SU19WSUFfQ1BVVEVNUCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfVklBNjg2
QSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfVlQxMjExIGlzIG5vdCBzZXQKQ09ORklH
X1NFTlNPUlNfVlQ4MjMxPXkKIyBDT05GSUdfU0VOU09SU19XODM3ODFEIGlzIG5vdCBzZXQK
Q09ORklHX1NFTlNPUlNfVzgzNzkxRD15CkNPTkZJR19TRU5TT1JTX1c4Mzc5MkQ9eQpDT05G
SUdfU0VOU09SU19XODM3OTM9eQojIENPTkZJR19TRU5TT1JTX1c4Mzc5NSBpcyBub3Qgc2V0
CkNPTkZJR19TRU5TT1JTX1c4M0w3ODVUUz15CiMgQ09ORklHX1NFTlNPUlNfVzgzTDc4Nk5H
IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19XODM2MjdIRiBpcyBub3Qgc2V0CiMgQ09O
RklHX1NFTlNPUlNfVzgzNjI3RUhGIGlzIG5vdCBzZXQKQ09ORklHX1NFTlNPUlNfV004MzFY
PXkKCiMKIyBBQ1BJIGRyaXZlcnMKIwojIENPTkZJR19TRU5TT1JTX0FDUElfUE9XRVIgaXMg
bm90IHNldAojIENPTkZJR19TRU5TT1JTX0FUSzAxMTAgaXMgbm90IHNldApDT05GSUdfVEhF
Uk1BTD15CkNPTkZJR19USEVSTUFMX0hXTU9OPXkKQ09ORklHX0ZBSVJfU0hBUkU9eQpDT05G
SUdfU1RFUF9XSVNFPXkKQ09ORklHX1VTRVJfU1BBQ0U9eQojIENPTkZJR19USEVSTUFMX0RF
RkFVTFRfR09WX1NURVBfV0lTRSBpcyBub3Qgc2V0CkNPTkZJR19USEVSTUFMX0RFRkFVTFRf
R09WX0ZBSVJfU0hBUkU9eQojIENPTkZJR19USEVSTUFMX0RFRkFVTFRfR09WX1VTRVJfU1BB
Q0UgaXMgbm90IHNldAojIENPTkZJR19XQVRDSERPRyBpcyBub3Qgc2V0CkNPTkZJR19TU0Jf
UE9TU0lCTEU9eQoKIwojIFNvbmljcyBTaWxpY29uIEJhY2twbGFuZQojCiMgQ09ORklHX1NT
QiBpcyBub3Qgc2V0CkNPTkZJR19CQ01BX1BPU1NJQkxFPXkKCiMKIyBCcm9hZGNvbSBzcGVj
aWZpYyBBTUJBCiMKQ09ORklHX0JDTUE9eQpDT05GSUdfQkNNQV9IT1NUX1BDSV9QT1NTSUJM
RT15CkNPTkZJR19CQ01BX0hPU1RfUENJPXkKIyBDT05GSUdfQkNNQV9EUklWRVJfR01BQ19D
TU4gaXMgbm90IHNldApDT05GSUdfQkNNQV9ERUJVRz15CgojCiMgTXVsdGlmdW5jdGlvbiBk
ZXZpY2UgZHJpdmVycwojCkNPTkZJR19NRkRfQ09SRT15CkNPTkZJR19NRkRfODhQTTg2MFg9
eQpDT05GSUdfTUZEXzg4UE04MDA9eQpDT05GSUdfTUZEXzg4UE04MDU9eQojIENPTkZJR19N
RkRfU001MDEgaXMgbm90IHNldApDT05GSUdfTUZEX1RJX0FNMzM1WF9UU0NBREM9eQpDT05G
SUdfSFRDX1BBU0lDMz15CiMgQ09ORklHX01GRF9MTTM1MzMgaXMgbm90IHNldApDT05GSUdf
VFBTNjEwNVg9eQojIENPTkZJR19UUFM2NTA3WCBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9U
UFM2NTIxNyBpcyBub3Qgc2V0CkNPTkZJR19NRkRfVFBTNjU4Nlg9eQojIENPTkZJR19UV0w0
MDMwX0NPUkUgaXMgbm90IHNldAojIENPTkZJR19UV0w2MDQwX0NPUkUgaXMgbm90IHNldApD
T05GSUdfTUZEX1NUTVBFPXkKCiMKIyBTVE1QRSBJbnRlcmZhY2UgRHJpdmVycwojCiMgQ09O
RklHX1NUTVBFX0kyQyBpcyBub3Qgc2V0CiMgQ09ORklHX1NUTVBFX1NQSSBpcyBub3Qgc2V0
CkNPTkZJR19NRkRfVEMzNTg5WD15CiMgQ09ORklHX01GRF9UTUlPIGlzIG5vdCBzZXQKIyBD
T05GSUdfTUZEX1NNU0MgaXMgbm90IHNldAojIENPTkZJR19QTUlDX0RBOTAzWCBpcyBub3Qg
c2V0CiMgQ09ORklHX01GRF9EQTkwNTJfU1BJIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX0RB
OTA1Ml9JMkMgaXMgbm90IHNldAojIENPTkZJR19NRkRfREE5MDU1IGlzIG5vdCBzZXQKQ09O
RklHX1BNSUNfQURQNTUyMD15CkNPTkZJR19NRkRfTFA4Nzg4PXkKQ09ORklHX01GRF9NQVg3
NzY4Nj15CkNPTkZJR19NRkRfTUFYNzc2OTM9eQojIENPTkZJR19NRkRfTUFYODkwNyBpcyBu
b3Qgc2V0CkNPTkZJR19NRkRfTUFYODkyNT15CkNPTkZJR19NRkRfTUFYODk5Nz15CkNPTkZJ
R19NRkRfTUFYODk5OD15CkNPTkZJR19NRkRfU0VDX0NPUkU9eQpDT05GSUdfTUZEX0FSSVpP
TkE9eQpDT05GSUdfTUZEX0FSSVpPTkFfSTJDPXkKQ09ORklHX01GRF9BUklaT05BX1NQST15
CiMgQ09ORklHX01GRF9XTTUxMDIgaXMgbm90IHNldAojIENPTkZJR19NRkRfV001MTEwIGlz
IG5vdCBzZXQKQ09ORklHX01GRF9XTTg0MDA9eQpDT05GSUdfTUZEX1dNODMxWD15CkNPTkZJ
R19NRkRfV004MzFYX0kyQz15CiMgQ09ORklHX01GRF9XTTgzMVhfU1BJIGlzIG5vdCBzZXQK
IyBDT05GSUdfTUZEX1dNODM1MF9JMkMgaXMgbm90IHNldAojIENPTkZJR19NRkRfV004OTk0
IGlzIG5vdCBzZXQKQ09ORklHX01GRF9QQ0Y1MDYzMz15CiMgQ09ORklHX1BDRjUwNjMzX0FE
QyBpcyBub3Qgc2V0CkNPTkZJR19QQ0Y1MDYzM19HUElPPXkKIyBDT05GSUdfTUZEX01DMTNY
WFhfU1BJIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX01DMTNYWFhfSTJDIGlzIG5vdCBzZXQK
IyBDT05GSUdfQUJYNTAwX0NPUkUgaXMgbm90IHNldApDT05GSUdfRVpYX1BDQVA9eQpDT05G
SUdfTUZEX0NTNTUzNT15CkNPTkZJR19MUENfU0NIPXkKQ09ORklHX0xQQ19JQ0g9eQojIENP
TkZJR19NRkRfUkRDMzIxWCBpcyBub3Qgc2V0CkNPTkZJR19NRkRfSkFOWl9DTU9ESU89eQoj
IENPTkZJR19NRkRfVlg4NTUgaXMgbm90IHNldApDT05GSUdfTUZEX1dMMTI3M19DT1JFPXkK
IyBDT05GSUdfTUZEX1RQUzY1MDkwIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX1JDNVQ1ODMg
aXMgbm90IHNldAojIENPTkZJR19NRkRfUEFMTUFTIGlzIG5vdCBzZXQKQ09ORklHX1JFR1VM
QVRPUj15CkNPTkZJR19SRUdVTEFUT1JfREVCVUc9eQpDT05GSUdfUkVHVUxBVE9SX0RVTU1Z
PXkKQ09ORklHX1JFR1VMQVRPUl9GSVhFRF9WT0xUQUdFPXkKIyBDT05GSUdfUkVHVUxBVE9S
X1ZJUlRVQUxfQ09OU1VNRVIgaXMgbm90IHNldAojIENPTkZJR19SRUdVTEFUT1JfVVNFUlNQ
QUNFX0NPTlNVTUVSIGlzIG5vdCBzZXQKIyBDT05GSUdfUkVHVUxBVE9SX0FENTM5OCBpcyBu
b3Qgc2V0CiMgQ09ORklHX1JFR1VMQVRPUl9BUklaT05BIGlzIG5vdCBzZXQKIyBDT05GSUdf
UkVHVUxBVE9SX0ZBTjUzNTU1IGlzIG5vdCBzZXQKQ09ORklHX1JFR1VMQVRPUl9JU0w2Mjcx
QT15CkNPTkZJR19SRUdVTEFUT1JfODhQTTg2MDc9eQpDT05GSUdfUkVHVUxBVE9SX01BWDE1
ODY9eQpDT05GSUdfUkVHVUxBVE9SX01BWDg2NDk9eQojIENPTkZJR19SRUdVTEFUT1JfTUFY
ODY2MCBpcyBub3Qgc2V0CkNPTkZJR19SRUdVTEFUT1JfTUFYODkyNT15CkNPTkZJR19SRUdV
TEFUT1JfTUFYODk1Mj15CiMgQ09ORklHX1JFR1VMQVRPUl9NQVg4OTk3IGlzIG5vdCBzZXQK
IyBDT05GSUdfUkVHVUxBVE9SX01BWDg5OTggaXMgbm90IHNldApDT05GSUdfUkVHVUxBVE9S
X01BWDc3Njg2PXkKIyBDT05GSUdfUkVHVUxBVE9SX1BDQVAgaXMgbm90IHNldAojIENPTkZJ
R19SRUdVTEFUT1JfTFAzOTcxIGlzIG5vdCBzZXQKQ09ORklHX1JFR1VMQVRPUl9MUDM5NzI9
eQojIENPTkZJR19SRUdVTEFUT1JfTFA4NzJYIGlzIG5vdCBzZXQKIyBDT05GSUdfUkVHVUxB
VE9SX0xQODc4OCBpcyBub3Qgc2V0CkNPTkZJR19SRUdVTEFUT1JfUENGNTA2MzM9eQpDT05G
SUdfUkVHVUxBVE9SX1MyTVBTMTE9eQojIENPTkZJR19SRUdVTEFUT1JfUzVNODc2NyBpcyBu
b3Qgc2V0CkNPTkZJR19SRUdVTEFUT1JfVFBTNTE2MzI9eQpDT05GSUdfUkVHVUxBVE9SX1RQ
UzYxMDVYPXkKIyBDT05GSUdfUkVHVUxBVE9SX1RQUzYyMzYwIGlzIG5vdCBzZXQKIyBDT05G
SUdfUkVHVUxBVE9SX1RQUzY1MDIzIGlzIG5vdCBzZXQKQ09ORklHX1JFR1VMQVRPUl9UUFM2
NTA3WD15CiMgQ09ORklHX1JFR1VMQVRPUl9UUFM2NTI0WCBpcyBub3Qgc2V0CiMgQ09ORklH
X1JFR1VMQVRPUl9UUFM2NTg2WCBpcyBub3Qgc2V0CiMgQ09ORklHX1JFR1VMQVRPUl9XTTgz
MVggaXMgbm90IHNldAojIENPTkZJR19SRUdVTEFUT1JfV004NDAwIGlzIG5vdCBzZXQKQ09O
RklHX01FRElBX1NVUFBPUlQ9eQoKIwojIE11bHRpbWVkaWEgY29yZSBzdXBwb3J0CiMKIyBD
T05GSUdfTUVESUFfQ0FNRVJBX1NVUFBPUlQgaXMgbm90IHNldApDT05GSUdfTUVESUFfQU5B
TE9HX1RWX1NVUFBPUlQ9eQpDT05GSUdfTUVESUFfRElHSVRBTF9UVl9TVVBQT1JUPXkKQ09O
RklHX01FRElBX1JBRElPX1NVUFBPUlQ9eQpDT05GSUdfVklERU9fREVWPXkKQ09ORklHX1ZJ
REVPX1Y0TDI9eQojIENPTkZJR19WSURFT19BRFZfREVCVUcgaXMgbm90IHNldAojIENPTkZJ
R19WSURFT19GSVhFRF9NSU5PUl9SQU5HRVMgaXMgbm90IHNldApDT05GSUdfVklERU9fVFVO
RVI9eQpDT05GSUdfVklERU9CVUZfR0VOPXkKQ09ORklHX1ZJREVPQlVGX0RNQV9TRz15CkNP
TkZJR19WSURFT0JVRl9EVkI9eQpDT05GSUdfRFZCX0NPUkU9eQpDT05GSUdfRFZCX05FVD15
CkNPTkZJR19EVkJfTUFYX0FEQVBURVJTPTgKIyBDT05GSUdfRFZCX0RZTkFNSUNfTUlOT1JT
IGlzIG5vdCBzZXQKCiMKIyBNZWRpYSBkcml2ZXJzCiMKIyBDT05GSUdfTUVESUFfVVNCX1NV
UFBPUlQgaXMgbm90IHNldApDT05GSUdfTUVESUFfUENJX1NVUFBPUlQ9eQoKIwojIE1lZGlh
IGNhcHR1cmUvYW5hbG9nIFRWIHN1cHBvcnQKIwpDT05GSUdfVklERU9fWk9SQU49eQpDT05G
SUdfVklERU9fWk9SQU5fREMzMD15CkNPTkZJR19WSURFT19aT1JBTl9aUjM2MDYwPXkKIyBD
T05GSUdfVklERU9fWk9SQU5fQlVaIGlzIG5vdCBzZXQKQ09ORklHX1ZJREVPX1pPUkFOX0RD
MTA9eQojIENPTkZJR19WSURFT19aT1JBTl9MTUwzMyBpcyBub3Qgc2V0CkNPTkZJR19WSURF
T19aT1JBTl9MTUwzM1IxMD15CiMgQ09ORklHX1ZJREVPX1pPUkFOX0FWUzZFWUVTIGlzIG5v
dCBzZXQKIyBDT05GSUdfVklERU9fSEVYSVVNX0dFTUlOSSBpcyBub3Qgc2V0CkNPTkZJR19W
SURFT19IRVhJVU1fT1JJT049eQpDT05GSUdfVklERU9fTVhCPXkKCiMKIyBNZWRpYSBjYXB0
dXJlL2FuYWxvZy9oeWJyaWQgVFYgc3VwcG9ydAojCiMgQ09ORklHX1ZJREVPX1NBQTcxMzQg
aXMgbm90IHNldApDT05GSUdfVklERU9fU0FBNzE2ND15CgojCiMgTWVkaWEgZGlnaXRhbCBU
ViBQQ0kgQWRhcHRlcnMKIwpDT05GSUdfVFRQQ0lfRUVQUk9NPXkKIyBDT05GSUdfRFZCX0FW
NzExMCBpcyBub3Qgc2V0CkNPTkZJR19EVkJfQlVER0VUX0NPUkU9eQojIENPTkZJR19EVkJf
QlVER0VUIGlzIG5vdCBzZXQKIyBDT05GSUdfRFZCX0JVREdFVF9BViBpcyBub3Qgc2V0CkNP
TkZJR19EVkJfQjJDMl9GTEVYQ09QX1BDST15CkNPTkZJR19EVkJfQjJDMl9GTEVYQ09QX1BD
SV9ERUJVRz15CkNPTkZJR19EVkJfUExVVE8yPXkKQ09ORklHX0RWQl9QVDE9eQojIENPTkZJ
R19EVkJfTkdFTkUgaXMgbm90IHNldApDT05GSUdfRFZCX0REQlJJREdFPXkKCiMKIyBTdXBw
b3J0ZWQgTU1DL1NESU8gYWRhcHRlcnMKIwojIENPTkZJR19SQURJT19BREFQVEVSUyBpcyBu
b3Qgc2V0CgojCiMgU3VwcG9ydGVkIEZpcmVXaXJlIChJRUVFIDEzOTQpIEFkYXB0ZXJzCiMK
IyBDT05GSUdfRFZCX0ZJUkVEVFYgaXMgbm90IHNldApDT05GSUdfRFZCX0IyQzJfRkxFWENP
UD15CkNPTkZJR19EVkJfQjJDMl9GTEVYQ09QX0RFQlVHPXkKQ09ORklHX1ZJREVPX1NBQTcx
NDY9eQpDT05GSUdfVklERU9fU0FBNzE0Nl9WVj15CkNPTkZJR19NRURJQV9TVUJEUlZfQVVU
T1NFTEVDVD15CgojCiMgTWVkaWEgYW5jaWxsYXJ5IGRyaXZlcnMgKHR1bmVycywgc2Vuc29y
cywgaTJjLCBmcm9udGVuZHMpCiMKQ09ORklHX1ZJREVPX1RWRUVQUk9NPXkKCiMKIyBBdWRp
byBkZWNvZGVycywgcHJvY2Vzc29ycyBhbmQgbWl4ZXJzCiMKQ09ORklHX1ZJREVPX1REQTk4
NDA9eQpDT05GSUdfVklERU9fVEVBNjQxNUM9eQpDT05GSUdfVklERU9fVEVBNjQyMD15Cgoj
CiMgUkRTIGRlY29kZXJzCiMKCiMKIyBWaWRlbyBkZWNvZGVycwojCkNPTkZJR19WSURFT19T
QUE3MTEwPXkKQ09ORklHX1ZJREVPX1NBQTcxMVg9eQpDT05GSUdfVklERU9fVlBYMzIyMD15
CgojCiMgVmlkZW8gYW5kIGF1ZGlvIGRlY29kZXJzCiMKCiMKIyBNUEVHIHZpZGVvIGVuY29k
ZXJzCiMKCiMKIyBWaWRlbyBlbmNvZGVycwojCkNPTkZJR19WSURFT19BRFY3MTcwPXkKQ09O
RklHX1ZJREVPX0FEVjcxNzU9eQoKIwojIENhbWVyYSBzZW5zb3IgZGV2aWNlcwojCgojCiMg
Rmxhc2ggZGV2aWNlcwojCgojCiMgVmlkZW8gaW1wcm92ZW1lbnQgY2hpcHMKIwoKIwojIE1p
c2NlbGFuZW91cyBoZWxwZXIgY2hpcHMKIwoKIwojIFNlbnNvcnMgdXNlZCBvbiBzb2NfY2Ft
ZXJhIGRyaXZlcgojCkNPTkZJR19NRURJQV9UVU5FUj15CkNPTkZJR19NRURJQV9UVU5FUl9T
SU1QTEU9eQpDT05GSUdfTUVESUFfVFVORVJfVERBODI5MD15CkNPTkZJR19NRURJQV9UVU5F
Ul9UREE4MjdYPXkKQ09ORklHX01FRElBX1RVTkVSX1REQTE4MjcxPXkKQ09ORklHX01FRElB
X1RVTkVSX1REQTk4ODc9eQpDT05GSUdfTUVESUFfVFVORVJfVEVBNTc2MT15CkNPTkZJR19N
RURJQV9UVU5FUl9URUE1NzY3PXkKQ09ORklHX01FRElBX1RVTkVSX01UMjBYWD15CkNPTkZJ
R19NRURJQV9UVU5FUl9YQzIwMjg9eQpDT05GSUdfTUVESUFfVFVORVJfWEM1MDAwPXkKQ09O
RklHX01FRElBX1RVTkVSX1hDNDAwMD15CkNPTkZJR19NRURJQV9UVU5FUl9NQzQ0UzgwMz15
CgojCiMgTXVsdGlzdGFuZGFyZCAoc2F0ZWxsaXRlKSBmcm9udGVuZHMKIwpDT05GSUdfRFZC
X1NUVjA5MHg9eQpDT05GSUdfRFZCX1NUVjYxMTB4PXkKCiMKIyBNdWx0aXN0YW5kYXJkIChj
YWJsZSArIHRlcnJlc3RyaWFsKSBmcm9udGVuZHMKIwpDT05GSUdfRFZCX0RSWEs9eQpDT05G
SUdfRFZCX1REQTE4MjcxQzJERD15CgojCiMgRFZCLVMgKHNhdGVsbGl0ZSkgZnJvbnRlbmRz
CiMKQ09ORklHX0RWQl9DWDI0MTIzPXkKQ09ORklHX0RWQl9NVDMxMj15CkNPTkZJR19EVkJf
UzVIMTQyMD15CkNPTkZJR19EVkJfU1RWMDI5OT15CkNPTkZJR19EVkJfVFVORVJfSVREMTAw
MD15CkNPTkZJR19EVkJfVFVORVJfQ1gyNDExMz15CgojCiMgRFZCLVQgKHRlcnJlc3RyaWFs
KSBmcm9udGVuZHMKIwpDT05GSUdfRFZCX1REQTEwMDRYPXkKQ09ORklHX0RWQl9NVDM1Mj15
CkNPTkZJR19EVkJfVERBMTAwNDg9eQoKIwojIERWQi1DIChjYWJsZSkgZnJvbnRlbmRzCiMK
Q09ORklHX0RWQl9TVFYwMjk3PXkKCiMKIyBBVFNDIChOb3J0aCBBbWVyaWNhbi9Lb3JlYW4g
VGVycmVzdHJpYWwvQ2FibGUgRFRWKSBmcm9udGVuZHMKIwpDT05GSUdfRFZCX05YVDIwMFg9
eQpDT05GSUdfRFZCX0JDTTM1MTA9eQpDT05GSUdfRFZCX0xHRFQzMzBYPXkKQ09ORklHX0RW
Ql9TNUgxNDExPXkKCiMKIyBJU0RCLVQgKHRlcnJlc3RyaWFsKSBmcm9udGVuZHMKIwoKIwoj
IERpZ2l0YWwgdGVycmVzdHJpYWwgb25seSB0dW5lcnMvUExMCiMKQ09ORklHX0RWQl9QTEw9
eQoKIwojIFNFQyBjb250cm9sIGRldmljZXMgZm9yIERWQi1TCiMKQ09ORklHX0RWQl9MTkJQ
MjE9eQpDT05GSUdfRFZCX0lTTDY0MjE9eQoKIwojIFRvb2xzIHRvIGRldmVsb3AgbmV3IGZy
b250ZW5kcwojCiMgQ09ORklHX0RWQl9EVU1NWV9GRSBpcyBub3Qgc2V0CgojCiMgR3JhcGhp
Y3Mgc3VwcG9ydAojCiMgQ09ORklHX0FHUCBpcyBub3Qgc2V0CkNPTkZJR19WR0FfQVJCPXkK
Q09ORklHX1ZHQV9BUkJfTUFYX0dQVVM9MTYKQ09ORklHX1ZHQV9TV0lUQ0hFUk9PPXkKQ09O
RklHX0RSTT15CkNPTkZJR19EUk1fS01TX0hFTFBFUj15CiMgQ09ORklHX0RSTV9MT0FEX0VE
SURfRklSTVdBUkUgaXMgbm90IHNldApDT05GSUdfRFJNX1RUTT15CkNPTkZJR19EUk1fVERG
WD15CiMgQ09ORklHX0RSTV9SMTI4IGlzIG5vdCBzZXQKIyBDT05GSUdfRFJNX1JBREVPTiBp
cyBub3Qgc2V0CkNPTkZJR19EUk1fTk9VVkVBVT15CkNPTkZJR19OT1VWRUFVX0RFQlVHPTUK
Q09ORklHX05PVVZFQVVfREVCVUdfREVGQVVMVD0zCiMgQ09ORklHX0RSTV9OT1VWRUFVX0JB
Q0tMSUdIVCBpcyBub3Qgc2V0CgojCiMgSTJDIGVuY29kZXIgb3IgaGVscGVyIGNoaXBzCiMK
Q09ORklHX0RSTV9JMkNfQ0g3MDA2PXkKQ09ORklHX0RSTV9JMkNfU0lMMTY0PXkKQ09ORklH
X0RSTV9NR0E9eQojIENPTkZJR19EUk1fVklBIGlzIG5vdCBzZXQKIyBDT05GSUdfRFJNX1NB
VkFHRSBpcyBub3Qgc2V0CiMgQ09ORklHX0RSTV9WTVdHRlggaXMgbm90IHNldAojIENPTkZJ
R19EUk1fR01BNTAwIGlzIG5vdCBzZXQKIyBDT05GSUdfRFJNX1VETCBpcyBub3Qgc2V0CiMg
Q09ORklHX0RSTV9BU1QgaXMgbm90IHNldApDT05GSUdfRFJNX01HQUcyMDA9eQpDT05GSUdf
RFJNX0NJUlJVU19RRU1VPXkKIyBDT05GSUdfU1RVQl9QT1VMU0JPIGlzIG5vdCBzZXQKQ09O
RklHX1ZHQVNUQVRFPXkKQ09ORklHX1ZJREVPX09VVFBVVF9DT05UUk9MPXkKQ09ORklHX0ZC
PXkKQ09ORklHX0ZJUk1XQVJFX0VESUQ9eQpDT05GSUdfRkJfRERDPXkKIyBDT05GSUdfRkJf
Qk9PVF9WRVNBX1NVUFBPUlQgaXMgbm90IHNldApDT05GSUdfRkJfQ0ZCX0ZJTExSRUNUPXkK
Q09ORklHX0ZCX0NGQl9DT1BZQVJFQT15CkNPTkZJR19GQl9DRkJfSU1BR0VCTElUPXkKIyBD
T05GSUdfRkJfQ0ZCX1JFVl9QSVhFTFNfSU5fQllURSBpcyBub3Qgc2V0CkNPTkZJR19GQl9T
WVNfRklMTFJFQ1Q9eQpDT05GSUdfRkJfU1lTX0NPUFlBUkVBPXkKQ09ORklHX0ZCX1NZU19J
TUFHRUJMSVQ9eQpDT05GSUdfRkJfRk9SRUlHTl9FTkRJQU49eQpDT05GSUdfRkJfQk9USF9F
TkRJQU49eQojIENPTkZJR19GQl9CSUdfRU5ESUFOIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJf
TElUVExFX0VORElBTiBpcyBub3Qgc2V0CkNPTkZJR19GQl9TWVNfRk9QUz15CiMgQ09ORklH
X0ZCX1dNVF9HRV9ST1BTIGlzIG5vdCBzZXQKQ09ORklHX0ZCX0RFRkVSUkVEX0lPPXkKQ09O
RklHX0ZCX0hFQ1VCQT15CkNPTkZJR19GQl9TVkdBTElCPXkKIyBDT05GSUdfRkJfTUFDTU9E
RVMgaXMgbm90IHNldAojIENPTkZJR19GQl9CQUNLTElHSFQgaXMgbm90IHNldApDT05GSUdf
RkJfTU9ERV9IRUxQRVJTPXkKQ09ORklHX0ZCX1RJTEVCTElUVElORz15CgojCiMgRnJhbWUg
YnVmZmVyIGhhcmR3YXJlIGRyaXZlcnMKIwpDT05GSUdfRkJfQ0lSUlVTPXkKIyBDT05GSUdf
RkJfUE0yIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfQ1lCRVIyMDAwIGlzIG5vdCBzZXQKIyBD
T05GSUdfRkJfQVJDIGlzIG5vdCBzZXQKQ09ORklHX0ZCX0FTSUxJQU5UPXkKIyBDT05GSUdf
RkJfSU1TVFQgaXMgbm90IHNldAojIENPTkZJR19GQl9WR0ExNiBpcyBub3Qgc2V0CiMgQ09O
RklHX0ZCX1ZFU0EgaXMgbm90IHNldApDT05GSUdfRkJfRUZJPXkKQ09ORklHX0ZCX040MTE9
eQojIENPTkZJR19GQl9IR0EgaXMgbm90IHNldApDT05GSUdfRkJfUzFEMTNYWFg9eQojIENP
TkZJR19GQl9OVklESUEgaXMgbm90IHNldAojIENPTkZJR19GQl9SSVZBIGlzIG5vdCBzZXQK
IyBDT05GSUdfRkJfSTc0MCBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX0xFODA1NzggaXMgbm90
IHNldApDT05GSUdfRkJfTUFUUk9YPXkKIyBDT05GSUdfRkJfTUFUUk9YX01JTExFTklVTSBp
cyBub3Qgc2V0CiMgQ09ORklHX0ZCX01BVFJPWF9NWVNUSVFVRSBpcyBub3Qgc2V0CkNPTkZJ
R19GQl9NQVRST1hfRz15CkNPTkZJR19GQl9NQVRST1hfSTJDPXkKQ09ORklHX0ZCX01BVFJP
WF9NQVZFTj15CiMgQ09ORklHX0ZCX1JBREVPTiBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX0FU
WTEyOCBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX0FUWSBpcyBub3Qgc2V0CkNPTkZJR19GQl9T
Mz15CiMgQ09ORklHX0ZCX1MzX0REQyBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX1NBVkFHRSBp
cyBub3Qgc2V0CiMgQ09ORklHX0ZCX1NJUyBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX1ZJQSBp
cyBub3Qgc2V0CiMgQ09ORklHX0ZCX05FT01BR0lDIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJf
S1lSTyBpcyBub3Qgc2V0CkNPTkZJR19GQl8zREZYPXkKIyBDT05GSUdfRkJfM0RGWF9BQ0NF
TCBpcyBub3Qgc2V0CkNPTkZJR19GQl8zREZYX0kyQz15CkNPTkZJR19GQl9WT09ET08xPXkK
IyBDT05GSUdfRkJfVlQ4NjIzIGlzIG5vdCBzZXQKQ09ORklHX0ZCX1RSSURFTlQ9eQojIENP
TkZJR19GQl9BUksgaXMgbm90IHNldApDT05GSUdfRkJfUE0zPXkKQ09ORklHX0ZCX0NBUk1J
TkU9eQojIENPTkZJR19GQl9DQVJNSU5FX0RSQU1fRVZBTCBpcyBub3Qgc2V0CkNPTkZJR19D
QVJNSU5FX0RSQU1fQ1VTVE9NPXkKQ09ORklHX0ZCX0dFT0RFPXkKQ09ORklHX0ZCX0dFT0RF
X0xYPXkKIyBDT05GSUdfRkJfR0VPREVfR1ggaXMgbm90IHNldApDT05GSUdfRkJfR0VPREVf
R1gxPXkKQ09ORklHX0ZCX1RNSU89eQojIENPTkZJR19GQl9UTUlPX0FDQ0VMTCBpcyBub3Qg
c2V0CkNPTkZJR19GQl9TTVNDVUZYPXkKIyBDT05GSUdfRkJfVURMIGlzIG5vdCBzZXQKIyBD
T05GSUdfRkJfVklSVFVBTCBpcyBub3Qgc2V0CkNPTkZJR19YRU5fRkJERVZfRlJPTlRFTkQ9
eQojIENPTkZJR19GQl9NRVRST05PTUUgaXMgbm90IHNldAojIENPTkZJR19GQl9NQjg2MlhY
IGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfQlJPQURTSEVFVCBpcyBub3Qgc2V0CiMgQ09ORklH
X0ZCX0FVT19LMTkwWCBpcyBub3Qgc2V0CiMgQ09ORklHX0VYWU5PU19WSURFTyBpcyBub3Qg
c2V0CiMgQ09ORklHX0JBQ0tMSUdIVF9MQ0RfU1VQUE9SVCBpcyBub3Qgc2V0CkNPTkZJR19C
QUNLTElHSFRfQ0xBU1NfREVWSUNFPXkKIyBDT05GSUdfTE9HTyBpcyBub3Qgc2V0CkNPTkZJ
R19TT1VORD15CkNPTkZJR19TT1VORF9PU1NfQ09SRT15CkNPTkZJR19TT1VORF9PU1NfQ09S
RV9QUkVDTEFJTT15CiMgQ09ORklHX1NORCBpcyBub3Qgc2V0CkNPTkZJR19TT1VORF9QUklN
RT15CkNPTkZJR19VU0JfQVJDSF9IQVNfT0hDST15CkNPTkZJR19VU0JfQVJDSF9IQVNfRUhD
ST15CkNPTkZJR19VU0JfQVJDSF9IQVNfWEhDST15CkNPTkZJR19VU0JfU1VQUE9SVD15CkNP
TkZJR19VU0JfQ09NTU9OPXkKQ09ORklHX1VTQl9BUkNIX0hBU19IQ0Q9eQpDT05GSUdfVVNC
PXkKIyBDT05GSUdfVVNCX0RFQlVHIGlzIG5vdCBzZXQKQ09ORklHX1VTQl9BTk5PVU5DRV9O
RVdfREVWSUNFUz15CgojCiMgTWlzY2VsbGFuZW91cyBVU0Igb3B0aW9ucwojCiMgQ09ORklH
X1VTQl9EWU5BTUlDX01JTk9SUyBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TVVNQRU5EIGlz
IG5vdCBzZXQKQ09ORklHX1VTQl9PVEdfV0hJVEVMSVNUPXkKQ09ORklHX1VTQl9PVEdfQkxB
Q0tMSVNUX0hVQj15CiMgQ09ORklHX1VTQl9NT04gaXMgbm90IHNldAojIENPTkZJR19VU0Jf
V1VTQl9DQkFGIGlzIG5vdCBzZXQKCiMKIyBVU0IgSG9zdCBDb250cm9sbGVyIERyaXZlcnMK
IwojIENPTkZJR19VU0JfQzY3WDAwX0hDRCBpcyBub3Qgc2V0CkNPTkZJR19VU0JfWEhDSV9I
Q0Q9eQpDT05GSUdfVVNCX1hIQ0lfSENEX0RFQlVHR0lORz15CiMgQ09ORklHX1VTQl9FSENJ
X0hDRCBpcyBub3Qgc2V0CkNPTkZJR19VU0JfT1hVMjEwSFBfSENEPXkKQ09ORklHX1VTQl9J
U1AxMTZYX0hDRD15CiMgQ09ORklHX1VTQl9JU1AxNzYwX0hDRCBpcyBub3Qgc2V0CkNPTkZJ
R19VU0JfSVNQMTM2Ml9IQ0Q9eQpDT05GSUdfVVNCX09IQ0lfSENEPXkKQ09ORklHX1VTQl9P
SENJX0hDRF9QTEFURk9STT15CiMgQ09ORklHX1VTQl9PSENJX0JJR19FTkRJQU5fREVTQyBp
cyBub3Qgc2V0CiMgQ09ORklHX1VTQl9PSENJX0JJR19FTkRJQU5fTU1JTyBpcyBub3Qgc2V0
CkNPTkZJR19VU0JfT0hDSV9MSVRUTEVfRU5ESUFOPXkKIyBDT05GSUdfVVNCX1VIQ0lfSENE
IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1UxMzJfSENEIGlzIG5vdCBzZXQKIyBDT05GSUdf
VVNCX1NMODExX0hDRCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9SOEE2NjU5N19IQ0QgaXMg
bm90IHNldApDT05GSUdfVVNCX0hDRF9CQ01BPXkKIyBDT05GSUdfVVNCX0NISVBJREVBIGlz
IG5vdCBzZXQKCiMKIyBVU0IgRGV2aWNlIENsYXNzIGRyaXZlcnMKIwpDT05GSUdfVVNCX0FD
TT15CkNPTkZJR19VU0JfUFJJTlRFUj15CiMgQ09ORklHX1VTQl9XRE0gaXMgbm90IHNldAoj
IENPTkZJR19VU0JfVE1DIGlzIG5vdCBzZXQKCiMKIyBOT1RFOiBVU0JfU1RPUkFHRSBkZXBl
bmRzIG9uIFNDU0kgYnV0IEJMS19ERVZfU0QgbWF5CiMKCiMKIyBhbHNvIGJlIG5lZWRlZDsg
c2VlIFVTQl9TVE9SQUdFIEhlbHAgZm9yIG1vcmUgaW5mbwojCkNPTkZJR19VU0JfU1RPUkFH
RT15CiMgQ09ORklHX1VTQl9TVE9SQUdFX0RFQlVHIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNC
X1NUT1JBR0VfUkVBTFRFSyBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TVE9SQUdFX0RBVEFG
QUIgaXMgbm90IHNldAojIENPTkZJR19VU0JfU1RPUkFHRV9GUkVFQ09NIGlzIG5vdCBzZXQK
Q09ORklHX1VTQl9TVE9SQUdFX0lTRDIwMD15CkNPTkZJR19VU0JfU1RPUkFHRV9VU0JBVD15
CiMgQ09ORklHX1VTQl9TVE9SQUdFX1NERFIwOSBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9T
VE9SQUdFX1NERFI1NSBpcyBub3Qgc2V0CkNPTkZJR19VU0JfU1RPUkFHRV9KVU1QU0hPVD15
CiMgQ09ORklHX1VTQl9TVE9SQUdFX0FMQVVEQSBpcyBub3Qgc2V0CkNPTkZJR19VU0JfU1RP
UkFHRV9LQVJNQT15CiMgQ09ORklHX1VTQl9TVE9SQUdFX0NZUFJFU1NfQVRBQ0IgaXMgbm90
IHNldApDT05GSUdfVVNCX1NUT1JBR0VfRU5FX1VCNjI1MD15CiMgQ09ORklHX1VTQl9VQVMg
aXMgbm90IHNldAoKIwojIFVTQiBJbWFnaW5nIGRldmljZXMKIwojIENPTkZJR19VU0JfTURD
ODAwIGlzIG5vdCBzZXQKQ09ORklHX1VTQl9NSUNST1RFSz15CgojCiMgVVNCIHBvcnQgZHJp
dmVycwojCiMgQ09ORklHX1VTQl9VU1M3MjAgaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VS
SUFMIGlzIG5vdCBzZXQKCiMKIyBVU0IgTWlzY2VsbGFuZW91cyBkcml2ZXJzCiMKIyBDT05G
SUdfVVNCX0VNSTYyIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0VNSTI2IGlzIG5vdCBzZXQK
Q09ORklHX1VTQl9BRFVUVVg9eQpDT05GSUdfVVNCX1NFVlNFRz15CiMgQ09ORklHX1VTQl9S
SU81MDAgaXMgbm90IHNldAojIENPTkZJR19VU0JfTEVHT1RPV0VSIGlzIG5vdCBzZXQKQ09O
RklHX1VTQl9MQ0Q9eQojIENPTkZJR19VU0JfTEVEIGlzIG5vdCBzZXQKQ09ORklHX1VTQl9D
WVBSRVNTX0NZN0M2Mz15CkNPTkZJR19VU0JfQ1lUSEVSTT15CkNPTkZJR19VU0JfSURNT1VT
RT15CkNPTkZJR19VU0JfRlRESV9FTEFOPXkKIyBDT05GSUdfVVNCX0FQUExFRElTUExBWSBp
cyBub3Qgc2V0CkNPTkZJR19VU0JfTEQ9eQojIENPTkZJR19VU0JfVFJBTkNFVklCUkFUT1Ig
aXMgbm90IHNldApDT05GSUdfVVNCX0lPV0FSUklPUj15CiMgQ09ORklHX1VTQl9URVNUIGlz
IG5vdCBzZXQKIyBDT05GSUdfVVNCX0lTSUdIVEZXIGlzIG5vdCBzZXQKQ09ORklHX1VTQl9Z
VVJFWD15CiMgQ09ORklHX1VTQl9FWlVTQl9GWDIgaXMgbm90IHNldAoKIwojIFVTQiBQaHlz
aWNhbCBMYXllciBkcml2ZXJzCiMKIyBDT05GSUdfT01BUF9VU0IyIGlzIG5vdCBzZXQKQ09O
RklHX1VTQl9JU1AxMzAxPXkKQ09ORklHX1VTQl9BVE09eQpDT05GSUdfVVNCX1NQRUVEVE9V
Q0g9eQpDT05GSUdfVVNCX0NYQUNSVT15CkNPTkZJR19VU0JfVUVBR0xFQVRNPXkKQ09ORklH
X1VTQl9YVVNCQVRNPXkKIyBDT05GSUdfVVNCX0dBREdFVCBpcyBub3Qgc2V0CgojCiMgT1RH
IGFuZCByZWxhdGVkIGluZnJhc3RydWN0dXJlCiMKIyBDT05GSUdfTk9QX1VTQl9YQ0VJViBp
cyBub3Qgc2V0CiMgQ09ORklHX1VXQiBpcyBub3Qgc2V0CiMgQ09ORklHX01NQyBpcyBub3Qg
c2V0CkNPTkZJR19NRU1TVElDSz15CkNPTkZJR19NRU1TVElDS19ERUJVRz15CgojCiMgTWVt
b3J5U3RpY2sgZHJpdmVycwojCkNPTkZJR19NRU1TVElDS19VTlNBRkVfUkVTVU1FPXkKIyBD
T05GSUdfTVNQUk9fQkxPQ0sgaXMgbm90IHNldAojIENPTkZJR19NU19CTE9DSyBpcyBub3Qg
c2V0CgojCiMgTWVtb3J5U3RpY2sgSG9zdCBDb250cm9sbGVyIERyaXZlcnMKIwpDT05GSUdf
TUVNU1RJQ0tfVElGTV9NUz15CkNPTkZJR19NRU1TVElDS19KTUlDUk9OXzM4WD15CkNPTkZJ
R19NRU1TVElDS19SNTkyPXkKQ09ORklHX05FV19MRURTPXkKQ09ORklHX0xFRFNfQ0xBU1M9
eQoKIwojIExFRCBkcml2ZXJzCiMKQ09ORklHX0xFRFNfODhQTTg2MFg9eQpDT05GSUdfTEVE
U19MTTM1MzA9eQpDT05GSUdfTEVEU19MTTM2NDI9eQpDT05GSUdfTEVEU19MUDM5NDQ9eQpD
T05GSUdfTEVEU19MUDU1MjE9eQpDT05GSUdfTEVEU19MUDU1MjM9eQpDT05GSUdfTEVEU19M
UDg3ODg9eQpDT05GSUdfTEVEU19QQ0E5NTVYPXkKIyBDT05GSUdfTEVEU19QQ0E5NjMzIGlz
IG5vdCBzZXQKIyBDT05GSUdfTEVEU19XTTgzMVhfU1RBVFVTIGlzIG5vdCBzZXQKQ09ORklH
X0xFRFNfREFDMTI0UzA4NT15CkNPTkZJR19MRURTX1JFR1VMQVRPUj15CkNPTkZJR19MRURT
X0JEMjgwMj15CiMgQ09ORklHX0xFRFNfQURQNTUyMCBpcyBub3Qgc2V0CkNPTkZJR19MRURT
X0RFTExfTkVUQk9PS1M9eQpDT05GSUdfTEVEU19UQ0E2NTA3PXkKQ09ORklHX0xFRFNfTUFY
ODk5Nz15CiMgQ09ORklHX0xFRFNfTE0zNTV4IGlzIG5vdCBzZXQKIyBDT05GSUdfTEVEU19P
VDIwMCBpcyBub3Qgc2V0CkNPTkZJR19MRURTX0JMSU5LTT15CiMgQ09ORklHX0xFRFNfVFJJ
R0dFUlMgaXMgbm90IHNldAoKIwojIExFRCBUcmlnZ2VycwojCiMgQ09ORklHX0FDQ0VTU0lC
SUxJVFkgaXMgbm90IHNldApDT05GSUdfSU5GSU5JQkFORD15CkNPTkZJR19JTkZJTklCQU5E
X1VTRVJfTUFEPXkKQ09ORklHX0lORklOSUJBTkRfVVNFUl9BQ0NFU1M9eQpDT05GSUdfSU5G
SU5JQkFORF9VU0VSX01FTT15CkNPTkZJR19JTkZJTklCQU5EX0FERFJfVFJBTlM9eQojIENP
TkZJR19JTkZJTklCQU5EX01USENBIGlzIG5vdCBzZXQKQ09ORklHX0lORklOSUJBTkRfUUlC
PXkKIyBDT05GSUdfSU5GSU5JQkFORF9BTVNPMTEwMCBpcyBub3Qgc2V0CkNPTkZJR19JTkZJ
TklCQU5EX0NYR0IzPXkKQ09ORklHX0lORklOSUJBTkRfQ1hHQjNfREVCVUc9eQojIENPTkZJ
R19JTkZJTklCQU5EX0NYR0I0IGlzIG5vdCBzZXQKIyBDT05GSUdfTUxYNF9JTkZJTklCQU5E
IGlzIG5vdCBzZXQKQ09ORklHX0lORklOSUJBTkRfTkVTPXkKIyBDT05GSUdfSU5GSU5JQkFO
RF9ORVNfREVCVUcgaXMgbm90IHNldApDT05GSUdfSU5GSU5JQkFORF9PQ1JETUE9eQpDT05G
SUdfSU5GSU5JQkFORF9JUE9JQj15CiMgQ09ORklHX0lORklOSUJBTkRfSVBPSUJfQ00gaXMg
bm90IHNldAojIENPTkZJR19JTkZJTklCQU5EX0lQT0lCX0RFQlVHIGlzIG5vdCBzZXQKIyBD
T05GSUdfSU5GSU5JQkFORF9TUlAgaXMgbm90IHNldApDT05GSUdfSU5GSU5JQkFORF9JU0VS
PXkKQ09ORklHX0VEQUM9eQoKIwojIFJlcG9ydGluZyBzdWJzeXN0ZW1zCiMKIyBDT05GSUdf
RURBQ19MRUdBQ1lfU1lTRlMgaXMgbm90IHNldAojIENPTkZJR19FREFDX0RFQlVHIGlzIG5v
dCBzZXQKQ09ORklHX0VEQUNfTU1fRURBQz15CkNPTkZJR19FREFDX0U3NTJYPXkKIyBDT05G
SUdfRURBQ19JODI5NzVYIGlzIG5vdCBzZXQKQ09ORklHX0VEQUNfSTMwMDA9eQojIENPTkZJ
R19FREFDX0kzMjAwIGlzIG5vdCBzZXQKIyBDT05GSUdfRURBQ19YMzggaXMgbm90IHNldAoj
IENPTkZJR19FREFDX0k1NDAwIGlzIG5vdCBzZXQKIyBDT05GSUdfRURBQ19JNTAwMCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0VEQUNfSTUxMDAgaXMgbm90IHNldAojIENPTkZJR19FREFDX0k3
MzAwIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0NMQVNTIGlzIG5vdCBzZXQKIyBDT05GSUdf
RE1BREVWSUNFUyBpcyBub3Qgc2V0CiMgQ09ORklHX0FVWERJU1BMQVkgaXMgbm90IHNldApD
T05GSUdfVUlPPXkKIyBDT05GSUdfVUlPX0NJRiBpcyBub3Qgc2V0CkNPTkZJR19VSU9fUERS
Vj15CiMgQ09ORklHX1VJT19QRFJWX0dFTklSUSBpcyBub3Qgc2V0CkNPTkZJR19VSU9fRE1F
TV9HRU5JUlE9eQpDT05GSUdfVUlPX0FFQz15CkNPTkZJR19VSU9fU0VSQ09TMz15CkNPTkZJ
R19VSU9fUENJX0dFTkVSSUM9eQpDT05GSUdfVUlPX05FVFg9eQpDT05GSUdfVklSVElPPXkK
CiMKIyBWaXJ0aW8gZHJpdmVycwojCkNPTkZJR19WSVJUSU9fUENJPXkKQ09ORklHX1ZJUlRJ
T19CQUxMT09OPXkKQ09ORklHX1ZJUlRJT19NTUlPPXkKQ09ORklHX1ZJUlRJT19NTUlPX0NN
RExJTkVfREVWSUNFUz15CgojCiMgTWljcm9zb2Z0IEh5cGVyLVYgZ3Vlc3Qgc3VwcG9ydAoj
CiMgQ09ORklHX0hZUEVSViBpcyBub3Qgc2V0CgojCiMgWGVuIGRyaXZlciBzdXBwb3J0CiMK
IyBDT05GSUdfWEVOX0JBTExPT04gaXMgbm90IHNldAojIENPTkZJR19YRU5fREVWX0VWVENI
TiBpcyBub3Qgc2V0CkNPTkZJR19YRU5fQkFDS0VORD15CkNPTkZJR19YRU5GUz15CkNPTkZJ
R19YRU5fQ09NUEFUX1hFTkZTPXkKQ09ORklHX1hFTl9TWVNfSFlQRVJWSVNPUj15CkNPTkZJ
R19YRU5fWEVOQlVTX0ZST05URU5EPXkKIyBDT05GSUdfWEVOX0dOVERFViBpcyBub3Qgc2V0
CiMgQ09ORklHX1hFTl9HUkFOVF9ERVZfQUxMT0MgaXMgbm90IHNldApDT05GSUdfU1dJT1RM
Ql9YRU49eQpDT05GSUdfWEVOX1RNRU09eQojIENPTkZJR19YRU5fUENJREVWX0JBQ0tFTkQg
aXMgbm90IHNldApDT05GSUdfWEVOX1BSSVZDTUQ9eQpDT05GSUdfWEVOX0hBVkVfUFZNTVU9
eQojIENPTkZJR19TVEFHSU5HIGlzIG5vdCBzZXQKQ09ORklHX1g4Nl9QTEFURk9STV9ERVZJ
Q0VTPXkKQ09ORklHX0FDRVJIREY9eQpDT05GSUdfQU1JTE9fUkZLSUxMPXkKQ09ORklHX0NP
TVBBTF9MQVBUT1A9eQpDT05GSUdfQUNQSV9XTUk9eQpDT05GSUdfVE9TSElCQV9CVF9SRktJ
TEw9eQojIENPTkZJR19BQ1BJX0NNUEMgaXMgbm90IHNldAojIENPTkZJR19JTlRFTF9JUFMg
aXMgbm90IHNldApDT05GSUdfSUJNX1JUTD15CkNPTkZJR19TQU1TVU5HX0xBUFRPUD15CkNP
TkZJR19NWE1fV01JPXkKIyBDT05GSUdfSU5URUxfT0FLVFJBSUwgaXMgbm90IHNldApDT05G
SUdfU0FNU1VOR19RMTA9eQojIENPTkZJR19BUFBMRV9HTVVYIGlzIG5vdCBzZXQKCiMKIyBI
YXJkd2FyZSBTcGlubG9jayBkcml2ZXJzCiMKQ09ORklHX0NMS0VWVF9JODI1Mz15CkNPTkZJ
R19JODI1M19MT0NLPXkKQ09ORklHX0NMS0JMRF9JODI1Mz15CkNPTkZJR19JT01NVV9TVVBQ
T1JUPXkKIyBDT05GSUdfQU1EX0lPTU1VIGlzIG5vdCBzZXQKCiMKIyBSZW1vdGVwcm9jIGRy
aXZlcnMgKEVYUEVSSU1FTlRBTCkKIwpDT05GSUdfUkVNT1RFUFJPQz15CkNPTkZJR19TVEVf
TU9ERU1fUlBST0M9eQoKIwojIFJwbXNnIGRyaXZlcnMKIwpDT05GSUdfVklSVF9EUklWRVJT
PXkKIyBDT05GSUdfUE1fREVWRlJFUSBpcyBub3Qgc2V0CiMgQ09ORklHX0VYVENPTiBpcyBu
b3Qgc2V0CkNPTkZJR19NRU1PUlk9eQojIENPTkZJR19JSU8gaXMgbm90IHNldApDT05GSUdf
Vk1FX0JVUz15CgojCiMgVk1FIEJyaWRnZSBEcml2ZXJzCiMKIyBDT05GSUdfVk1FX0NBOTFD
WDQyIGlzIG5vdCBzZXQKIyBDT05GSUdfVk1FX1RTSTE0OCBpcyBub3Qgc2V0CgojCiMgVk1F
IEJvYXJkIERyaXZlcnMKIwpDT05GSUdfVk1JVk1FXzc4MDU9eQoKIwojIFZNRSBEZXZpY2Ug
RHJpdmVycwojCkNPTkZJR19QV009eQoKIwojIEZpcm13YXJlIERyaXZlcnMKIwojIENPTkZJ
R19FREQgaXMgbm90IHNldApDT05GSUdfRklSTVdBUkVfTUVNTUFQPXkKQ09ORklHX0VGSV9W
QVJTPXkKQ09ORklHX0RFTExfUkJVPXkKIyBDT05GSUdfRENEQkFTIGlzIG5vdCBzZXQKIyBD
T05GSUdfSVNDU0lfSUJGVF9GSU5EIGlzIG5vdCBzZXQKQ09ORklHX0dPT0dMRV9GSVJNV0FS
RT15CgojCiMgR29vZ2xlIEZpcm13YXJlIERyaXZlcnMKIwoKIwojIEZpbGUgc3lzdGVtcwoj
CkNPTkZJR19EQ0FDSEVfV09SRF9BQ0NFU1M9eQojIENPTkZJR19FWFQyX0ZTIGlzIG5vdCBz
ZXQKIyBDT05GSUdfRVhUM19GUyBpcyBub3Qgc2V0CiMgQ09ORklHX0VYVDRfRlMgaXMgbm90
IHNldApDT05GSUdfSkJEMj15CiMgQ09ORklHX0pCRDJfREVCVUcgaXMgbm90IHNldApDT05G
SUdfUkVJU0VSRlNfRlM9eQpDT05GSUdfUkVJU0VSRlNfQ0hFQ0s9eQpDT05GSUdfUkVJU0VS
RlNfRlNfWEFUVFI9eQpDT05GSUdfUkVJU0VSRlNfRlNfUE9TSVhfQUNMPXkKQ09ORklHX1JF
SVNFUkZTX0ZTX1NFQ1VSSVRZPXkKIyBDT05GSUdfSkZTX0ZTIGlzIG5vdCBzZXQKQ09ORklH
X1hGU19GUz15CkNPTkZJR19YRlNfUVVPVEE9eQpDT05GSUdfWEZTX1BPU0lYX0FDTD15CkNP
TkZJR19YRlNfUlQ9eQojIENPTkZJR19YRlNfREVCVUcgaXMgbm90IHNldAojIENPTkZJR19H
RlMyX0ZTIGlzIG5vdCBzZXQKQ09ORklHX09DRlMyX0ZTPXkKIyBDT05GSUdfT0NGUzJfRlNf
TzJDQiBpcyBub3Qgc2V0CiMgQ09ORklHX09DRlMyX0ZTX1NUQVRTIGlzIG5vdCBzZXQKQ09O
RklHX09DRlMyX0RFQlVHX01BU0tMT0c9eQpDT05GSUdfT0NGUzJfREVCVUdfRlM9eQpDT05G
SUdfQlRSRlNfRlM9eQojIENPTkZJR19CVFJGU19GU19QT1NJWF9BQ0wgaXMgbm90IHNldApD
T05GSUdfQlRSRlNfRlNfQ0hFQ0tfSU5URUdSSVRZPXkKIyBDT05GSUdfTklMRlMyX0ZTIGlz
IG5vdCBzZXQKQ09ORklHX0ZTX1BPU0lYX0FDTD15CkNPTkZJR19FWFBPUlRGUz15CiMgQ09O
RklHX0ZJTEVfTE9DS0lORyBpcyBub3Qgc2V0CkNPTkZJR19GU05PVElGWT15CkNPTkZJR19E
Tk9USUZZPXkKIyBDT05GSUdfSU5PVElGWV9VU0VSIGlzIG5vdCBzZXQKQ09ORklHX0ZBTk9U
SUZZPXkKQ09ORklHX1FVT1RBPXkKIyBDT05GSUdfUVVPVEFfTkVUTElOS19JTlRFUkZBQ0Ug
aXMgbm90IHNldApDT05GSUdfUFJJTlRfUVVPVEFfV0FSTklORz15CiMgQ09ORklHX1FVT1RB
X0RFQlVHIGlzIG5vdCBzZXQKQ09ORklHX1FVT1RBX1RSRUU9eQpDT05GSUdfUUZNVF9WMT15
CiMgQ09ORklHX1FGTVRfVjIgaXMgbm90IHNldApDT05GSUdfUVVPVEFDVEw9eQpDT05GSUdf
UVVPVEFDVExfQ09NUEFUPXkKQ09ORklHX0FVVE9GUzRfRlM9eQojIENPTkZJR19GVVNFX0ZT
IGlzIG5vdCBzZXQKCiMKIyBDYWNoZXMKIwpDT05GSUdfRlNDQUNIRT15CiMgQ09ORklHX0ZT
Q0FDSEVfREVCVUcgaXMgbm90IHNldAojIENPTkZJR19DQUNIRUZJTEVTIGlzIG5vdCBzZXQK
CiMKIyBDRC1ST00vRFZEIEZpbGVzeXN0ZW1zCiMKIyBDT05GSUdfSVNPOTY2MF9GUyBpcyBu
b3Qgc2V0CiMgQ09ORklHX1VERl9GUyBpcyBub3Qgc2V0CgojCiMgRE9TL0ZBVC9OVCBGaWxl
c3lzdGVtcwojCkNPTkZJR19GQVRfRlM9eQpDT05GSUdfTVNET1NfRlM9eQpDT05GSUdfVkZB
VF9GUz15CkNPTkZJR19GQVRfREVGQVVMVF9DT0RFUEFHRT00MzcKQ09ORklHX0ZBVF9ERUZB
VUxUX0lPQ0hBUlNFVD0iaXNvODg1OS0xIgpDT05GSUdfTlRGU19GUz15CiMgQ09ORklHX05U
RlNfREVCVUcgaXMgbm90IHNldAojIENPTkZJR19OVEZTX1JXIGlzIG5vdCBzZXQKCiMKIyBQ
c2V1ZG8gZmlsZXN5c3RlbXMKIwojIENPTkZJR19QUk9DX0ZTIGlzIG5vdCBzZXQKQ09ORklH
X1NZU0ZTPXkKQ09ORklHX0hVR0VUTEJGUz15CkNPTkZJR19IVUdFVExCX1BBR0U9eQpDT05G
SUdfQ09ORklHRlNfRlM9eQpDT05GSUdfTUlTQ19GSUxFU1lTVEVNUz15CiMgQ09ORklHX0FE
RlNfRlMgaXMgbm90IHNldApDT05GSUdfQUZGU19GUz15CkNPTkZJR19FQ1JZUFRfRlM9eQoj
IENPTkZJR19IRlNfRlMgaXMgbm90IHNldApDT05GSUdfSEZTUExVU19GUz15CkNPTkZJR19C
RUZTX0ZTPXkKQ09ORklHX0JFRlNfREVCVUc9eQojIENPTkZJR19CRlNfRlMgaXMgbm90IHNl
dAojIENPTkZJR19FRlNfRlMgaXMgbm90IHNldApDT05GSUdfTE9HRlM9eQpDT05GSUdfQ1JB
TUZTPXkKQ09ORklHX1NRVUFTSEZTPXkKQ09ORklHX1NRVUFTSEZTX1hBVFRSPXkKIyBDT05G
SUdfU1FVQVNIRlNfWkxJQiBpcyBub3Qgc2V0CkNPTkZJR19TUVVBU0hGU19MWk89eQpDT05G
SUdfU1FVQVNIRlNfWFo9eQojIENPTkZJR19TUVVBU0hGU180S19ERVZCTEtfU0laRSBpcyBu
b3Qgc2V0CkNPTkZJR19TUVVBU0hGU19FTUJFRERFRD15CkNPTkZJR19TUVVBU0hGU19GUkFH
TUVOVF9DQUNIRV9TSVpFPTMKIyBDT05GSUdfVlhGU19GUyBpcyBub3Qgc2V0CkNPTkZJR19N
SU5JWF9GUz15CkNPTkZJR19PTUZTX0ZTPXkKQ09ORklHX0hQRlNfRlM9eQpDT05GSUdfUU5Y
NEZTX0ZTPXkKIyBDT05GSUdfUU5YNkZTX0ZTIGlzIG5vdCBzZXQKIyBDT05GSUdfUk9NRlNf
RlMgaXMgbm90IHNldApDT05GSUdfUFNUT1JFPXkKQ09ORklHX1BTVE9SRV9DT05TT0xFPXkK
IyBDT05GSUdfUFNUT1JFX1JBTSBpcyBub3Qgc2V0CkNPTkZJR19TWVNWX0ZTPXkKIyBDT05G
SUdfVUZTX0ZTIGlzIG5vdCBzZXQKQ09ORklHX0VYT0ZTX0ZTPXkKIyBDT05GSUdfRVhPRlNf
REVCVUcgaXMgbm90IHNldApDT05GSUdfT1JFPXkKQ09ORklHX05FVFdPUktfRklMRVNZU1RF
TVM9eQpDT05GSUdfQ0VQSF9GUz15CiMgQ09ORklHX0NJRlMgaXMgbm90IHNldAojIENPTkZJ
R19OQ1BfRlMgaXMgbm90IHNldApDT05GSUdfQ09EQV9GUz15CiMgQ09ORklHX0FGU19GUyBp
cyBub3Qgc2V0CkNPTkZJR19OTFM9eQpDT05GSUdfTkxTX0RFRkFVTFQ9Imlzbzg4NTktMSIK
Q09ORklHX05MU19DT0RFUEFHRV80Mzc9eQpDT05GSUdfTkxTX0NPREVQQUdFXzczNz15CkNP
TkZJR19OTFNfQ09ERVBBR0VfNzc1PXkKQ09ORklHX05MU19DT0RFUEFHRV84NTA9eQpDT05G
SUdfTkxTX0NPREVQQUdFXzg1Mj15CkNPTkZJR19OTFNfQ09ERVBBR0VfODU1PXkKQ09ORklH
X05MU19DT0RFUEFHRV84NTc9eQojIENPTkZJR19OTFNfQ09ERVBBR0VfODYwIGlzIG5vdCBz
ZXQKQ09ORklHX05MU19DT0RFUEFHRV84NjE9eQpDT05GSUdfTkxTX0NPREVQQUdFXzg2Mj15
CiMgQ09ORklHX05MU19DT0RFUEFHRV84NjMgaXMgbm90IHNldAojIENPTkZJR19OTFNfQ09E
RVBBR0VfODY0IGlzIG5vdCBzZXQKQ09ORklHX05MU19DT0RFUEFHRV84NjU9eQojIENPTkZJ
R19OTFNfQ09ERVBBR0VfODY2IGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0NPREVQQUdFXzg2
OSBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV85MzYgaXMgbm90IHNldApDT05G
SUdfTkxTX0NPREVQQUdFXzk1MD15CiMgQ09ORklHX05MU19DT0RFUEFHRV85MzIgaXMgbm90
IHNldApDT05GSUdfTkxTX0NPREVQQUdFXzk0OT15CkNPTkZJR19OTFNfQ09ERVBBR0VfODc0
PXkKIyBDT05GSUdfTkxTX0lTTzg4NTlfOCBpcyBub3Qgc2V0CkNPTkZJR19OTFNfQ09ERVBB
R0VfMTI1MD15CiMgQ09ORklHX05MU19DT0RFUEFHRV8xMjUxIGlzIG5vdCBzZXQKIyBDT05G
SUdfTkxTX0FTQ0lJIGlzIG5vdCBzZXQKQ09ORklHX05MU19JU084ODU5XzE9eQpDT05GSUdf
TkxTX0lTTzg4NTlfMj15CiMgQ09ORklHX05MU19JU084ODU5XzMgaXMgbm90IHNldAojIENP
TkZJR19OTFNfSVNPODg1OV80IGlzIG5vdCBzZXQKQ09ORklHX05MU19JU084ODU5XzU9eQoj
IENPTkZJR19OTFNfSVNPODg1OV82IGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0lTTzg4NTlf
NyBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19JU084ODU5XzkgaXMgbm90IHNldApDT05GSUdf
TkxTX0lTTzg4NTlfMTM9eQojIENPTkZJR19OTFNfSVNPODg1OV8xNCBpcyBub3Qgc2V0CiMg
Q09ORklHX05MU19JU084ODU5XzE1IGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0tPSThfUiBp
cyBub3Qgc2V0CkNPTkZJR19OTFNfS09JOF9VPXkKQ09ORklHX05MU19NQUNfUk9NQU49eQoj
IENPTkZJR19OTFNfTUFDX0NFTFRJQyBpcyBub3Qgc2V0CkNPTkZJR19OTFNfTUFDX0NFTlRF
VVJPPXkKIyBDT05GSUdfTkxTX01BQ19DUk9BVElBTiBpcyBub3Qgc2V0CkNPTkZJR19OTFNf
TUFDX0NZUklMTElDPXkKQ09ORklHX05MU19NQUNfR0FFTElDPXkKQ09ORklHX05MU19NQUNf
R1JFRUs9eQojIENPTkZJR19OTFNfTUFDX0lDRUxBTkQgaXMgbm90IHNldAojIENPTkZJR19O
TFNfTUFDX0lOVUlUIGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX01BQ19ST01BTklBTiBpcyBu
b3Qgc2V0CiMgQ09ORklHX05MU19NQUNfVFVSS0lTSCBpcyBub3Qgc2V0CkNPTkZJR19OTFNf
VVRGOD15CiMgQ09ORklHX0RMTSBpcyBub3Qgc2V0CgojCiMgS2VybmVsIGhhY2tpbmcKIwpD
T05GSUdfVFJBQ0VfSVJRRkxBR1NfU1VQUE9SVD15CkNPTkZJR19ERUZBVUxUX01FU1NBR0Vf
TE9HTEVWRUw9NAojIENPTkZJR19FTkFCTEVfV0FSTl9ERVBSRUNBVEVEIGlzIG5vdCBzZXQK
Q09ORklHX0VOQUJMRV9NVVNUX0NIRUNLPXkKQ09ORklHX0ZSQU1FX1dBUk49MjA0OAojIENP
TkZJR19NQUdJQ19TWVNSUSBpcyBub3Qgc2V0CkNPTkZJR19TVFJJUF9BU01fU1lNUz15CkNP
TkZJR19SRUFEQUJMRV9BU009eQojIENPTkZJR19VTlVTRURfU1lNQk9MUyBpcyBub3Qgc2V0
CkNPTkZJR19ERUJVR19GUz15CkNPTkZJR19IRUFERVJTX0NIRUNLPXkKIyBDT05GSUdfREVC
VUdfU0VDVElPTl9NSVNNQVRDSCBpcyBub3Qgc2V0CkNPTkZJR19ERUJVR19LRVJORUw9eQoj
IENPTkZJR19ERUJVR19TSElSUSBpcyBub3Qgc2V0CkNPTkZJR19MT0NLVVBfREVURUNUT1I9
eQpDT05GSUdfSEFSRExPQ0tVUF9ERVRFQ1RPUj15CiMgQ09ORklHX0JPT1RQQVJBTV9IQVJE
TE9DS1VQX1BBTklDIGlzIG5vdCBzZXQKQ09ORklHX0JPT1RQQVJBTV9IQVJETE9DS1VQX1BB
TklDX1ZBTFVFPTAKQ09ORklHX0JPT1RQQVJBTV9TT0ZUTE9DS1VQX1BBTklDPXkKQ09ORklH
X0JPT1RQQVJBTV9TT0ZUTE9DS1VQX1BBTklDX1ZBTFVFPTEKIyBDT05GSUdfUEFOSUNfT05f
T09QUyBpcyBub3Qgc2V0CkNPTkZJR19QQU5JQ19PTl9PT1BTX1ZBTFVFPTAKIyBDT05GSUdf
REVURUNUX0hVTkdfVEFTSyBpcyBub3Qgc2V0CiMgQ09ORklHX0RFQlVHX09CSkVDVFMgaXMg
bm90IHNldApDT05GSUdfU0xVQl9TVEFUUz15CkNPTkZJR19IQVZFX0RFQlVHX0tNRU1MRUFL
PXkKIyBDT05GSUdfREVCVUdfS01FTUxFQUsgaXMgbm90IHNldAojIENPTkZJR19ERUJVR19S
VF9NVVRFWEVTIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRfTVVURVhfVEVTVEVSIGlzIG5vdCBz
ZXQKQ09ORklHX0RFQlVHX1NQSU5MT0NLPXkKQ09ORklHX0RFQlVHX01VVEVYRVM9eQpDT05G
SUdfREVCVUdfTE9DS19BTExPQz15CkNPTkZJR19QUk9WRV9MT0NLSU5HPXkKQ09ORklHX1BS
T1ZFX1JDVT15CiMgQ09ORklHX1BST1ZFX1JDVV9SRVBFQVRFRExZIGlzIG5vdCBzZXQKIyBD
T05GSUdfU1BBUlNFX1JDVV9QT0lOVEVSIGlzIG5vdCBzZXQKQ09ORklHX0xPQ0tERVA9eQpD
T05GSUdfTE9DS19TVEFUPXkKIyBDT05GSUdfREVCVUdfTE9DS0RFUCBpcyBub3Qgc2V0CkNP
TkZJR19UUkFDRV9JUlFGTEFHUz15CiMgQ09ORklHX0RFQlVHX0FUT01JQ19TTEVFUCBpcyBu
b3Qgc2V0CkNPTkZJR19ERUJVR19MT0NLSU5HX0FQSV9TRUxGVEVTVFM9eQpDT05GSUdfU1RB
Q0tUUkFDRT15CkNPTkZJR19ERUJVR19TVEFDS19VU0FHRT15CkNPTkZJR19ERUJVR19LT0JK
RUNUPXkKQ09ORklHX0RFQlVHX0JVR1ZFUkJPU0U9eQojIENPTkZJR19ERUJVR19JTkZPIGlz
IG5vdCBzZXQKIyBDT05GSUdfREVCVUdfVk0gaXMgbm90IHNldApDT05GSUdfREVCVUdfVklS
VFVBTD15CiMgQ09ORklHX0RFQlVHX1dSSVRFQ09VTlQgaXMgbm90IHNldApDT05GSUdfREVC
VUdfTUVNT1JZX0lOSVQ9eQojIENPTkZJR19ERUJVR19MSVNUIGlzIG5vdCBzZXQKQ09ORklH
X1RFU1RfTElTVF9TT1JUPXkKQ09ORklHX0RFQlVHX1NHPXkKIyBDT05GSUdfREVCVUdfTk9U
SUZJRVJTIGlzIG5vdCBzZXQKQ09ORklHX0RFQlVHX0NSRURFTlRJQUxTPXkKQ09ORklHX0FS
Q0hfV0FOVF9GUkFNRV9QT0lOVEVSUz15CkNPTkZJR19GUkFNRV9QT0lOVEVSPXkKIyBDT05G
SUdfREVCVUdfU1lOQ0hST19URVNUIGlzIG5vdCBzZXQKIyBDT05GSUdfUkNVX1RPUlRVUkVf
VEVTVCBpcyBub3Qgc2V0CkNPTkZJR19SQ1VfQ1BVX1NUQUxMX1RJTUVPVVQ9MjEKQ09ORklH
X1JDVV9DUFVfU1RBTExfSU5GTz15CkNPTkZJR19SQ1VfVFJBQ0U9eQojIENPTkZJR19CQUNL
VFJBQ0VfU0VMRl9URVNUIGlzIG5vdCBzZXQKIyBDT05GSUdfREVCVUdfQkxPQ0tfRVhUX0RF
VlQgaXMgbm90IHNldApDT05GSUdfREVCVUdfRk9SQ0VfV0VBS19QRVJfQ1BVPXkKQ09ORklH
X0RFQlVHX1BFUl9DUFVfTUFQUz15CkNPTkZJR19MS0RUTT15CkNPTkZJR19OT1RJRklFUl9F
UlJPUl9JTkpFQ1RJT049eQojIENPTkZJR19DUFVfTk9USUZJRVJfRVJST1JfSU5KRUNUIGlz
IG5vdCBzZXQKIyBDT05GSUdfUE1fTk9USUZJRVJfRVJST1JfSU5KRUNUIGlzIG5vdCBzZXQK
Q09ORklHX01FTU9SWV9OT1RJRklFUl9FUlJPUl9JTkpFQ1Q9eQpDT05GSUdfRkFVTFRfSU5K
RUNUSU9OPXkKIyBDT05GSUdfRkFJTFNMQUIgaXMgbm90IHNldApDT05GSUdfRkFJTF9QQUdF
X0FMTE9DPXkKQ09ORklHX0ZBSUxfTUFLRV9SRVFVRVNUPXkKIyBDT05GSUdfRkFJTF9JT19U
SU1FT1VUIGlzIG5vdCBzZXQKQ09ORklHX0ZBVUxUX0lOSkVDVElPTl9ERUJVR19GUz15CkNP
TkZJR19ERUJVR19QQUdFQUxMT0M9eQpDT05GSUdfV0FOVF9QQUdFX0RFQlVHX0ZMQUdTPXkK
Q09ORklHX1BBR0VfR1VBUkQ9eQpDT05GSUdfVVNFUl9TVEFDS1RSQUNFX1NVUFBPUlQ9eQpD
T05GSUdfSEFWRV9GVU5DVElPTl9UUkFDRVI9eQpDT05GSUdfSEFWRV9GVU5DVElPTl9HUkFQ
SF9UUkFDRVI9eQpDT05GSUdfSEFWRV9GVU5DVElPTl9HUkFQSF9GUF9URVNUPXkKQ09ORklH
X0hBVkVfRlVOQ1RJT05fVFJBQ0VfTUNPVU5UX1RFU1Q9eQpDT05GSUdfSEFWRV9EWU5BTUlD
X0ZUUkFDRT15CkNPTkZJR19IQVZFX0ZUUkFDRV9NQ09VTlRfUkVDT1JEPXkKQ09ORklHX0hB
VkVfU1lTQ0FMTF9UUkFDRVBPSU5UUz15CkNPTkZJR19IQVZFX0ZFTlRSWT15CkNPTkZJR19I
QVZFX0NfUkVDT1JETUNPVU5UPXkKQ09ORklHX1RSQUNJTkdfU1VQUE9SVD15CiMgQ09ORklH
X0ZUUkFDRSBpcyBub3Qgc2V0CkNPTkZJR19QUk9WSURFX09IQ0kxMzk0X0RNQV9JTklUPXkK
Q09ORklHX0JVSUxEX0RPQ1NSQz15CiMgQ09ORklHX0RNQV9BUElfREVCVUcgaXMgbm90IHNl
dApDT05GSUdfQVRPTUlDNjRfU0VMRlRFU1Q9eQpDT05GSUdfU0FNUExFUz15CkNPTkZJR19I
QVZFX0FSQ0hfS0dEQj15CiMgQ09ORklHX0tHREIgaXMgbm90IHNldApDT05GSUdfSEFWRV9B
UkNIX0tNRU1DSEVDSz15CkNPTkZJR19URVNUX0tTVFJUT1g9eQpDT05GSUdfU1RSSUNUX0RF
Vk1FTT15CiMgQ09ORklHX1g4Nl9WRVJCT1NFX0JPT1RVUCBpcyBub3Qgc2V0CiMgQ09ORklH
X0VBUkxZX1BSSU5USyBpcyBub3Qgc2V0CiMgQ09ORklHX0RFQlVHX1NUQUNLT1ZFUkZMT1cg
aXMgbm90IHNldApDT05GSUdfWDg2X1BURFVNUD15CiMgQ09ORklHX0RFQlVHX1JPREFUQSBp
cyBub3Qgc2V0CkNPTkZJR19ERUJVR19UTEJGTFVTSD15CkNPTkZJR19JT01NVV9TVFJFU1M9
eQpDT05GSUdfSEFWRV9NTUlPVFJBQ0VfU1VQUE9SVD15CkNPTkZJR19JT19ERUxBWV9UWVBF
XzBYODA9MApDT05GSUdfSU9fREVMQVlfVFlQRV8wWEVEPTEKQ09ORklHX0lPX0RFTEFZX1RZ
UEVfVURFTEFZPTIKQ09ORklHX0lPX0RFTEFZX1RZUEVfTk9ORT0zCkNPTkZJR19JT19ERUxB
WV8wWDgwPXkKIyBDT05GSUdfSU9fREVMQVlfMFhFRCBpcyBub3Qgc2V0CiMgQ09ORklHX0lP
X0RFTEFZX1VERUxBWSBpcyBub3Qgc2V0CiMgQ09ORklHX0lPX0RFTEFZX05PTkUgaXMgbm90
IHNldApDT05GSUdfREVGQVVMVF9JT19ERUxBWV9UWVBFPTAKQ09ORklHX0RFQlVHX0JPT1Rf
UEFSQU1TPXkKIyBDT05GSUdfQ1BBX0RFQlVHIGlzIG5vdCBzZXQKIyBDT05GSUdfT1BUSU1J
WkVfSU5MSU5JTkcgaXMgbm90IHNldAojIENPTkZJR19ERUJVR19TVFJJQ1RfVVNFUl9DT1BZ
X0NIRUNLUyBpcyBub3Qgc2V0CkNPTkZJR19ERUJVR19OTUlfU0VMRlRFU1Q9eQoKIwojIFNl
Y3VyaXR5IG9wdGlvbnMKIwpDT05GSUdfS0VZUz15CiMgQ09ORklHX0VOQ1JZUFRFRF9LRVlT
IGlzIG5vdCBzZXQKQ09ORklHX0tFWVNfREVCVUdfUFJPQ19LRVlTPXkKQ09ORklHX1NFQ1VS
SVRZX0RNRVNHX1JFU1RSSUNUPXkKIyBDT05GSUdfU0VDVVJJVFkgaXMgbm90IHNldAojIENP
TkZJR19TRUNVUklUWUZTIGlzIG5vdCBzZXQKQ09ORklHX0RFRkFVTFRfU0VDVVJJVFlfREFD
PXkKQ09ORklHX0RFRkFVTFRfU0VDVVJJVFk9IiIKQ09ORklHX1hPUl9CTE9DS1M9eQpDT05G
SUdfQVNZTkNfQ09SRT15CkNPTkZJR19BU1lOQ19YT1I9eQpDT05GSUdfQ1JZUFRPPXkKCiMK
IyBDcnlwdG8gY29yZSBvciBoZWxwZXIKIwpDT05GSUdfQ1JZUFRPX0FMR0FQST15CkNPTkZJ
R19DUllQVE9fQUxHQVBJMj15CkNPTkZJR19DUllQVE9fQUVBRD15CkNPTkZJR19DUllQVE9f
QUVBRDI9eQpDT05GSUdfQ1JZUFRPX0JMS0NJUEhFUj15CkNPTkZJR19DUllQVE9fQkxLQ0lQ
SEVSMj15CkNPTkZJR19DUllQVE9fSEFTSD15CkNPTkZJR19DUllQVE9fSEFTSDI9eQpDT05G
SUdfQ1JZUFRPX1JORz15CkNPTkZJR19DUllQVE9fUk5HMj15CkNPTkZJR19DUllQVE9fUENP
TVA9eQpDT05GSUdfQ1JZUFRPX1BDT01QMj15CkNPTkZJR19DUllQVE9fTUFOQUdFUj15CkNP
TkZJR19DUllQVE9fTUFOQUdFUjI9eQpDT05GSUdfQ1JZUFRPX1VTRVI9eQpDT05GSUdfQ1JZ
UFRPX01BTkFHRVJfRElTQUJMRV9URVNUUz15CkNPTkZJR19DUllQVE9fR0YxMjhNVUw9eQpD
T05GSUdfQ1JZUFRPX05VTEw9eQpDT05GSUdfQ1JZUFRPX1BDUllQVD15CkNPTkZJR19DUllQ
VE9fV09SS1FVRVVFPXkKQ09ORklHX0NSWVBUT19DUllQVEQ9eQpDT05GSUdfQ1JZUFRPX0FV
VEhFTkM9eQpDT05GSUdfQ1JZUFRPX0FCTEtfSEVMUEVSX1g4Nj15CkNPTkZJR19DUllQVE9f
R0xVRV9IRUxQRVJfWDg2PXkKCiMKIyBBdXRoZW50aWNhdGVkIEVuY3J5cHRpb24gd2l0aCBB
c3NvY2lhdGVkIERhdGEKIwpDT05GSUdfQ1JZUFRPX0NDTT15CiMgQ09ORklHX0NSWVBUT19H
Q00gaXMgbm90IHNldApDT05GSUdfQ1JZUFRPX1NFUUlWPXkKCiMKIyBCbG9jayBtb2Rlcwoj
CkNPTkZJR19DUllQVE9fQ0JDPXkKQ09ORklHX0NSWVBUT19DVFI9eQojIENPTkZJR19DUllQ
VE9fQ1RTIGlzIG5vdCBzZXQKQ09ORklHX0NSWVBUT19FQ0I9eQpDT05GSUdfQ1JZUFRPX0xS
Vz15CkNPTkZJR19DUllQVE9fUENCQz15CkNPTkZJR19DUllQVE9fWFRTPXkKCiMKIyBIYXNo
IG1vZGVzCiMKQ09ORklHX0NSWVBUT19ITUFDPXkKQ09ORklHX0NSWVBUT19YQ0JDPXkKQ09O
RklHX0NSWVBUT19WTUFDPXkKCiMKIyBEaWdlc3QKIwpDT05GSUdfQ1JZUFRPX0NSQzMyQz15
CkNPTkZJR19DUllQVE9fQ1JDMzJDX1g4Nl82ND15CkNPTkZJR19DUllQVE9fQ1JDMzJDX0lO
VEVMPXkKIyBDT05GSUdfQ1JZUFRPX0dIQVNIIGlzIG5vdCBzZXQKQ09ORklHX0NSWVBUT19N
RDQ9eQpDT05GSUdfQ1JZUFRPX01ENT15CkNPTkZJR19DUllQVE9fTUlDSEFFTF9NSUM9eQoj
IENPTkZJR19DUllQVE9fUk1EMTI4IGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX1JNRDE2
MCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19STUQyNTYgaXMgbm90IHNldAojIENPTkZJ
R19DUllQVE9fUk1EMzIwIGlzIG5vdCBzZXQKQ09ORklHX0NSWVBUT19TSEExPXkKIyBDT05G
SUdfQ1JZUFRPX1NIQTFfU1NTRTMgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fU0hBMjU2
IGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX1NIQTUxMiBpcyBub3Qgc2V0CkNPTkZJR19D
UllQVE9fVEdSMTkyPXkKQ09ORklHX0NSWVBUT19XUDUxMj15CkNPTkZJR19DUllQVE9fR0hB
U0hfQ0xNVUxfTklfSU5URUw9eQoKIwojIENpcGhlcnMKIwpDT05GSUdfQ1JZUFRPX0FFUz15
CkNPTkZJR19DUllQVE9fQUVTX1g4Nl82ND15CkNPTkZJR19DUllQVE9fQUVTX05JX0lOVEVM
PXkKIyBDT05GSUdfQ1JZUFRPX0FOVUJJUyBpcyBub3Qgc2V0CkNPTkZJR19DUllQVE9fQVJD
ND15CiMgQ09ORklHX0NSWVBUT19CTE9XRklTSCBpcyBub3Qgc2V0CkNPTkZJR19DUllQVE9f
QkxPV0ZJU0hfQ09NTU9OPXkKQ09ORklHX0NSWVBUT19CTE9XRklTSF9YODZfNjQ9eQojIENP
TkZJR19DUllQVE9fQ0FNRUxMSUEgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fQ0FNRUxM
SUFfWDg2XzY0IGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX0NBU1Q1IGlzIG5vdCBzZXQK
IyBDT05GSUdfQ1JZUFRPX0NBU1Q1X0FWWF9YODZfNjQgaXMgbm90IHNldAojIENPTkZJR19D
UllQVE9fQ0FTVDYgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fQ0FTVDZfQVZYX1g4Nl82
NCBpcyBub3Qgc2V0CkNPTkZJR19DUllQVE9fREVTPXkKQ09ORklHX0NSWVBUT19GQ1JZUFQ9
eQojIENPTkZJR19DUllQVE9fS0hBWkFEIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX1NB
TFNBMjAgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fU0FMU0EyMF9YODZfNjQgaXMgbm90
IHNldAojIENPTkZJR19DUllQVE9fU0VFRCBpcyBub3Qgc2V0CkNPTkZJR19DUllQVE9fU0VS
UEVOVD15CkNPTkZJR19DUllQVE9fU0VSUEVOVF9TU0UyX1g4Nl82ND15CiMgQ09ORklHX0NS
WVBUT19TRVJQRU5UX0FWWF9YODZfNjQgaXMgbm90IHNldApDT05GSUdfQ1JZUFRPX1RFQT15
CkNPTkZJR19DUllQVE9fVFdPRklTSD15CkNPTkZJR19DUllQVE9fVFdPRklTSF9DT01NT049
eQojIENPTkZJR19DUllQVE9fVFdPRklTSF9YODZfNjQgaXMgbm90IHNldAojIENPTkZJR19D
UllQVE9fVFdPRklTSF9YODZfNjRfM1dBWSBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19U
V09GSVNIX0FWWF9YODZfNjQgaXMgbm90IHNldAoKIwojIENvbXByZXNzaW9uCiMKQ09ORklH
X0NSWVBUT19ERUZMQVRFPXkKQ09ORklHX0NSWVBUT19aTElCPXkKIyBDT05GSUdfQ1JZUFRP
X0xaTyBpcyBub3Qgc2V0CgojCiMgUmFuZG9tIE51bWJlciBHZW5lcmF0aW9uCiMKQ09ORklH
X0NSWVBUT19BTlNJX0NQUk5HPXkKQ09ORklHX0NSWVBUT19VU0VSX0FQST15CiMgQ09ORklH
X0NSWVBUT19VU0VSX0FQSV9IQVNIIGlzIG5vdCBzZXQKQ09ORklHX0NSWVBUT19VU0VSX0FQ
SV9TS0NJUEhFUj15CiMgQ09ORklHX0NSWVBUT19IVyBpcyBub3Qgc2V0CiMgQ09ORklHX0FT
WU1NRVRSSUNfS0VZX1RZUEUgaXMgbm90IHNldApDT05GSUdfSEFWRV9LVk09eQojIENPTkZJ
R19WSVJUVUFMSVpBVElPTiBpcyBub3Qgc2V0CiMgQ09ORklHX0JJTkFSWV9QUklOVEYgaXMg
bm90IHNldAoKIwojIExpYnJhcnkgcm91dGluZXMKIwpDT05GSUdfQklUUkVWRVJTRT15CkNP
TkZJR19HRU5FUklDX1NUUk5DUFlfRlJPTV9VU0VSPXkKQ09ORklHX0dFTkVSSUNfU1RSTkxF
Tl9VU0VSPXkKQ09ORklHX0dFTkVSSUNfRklORF9GSVJTVF9CSVQ9eQpDT05GSUdfR0VORVJJ
Q19QQ0lfSU9NQVA9eQpDT05GSUdfR0VORVJJQ19JT01BUD15CkNPTkZJR19HRU5FUklDX0lP
PXkKQ09ORklHX0NSQ19DQ0lUVD15CkNPTkZJR19DUkMxNj15CkNPTkZJR19DUkNfVDEwRElG
PXkKQ09ORklHX0NSQ19JVFVfVD15CkNPTkZJR19DUkMzMj15CiMgQ09ORklHX0NSQzMyX1NF
TEZURVNUIGlzIG5vdCBzZXQKQ09ORklHX0NSQzMyX1NMSUNFQlk4PXkKIyBDT05GSUdfQ1JD
MzJfU0xJQ0VCWTQgaXMgbm90IHNldAojIENPTkZJR19DUkMzMl9TQVJXQVRFIGlzIG5vdCBz
ZXQKIyBDT05GSUdfQ1JDMzJfQklUIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JDNyBpcyBub3Qg
c2V0CkNPTkZJR19MSUJDUkMzMkM9eQojIENPTkZJR19DUkM4IGlzIG5vdCBzZXQKQ09ORklH
X1pMSUJfSU5GTEFURT15CkNPTkZJR19aTElCX0RFRkxBVEU9eQpDT05GSUdfTFpPX0NPTVBS
RVNTPXkKQ09ORklHX0xaT19ERUNPTVBSRVNTPXkKQ09ORklHX1haX0RFQz15CiMgQ09ORklH
X1haX0RFQ19YODYgaXMgbm90IHNldApDT05GSUdfWFpfREVDX1BPV0VSUEM9eQpDT05GSUdf
WFpfREVDX0lBNjQ9eQpDT05GSUdfWFpfREVDX0FSTT15CiMgQ09ORklHX1haX0RFQ19BUk1U
SFVNQiBpcyBub3Qgc2V0CkNPTkZJR19YWl9ERUNfU1BBUkM9eQpDT05GSUdfWFpfREVDX0JD
Sj15CiMgQ09ORklHX1haX0RFQ19URVNUIGlzIG5vdCBzZXQKQ09ORklHX0RFQ09NUFJFU1Nf
TFpNQT15CkNPTkZJR19HRU5FUklDX0FMTE9DQVRPUj15CkNPTkZJR19CVFJFRT15CkNPTkZJ
R19IQVNfSU9NRU09eQpDT05GSUdfSEFTX0lPUE9SVD15CkNPTkZJR19IQVNfRE1BPXkKQ09O
RklHX0NIRUNLX1NJR05BVFVSRT15CkNPTkZJR19DUFVNQVNLX09GRlNUQUNLPXkKQ09ORklH
X0NQVV9STUFQPXkKQ09ORklHX0RRTD15CkNPTkZJR19OTEFUVFI9eQpDT05GSUdfQVJDSF9I
QVNfQVRPTUlDNjRfREVDX0lGX1BPU0lUSVZFPXkKQ09ORklHX0FWRVJBR0U9eQpDT05GSUdf
Q09SRElDPXkKIyBDT05GSUdfRERSIGlzIG5vdCBzZXQK
--------------040206060302080906000102--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
