Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id EDC206B0031
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 07:40:29 -0400 (EDT)
Date: Thu, 6 Jun 2013 06:40:28 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: mmotm 2013-06-05-17-24 uploaded
Message-ID: <20130606114028.GG3672@sgi.com>
References: <20130606002636.6746F5A41AE@corp2gmr1-2.hot.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130606002636.6746F5A41AE@corp2gmr1-2.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Wed, Jun 05, 2013 at 05:26:36PM -0700, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2013-06-05-17-24 has been uploaded to
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

It looks like the shutdown-reboot patches I sent are still not queued
for Linus.  Did these just get lost in the shuffle or do they need to
be resubmitted?  The first two were marked for -stable and I would really
like to get them in sometime as it does affect severely affect shutdown
of large systems.  I will resend them shortly.

Robin

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
> This mmotm tree contains the following patches against 3.10-rc4:
> (patches marked "*" will be included in linux-next)
> 
>   origin.patch
>   linux-next.patch
>   linux-next-git-rejects.patch
>   arch-alpha-kernel-systblss-remove-debug-check.patch
>   i-need-old-gcc.patch
> * cpu-hotplug-provide-a-generic-helper-to-disable-enable-cpu-hotplug.patch
> * cpu-hotplug-provide-a-generic-helper-to-disable-enable-cpu-hotplug-v11.patch
> * migrate-shutdown-reboot-to-boot-cpu.patch
> * migrate-shutdown-reboot-to-boot-cpu-v11.patch
> * kmsg-honor-dmesg_restrict-sysctl-on-dev-kmsg.patch
> * kmsg-honor-dmesg_restrict-sysctl-on-dev-kmsg-fix.patch
> * lib-mpi-mpicoderc-looping-issue-need-stop-when-equal-to-zero-found-by-extra_flags=-w.patch
> * ocfs2-ocfs2_prep_new_orphaned_file-should-return-ret.patch
> * memcg-dont-initialize-kmem-cache-destroying-work-for-root-caches.patch
> * rtc-tps6586x-device-wakeup-flags-correction.patch
> * drivers-rtc-rtc-cmosc-fix-accidentally-enabling-rtc-channel.patch
> * drivers-rtc-rtc-cmosc-fix-accidentally-enabling-rtc-channel-fix.patch
> * audit-wait_for_auditd-should-use-task_uninterruptible.patch
> * cciss-fix-broken-mutex-usage-in-ioctl.patch
> * drivers-rtc-rtc-twlc-fix-missing-device_init_wakeup-when-booted-with-device-tree.patch
> * swap-avoid-read_swap_cache_async-race-to-deadlock-while-waiting-on-discard-i-o-completion.patch
> * fs-ocfs2-nameic-remove-unecessary-error-when-removing-non-empty-directory.patch
> * rtc-at91rm9200-add-match-table-compile-guard.patch
> * rtc-at91rm9200-add-configuration-support.patch
> * rtc-at91rm9200-refactor-interrupt-register-handling.patch
> * rtc-at91rm9200-add-shadow-interrupt-mask.patch
> * rtc-at91rm9200-use-shadow-imr-on-at91sam9x5.patch
> * aio-use-call_rcu-instead-of-synchronize_rcu-in-kill_ioctx.patch
> * drivers-misc-sgi-gru-grufilec-fix-info-leak-in-gru_get_config_info.patch
> * mm-page_alloc-fix-watermark-check-in-__zone_watermark_ok.patch
> * mm-migration-add-migrate_entry_wait_huge.patch
> * drivers-base-cpuc-fix-maxcpus-boot-option.patch
> * drivers-base-cpuc-fix-maxcpus-boot-option-fix.patch
> * kernel-audit_treec-audit_add_tree_rule-protect-rule-from-kill_rules.patch
> * frontswap-fix-incorrect-zeroing-and-allocation-size-for-frontswap_map.patch
> * mm-memcontrol-fix-lockless-reclaim-hierarchy-iterator.patch
> * drivers-platform-x86-intel_ips-convert-to-module_pci_driver.patch
> * sound-soc-codecs-si476xc-dont-use-0bnnn.patch
> * x86-make-mem=-option-to-work-for-efi-platform.patch
> * audit-fix-mq_open-and-mq_unlink-to-add-the-mq-root-as-a-hidden-parent-audit_names-record.patch
> * kernel-auditfilterc-fixing-build-warning.patch
> * kernel-auditfilterc-fix-leak-in-audit_add_rule-error-path.patch
> * drivers-pcmcia-pd6729c-convert-to-module_pci_driver.patch
> * drivers-pcmcia-yenta_socketc-convert-to-module_pci_driver.patch
> * drm-fb-helper-dont-sleep-for-screen-unblank-when-an-oopps-is-in-progress.patch
> * drm-cirrus-correct-register-values-for-16bpp.patch
> * drm-nouveau-make-vga_switcheroo-code-depend-on-vga_switcheroo.patch
> * drivers-media-pci-mantis-mantis_cards-convert-to-module_pci_driver.patch
> * drivers-media-pci-dm1105-dm1105-convert-to-module_pci_driver.patch
> * drivers-media-pci-mantis-hopper_cards-convert-to-module_pci_driver.patch
> * drivers-media-pci-pluto2-pluto2-convert-to-module_pci_driver.patch
> * drivers-media-pci-pt1-pt1-convert-to-module_pci_driver.patch
> * video-smscufx-use-null-instead-of-0.patch
> * video-udlfb-use-null-instead-of-0.patch
> * video-udlfb-make-local-symbol-static.patch
> * video-imxfb-make-local-symbols-static.patch
> * drivers-video-acornfbc-remove-dead-code.patch
> * cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
> * drivers-iommu-msm_iommu_devc-fix-leak-and-clean-up-error-paths.patch
> * drivers-iommu-msm_iommu_devc-fix-leak-and-clean-up-error-paths-fix.patch
> * posix_cpu_timer-consolidate-expiry-time-type.patch
> * posix_cpu_timers-consolidate-timer-list-cleanups.patch
> * posix_cpu_timers-consolidate-expired-timers-check.patch
> * selftests-add-basic-posix-timers-selftests.patch
> * posix-timers-correctly-get-dying-task-time-sample-in-posix_cpu_timer_schedule.patch
> * posix_timers-fix-racy-timer-delta-caching-on-task-exit.patch
> * kernel-timerc-fix-jiffies-wrap-behavior-of-round_jiffies.patch
> * drivers-infiniband-core-cmc-convert-to-using-idr_alloc_cyclic.patch
> * drivers-ide-delkin_cb-convert-to-module_pci_driver.patch
> * drivers-mfd-lpc_ich-convert-to-module_pci_driver.patch
> * drivers-mtd-chips-gen_probec-refactor-call-to-request_module.patch
> * configfs-use-capped-length-for-store_attribute.patch
> * ipvs-change-type-of-netns_ipvs-sysctl_sync_qlen_max.patch
> * drivers-net-ethernet-ibm-ehea-ehea_mainc-add-alias-entry-for-portn-properties.patch
> * misdn-add-support-for-group-membership-check.patch
> * drivers-atm-he-convert-to-module_pci_driver.patch
> * drivers-ptp-ptp_pch-convert-to-module_pci_driver.patch
> * fs-ocfs2-dlm-dlmrecoveryc-remove-duplicate-declarations.patch
> * fs-ocfs2-dlm-dlmrecoveryc-dlm_request_all_locks-ret-should-be-int-instead-of-enum.patch
> * ocfs2-should-not-use-le32_add_cpu-to-set-ocfs2_dinode-i_flags.patch
> * ocfs2-add-missing-dlm_put-in-dlm_begin_reco_handler.patch
> * softirq-use-_ret_ip_.patch
> * include-linux-schedh-dont-use-task-pid-tgid-in-same_thread_group-has_group_leader_pid.patch
> * lockdep-introduce-lock_acquire_exclusive-shared-helper-macros.patch
> * lglock-update-lockdep-annotations-to-report-recursive-local-locks.patch
> * drivers-scsi-a100u2w-convert-to-module_pci_driver.patch
> * drivers-scsi-dc395x-convert-to-module_pci_driver.patch
> * drivers-scsi-dmx3191d-convert-to-module_pci_driver.patch
> * drivers-scsi-initio-convert-to-module_pci_driver.patch
> * drivers-scsi-mvumi-convert-to-module_pci_driver.patch
> * drivers-net-irda-donauboe-convert-to-module_pci_driver.patch
> * drivers-cdrom-gdromc-fix-device-number-leak.patch
> * block-compat_ioctlc-do-not-leak-info-to-user-space.patch
> * drivers-cdrom-cdromc-use-kzalloc-for-failing-hardware.patch
> * block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
> * watchdog-trigger-all-cpu-backtrace-when-locked-up-and-going-to-panic.patch
>   mm.patch
> * clear_refs-sanitize-accepted-commands-declaration.patch
> * clear_refs-introduce-private-struct-for-mm_walk.patch
> * pagemap-introduce-pagemap_entry_t-without-pmshift-bits.patch
> * pagemap-introduce-pagemap_entry_t-without-pmshift-bits-v4.patch
> * mm-soft-dirty-bits-for-user-memory-changes-tracking.patch
> * mm-soft-dirty-bits-for-user-memory-changes-tracking-call-mmu-notifiers-when-write-protecting-ptes.patch
> * pagemap-prepare-to-reuse-constant-bits-with-page-shift.patch
> * mm-thp-use-the-right-function-when-updating-access-flags.patch
> * mm-memcg-dont-take-task_lock-in-task_in_mem_cgroup.patch
> * mm-remove-free_area_cache.patch
> * mm-remove-compressed-copy-from-zram-in-memory.patch
> * mm-remove-compressed-copy-from-zram-in-memory-fix.patch
> * swap-add-a-simple-detector-for-inappropriate-swapin-readahead.patch
> * mm-use-vma_pages-to-replace-vm_end-vm_start-page_shift.patch
> * ncpfs-use-vma_pages-to-replace-vm_end-vm_start-page_shift.patch
> * uio-use-vma_pages-to-replace-vm_end-vm_start-page_shift.patch
> * mm-page_alloc-factor-out-setting-of-pcp-high-and-pcp-batch.patch
> * mm-page_alloc-prevent-concurrent-updaters-of-pcp-batch-and-high.patch
> * mm-page_alloc-insert-memory-barriers-to-allow-async-update-of-pcp-batch-and-high.patch
> * mm-page_alloc-protect-pcp-batch-accesses-with-access_once.patch
> * mm-page_alloc-convert-zone_pcp_update-to-rely-on-memory-barriers-instead-of-stop_machine.patch
> * mm-page_alloc-when-handling-percpu_pagelist_fraction-dont-unneedly-recalulate-high.patch
> * mm-page_alloc-factor-setup_pageset-into-pageset_init-and-pageset_set_batch.patch
> * mm-page_alloc-relocate-comment-to-be-directly-above-code-it-refers-to.patch
> * mm-page_alloc-factor-zone_pageset_init-out-of-setup_zone_pageset.patch
> * mm-page_alloc-in-zone_pcp_update-uze-zone_pageset_init.patch
> * mm-page_alloc-rename-setup_pagelist_highmark-to-match-naming-of-pageset_set_batch.patch
> * mm-thp-add-pmd-args-to-pgtable-deposit-and-withdraw-apis.patch
> * mm-thp-withdraw-the-pgtable-after-pmdp-related-operations.patch
> * mm-thp-dont-use-hpage_shift-in-transparent-hugepage-code.patch
> * mm-thp-deposit-the-transpare-huge-pgtable-before-set_pmd.patch
> * mm-vmscan-limit-the-number-of-pages-kswapd-reclaims-at-each-priority.patch
> * mm-vmscan-obey-proportional-scanning-requirements-for-kswapd.patch
> * mm-vmscan-flatten-kswapd-priority-loop.patch
> * mm-vmscan-decide-whether-to-compact-the-pgdat-based-on-reclaim-progress.patch
> * mm-vmscan-do-not-allow-kswapd-to-scan-at-maximum-priority.patch
> * mm-vmscan-have-kswapd-writeback-pages-based-on-dirty-pages-encountered-not-priority.patch
> * mm-vmscan-block-kswapd-if-it-is-encountering-pages-under-writeback.patch
> * mm-vmscan-block-kswapd-if-it-is-encountering-pages-under-writeback-fix.patch
> * mm-vmscan-block-kswapd-if-it-is-encountering-pages-under-writeback-fix-2.patch
> * mm-vmscan-check-if-kswapd-should-writepage-once-per-pgdat-scan.patch
> * mm-vmscan-move-logic-from-balance_pgdat-to-kswapd_shrink_zone.patch
> * mm-vmscan-stall-page-reclaim-and-writeback-pages-based-on-dirty-writepage-pages-encountered-v3.patch
> * mm-vmscan-stall-page-reclaim-after-a-list-of-pages-have-been-processed-v3.patch
> * mm-vmscan-set-zone-flags-before-blocking.patch
> * mm-vmscan-move-direct-reclaim-wait_iff_congested-into-shrink_list.patch
> * mm-vmscan-treat-pages-marked-for-immediate-reclaim-as-zone-congestion.patch
> * mm-vmscan-take-page-buffers-dirty-and-locked-state-into-account-v3.patch
> * fs-nfs-inform-the-vm-about-pages-being-committed-or-unstable.patch
> * mm-fix-comment-referring-to-non-existent-size_seqlock-change-to-span_seqlock.patch
> * mmzone-note-that-node_size_lock-should-be-manipulated-via-pgdat_resize_lock.patch
> * memory_hotplug-use-pgdat_resize_lock-in-online_pages.patch
> * memory_hotplug-use-pgdat_resize_lock-in-__offline_pages.patch
> * memory_hotplug-use-pgdat_resize_lock-in-__offline_pages-fix.patch
> * include-linux-mmh-add-page_aligned-helper.patch
> * vmcore-clean-up-read_vmcore.patch
> * vmcore-allocate-buffer-for-elf-headers-on-page-size-alignment.patch
> * vmcore-allocate-buffer-for-elf-headers-on-page-size-alignment-fix.patch
> * vmcore-treat-memory-chunks-referenced-by-pt_load-program-header-entries-in-page-size-boundary-in-vmcore_list.patch
> * vmalloc-make-find_vm_area-check-in-range.patch
> * vmalloc-introduce-remap_vmalloc_range_partial.patch
> * vmalloc-introduce-remap_vmalloc_range_partial-fix.patch
> * vmcore-allocate-elf-note-segment-in-the-2nd-kernel-vmalloc-memory.patch
> * vmcore-allocate-elf-note-segment-in-the-2nd-kernel-vmalloc-memory-fix.patch
> * vmcore-allow-user-process-to-remap-elf-note-segment-buffer.patch
> * vmcore-allow-user-process-to-remap-elf-note-segment-buffer-fix.patch
> * vmcore-calculate-vmcore-file-size-from-buffer-size-and-total-size-of-vmcore-objects.patch
> * vmcore-support-mmap-on-proc-vmcore.patch
> * vmcore-support-mmap-on-proc-vmcore-fix.patch
> * memcg-update-todo-list-in-documentation.patch
> * mm-add-tracepoints-for-lru-activation-and-insertions.patch
> * mm-pagevec-defer-deciding-what-lru-to-add-a-page-to-until-pagevec-drain-time.patch
> * mm-activate-pagelru-pages-on-mark_page_accessed-if-page-is-on-local-pagevec.patch
> * mm-remove-lru-parameter-from-__pagevec_lru_add-and-remove-parts-of-pagevec-api.patch
> * mm-remove-lru-parameter-from-__lru_cache_add-and-lru_cache_add_lru.patch
> * mm-page_allocc-add-additional-checking-and-return-value-for-the-table-data.patch
> * mm-nommuc-add-additional-check-for-vread-just-like-vwrite-has-done.patch
> * mm-memory-failurec-fix-memory-leak-in-successful-soft-offlining.patch
> * mm-remove-duplicated-call-of-get_pfn_range_for_nid.patch
> * mm-change-normal-message-to-use-pr_debug.patch
> * mm-memory-hotplug-fix-lowmem-count-overflow-when-offline-pages.patch
> * mm-memory-hotplug-fix-lowmem-count-overflow-when-offline-pages-fix.patch
> * mm-pageblock-remove-get-set_pageblock_flags.patch
> * mm-hugetlb-remove-hugetlb_prefault.patch
> * mm-hugetlb-use-already-exist-interface-huge_page_shift.patch
> * mm-tune-vm_committed_as-percpu_counter-batching-size.patch
> * swap-discard-while-swapping-only-if-swap_flag_discard_pages.patch
> * swap-discard-while-swapping-only-if-swap_flag_discard_pages-fix.patch
> * mm-change-signature-of-free_reserved_area-to-fix-building-warnings.patch
> * mm-enhance-free_reserved_area-to-support-poisoning-memory-with-zero.patch
> * mm-arm64-kill-poison_init_mem.patch
> * mm-x86-use-free_reserved_area-to-simplify-code.patch
> * mm-tile-use-common-help-functions-to-free-reserved-pages.patch
> * mm-fix-some-trivial-typos-in-comments.patch
> * mm-use-managed_pages-to-calculate-default-zonelist-order.patch
> * mm-accurately-calculate-zone-managed_pages-for-highmem-zones.patch
> * mm-use-a-dedicated-lock-to-protect-totalram_pages-and-zone-managed_pages.patch
> * mm-make-__free_pages_bootmem-only-available-at-boot-time.patch
> * mm-correctly-update-zone-managed_pages.patch
> * mm-correctly-update-zone-managed_pages-fix.patch
> * mm-correctly-update-zone-managed_pages-fix-fix.patch
> * mm-concentrate-modification-of-totalram_pages-into-the-mm-core.patch
> * mm-report-available-pages-as-memtotal-for-each-numa-node.patch
> * memcg-kconfig-info-update.patch
> * mm-fix-the-tlb-range-flushed-when-__tlb_remove_page-runs-out-of-slots.patch
> * vmlinuxlds-add-comments-for-global-variables-and-clean-up-useless-declarations.patch
> * avr32-normalize-global-variables-exported-by-vmlinuxlds.patch
> * c6x-normalize-global-variables-exported-by-vmlinuxlds.patch
> * h8300-normalize-global-variables-exported-by-vmlinuxlds.patch
> * score-normalize-global-variables-exported-by-vmlinuxlds.patch
> * tile-normalize-global-variables-exported-by-vmlinuxlds.patch
> * uml-normalize-global-variables-exported-by-vmlinuxlds.patch
> * mm-introduce-helper-function-mem_init_print_info-to-simplify-mem_init.patch
> * mm-use-totalram_pages-instead-of-num_physpages-at-runtime.patch
> * mm-hotplug-prepare-for-removing-num_physpages.patch
> * mm-alpha-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-arc-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-arm-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-arm64-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-avr32-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-blackfin-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-c6x-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-cris-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-frv-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-h8300-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-hexagon-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-ia64-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-m32r-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-m68k-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-metag-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-microblaze-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-mips-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-mn10300-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-openrisc-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-parisc-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-ppc-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-s390-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-score-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-sh-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-sparc-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-tile-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-um-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-unicore32-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-x86-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-xtensa-prepare-for-removing-num_physpages-and-simplify-mem_init.patch
> * mm-kill-global-variable-num_physpages.patch
> * mm-introduce-helper-function-set_max_mapnr.patch
> * mm-avr32-prepare-for-killing-free_all_bootmem_node.patch
> * mm-ia64-prepare-for-killing-free_all_bootmem_node.patch
> * mm-m32r-prepare-for-killing-free_all_bootmem_node.patch
> * mm-m68k-prepare-for-killing-free_all_bootmem_node.patch
> * mm-metag-prepare-for-killing-free_all_bootmem_node.patch
> * mm-mips-prepare-for-killing-free_all_bootmem_node.patch
> * mm-parisc-prepare-for-killing-free_all_bootmem_node.patch
> * mm-ppc-prepare-for-killing-free_all_bootmem_node.patch
> * mm-sh-prepare-for-killing-free_all_bootmem_node.patch
> * mm-kill-free_all_bootmem_node.patch
> * mm-alpha-unify-mem_init-for-both-uma-and-numa-architectures.patch
> * mm-m68k-fix-build-warning-of-unused-variable.patch
> * mm-alpha-clean-up-unused-valid_page.patch
> * mm-arm-fix-stale-comment-about-valid_page.patch
> * mm-cris-clean-up-unused-valid_page.patch
> * mm-microblaze-clean-up-unused-valid_page.patch
> * mm-unicore32-fix-stale-comment-about-valid_page.patch
> * sparsemem-add-build_bug_on-when-sizeof-mem_section-is-non-power-of-2.patch
> * documentation-update-address_space_operations.patch
> * documentation-document-the-is_dirty_writeback-aops-callback.patch
> * mm-tlb_fast_mode-check-missing-in-tlb_finish_mmu.patch
> * fs-fs-writebackc-make-wb_do_writeback-as-static.patch
> * mm-vmalloc-only-call-setup_vmalloc_vm-only-in-__get_vm_area_node.patch
> * mm-vmalloc-call-setup_vmalloc_vm-instead-of-insert_vmalloc_vm.patch
> * mm-vmalloc-remove-insert_vmalloc_vm.patch
> * mm-vmalloc-use-clamp-to-simplify-code.patch
> * memcg-debugging-facility-to-access-dangling-memcgs.patch
> * memcg-debugging-facility-to-access-dangling-memcgs-fix.patch
> * mm-memcontrol-factor-out-reclaim-iterator-loading-and-updating.patch
> * fs-bump-inode-and-dentry-counters-to-long.patch
> * super-fix-calculation-of-shrinkable-objects-for-small-numbers.patch
> * dcache-convert-dentry_statnr_unused-to-per-cpu-counters.patch
> * dentry-move-to-per-sb-lru-locks.patch
> * dcache-remove-dentries-from-lru-before-putting-on-dispose-list.patch
> * dcache-remove-dentries-from-lru-before-putting-on-dispose-list-fix.patch
> * mm-new-shrinker-api.patch
> * shrinker-convert-superblock-shrinkers-to-new-api.patch
> * list-add-a-new-lru-list-type.patch
> * inode-convert-inode-lru-list-to-generic-lru-list-code.patch
> * dcache-convert-to-use-new-lru-list-infrastructure.patch
> * list_lru-per-node-list-infrastructure.patch
> * shrinker-add-node-awareness.patch
> * vmscan-per-node-deferred-work.patch
> * list_lru-per-node-api.patch
> * fs-convert-inode-and-dentry-shrinking-to-be-node-aware.patch
> * xfs-convert-buftarg-lru-to-generic-code.patch
> * xfs-rework-buffer-dispose-list-tracking.patch
> * xfs-convert-dquot-cache-lru-to-list_lru.patch
> * fs-convert-fs-shrinkers-to-new-scan-count-api.patch
> * drivers-convert-shrinkers-to-new-count-scan-api.patch
> * i915-bail-out-earlier-when-shrinker-cannot-acquire-mutex.patch
> * shrinker-convert-remaining-shrinkers-to-count-scan-api.patch
> * hugepage-convert-huge-zero-page-shrinker-to-new-shrinker-api.patch
> * shrinker-kill-old-shrink-api.patch
> * vmscan-also-shrink-slab-in-memcg-pressure.patch
> * memcglist_lru-duplicate-lrus-upon-kmemcg-creation.patch
> * lru-add-an-element-to-a-memcg-list.patch
> * list_lru-per-memcg-walks.patch
> * memcg-per-memcg-kmem-shrinking.patch
> * memcg-scan-cache-objects-hierarchically.patch
> * vmscan-take-at-least-one-pass-with-shrinkers.patch
> * super-targeted-memcg-reclaim.patch
> * memcg-move-initialization-to-memcg-creation.patch
> * vmpressure-in-kernel-notifications.patch
> * memcg-reap-dead-memcgs-upon-global-memory-pressure.patch
> * include-linux-mmzoneh-cleanups.patch
> * include-linux-mmzoneh-cleanups-fix.patch
> * mm-memmap_init_zone-performance-improvement.patch
> * drop_caches-add-some-documentation-and-info-messsge.patch
> * drivers-usb-gadget-amd5536udcc-avoid-calling-dma_pool_create-with-null-dev.patch
> * mm-dmapoolc-fix-null-dev-in-dma_pool_create.patch
> * mm-add-vm-event-counters-for-balloon-pages-compaction.patch
> * arch-frv-kernel-trapsc-using-vsnprintf-instead-of-vsprintf.patch
> * arch-frv-kernel-setupc-use-strncmp-instead-of-memcmp.patch
> * errh-is_err-can-accept-__user-pointers.patch
> * clean-up-scary-strncpydst-src-strlensrc-uses.patch
> * clean-up-scary-strncpydst-src-strlensrc-uses-fix.patch
> * dump_stack-serialize-the-output-from-dump_stack.patch
> * dump_stack-serialize-the-output-from-dump_stack-fix.patch
> * panic-add-cpu-pid-to-warn_slowpath_common-in-warning-printks.patch
> * panic-add-cpu-pid-to-warn_slowpath_common-in-warning-printks-fix.patch
> * kernel-sysc-sys_reboot-fix-malformed-panic-message.patch
> * smp-give-warning-when-calling-smp_call_function_many-single-in-serving-irq.patch
> * drivers-misc-sgi-gru-grufaultc-fix-a-sanity-test-in-gru_set_context_option.patch
> * maintainers-fix-tape-driver-file-mappings.patch
> * backlight-atmel-pwm-bl-remove-unnecessary-platform_set_drvdata.patch
> * backlight-ep93xx-remove-unnecessary-platform_set_drvdata.patch
> * backlight-lp8788-remove-unnecessary-platform_set_drvdata.patch
> * backlight-pcf50633-remove-unnecessary-platform_set_drvdata.patch
> * backlight-add-devm_backlight_device_registerunregister.patch
> * lcd-add-devm_lcd_device_registerunregister.patch
> * maintainers-add-backlight-subsystem-co-maintainer.patch
> * backlight-convert-from-legacy-pm-ops-to-dev_pm_ops.patch
> * rbtree-remove-unneeded-include.patch
> * rbtree-remove-unneeded-include-fix.patch
> * checkpatch-change-camelcase-test-and-make-it-strict.patch
> * checkpatch-warn-when-using-gccs-binary-constant-extension.patch
> * checkpatch-add-strict-preference-for-p-=-kmallocsizeofp.patch
> * binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
> * init-remove-permanent-string-buffer-from-do_one_initcall.patch
> * insert-missing-space-in-printk-line-of-root_delay.patch
> * kprobes-handle-empty-invalid-input-to-debugfs-enabled-file.patch
> * autofs4-allow-autofs-to-work-outside-the-initial-pid-namespace.patch
> * autofs4-translate-pids-to-the-right-namespace-for-the-daemon.patch
> * rtc-rtc-88pm80x-remove-unnecessary-platform_set_drvdata.patch
> * drivers-rtc-rtc-v3020c-remove-redundant-goto.patch
> * drivers-rtc-interfacec-fix-checkpatch-errors.patch
> * drivers-rtc-rtc-at32ap700xc-fix-checkpatch-error.patch
> * drivers-rtc-rtc-at91rm9200c-include-linux-uaccessh.patch
> * drivers-rtc-rtc-cmosc-fix-whitespace-related-errors.patch
> * drivers-rtc-rtc-davincic-fix-whitespace-warning.patch
> * drivers-rtc-rtc-ds1305c-add-missing-braces-around-sizeof.patch
> * drivers-rtc-rtc-ds1374c-fix-spacing-related-issues.patch
> * drivers-rtc-rtc-ds1511c-fix-issues-related-to-spaces-and-braces.patch
> * drivers-rtc-rtc-ds3234c-fix-whitespace-issue.patch
> * drivers-rtc-rtc-fm3130c-fix-whitespace-related-issue.patch
> * drivers-rtc-rtc-m41t80c-fix-spacing-related-issue.patch
> * drivers-rtc-rtc-max6902c-remove-unwanted-spaces.patch
> * drivers-rtc-rtc-max77686c-remove-space-before-semicolon.patch
> * drivers-rtc-rtc-max8997c-remove-space-before-semicolon.patch
> * drivers-rtc-rtc-mpc5121c-remove-space-before-tab.patch
> * drivers-rtc-rtc-msm6242c-use-pr_warn.patch
> * drivers-rtc-rtc-mxcc-fix-checkpatch-error.patch
> * drivers-rtc-rtc-omapc-include-linux-ioh-instead-of-asm-ioh.patch
> * drivers-rtc-rtc-pcf2123c-remove-space-before-tabs.patch
> * drivers-rtc-rtc-pcf8583c-move-assignment-outside-if-condition.patch
> * drivers-rtc-rtc-rs5c313c-include-linux-ioh-instead-of-asm-ioh.patch
> * drivers-rtc-rtc-rs5c313c-fix-spacing-related-issues.patch
> * drivers-rtc-rtc-v3020c-fix-spacing-issues.patch
> * drivers-rtc-rtc-vr41xxc-fix-spacing-issues.patch
> * drivers-rtc-rtc-x1205c-fix-checkpatch-issues.patch
> * rtc-rtc-88pm860x-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-ab3100-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-ab8500-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-at32ap700x-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-at91rm9200-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-at91sam9-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-au1xxx-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-bfin-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-bq4802-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-coh901331-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-da9052-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-da9055-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-davinci-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-dm355evm-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-ds1302-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-ep93xx-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-jz4740-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-lp8788-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-lpc32xx-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-ls1x-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-m48t59-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-max8925-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-max8998-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-mc13xxx-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-msm6242-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-mxc-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-nuc900-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-pcap-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-pm8xxx-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-s3c-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-sa1100-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-sh-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-spear-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-stmp3xxx-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-twl-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-vr41xx-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-vt8500-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-m48t86-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-puv3-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-rp5c01-remove-unnecessary-platform_set_drvdata.patch
> * rtc-rtc-tile-remove-unnecessary-platform_set_drvdata.patch
> * drivers-rtc-rtc-rv3029c2c-fix-disabling-aie-irq.patch
> * drivers-rtc-rtc-m48t86c-remove-empty-function.patch
> * drivers-rtc-rtc-tilec-remove-empty-function.patch
> * drivers-rtc-rtc-nuc900c-remove-empty-function.patch
> * drivers-rtc-rtc-msm6242c-remove-empty-function.patch
> * drivers-rtc-rtc-max8998c-remove-empty-function.patch
> * drivers-rtc-rtc-max8925c-remove-empty-function.patch
> * drivers-rtc-rtc-ls1xc-remove-empty-function.patch
> * drivers-rtc-rtc-lp8788c-remove-empty-function.patch
> * drivers-rtc-rtc-ds1302c-remove-empty-function.patch
> * drivers-rtc-rtc-dm355evmc-remove-empty-function.patch
> * drivers-rtc-rtc-da9055c-remove-empty-function.patch
> * drivers-rtc-rtc-da9052c-remove-empty-function.patch
> * drivers-rtc-rtc-bq4802c-remove-empty-function.patch
> * drivers-rtc-rtc-au1xxxc-remove-empty-function.patch
> * drivers-rtc-rtc-ab3100c-remove-empty-function.patch
> * rtc-rtc-hid-sensor-time-allow-full-years-16bit-in-hid-reports.patch
> * rtc-rtc-hid-sensor-time-allow-16-and-32-bit-values-for-all-attributes.patch
> * rtc-rtc-hid-sensor-time-add-option-hctosys-to-set-time-at-boot.patch
> * rtc-rtc-hid-sensor-time-add-support-for-milliseconds.patch
> * rtc-add-ability-to-push-out-an-existing-wakealarm-using-sysfs.patch
> * rtc-rtc-vr41xx-fix-error-return-code-in-rtc_probe.patch
> * rtc-rtc-ds1307-use-devm_-functions.patch
> * rtc-rtc-jz4740-use-devm_-functions.patch
> * rtc-rtc-mpc5121-use-devm_-functions.patch
> * rtc-rtc-m48t59-use-devm_-functions.patch
> * rtc-rtc-pm8xxx-use-devm_-functions.patch
> * rtc-rtc-pxa-use-devm_-functions.patch
> * rtc-rtc-rx8025-use-devm_-functions.patch
> * rtc-rtc-sh-use-devm_-functions.patch
> * rtc-rtc-coh901331-use-platform_getset_drvdata.patch
> * rtc-rtc-rc5t583-use-platform_getset_drvdata.patch
> * drivers-rtc-rtc-bq32kc-remove-empty-function.patch
> * drivers-rtc-rtc-ds1216c-remove-empty-function.patch
> * drivers-rtc-rtc-ds1286c-remove-empty-function.patch
> * drivers-rtc-rtc-ds1672c-remove-empty-function.patch
> * drivers-rtc-rtc-ds3234c-remove-empty-function.patch
> * drivers-rtc-rtc-ds1390c-remove-empty-function.patch
> * drivers-rtc-rtc-efic-remove-empty-function.patch
> * drivers-rtc-rtc-em3027c-remove-empty-function.patch
> * drivers-rtc-rtc-fm3130c-remove-empty-function.patch
> * drivers-rtc-rtc-isl12022c-remove-empty-function.patch
> * drivers-rtc-rtc-m41t93c-remove-empty-function.patch
> * drivers-rtc-rtc-m48t35c-remove-empty-function.patch
> * drivers-rtc-rtc-genericc-remove-empty-function.patch
> * drivers-rtc-rtc-m41t94c-remove-empty-function.patch
> * drivers-rtc-rtc-max6902c-remove-empty-function.patch
> * drivers-rtc-rtc-max6900c-remove-empty-function.patch
> * drivers-rtc-rtc-max8907c-remove-empty-function.patch
> * drivers-rtc-rtc-max77686c-remove-empty-function.patch
> * drivers-rtc-rtc-max8997c-remove-empty-function.patch
> * drivers-rtc-rtc-pcf8523c-remove-empty-function.patch
> * drivers-rtc-rtc-pcf8563c-remove-empty-function.patch
> * drivers-rtc-rtc-pcf8583c-remove-empty-function.patch
> * drivers-rtc-rtc-ps3c-remove-empty-function.patch
> * drivers-rtc-rtc-rs5c313c-remove-empty-function.patch
> * drivers-rtc-rtc-rv3029c2c-remove-empty-function.patch
> * drivers-rtc-rtc-rx4581c-remove-empty-function.patch
> * drivers-rtc-rtc-rs5c348c-remove-empty-function.patch
> * drivers-rtc-rtc-rx8581c-remove-empty-function.patch
> * drivers-rtc-rtc-snvsc-remove-empty-function.patch
> * drivers-rtc-rtc-starfirec-remove-empty-function.patch
> * drivers-rtc-rtc-sun4vc-remove-empty-function.patch
> * drivers-rtc-rtc-tps80031c-remove-empty-function.patch
> * drivers-rtc-rtc-wm831xc-remove-empty-function.patch
> * mfd-ab8540-add-device-for-new-rtc-version-on-ab8540-cut2.patch
> * rtc-ab8540-add-second-resolution-to-rtc-driver.patch
> * drivers-rtc-rtc-ds1302c-handle-write-protection.patch
> * drivers-rtc-rtc-mpc5121c-use-platform_getset_drvdata.patch
> * drivers-rtc-rtc-da9052c-use-ptr_ret.patch
> * drivers-rtc-rtc-isl12022c-use-ptr_ret.patch
> * drivers-rtc-rtc-m48t35c-use-ptr_ret.patch
> * drivers-rtc-rtc-pcf8563c-use-ptr_ret.patch
> * drivers-rtc-rtc-pcf8583c-use-ptr_ret.patch
> * drivers-rtc-class-convert-from-legacy-pm-ops-to-dev_pm_ops.patch
> * drivers-rtc-rtc-twlc-ensure-irq-is-wakeup-enabled.patch
> * drivers-rtc-rtc-cmosc-work-around-bios-clearing-rtc-control.patch
> * minix-bug-widening-a-binary-not-operation.patch
> * nilfs2-implement-calculation-of-free-inodes-count.patch
> * nilfs2-use-atomic64_t-type-for-inodes_count-and-blocks_count-fields-in-nilfs_root-struct.patch
> * fs-fat-use-fat_msg-to-replace-printk-in-__fat_fs_error.patch
> * fat-additions-to-support-fat_fallocate.patch
> * fat-additions-to-support-fat_fallocate-fix.patch
> * documentation-codingstyle-allow-multiple-return-statements-per-function.patch
> * ptrace-x86-revert-hw_breakpoints-fix-racy-access-to-ptrace-breakpoints.patch
> * ptrace-powerpc-revert-hw_breakpoints-fix-racy-access-to-ptrace-breakpoints.patch
> * ptrace-arm-revert-hw_breakpoints-fix-racy-access-to-ptrace-breakpoints.patch
> * ptrace-sh-revert-hw_breakpoints-fix-racy-access-to-ptrace-breakpoints.patch
> * ptrace-revert-prepare-to-fix-racy-accesses-on-task-breakpoints.patch
> * ptrace-x86-simplify-the-disable-logic-in-ptrace_write_dr7.patch
> * ptrace-x86-dont-delay-disable-till-second-pass-in-ptrace_write_dr7.patch
> * ptrace-x86-introduce-ptrace_register_breakpoint.patch
> * ptrace-x86-ptrace_write_dr7-should-create-bp-if-disabled.patch
> * ptrace-x86-cleanup-ptrace_set_debugreg.patch
> * ptrace-ptrace_detach-should-do-flush_ptrace_hw_breakpointchild.patch
> * ptrace-x86-flush_ptrace_hw_breakpoint-shoule-clear-the-virtual-debug-registers.patch
> * x86-kill-tif_debug.patch
> * ptrace-add-ability-to-get-set-signal-blocked-mask.patch
> * ptrace-add-ability-to-get-set-signal-blocked-mask-fix.patch
> * usermodehelper-kill-the-sub_info-path-check.patch
> * coredump-format_corename-can-leak-cn-corename.patch
> * coredump-introduce-cn_vprintf.patch
> * coredump-cn_vprintf-has-no-reason-to-call-vsnprintf-twice.patch
> * coredump-kill-cn_escape-introduce-cn_esc_printf.patch
> * coredump-kill-call_count-add-core_name_size.patch
> * coredump-%-at-the-end-shouldnt-bypass-core_uses_pid-logic.patch
> * coredump-%-at-the-end-shouldnt-bypass-core_uses_pid-logic-fix.patch
> * fork-reorder-permissions-when-violating-number-of-processes-limits.patch
> * fs-execc-do_execve_common-use-current_user.patch
> * dev-oldmem-remove-the-interface.patch
> * dev-oldmem-remove-the-interface-fix.patch
> * documentation-kdump-kdumptxt-remove-dev-oldmem-description.patch
> * mips-remove-savemaxmem-parameter-setup.patch
> * powerpc-remove-savemaxmem-parameter-setup.patch
> * ia64-remove-setting-for-saved_max_pfn.patch
> * s390-remove-setting-for-saved_max_pfn.patch
> * idr-print-a-stack-dump-after-ida_remove-warning.patch
> * idr-print-a-stack-dump-after-ida_remove-warning-fix.patch
> * shm-fix-null-pointer-deref-when-userspace-specifies-invalid-hugepage-size-fix.patch
> * ipc-move-rcu-lock-out-of-ipc_addid.patch
> * ipc-introduce-ipc-object-locking-helpers.patch
> * ipc-close-open-coded-spin-lock-calls.patch
> * ipc-move-locking-out-of-ipcctl_pre_down_nolock.patch
> * ipcmsg-shorten-critical-region-in-msgctl_down.patch
> * ipcmsg-introduce-msgctl_nolock.patch
> * ipcmsg-introduce-lockless-functions-to-obtain-the-ipc-object.patch
> * ipcmsg-make-msgctl_nolock-lockless.patch
> * ipcmsg-shorten-critical-region-in-msgsnd.patch
> * ipcmsg-shorten-critical-region-in-msgrcv.patch
> * ipc-remove-unused-functions.patch
> * ipc-sem-seperate-wait-for-zero-and-alter-tasks-into-seperate-queues.patch
> * ipc-semc-always-use-only-one-queue-for-alter-operations.patch
> * ipc-semc-rename-try_atomic_semop-to-perform_atomic_semop-docu-update.patch
> * mwave-fix-info-leak-in-mwave_ioctl.patch
> * partitions-msdosc-end-of-line-whitespace-and-semicolon-cleanup.patch
> * partitions-add-aix-lvm-partition-support-files.patch
> * partitions-add-aix-lvm-partition-support-files-v2.patch
> * partitions-add-aix-lvm-partition-support-files-checkpatch-fixes.patch
> * partitions-add-aix-lvm-partition-support-files-compile-aixc-if-configured.patch
> * partitions-add-aix-lvm-partition-support-files-add-the-aix_partition-entry.patch
> * partitions-msdos-enumerate-also-aix-lvm-partitions.patch
> * rapidio-switches-remove-tsi500-driver.patch
> * drivers-parport-use-kzalloc.patch
> * drivers-pps-clients-pps-gpioc-convert-to-devm_-helpers.patch
> * drivers-pps-clients-pps-gpioc-convert-to-module_platform_driver.patch
> * pps-gpio-add-device-tree-binding-and-support.patch
> * drivers-memstick-host-jmb38x_ms-convert-to-module_pci_driver.patch
> * drivers-memstick-host-r592-convert-to-module_pci_driver.patch
> * drivers-w1-slaves-w1_ds2408c-add-magic-sequence-to-disable-p0-test-mode.patch
> * drivers-w1-slaves-w1_ds2408c-add-magic-sequence-to-disable-p0-test-mode-fix.patch
> * relay-fix-timer-madness.patch
> * kernel-resourcec-remove-the-unneeded-assignment-in-function-__find_resource.patch
> * lib-add-weak-clz-ctz-functions.patch
> * decompressor-add-lz4-decompressor-module.patch
> * lib-add-support-for-lz4-compressed-kernel.patch
> * lib-add-support-for-lz4-compressed-kernel-kbuild-fix-for-updated-lz4-tool-with-the-new-streaming-format.patch
> * arm-add-support-for-lz4-compressed-kernel.patch
> * arm-add-support-for-lz4-compressed-kernel-fix.patch
> * x86-add-support-for-lz4-compressed-kernel.patch
> * x86-add-support-for-lz4-compressed-kernel-doc-add-lz4-magic-number-for-the-new-compression.patch
> * lib-add-lz4-compressor-module.patch
> * lib-add-lz4-compressor-module-fix.patch
> * crypto-add-lz4-cryptographic-api.patch
> * crypto-add-lz4-cryptographic-api-fix.patch
> * scripts-sortextablec-fix-building-on-non-linux-systems.patch
>   debugging-keep-track-of-page-owners.patch
>   debugging-keep-track-of-page-owners-fix.patch
>   debugging-keep-track-of-page-owners-fix-2.patch
>   debugging-keep-track-of-page-owners-fix-2-fix.patch
>   debugging-keep-track-of-page-owners-fix-2-fix-fix.patch
>   debugging-keep-track-of-page-owners-fix-2-fix-fix-fix.patch
>   debugging-keep-track-of-page-owner-now-depends-on-stacktrace_support.patch
>   make-sure-nobodys-leaking-resources.patch
>   journal_add_journal_head-debug.patch
>   releasing-resources-with-children.patch
>   make-frame_pointer-default=y.patch
>   kernel-forkc-export-kernel_thread-to-modules.patch
>   mutex-subsystem-synchro-test-module.patch
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
