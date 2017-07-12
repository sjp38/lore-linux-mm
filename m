Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 595BA440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 18:12:42 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i127so1333459wma.15
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 15:12:42 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g5si3303323wmf.31.2017.07.12.15.12.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 15:12:40 -0700 (PDT)
Date: Wed, 12 Jul 2017 15:12:38 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2017-07-12-15-11 uploaded
Message-ID: <59669ed6.BFVlfhZwlMpleSiF%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-07-12-15-11 has been uploaded to

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


This mmotm tree contains the following patches against 4.12:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* include-linux-dcacheh-use-unsigned-chars-in-struct-name_snapshot.patch
* kernelh-handle-pointers-to-arrays-better-in-container_of.patch
* mm-mark-create_huge_pmd-inline-to-prevent-build-failure.patch
* virtually-mapped-stacks-do-not-disable-interrupts.patch
* kexec-move-vmcoreinfo-out-of-the-kernels-bss-section.patch
* powerpc-fadump-use-the-correct-vmcoreinfo_note_size-for-phdr.patch
* kdump-protect-vmcoreinfo-data-under-the-crash-memory.patch
* kexec-kdump-minor-documentation-updates-for-arm64-and-image.patch
* sysctl-fix-lax-sysctl_check_table-sanity-check.patch
* sysctl-kdocify-sysctl_writes_strict.patch
* sysctl-fold-sysctl_writes_strict-checks-into-helper.patch
* sysctl-simplify-unsigned-int-support.patch
* sysctl-add-unsigned-int-range-support.patch
* test_sysctl-add-dedicated-proc-sysctl-test-driver.patch
* test_sysctl-add-generic-script-to-expand-on-tests.patch
* test_sysctl-test-against-page_size-for-int.patch
* test_sysctl-add-simple-proc_dointvec-case.patch
* test_sysctl-add-simple-proc_douintvec-case.patch
* test_sysctl-test-against-int-proc_dointvec-array-support.patch
* sysctl-check-name-array-length-in-deprecated_sysctl_warning.patch
* random-do-not-ignore-early-device-randomness.patch
* bfs-fix-sanity-checks-for-empty-files.patch
* fs-kill-config_percpu_rwsem-some-more.patch
* scripts-gdb-add-lx-fdtdump-command.patch
* scripts-gdb-lx-dmesg-cast-log_buf-to-void-for-addr-fetch.patch
* scripts-gdb-lx-dmesg-use-explicit-encoding=utf8-errors=replace.patch
* kfifo-cleanup-example-to-not-use-page_link.patch
* procfs-fdinfo-extend-information-about-epoll-target-files.patch
* kcmp-add-kcmp_epoll_tfd-mode-to-compare-epoll-target-files.patch
* kcmp-fs-epoll-wrap-kcmp-code-with-config_checkpoint_restore.patch
* fault-inject-support-systematic-fault-injection.patch
* ipc-semc-remove-sem_base-embed-struct-sem.patch
* ipc-merge-ipc_rcu-and-kern_ipc_perm.patch
* include-linux-semh-correctly-document-sem_ctime.patch
* ipc-drop-non-rcu-allocation.patch
* ipc-sem-do-not-use-ipc_rcu_free.patch
* ipc-shm-do-not-use-ipc_rcu_free.patch
* ipc-msg-do-not-use-ipc_rcu_free.patch
* ipc-util-drop-ipc_rcu_free.patch
* ipc-sem-avoid-ipc_rcu_alloc.patch
* ipc-shm-avoid-ipc_rcu_alloc.patch
* ipc-msg-avoid-ipc_rcu_alloc.patch
* ipc-util-drop-ipc_rcu_alloc.patch
* ipc-semc-avoid-ipc_rcu_putref-for-failed-ipc_addid.patch
* ipc-shmc-avoid-ipc_rcu_putref-for-failed-ipc_addid.patch
* ipc-msgc-avoid-ipc_rcu_putref-for-failed-ipc_addid.patch
* ipc-move-atomic_set-to-where-it-is-needed.patch
* ipc-shm-remove-special-shm_alloc-free.patch
* ipc-msg-remove-special-msg_alloc-free.patch
* ipc-sem-drop-__sem_free.patch
* ipc-utilh-update-documentation-for-ipc_getref-and-ipc_putref.patch
* netfilter-use-kvmalloc-xt_alloc_table_info.patch
* watchdog-remove-unused-declaration.patch
* watchdog-introduce-arch_touch_nmi_watchdog.patch
* watchdog-split-up-config-options.patch
* watchdog-provide-watchdog_reconfigure-for-arch-watchdogs.patch
* powerpc-64s-implement-arch-specific-hardlockup-watchdog.patch
* efi-avoid-fortify-checks-in-efi-stub.patch
* kexec_file-adjust-declaration-of-kexec_purgatory.patch
* ib-rxe-do-not-copy-extra-stack-memory-to-skb.patch
* powerpc-dont-fortify-prom_init.patch
* powerpc-make-feature-fixup-tests-fortify-safe.patch
* include-linux-stringh-add-the-option-of-fortified-stringh-functions.patch
* sh-mark-end-of-bug-implementation-as-unreachable.patch
* randomstackprotect-introduce-get_random_canary-function.patch
* forkrandom-use-get_random_canary-to-set-tsk-stack_canary.patch
* x86-ascii-armor-the-x86_64-boot-init-stack-canary.patch
* arm64-ascii-armor-the-arm64-boot-init-stack-canary.patch
* sh64-ascii-armor-the-sh64-boot-init-stack-canary.patch
* x86-mmap-properly-account-for-stack-randomization-in-mmap_base.patch
* arm64-mmap-properly-account-for-stack-randomization-in-mmap_base.patch
* powerpcmmap-properly-account-for-stack-randomization-in-mmap_base.patch
* mips-do-not-use-__gfp_repeat-for-order-0-request.patch
* mm-tree-wide-replace-__gfp_repeat-by-__gfp_retry_mayfail-with-more-useful-semantic.patch
* xfs-map-km_mayfail-to-__gfp_retry_mayfail.patch
* mm-kvmalloc-support-__gfp_retry_mayfail-for-all-sizes.patch
* drm-i915-use-__gfp_retry_mayfail.patch
* mm-migration-do-not-trigger-oom-killer-when-migrating-memory.patch
* checkpatch-improve-the-storage_class-test.patch
* arm-kvm-move-asmlinkage-before-type.patch
* arm-hp-jornada-7xx-move-inline-before-return-type.patch
* cris-gpio-move-inline-before-return-type.patch
* frv-tlbflush-move-asmlinkage-before-return-type.patch
* ia64-move-inline-before-return-type.patch
* ia64-sn-pci-move-inline-before-type.patch
* m68k-coldfire-move-inline-before-return-type.patch
* mips-smp-move-asmlinkage-before-return-type.patch
* sh-move-inline-before-return-type.patch
* x86-efi-move-asmlinkage-before-return-type.patch
* drivers-s390-move-static-and-inline-before-return-type.patch
* drivers-tty-serial-move-inline-before-return-type.patch
* usb-serial-safe_serial-move-__inline__-before-return-type.patch
* video-fbdev-intelfb-move-inline-before-return-type.patch
* video-fbdev-omap-move-inline-before-return-type.patch
* arm-samsung-usb-ohci-move-inline-before-return-type.patch
* writeback-rework-wb__stat-family-of-functions.patch
* mm-skip-hwpoisoned-pages-when-onlining-pages.patch
* mm-fix-overflow-check-in-expand_upwards.patch
* lib-atomic64-test-add-a-test-that-atomic64_inc_not_zero-returns-an-int.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks-checkpatch-fixes.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names-v2.patch
* ocfs2-move-some-definitions-to-header-file.patch
* ocfs2-fix-some-small-problems.patch
* ocfs2-add-kobject-for-online-file-check.patch
* ocfs2-add-duplicative-ino-number-check.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* sendfile-do-not-update-file-offset-of-non-lseekable-objects.patch
  mm.patch
