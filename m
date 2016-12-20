Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A21446B02D1
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 19:30:53 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id o141so98874336itc.1
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 16:30:53 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n72si14768319iod.83.2016.12.19.16.30.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 16:30:52 -0800 (PST)
Date: Mon, 19 Dec 2016 16:31:52 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2016-12-19-16-31 uploaded
Message-ID: <58587bf8.goMs+R2nzGI9OM09%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-12-19-16-31 has been uploaded to

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


This mmotm tree contains the following patches against 4.9:
(patches marked "*" will be included in linux-next)

  origin.patch
* powerpc-ima-get-the-kexec-buffer-passed-by-the-previous-kernel.patch
* ima-on-soft-reboot-restore-the-measurement-list.patch
* ima-permit-duplicate-measurement-list-entries.patch
* ima-maintain-memory-size-needed-for-serializing-the-measurement-list.patch
* powerpc-ima-send-the-kexec-buffer-to-the-next-kernel.patch
* ima-on-soft-reboot-save-the-measurement-list.patch
* ima-store-the-builtin-custom-template-definitions-in-a-list.patch
* ima-support-restoring-multiple-template-formats.patch
* ima-define-a-canonical-binary_runtime_measurements-list-format.patch
* ima-platform-independent-hash-value.patch
* mm-fadvise-avoid-expensive-remote-lru-cache-draining-after-fadv_dontneed.patch
* arm64-setup-introduce-kaslr_offset.patch
* kcov-make-kcov-work-properly-with-kaslr-enabled.patch
* ratelimit-fix-warn_on_ratelimit-return-value.patch
* printk-fix-typo-in-console_loglevel_default-help-text.patch
  i-need-old-gcc.patch
* mm-page_alloc-fix-incorrect-zone_statistics-data.patch
* mm-thp-pagecache-only-withdraw-page-table-after-a-successful-deposit.patch
* mm-thp-pagecache-collapse-free-the-pte-page-table-on-collapse-for-thp-page-cache.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* scripts-spellingtxt-add-several-more-common-spelling-mistakes.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
* ocfs2-fix-crash-caused-by-stale-lvb-with-fsdlm-plugin.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* kernel-watchdog-prevent-false-hardlockup-on-overloaded-system.patch
* kernel-watchdog-prevent-false-hardlockup-on-overloaded-system-fix.patch
  mm.patch
* tmpfs-change-shmem_mapping-to-test-shmem_aops.patch
* mm-throttle-show_mem-from-warn_alloc.patch
* mm-throttle-show_mem-from-warn_alloc-fix.patch
* mm-page_alloc-dont-convert-pfn-to-idx-when-merging.patch
* mm-page_alloc-avoid-page_to_pfn-when-merging-buddies.patch
* z3fold-limit-first_num-to-the-actual-range-of-possible-buddy-indexes.patch
* z3fold-make-pages_nr-atomic.patch
* z3fold-extend-compaction-function.patch
* z3fold-use-per-page-spinlock.patch
* z3fold-discourage-use-of-pages-that-werent-compacted.patch
* z3fold-fix-header-size-related-issues.patch
* z3fold-fix-locking-issues.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* lib-add-crc64-ecma-module.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* scripts-gdb-add-lx-fdtdump-command.patch
* ipc-semc-avoid-using-spin_unlock_wait.patch
* ipc-sem-add-hysteresis.patch
  linux-next.patch
  linux-next-git-rejects.patch
* fs-add-i_blocksize.patch
* reimplement-idr-and-ida-using-the-radix-tree.patch
* reimplement-idr-and-ida-using-the-radix-tree-support-storing-null-in-the-idr.patch
* reimplement-idr-and-ida-using-the-radix-tree-support-storing-null-in-the-idr-checkpatch-fixes.patch
* scripts-spellingtxt-add-swith-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-swithc-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-an-user-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-an-union-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-an-one-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-partiton-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-aligment-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-algined-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-efective-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-varible-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-embeded-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-againt-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-neded-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-unneded-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-intialization-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-initialiazation-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-intialised-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-comsumer-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-disbled-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-overide-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-overrided-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-configuartion-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-applys-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-explictely-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-omited-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-disassocation-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-deintialized-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-overwritting-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-overwriten-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-therfore-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-followings-pattern-and-fix-typo-instances.patch
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
