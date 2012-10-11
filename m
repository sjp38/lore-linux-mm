Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id D4EBB6B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 19:15:52 -0400 (EDT)
Received: by mail-gh0-f201.google.com with SMTP id z19so288217ghb.2
        for <linux-mm@kvack.org>; Thu, 11 Oct 2012 16:15:52 -0700 (PDT)
Subject: mmotm 2012-10-11-16-14 uploaded
From: akpm@linux-foundation.org
Date: Thu, 11 Oct 2012 16:15:50 -0700
Message-Id: <20121011231551.641101E0048@wpzn4.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2012-10-11-16-14 has been uploaded to

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


This mmotm tree contains the following patches against 3.6:
(patches marked "*" will be included in linux-next)

  origin.patch
  linux-next.patch
  linux-next-git-rejects.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* linux-coredumph-needs-asm-siginfoh.patch
* memstick-remove-unused-field-from-state-struct.patch
* memstick-ms_block-fix-complile-issue.patch
* memstick-use-after-free-in-msb_disk_release.patch
* memstick-memory-leak-on-error-in-msb_ftl_scan.patch
* kernel-sysc-fix-stack-memory-content-leak-via-uname26.patch
* drivers-video-backlight-lm3639_blc-return-proper-error-in-lm3639_bled_mode_store-error-paths.patch
* pidns-remove-recursion-from-free_pid_ns-v5.patch
* pidns-remove-recursion-from-free_pid_ns-v5-fix.patch
* cris-fix-i-o-macros.patch
* selinux-fix-sel_netnode_insert-suspicious-rcu-dereference.patch
* mm-slab-release-slab_mutex-earlier-in-kmem_cache_destroy.patch
* nohz-fix-idle-ticks-in-cpu-summary-line-of-proc-stat.patch
* vfs-d_obtain_alias-needs-to-use-as-default-name.patch
* cpu_hotplug-unmap-cpu2node-when-the-cpu-is-hotremoved.patch
* cpu_hotplug-unmap-cpu2node-when-the-cpu-is-hotremoved-fix.patch
* acpi_memhotplugc-fix-memory-leak-when-memory-device-is-unbound-from-the-module-acpi_memhotplug.patch
* acpi_memhotplugc-free-memory-device-if-acpi_memory_enable_device-failed.patch
* acpi_memhotplugc-remove-memory-info-from-list-before-freeing-it.patch
* acpi_memhotplugc-dont-allow-to-eject-the-memory-device-if-it-is-being-used.patch
* acpi_memhotplugc-bind-the-memory-device-when-the-driver-is-being-loaded.patch
* acpi_memhotplugc-auto-bind-the-memory-device-which-is-hotplugged-before-the-driver-is-loaded.patch
* arch-x86-platform-iris-irisc-register-a-platform-device-and-a-platform-driver.patch
* x86-numa-dont-check-if-node-is-numa_no_node.patch
* arch-x86-tools-insn_sanityc-identify-source-of-messages.patch
* uv-fix-incorrect-tlb-flush-all-issue.patch
* olpc-fix-olpc-xo1-scic-build-errors.patch
* fs-debugsfs-remove-unnecessary-inode-i_private-initialization.patch
* pcmcia-move-unbind-rebind-into-dev_pm_opscomplete.patch
* drm-i915-optimize-div_round_closest-call.patch
* drm-fix-radeon-printk-format-warnings.patch
  cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* timeconstpl-remove-deprecated-defined-array.patch
* time-dont-inline-export_symbol-functions.patch
* h8300-select-generic-atomic64_t-support.patch
* cciss-cleanup-bitops-usage.patch
* cciss-use-check_signature.patch
* block-store-partition_meta_infouuid-as-a-string.patch
* init-reduce-partuuid-min-length-to-1-from-36.patch
* block-partition-msdos-provide-uuids-for-partitions.patch
* drbd-use-copy_highpage.patch
* vfs-increment-iversion-when-a-file-is-truncated.patch
* fs-change-return-values-from-eacces-to-eperm.patch
* fs-block_devc-need-not-to-check-inode-i_bdev-in-bd_forget.patch
* mm-slab-remove-duplicate-check.patch
  mm.patch
* writeback-remove-nr_pages_dirtied-arg-from-balance_dirty_pages_ratelimited_nr.patch
* mm-show-migration-types-in-show_mem.patch
* memory-hotplug-suppress-device-memoryx-does-not-have-a-release-function-warning.patch
* memory-hotplug-suppress-device-nodex-does-not-have-a-release-function-warning.patch
* mm-memcg-make-mem_cgroup_out_of_memory-static.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead-fix.patch
* mm-memblock-reduce-overhead-in-binary-search.patch
* compat-generic-compat_sys_sched_rr_get_interval-implementation.patch
* drivers-firmware-dmi_scanc-check-dmi-version-when-get-system-uuid.patch
* drivers-firmware-dmi_scanc-check-dmi-version-when-get-system-uuid-fix.patch
* drivers-firmware-dmi_scanc-fetch-dmi-version-from-smbios-if-it-exists.patch
* drivers-firmware-dmi_scanc-fetch-dmi-version-from-smbios-if-it-exists-checkpatch-fixes.patch
* hfsplus-add-on-disk-layout-declarations-related-to-attributes-tree.patch
* hfsplus-add-functionality-of-manipulating-by-records-in-attributes-tree.patch
* hfsplus-rework-functionality-of-getting-setting-and-deleting-of-extended-attributes.patch
* hfsplus-add-support-of-manipulation-by-attributes-file.patch
* hfsplus-add-support-of-manipulation-by-attributes-file-checkpatch-fixes.patch
* hfsplus-code-style-fixes-reworked-support-of-extended-attributes.patch
* fat-modify-nfs-mount-option.patch
* fat-exportfs-rebuild-inode-if-ilookup-fails.patch
* fat-exportfs-rebuild-inode-if-ilookup-fails-fix.patch
* fat-exportfs-rebuild-directory-inode-if-fat_dget-fails.patch
* documentation-update-nfs-option-in-filesystem-vfattxt.patch
* kstrto-add-documentation.patch
* simple_strto-annotate-function-as-obsolete.patch
* proc-dont-show-nonexistent-capabilities.patch
* ipc-semc-alternatives-to-preempt_disable.patch
* dma-debug-new-interfaces-to-debug-dma-mapping-errors.patch
* linux-compilerh-add-__must_hold-macro-for-functions-called-with-a-lock-held.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  mutex-subsystem-synchro-test-module-fix.patch
  mutex-subsystem-synchro-test-module-fix-2.patch
  slab-leaks3-default-y.patch
  put_bh-debug.patch
  add-debugging-aid-for-memory-initialisation-problems.patch
  workaround-for-a-pci-restoring-bug.patch
  single_open-seq_release-leak-diagnostics.patch
  add-a-refcount-check-in-dput.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
