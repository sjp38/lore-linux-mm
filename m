Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5966B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 18:52:00 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id yl2so131670442pac.2
        for <linux-mm@kvack.org>; Thu, 26 May 2016 15:52:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id dl2si19875935pab.163.2016.05.26.15.51.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 15:51:59 -0700 (PDT)
Date: Thu, 26 May 2016 15:51:58 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2016-05-26-15-51 uploaded
Message-ID: <57477e0e.heHpk5aBP3qf0Iqj%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-05-26-15-51 has been uploaded to

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


This mmotm tree contains the following patches against 4.6:
(patches marked "*" will be included in linux-next)

  origin.patch
* seqlock-fix-raw_read_seqcount_latch.patch
* mm-make-config_deferred_struct_page_init-depends-on-flatmem-explicitly.patch
* mm-kasan-remove-unused-reserved-field-from-struct-kasan_alloc_meta.patch
* mm-slub-remove-unused-virt_to_obj.patch
* ocfs2-fix-improper-handling-of-return-errno.patch
* memcg-fix-mem_cgroup_out_of_memory-return-value.patch
* mm-oom_reaper-do-not-mmput-synchronously-from-the-oom-reaper-context-fix.patch
* dma-debug-avoid-spinlock-recursion-when-disabling-dma-debug.patch
* update-mm-zsmalloc-dont-fail-if-cant-create-debugfs-info.patch
* drivers-pinctrl-intel-pinctrl-baytrailc-fix-build-with-gcc-44.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* direct-io-fix-direct-write-stale-data-exposure-from-concurrent-buffered-read.patch
* mm-oom-do-not-reap-task-if-there-are-live-threads-in-threadgroup.patch
* maintainers-add-kexec_corec-and-kexec_filec.patch
* maintainers-kdump-maintainers-update.patch
* mm-use-early_pfn_to_nid-in-page_ext_init.patch
* mm-use-early_pfn_to_nid-in-register_page_bootmem_info_node.patch
* oom_reaper-close-race-with-exiting-task.patch
* oom_reaper-close-race-with-exiting-task-checkpatch-fixes.patch
* mm-thp-avoid-false-positive-vm_bug_on_page-in-page_move_anon_rmap.patch
* mm-cma-silence-warnings-due-to-max-usage.patch
* mm-cma-silence-warnings-due-to-max-usage-checkpatch-fixes.patch
* mm-memcontrol-fix-the-margin-computation-in-mem_cgroup_margin.patch
* mm-memcontrol-move-comments-for-get_mctgt_type-to-proper-position.patch
* mm-disable-deferred_struct_page_init-on-no_bootmem.patch
* mm-fix-overflow-in-vm_map_ram.patch
* kdump-fix-dmesg-gdbmacro-to-work-with-record-based-printk.patch
* memcg-add-rcu-locking-around-css_for_each_descendant_pre-in-memcg_offline_kmem.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-fix-a-redundant-re-initialization.patch
* ocfs2-o2hb-add-negotiate-timer.patch
* ocfs2-o2hb-add-nego_timeout-message.patch
* ocfs2-o2hb-add-negotiate_approve-message.patch
* ocfs2-o2hb-add-some-user-debug-log.patch
* ocfs2-o2hb-dont-negotiate-if-last-hb-fail.patch
* ocfs2-o2hb-fix-hb-hung-time.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* mm-memcontrol-remove-the-useless-parameter-for-mc_handle_swap_pte.patch
* mm-init-fix-zone-boundary-creation.patch
* mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites.patch
* mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites-fix.patch
* mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites-fix-2.patch
* mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites-checkpatch-fixes.patch
* memory-hotplug-add-move_pfn_range.patch
* memory-hotplug-more-general-validation-of-zone-during-online.patch
* memory-hotplug-use-zone_can_shift-for-sysfs-valid_zones-attribute.patch
* mm-memblock-if-nr_new-is-0-just-return.patch
* mm-make-optimistic-check-for-swapin-readahead.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch
* mm-vmstat-calculate-particular-vm-event.patch
* mm-thp-avoid-unnecessary-swapin-in-khugepaged.patch
* mm-thp-avoid-unnecessary-swapin-in-khugepaged-fix.patch
* lib-switch-config_printk_time-to-int.patch
* printk-allow-different-timestamps-for-printktime.patch
* lib-add-crc64-ecma-module.patch
* samples-kprobe-convert-the-printk-to-pr_info-pr_err.patch
* samples-jprobe-convert-the-printk-to-pr_info-pr_err.patch
* samples-kretprobe-convert-the-printk-to-pr_info-pr_err.patch
* samples-kretprobe-fix-the-wrong-type.patch
* kexec-return-error-number-directly.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* futex-fix-shared-futex-operations-on-nommu.patch
* kcov-allow-more-fine-grained-coverage-instrumentation.patch
* ipc-semc-fix-complex_count-vs-simple-op-race.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
  linux-next-git-rejects.patch
* mm-make-optimistic-check-for-swapin-readahead-fix.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* fs-nfs-nfs4statec-work-around-gcc-44-union-initialization-bug.patch
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
