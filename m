Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8AD946B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 19:59:48 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b9so1642233wra.3
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 16:59:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 68si165124wmm.153.2017.09.13.16.59.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Sep 2017 16:59:47 -0700 (PDT)
Date: Wed, 13 Sep 2017 16:59:44 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2017-09-13-16-59 uploaded
Message-ID: <59b9c670.0hfoecHT32h4pDA2%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-09-13-16-59 has been uploaded to

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


This mmotm tree contains the following patches against 4.13:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* idr-remove-warn_on_once-when-trying-to-replace-negative-id.patch
* drivers-media-cec-cec-adapc-fix-build-with-gcc-444.patch
* procfs-remove-unused-variable.patch
* test_bitmap-use-ull-suffix-for-64-bit-constants.patch
* fscache-fix-fscache_objlist_show-format-processing.patch
* ib-mlx4-fix-sprintf-format-warning.patch
* treewide-remove-gfp_temporary-allocation-flag.patch
* arm64-stacktrace-avoid-listing-stacktrace-functions-in-stacktrace.patch
* mm-page_owner-skip-unnecessary-stack_trace-entries.patch
* mm-skip-hwpoisoned-pages-when-onlining-pages.patch
* ksm-fix-unlocked-iteration-over-vmas-in-cmp_and_merge_page.patch
* mm-hugetlb-soft_offline-save-compound-page-order-before-page-migration.patch
* sh-sh7722-remove-nonexistent-gpio_ptq7-to-fix-pinctrl-registration.patch
* sh-sh7757-remove-nonexistent-gpio_pt7_resv-to-fix-pinctrl-registration.patch
* sh-sh7264-remove-nonexistent-gpio_ph-to-fix-pinctrl-registration.patch
* sh-sh7269-remove-nonexistent-gpio_ph-to-fix-pinctrl-registration.patch
* z3fold-fix-potential-race-in-z3fold_reclaim_page.patch
* mm-oom_reaper-skip-mm-structs-with-mmu-notifiers.patch
* mm-oom_reaper-skip-mm-structs-with-mmu-notifiers-checkpatch-fixes.patch
* mm-memcg-remove-hotplug-locking-from-try_charge.patch
* mm-memory_hotplug-do-not-back-off-draining-pcp-free-pages-from-kworker-context.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names-v2.patch
* ocfs2-move-some-definitions-to-header-file.patch
* ocfs2-fix-some-small-problems.patch
* ocfs2-add-kobject-for-online-file-check.patch
* ocfs2-add-duplicative-ino-number-check.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* dentry-fix-kmemcheck-splat-at-take_dentry_name_snapshot.patch
  mm.patch
* mm-compaction-kcompactd-should-not-ignore-pageblock-skip.patch
* mm-compaction-persistently-skip-hugetlbfs-pageblocks.patch
* mm-compaction-persistently-skip-hugetlbfs-pageblocks-fix.patch
* mm-cma-manage-the-memory-of-the-cma-area-by-using-the-zone_movable.patch
* mm-cma-remove-alloc_cma.patch
* arm-cma-avoid-double-mapping-to-the-cma-area-if-config_highmem-=-y.patch
* mm-page_alloc-return-0-in-case-this-node-has-no-page-within-the-zone.patch
* mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* parse-maintainers-add-ability-to-specify-filenames.patch
* seq_file-delete-small-value-optimization.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* rapidio-remove-global-irq-spinlocks-from-the-subsystem.patch
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
* kernel-reboot-add-devm_register_reboot_notifier.patch
* kernel-reboot-add-devm_register_reboot_notifier-fix.patch
  linux-next.patch
  linux-next-git-rejects.patch
* iopoll-avoid-wint-in-bool-context-warning.patch
* sparc64-ng4-memset-32-bits-overflow.patch
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
