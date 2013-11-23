Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id EFF376B0035
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 19:51:10 -0500 (EST)
Received: by mail-qa0-f45.google.com with SMTP id o15so1005283qap.18
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 16:51:10 -0800 (PST)
Received: from mail-qa0-f73.google.com (mail-qa0-f73.google.com [209.85.216.73])
        by mx.google.com with ESMTPS id ll3si24948242qeb.83.2013.11.22.16.51.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 16:51:09 -0800 (PST)
Received: by mail-qa0-f73.google.com with SMTP id o15so779858qap.4
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 16:51:09 -0800 (PST)
Subject: mmotm 2013-11-22-16-50 uploaded
From: akpm@linux-foundation.org
Date: Fri, 22 Nov 2013 16:51:08 -0800
Message-Id: <20131123005108.B1FA95A41FE@corp2gmr1-2.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2013-11-22-16-50 has been uploaded to

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


This mmotm tree contains the following patches against 3.13-rc1:
(patches marked "*" will be included in linux-next)

  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* include-linux-hugetlbh-make-isolate_huge_page-an-inline.patch
* documentation-docbook-device-driverstmpl-fix-generation-of-device-drivers.patch
* mm-memcg-do-not-declare-oom-from-__gfp_nofail-allocations.patch
* drivers-rtc-rtc-at91rm9200c-correct-alarm-over-day-month-wrap.patch
* drivers-rtc-rtc-s5mc-fix-info-rtc-assignment.patch
* arch-x86-mnify-pte_to_pgoff-and-pgoff_to_pte-helpers.patch
* x86-mm-get-aslr-work-for-hugetlb-mappings.patch
* dma-debug-enhance-dma_debug_device_change-to-check-for-mapping-errors.patch
* drm-fb-helper-dont-sleep-for-screen-unblank-when-an-oopps-is-in-progress.patch
* drm-cirrus-correct-register-values-for-16bpp.patch
* drm-nouveau-make-vga_switcheroo-code-depend-on-vga_switcheroo.patch
* drivers-gpu-drm-drm_edid_loadc-make-edid_load-return-a-void.patch
* genirq-correct-fuzzy-and-fragile-irq_retval-definition.patch
* sched_clock-document-4mhz-vs-1mhz-decision.patch
* kernel-timerc-convert-kmalloc_nodegfp_zero-to-kzalloc_node.patch
* kernel-time-tick-commonc-document-tick_do_timer_cpu.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* drivers-net-irda-donauboe-convert-to-module_pci_driver.patch
* ocfs2-free-allocated-clusters-if-error-occurs-after-ocfs2_claim_clusters.patch
* ocfs2-o2net-incorrect-to-terminate-accepting-connections-loop-upon-rejecting-an-invalid-one.patch
* ocfs2-should-call-ocfs2_journal_access_di-before-ocfs2_delete_entry-in-ocfs2_orphan_del.patch
* ocfs2-llseek-requires-ocfs2-inode-lock-for-the-file-in-seek_end.patch
* ocfs2-fix-issue-that-ocfs2_setattr-does-not-deal-with-new_i_size==i_size.patch
* ocfs2-update-inode-size-after-zeronig-the-hole.patch
* scsi-do-not-call-do_div-with-a-64-bit-divisor.patch
* drivers-scsi-megaraid-megaraid_mmc-missing-bounds-check-in-mimd_to_kioc.patch
* drivers-cdrom-gdromc-remove-deprecated-irqf_disabled.patch
* drivers-block-sx8c-use-module_pci_driver.patch
* drivers-block-sx8c-remove-unnecessary-pci_set_drvdata.patch
* drivers-block-paride-pgc-underflow-bug-in-pg_write.patch
* hpsa-return-0-from-driver-probe-function-on-success-not-1.patch
* drivers-block-ccissc-cciss_init_one-use-proper-errnos.patch
* blk-mq-use-__smp_call_function_single-directly.patch
* block-blk-mq-cpuc-use-hotcpu_notifier.patch
* block-remove-unrelated-header-files-and-export-symbol.patch
* mtd-cmdlinepart-use-cmdline-partition-parser-lib.patch
* mtd-cmdlinepart-use-cmdline-partition-parser-lib-fix.patch
* mtd-cmdlinepart-use-cmdline-partition-parser-lib-fix-fix.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* posix_acl-uninlining.patch
* watchdog-trigger-all-cpu-backtrace-when-locked-up-and-going-to-panic.patch
* xfs-underflow-bug-in-xfs_attrlist_by_handle.patch
  mm.patch
