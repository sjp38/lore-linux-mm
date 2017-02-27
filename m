Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D4AA56B038B
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 18:19:08 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 65so200680097pgi.7
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 15:19:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h11si16379559pln.300.2017.02.27.15.19.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 15:19:07 -0800 (PST)
Date: Mon, 27 Feb 2017 15:19:05 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2017-02-27-15-18 uploaded
Message-ID: <58b4b3e9.NcEWFbM/DvuITPkf%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-02-27-15-18 has been uploaded to

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


This mmotm tree contains the following patches against 4.10:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* mmfsdax-mark-dax_iomap_pmd_fault-as-const.patch
* zswap-allow-initialization-at-boot-without-pool.patch
* zswap-clear-compressor-or-zpool-param-if-invalid-at-init.patch
* zswap-dont-param_set_charp-while-holding-spinlock.patch
* kprobes-move-kprobe-declarations-to-asm-generic-kprobesh.patch
* autofs-remove-wrong-comment.patch
* autofs-fix-typo-in-documentation.patch
* autofs-fix-wrong-ioctl-documentation-regarding-devid.patch
* autofs-update-ioctl-documentation-regarding-struct-autofs_dev_ioctl.patch
* autofs-add-command-enum-macros-for-root-dir-ioctls.patch
* autofs-remove-duplicated-autofs_dev_ioctl_size-definition.patch
* autofs-take-more-care-to-not-update-last_used-on-path-walk.patch
* hfsplus-atomically-read-inode-size.patch
* fs-reiserfs-atomically-read-inode-size.patch
* sigaltstack-support-ss_autodisarm-for-config_compat.patch
* tests-improve-output-of-sigaltstack-testcase.patch
* proc-kcore-update-physical-address-for-kcore-ram-and-text.patch
* rapidio-use-get_user_pages_unlocked.patch
* pid-use-for_each_thread-in-do_each_pid_thread.patch
* fseventpoll-dont-test-for-bitfield-with-stack-value.patch
* fs-affs-remove-reference-to-affs_parent_ino.patch
* fs-affs-add-validation-block-function.patch
* fs-affs-make-affs-exportable.patch
* fs-affs-use-octal-for-permissions.patch
* fs-affs-add-prefix-to-some-functions.patch
* fs-affs-nameic-forward-declarations-clean-up.patch
* fs-affs-make-export-work-with-cold-dcache.patch
* config-android-recommended-disable-aio-support.patch
* config-android-base-enable-hardened-usercopy-and-kernel-aslr.patch
* fonts-keep-non-sparc-fonts-listed-together.patch
* initramfs-finish-fput-before-accessing-any-binary-from-initramfs.patch
* ipc-semc-avoid-using-spin_unlock_wait.patch
* ipc-sem-add-hysteresis.patch
* ipc-mqueue-add-missing-sparse-annotation.patch
* ipc-shm-fix-shmat-mmap-nil-page-protection.patch
* scatterlist-reorder-compound-boolean-expression.patch
* scatterlist-do-not-disable-irqs-in-sg_copy_buffer.patch
* fs-add-i_blocksize.patch
* nilfs2-use-nilfs_btree_node_size.patch
* nilfs2-use-i_blocksize.patch
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
* scripts-spellingtxt-add-comsumer-pattern-and-fix-typo-instances.patch
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
* scripts-spellingtxt-add-some-typo-words.patch
* lib-vsprintfc-remove-%z-support.patch
* checkpatchpl-warn-against-using-%z.patch
* mm-add-new-mmgrab-helper.patch
* mm-add-new-mmget-helper.patch
* mm-use-mmget_not_zero-helper.patch
* mm-clarify-mm_structmm_userscount-documentation.patch
* hfs-atomically-read-inode-size.patch
* mm-add-arch-independent-testcases-for-rodata.patch
* mm-x86-fix-highmem64-paravirt-build-config-for-native_pud_clear.patch
* scatterlist-dont-overflow-length-field.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks-checkpatch-fixes.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* mm-page_alloc-return-0-in-case-this-node-has-no-page-within-the-zone.patch
* mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
* scripts-gdb-add-lx-fdtdump-command.patch
  linux-next.patch
  linux-next-rejects.patch
* scripts-spellingtxt-add-intialised-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-disbled-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-overide-pattern-and-fix-typo-instances.patch
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
