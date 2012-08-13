Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id C36FC6B005A
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 19:56:52 -0400 (EDT)
Received: by obbun3 with SMTP id un3so3206136obb.2
        for <linux-mm@kvack.org>; Mon, 13 Aug 2012 16:56:52 -0700 (PDT)
Subject: mmotm 2012-08-13-16-55 uploaded
From: akpm@linux-foundation.org
Date: Mon, 13 Aug 2012 16:56:50 -0700
Message-Id: <20120813235651.00A13100047@wpzn3.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2012-08-13-16-55 has been uploaded to

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


This mmotm tree contains the following patches against 3.6-rc1:
(patches marked "*" will be included in linux-next)

  origin.patch
  linux-next.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* cs5535-clockevt-typo-its-mfgpt-not-mfpgt.patch
* mm-change-nr_ptes-bug_on-to-warn_on.patch
* documentation-update-mount-option-in-filesystem-vfattxt.patch
* cciss-fix-incorrect-scsi-status-reporting.patch
* acpi_memhotplugc-fix-memory-leak-when-memory-device-is-unbound-from-the-module-acpi_memhotplug.patch
* acpi_memhotplugc-free-memory-device-if-acpi_memory_enable_device-failed.patch
* acpi_memhotplugc-remove-memory-info-from-list-before-freeing-it.patch
* acpi_memhotplugc-dont-allow-to-eject-the-memory-device-if-it-is-being-used.patch
* acpi_memhotplugc-bind-the-memory-device-when-the-driver-is-being-loaded.patch
* acpi_memhotplugc-auto-bind-the-memory-device-which-is-hotplugged-before-the-driver-is-loaded.patch
* arch-x86-platform-iris-irisc-register-a-platform-device-and-a-platform-driver.patch
* arch-x86-include-asm-spinlockh-fix-comment.patch
* mn10300-only-add-mmem-funcs-to-kbuild_cflags-if-gcc-supports-it.patch
* dma-dmaengine-lower-the-priority-of-failed-to-get-dma-channel-message.patch
* pcmcia-move-unbind-rebind-into-dev_pm_opscomplete.patch
* ppc-e500_tlb-memset-clears-nothing.patch
  cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* timeconstpl-remove-deprecated-defined-array.patch
* time-dont-inline-export_symbol-functions.patch
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
* mm-slab-remove-duplicate-check.patch
* slab-do-not-call-compound_head-in-page_get_cache.patch
* mm-slab_commonc-fix-warning.patch
  mm.patch
* mm-remove-__gfp_no_kswapd.patch
* remove-__gfp_no_kswapd-fixes.patch
* remove-__gfp_no_kswapd-fixes-fix.patch
* x86-pat-remove-the-dependency-on-vm_pgoff-in-track-untrack-pfn-vma-routines.patch
* x86-pat-separate-the-pfn-attribute-tracking-for-remap_pfn_range-and-vm_insert_pfn.patch
* x86-pat-separate-the-pfn-attribute-tracking-for-remap_pfn_range-and-vm_insert_pfn-fix.patch
* mm-x86-pat-rework-linear-pfn-mmap-tracking.patch
* mm-introduce-arch-specific-vma-flag-vm_arch_1.patch
* mm-kill-vma-flag-vm_insertpage.patch
* mm-kill-vma-flag-vm_can_nonlinear.patch
* mm-use-mm-exe_file-instead-of-first-vm_executable-vma-vm_file.patch
* mm-kill-vma-flag-vm_executable-and-mm-num_exe_file_vmas.patch
* mm-prepare-vm_dontdump-for-using-in-drivers.patch
* mm-kill-vma-flag-vm_reserved-and-mm-reserved_vm-counter.patch
* mm-kill-vma-flag-vm_reserved-and-mm-reserved_vm-counter-fix.patch
* frv-kill-used-but-uninitialized-variable.patch
* ipc-mqueue-remove-unnecessary-rb_init_node-calls.patch
* rbtree-reference-documentation-rbtreetxt-for-usage-instructions.patch
* rbtree-empty-nodes-have-no-color.patch
* rbtree-empty-nodes-have-no-color-fix.patch
* rbtree-fix-incorrect-rbtree-node-insertion-in-fs-proc-proc_sysctlc.patch
* rbtree-move-some-implementation-details-from-rbtreeh-to-rbtreec.patch
* rbtree-move-some-implementation-details-from-rbtreeh-to-rbtreec-fix.patch
* rbtree-performance-and-correctness-test.patch
* rbtree-performance-and-correctness-test-fix.patch
* rbtree-break-out-of-rb_insert_color-loop-after-tree-rotation.patch
* rbtree-adjust-root-color-in-rb_insert_color-only-when-necessary.patch
* rbtree-low-level-optimizations-in-rb_insert_color.patch
* rbtree-adjust-node-color-in-__rb_erase_color-only-when-necessary.patch
* rbtree-optimize-case-selection-logic-in-__rb_erase_color.patch
* rbtree-low-level-optimizations-in-__rb_erase_color.patch
* rbtree-coding-style-adjustments.patch
* rbtree-rb_erase-updates-and-comments.patch
* rbtree-optimize-fetching-of-sibling-node.patch
* drivers-firmware-dmi_scanc-check-dmi-version-when-get-system-uuid.patch
* drivers-firmware-dmi_scanc-check-dmi-version-when-get-system-uuid-fix.patch
* drivers-firmware-dmi_scanc-fetch-dmi-version-from-smbios-if-it-exists.patch
* drivers-firmware-dmi_scanc-fetch-dmi-version-from-smbios-if-it-exists-checkpatch-fixes.patch
* fat-exportfs-move-nfs-support-code.patch
* fat-exportfs-fix-dentry-reconnection.patch
* ipc-semc-alternatives-to-preempt_disable.patch
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