* mm-hugetlbfs-add-some-vm_bug_ons-to-catch-non-hugetlbfs-pages.patch
* mm-memcg-avoid-oom-notification-when-current-needs-access-to-memory-reserves.patch
* mm-hugetlb-use-get_page_foll-in-follow_hugetlb_page.patch
* mm-hugetlbfs-move-the-put-get_page-slab-and-hugetlbfs-optimization-in-a-faster-path.patch
* mm-thp-optimize-compound_trans_huge.patch
* mm-tail-page-refcounting-optimization-for-slab-and-hugetlbfs.patch
* mm-hugetlbfs-use-__compound_tail_refcounted-in-__get_page_tail-too.patch
* mm-hugetlbc-simplify-pageheadhuge-and-pagehuge.patch
* mm-swapc-reorganize-put_compound_page.patch
* mm-hugetlbc-defer-pageheadhuge-symbol-export.patch
* proc-meminfo-provide-estimated-available-memory.patch
* mm-get-rid-of-unnecessary-pageblock-scanning-in-setup_zone_migrate_reserve.patch
* mm-get-rid-of-unnecessary-pageblock-scanning-in-setup_zone_migrate_reserve-fix.patch
* mm-create-a-separate-slab-for-page-ptl-allocation-try-two.patch
* mm-memory-failure-fix-the-typo-in-me_pagecache_dirty.patch
* mm-memory-failure-fix-the-typo-in-me_pagecache_dirty-fix.patch
* mm-call-mmu-notifiers-when-copying-a-hugetlb-page-range.patch
* swap-fix-setting-page_size-blocksize-during-swapoff-swapon-race.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead-fix.patch
* arch-um-kernel-sysrqc-rename-print_stack_trace.patch
* kernel-use-lockless-list-for-smp_call_function_single.patch
* asm-typesh-remove-include-asm-generic-int-l64h.patch
* drivers-mailbox-omap-make-mbox-irq-signed-for-error-handling.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* lib-parserc-add-match_wildcard-function.patch
* lib-parserc-put-export_symbols-in-the-conventional-place.patch
* dynamic_debug-add-wildcard-support-to-filter-files-functions-modules.patch
* dynamic-debug-howtotxt-update-since-new-wildcard-support.patch
* printk-cache-mark-printk_once-test-variable-__read_mostly.patch
* printk-cache-mark-printk_once-test-variable-__read_mostly-fix.patch
* get_maintainer-add-commit-author-information-to-rolestats.patch
* maintainers-add-an-entry-for-the-macintosh-hfsplus-filesystem.patch
* kstrtox-remove-redundant-cleanup.patch
* cmdline-fix-style-issues.patch
* lib-cmdlinec-declare-exported-symbols-immediately.patch
* kernel-paramsc-improve-standard-definitions.patch
* kernel-paramsc-improve-standard-definitions-checkpatch-fixes.patch
* lib-add-crc64-ecma-module.patch
* checkpatchpl-check-for-function-declarations-without-arguments.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* fs-ramfs-file-nommuc-make-ramfs_nommu_get_unmapped_area-and-ramfs_nommu_mmap-static.patch
* fs-ramfs-move-ramfs_aops-to-inodec.patch
* init-mainc-remove-unused-declaration-of-tc_init.patch
* autofs4-allow-autofs-to-work-outside-the-initial-pid-namespace.patch
* autofs4-translate-pids-to-the-right-namespace-for-the-daemon.patch
* drivers-rtc-rtc-at91sam9c-include-mach-hardwareh-explicitly.patch
* drivers-rtc-rtc-as3722-use-devm-for-rtc-and-irq-registration.patch
* fat-add-i_disksize-to-represent-uninitialized-size.patch
* fat-add-fat_fallocate-operation.patch
* fat-zero-out-seek-range-on-_fat_get_block.patch
* fat-fallback-to-buffered-write-in-case-of-fallocatded-region-on-direct-io.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-filesystems-sysfstxt-fix-device_attribute-declaration.patch
* kmod-run-usermodehelpers-only-on-cpus-allowed-for-kthreadd-v2.patch
* kmod-run-usermodehelpers-only-on-cpus-allowed-for-kthreadd-v2-fix.patch
* kmod-run-usermodehelpers-only-on-cpus-allowed-for-kthreadd-v2-checkpatch-fixes.patch
* coredump-set_dumpable-fix-the-theoretical-race-with-itself.patch
* coredump-kill-mmf_dumpable-and-mmf_dump_securely.patch
* coredump-make-__get_dumpable-get_dumpable-inline-kill-fs-coredumph.patch
* exit_state-kill-task_is_dead.patch
* proc-cleanup-simplify-get_task_state-task_state_array.patch
* proc-fix-the-potential-use-after-free-in-first_tid.patch
* proc-change-first_tid-to-use-while_each_thread-rather-than-next_thread.patch
* proc-dont-abuse-group_leader-in-proc_task_readdir-paths.patch
* proc-fix-f_pos-overflows-in-first_tid.patch
* fork-no-need-to-initialize-child-exit_state.patch
* exec-check_unsafe_exec-use-while_each_thread-rather-than-next_thread.patch
* exec-check_unsafe_exec-kill-the-dead-eagain-and-clear_in_exec-logic.patch
* exec-move-the-final-allow_write_access-fput-into-free_bprm.patch
* exec-kill-task_struct-did_exec.patch
* fs-proc-arrayc-change-do_task_stat-to-use-while_each_thread.patch
* kernel-sysc-k_getrusage-can-use-while_each_thread.patch
* kernel-signalc-change-do_signal_stop-do_sigaction-to-use-while_each_thread.patch
* lib-cpumask-make-cpumask_offstack-usable-without-debug-dependency.patch
* kernel-kexecc-use-vscnprintf-instead-of-vsnprintf-in-vmcoreinfo_append_str.patch
* kexec-migrate-to-reboot-cpu.patch
* rbtree-test-move-rb_node-to-the-middle-of-the-test-struct.patch
* rbtree-test-test-rbtree_postorder_for_each_entry_safe.patch
* net-netfilter-ipset-ip_set_hash_netifacec-use-rbtree-postorder-iteration-instead-of-opencoding.patch
* fs-ubifs-use-rbtree-postorder-iteration-helper-instead-of-opencoding.patch
* fs-ext4-use-rbtree-postorder-iteration-helper-instead-of-opencoding.patch
* fs-jffs2-use-rbtree-postorder-iteration-helper-instead-of-opencoding.patch
* fs-ext3-use-rbtree-postorder-iteration-helper-instead-of-opencoding.patch
* drivers-mtd-ubi-use-rbtree-postorder-iteration-helper-instead-of-opencoding.patch
* arch-sh-kernel-dwarfc-use-rbtree-postorder-iteration-helper-instead-of-solution-using-repeated-rb_erase.patch
* pps-add-non-blocking-option-to-pps_fetch-ioctl.patch
* drivers-memstick-host-rtsx_pci_msc-fix-ms-card-data-transfer-bug.patch
* drivers-w1-masters-w1-gpioc-add-strong-pullup-emulation.patch
* lib-decompress_unlz4c-always-set-an-error-return-code-on-failures.patch
  linux-next.patch
  linux-next-git-rejects.patch
* mm-add-strictlimit-knob-v2.patch
  debugging-keep-track-of-page-owners.patch
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
