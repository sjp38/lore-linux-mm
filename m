Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E635D6B0005
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 18:54:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o124so488850508pfg.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 15:54:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e125si16782708pfa.186.2016.08.04.15.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 15:54:29 -0700 (PDT)
Date: Thu, 04 Aug 2016 15:54:28 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2016-08-04-15-53 uploaded
Message-ID: <57a3c7a4.gCWzM2XkCo5koanA%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-08-04-15-53 has been uploaded to

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
* mm-add-restriction-when-memory_hotplug-config-enable.patch
* mm-memblock-fix-a-typo-in-a-comment.patch
* mm-initialise-per_cpu_nodestats-for-all-online-pgdats-at-boot.patch
* powerpc-fsl_rio-fix-a-missing-error-code.patch
* slub-drop-bogus-inline-for-fixup_red_left.patch
* maintainers-update-cgroups-document-path.patch
* mm-memblockc-fix-null-dereference-error.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* mm-oom-fix-uninitialized-ret-in-task_will_free_mem.patch
* mm-page_alloc-replace-set_dma_reserve-to-set_memory_reserve.patch
* fadump-register-the-memory-reserved-by-fadump.patch
* mm-memcontrol-fix-swap-counter-leak-on-swapout-from-offline-cgroup.patch
* mm-memcontrol-fix-memcg-id-ref-counter-on-swap-charge-move.patch
* mm-slab-improve-performance-of-gathering-slabinfo-stats.patch
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
* printk-remove-unnecessary-ifdef-config_printk.patch
* lib-add-crc64-ecma-module.patch
* compat-remove-compat_printk.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* random-simplify-api-for-random-address-requests.patch
* x86-use-simpler-api-for-random-address-requests.patch
* arm-use-simpler-api-for-random-address-requests.patch
* arm64-use-simpler-api-for-random-address-requests.patch
* tile-use-simpler-api-for-random-address-requests.patch
* unicore32-use-simpler-api-for-random-address-requests.patch
* random-remove-unused-randomize_range.patch
* dma-mapping-introduce-the-dma_attr_no_warn-attribute.patch
* powerpc-implement-the-dma_attr_no_warn-attribute.patch
* nvme-use-the-dma_attr_no_warn-attribute.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
  linux-next-git-rejects.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* ipc-semc-fix-complex_count-vs-simple-op-race.patch
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