* slub-make-sure-struct-kmem_cache_node-is-initialized-before-publication.patch
* mm-memory_hotplug-just-build-zonelist-for-new-added-node.patch
* mm-memory_hotplug-just-build-zonelist-for-new-added-node-fix.patch
* mm-memory_hotplug-just-build-zonelist-for-new-added-node-fix-fix.patch
* mm-page_alloc-return-0-in-case-this-node-has-no-page-within-the-zone.patch
* mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* seq_file-delete-small-value-optimization.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
* kernel-reboot-add-devm_register_reboot_notifier.patch
* kernel-reboot-add-devm_register_reboot_notifier-fix.patch
* fault-inject-automatically-detect-the-number-base-for-fail-nth-write-interface.patch
* fault-inject-parse-as-natural-1-based-value-for-fail-nth-write-interface.patch
* fault-inject-make-fail-nth-read-write-interface-symmetric.patch
* fault-inject-simplify-access-check-for-fail-nth.patch
* fault-inject-simplify-access-check-for-fail-nth-fix.patch
* fault-inject-add-proc-pid-fail-nth.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
* sparc64-ng4-memset-32-bits-overflow.patch
* xtensa-use-generic-fbh.patch
* maintainers-give-kmod-some-maintainer-love.patch
* kmod-add-test-driver-to-stress-test-the-module-loader.patch
* kmod-add-test-driver-to-stress-test-the-module-loader-fix.patch
* kmod-throttle-kmod-thread-limit.patch
* lib-crc-ccitt-add-ccitt-false-crc16-variant.patch
  mm-add-strictlimit-knob-v2.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
