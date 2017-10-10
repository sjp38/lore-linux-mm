Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id AA1426B025F
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 14:06:43 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t134so6087556oih.0
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 11:06:43 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d84sor2706399oia.30.2017.10.10.11.06.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Oct 2017 11:06:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57a124aa.eJmVCvd1SOHlQ1X8%akpm@linux-foundation.org>
References: <57a124aa.eJmVCvd1SOHlQ1X8%akpm@linux-foundation.org>
From: Vitaly Mayatskih <v.mayatskih@gmail.com>
Date: Tue, 10 Oct 2017 14:06:41 -0400
Message-ID: <CAGF4SLgi6jgtxbqtTEjL8FGXUHHsSm6KeoVqANLt3LB6OTBboA@mail.gmail.com>
Subject: Re: mmotm 2016-08-02-15-53 uploaded
Content-Type: multipart/alternative; boundary="001a113ac8dc5707dd055b352b2f"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

--001a113ac8dc5707dd055b352b2f
Content-Type: text/plain; charset="UTF-8"

* ocfs2-dlm-continue-to-purge-recovery-lockres-when-recovery
-master-goes-down.patch

This one completely broke two node cluster use case: when one node dies,
the other one either eventually crashes (~4.14-rc4) or locks up (pre-4.14).

On Tue, Aug 2, 2016 at 6:54 PM, <akpm@linux-foundation.org> wrote:

> The mm-of-the-moment snapshot 2016-08-02-15-53 has been uploaded to
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
> You will need quilt to apply these patches to the latest Linus release (4.x
> or 4.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> http://ozlabs.org/~akpm/mmotm/series
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
> http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/
>
> To develop on top of mmotm git:
>
>   $ git remote add mmotm git://git.kernel.org/pub/scm/
> linux/kernel/git/mhocko/mm.git
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
>         http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/
>
> and use of this tree is similar to
> http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/, described above.
>
>
> This mmotm tree contains the following patches against 4.7:
> (patches marked "*" will be included in linux-next)
>
>   origin.patch
> * ocfs2-insure-dlm-lockspace-is-created-by-kernel-module.patch
> * ocfs2-retry-on-enospc-if-sufficient-space-in-truncate-log.patch
> * ocfs2-dlm-disable-bug_on-when-dlm_lock_res_dropping_ref-is-
> cleared-before-dlm_deref_lockres_done_handler.patch
> * ocfs2-dlm-solve-a-bug-when-deref-failed-in-dlm_drop_lockres_ref.patch
> * ocfs2-dlm-continue-to-purge-recovery-lockres-when-
> recovery-master-goes-down.patch
> * mm-fail-prefaulting-if-page-table-allocation-fails.patch
> * mm-move-swap-in-anonymous-page-into-active-list.patch
> * fix-bitrotted-value-in-tools-testing-radix-tree-linux-gfph.patch
> * mm-hugetlb-avoid-soft-lockup-in-set_max_huge_pages.patch
> * mm-hugetlb-fix-huge_pte_alloc-bug_on.patch
> * memcg-put-soft-limit-reclaim-out-of-way-if-the-excess-tree-
> is-empty.patch
> * mm-kasan-fix-corruptions-and-false-positive-reports.patch
> * mm-kasan-dont-reduce-quarantine-in-atomic-contexts.patch
> * mm-kasan-slub-dont-disable-interrupts-when-object-leaves-
> quarantine.patch
> * mm-kasan-get-rid-of-alloc_size-in-struct-kasan_alloc_meta.patch
> * mm-kasan-get-rid-of-state-in-struct-kasan_alloc_meta.patch
> * kasan-improve-double-free-reports.patch
> * kasan-avoid-overflowing-quarantine-size-on-low-memory-systems.patch
> * radix-tree-account-nodes-to-memcg-only-if-explicitly-requested.patch
> * mm-vmscan-fix-memcg-aware-shrinkers-not-called-on-global-reclaim.patch
> * sysv-ipc-fix-security-layer-leaking.patch
> * ubsan-fix-typo-in-format-string.patch
> * cgroup-update-cgroups-document-path.patch
> * maintainers-befs-add-new-maintainers.patch
> * proc_oom_score-remove-tasklist_lock-and-pid_alive.patch
> * procfs-avoid-32-bit-time_t-in-proc-stat.patch
> * suppress-warnings-when-compiling-fs-proc-task_mmuc-with-w=1.patch
> * make-compile_test-depend-on-uml.patch
> * memstick-dont-allocate-unused-major-for-ms_block.patch
> * treewide-replace-obsolete-_refok-by-__ref.patch
> * uapi-move-forward-declarations-of-internal-structures.patch
> * mailmap-add-linus-lussing.patch
> * include-mman-use-bool-instead-of-int-for-the-return-value-
> of-arch_validate_prot.patch
> * task_work-use-read_once-lockless_dereference-avoid-pi_
> lock-if-task_works.patch
> * dynamic_debug-only-add-header-when-used.patch
> * printk-do-not-include-interrupth.patch
> * printk-create-pr_level-functions.patch
> * printk-introduce-suppress_message_printing.patch
> * printk-include-asm-sectionsh-instead-of-asm-generic-sectionsh.patch
> * fbdev-bfin_adv7393fb-move-driver_name-before-its-first-use.patch
> * ratelimit-extend-to-print-suppressed-messages-on-release.patch
> * printk-add-kernel-parameter-to-control-writes-to-dev-kmsg.patch
> * get_maintainerpl-reduce-need-for-command-line-option-f.patch
> * lib-iommu-helper-skip-to-next-segment.patch
> * crc32-use-ktime_get_ns-for-measurement.patch
> * radix-tree-fix-comment-about-exceptional-bits.patch
> * firmware-consolidate-kmap-read-write-logic.patch
> * firmware-provide-infrastructure-to-make-fw-caching-optional.patch
> * firmware-support-loading-into-a-pre-allocated-buffer.patch
> * checkpatch-skip-long-lines-that-use-an-efi_guid-macro.patch
> * checkpatch-allow-c99-style-comments.patch
> * checkpatch-yet-another-commit-id-improvement.patch
> * checkpatch-dont-complain-about-bit-macro-in-uapi.patch
> * checkpatch-improve-bare-use-of-signed-unsigned-types-warning.patch
> * checkpatch-check-signoff-when-reading-stdin.patch
> * checkpatch-if-no-filenames-then-read-stdin.patch
> * binfmt_elf-fix-calculations-for-bss-padding.patch
> * mm-refuse-wrapped-vm_brk-requests.patch
> * binfmt_em86-fix-incompatible-pointer-type.patch
> * nilfs2-hide-function-name-argument-from-nilfs_error.patch
> * nilfs2-add-nilfs_msg-message-interface.patch
> * nilfs2-embed-a-back-pointer-to-super-block-instance-in-
> nilfs-object.patch
> * nilfs2-reduce-bare-use-of-printk-with-nilfs_msg.patch
> * nilfs2-replace-nilfs_warning-with-nilfs_msg.patch
> * nilfs2-emit-error-message-when-i-o-error-is-detected.patch
> * nilfs2-do-not-use-yield.patch
> * nilfs2-refactor-parser-of-snapshot-mount-option.patch
> * nilfs2-fix-misuse-of-a-semaphore-in-sysfs-code.patch
> * nilfs2-use-bit-macro.patch
> * nilfs2-move-ioctl-interface-and-disk-layout-to-uapi-separately.patch
> * reiserfs-fix-new_insert_key-may-be-used-uninitialized.patch
> * signal-consolidate-tstlf_restore_sigmask-code.patch
> * exit-quieten-greatest-stack-depth-printk.patch
> * cpumask-fix-code-comment.patch
> * kexec-return-error-number-directly.patch
> * arm-kdump-advertise-boot-aliased-crash-kernel-resource.patch
> * arm-kexec-advertise-location-of-bootable-ram.patch
> * kexec-dont-invoke-oom-killer-for-control-page-allocation.patch
> * kexec-ensure-user-memory-sizes-do-not-wrap.patch
> * kdump-arrange-for-paddr_vmcoreinfo_note-to-return-phys_addr_t.patch
> * kexec-allow-architectures-to-override-boot-mapping.patch
> * arm-keystone-dts-add-psci-command-definition.patch
> * arm-kexec-fix-kexec-for-keystone-2.patch
> * kexec-use-core_param-for-crash_kexec_post_notifiers-boot-option.patch
> * add-a-kexec_crash_loaded-function.patch
> * allow-kdump-with-crash_kexec_post_notifiers.patch
> * kexec-add-restriction-on-kexec_load-segment-sizes.patch
> * rapidio-add-rapidio-channelized-messaging-driver.patch
> * rapidio-remove-unnecessary-0x-prefixes-before-%pa-extension-uses.patch
> * rapidio-documentation-fix-mangled-paragraph-in-mport_cdev.patch
> * rapidio-fix-return-value-description-for-dma_prep-functions.patch
> * rapidio-tsi721_dma-add-channel-mask-and-queue-size-parameters.patch
> * rapidio-tsi721-add-pcie-mrrs-override-parameter.patch
> * rapidio-tsi721-add-messaging-mbox-selector-parameter.patch
> * rapidio-tsi721_dma-advance-queue-processing-from-
> transfer-submit-call.patch
> * rapidio-fix-error-handling-in-mbox-request-release-functions.patch
> * rapidio-idt_gen2-fix-locking-warning.patch
> * rapidio-change-inbound-window-size-type-to-u64.patch
> * rapidio-modify-for-rev3-specification-changes.patch
> * powerpc-fsl_rio-apply-changes-for-rio-spec-rev-3.patch
> * rapidio-switches-add-driver-for-idt-gen3-switches.patch
> * w1-remove-need-for-ida-and-use-platform_devid_auto.patch
> * w1-add-helper-macro-module_w1_family.patch
> * w1-omap_hdq-fix-regression.patch
> * init-allow-blacklisting-of-module_init-functions.patch
> * relay-add-global-mode-support-for-buffer-only-channels.patch
> * ban-config_localversion_auto-with-allmodconfig.patch
> * config-add-android-config-fragments.patch
> * init-kconfig-add-clarification-for-out-of-tree-modules.patch
> * kcov-allow-more-fine-grained-coverage-instrumentation.patch
> * ipc-delete-nr_ipc_ns.patch
>   arch-alpha-kernel-systblss-remove-debug-check.patch
>   i-need-old-gcc.patch
> * mm-add-restriction-when-memory_hotplug-config-enable.patch
> * mm-memcontrol-fix-swap-counter-leak-on-swapout-from-offline-cgroup.patch
> * mm-memcontrol-fix-memcg-id-ref-counter-on-swap-charge-move.patch
> * arm-arch-arm-include-asm-pageh-needs-personalityh.patch
> * kbuild-simpler-generation-of-assembly-constants.patch
> * block-restore-proc-partitions-to-not-display-non-
> partitionable-removable-devices.patch
> * kernel-watchdog-use-nmi-registers-snapshot-in-hardlockup-handler.patch
>   mm.patch
> * mm-memcontrol-add-sanity-checks-for-memcg-idref-on-get-put.patch
> * mm-oom-deduplicate-victim-selection-code-for-memcg-and-global-oom.patch
> * mm-zsmalloc-add-trace-events-for-zs_compact.patch
> * mm-zsmalloc-add-per-class-compact-trace-event.patch
> * mm-page_owner-align-with-pageblock_nr-pages.patch
> * mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
> * proc-relax-proc-tid-timerslack_ns-capability-requirements.patch
> * proc-add-lsm-hook-checks-to-proc-tid-timerslack_ns.patch
> * lib-add-crc64-ecma-module.patch
> * compat-remove-compat_printk.patch
> * kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
> * ipc-msgc-msgsnd-use-freezable-blocking-call.patch
> * msgrcv-use-freezable-blocking-call.patch
>   linux-next.patch
>   linux-next-rejects.patch
>   linux-next-git-rejects.patch
> * drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
> * fpga-zynq-fpga-fix-build-failure.patch
> * tree-wide-replace-config_enabled-with-is_enabled.patch
> * bitmap-bitmap_equal-memcmp-optimization-fix.patch
> * powerpc-add-explicit-include-asm-asm-compath-for-jump-label.patch
> * sparc-support-static_key-usage-in-non-module-__exit-sections.patch
> * tile-support-static_key-usage-in-non-module-__exit-sections.patch
> * arm-jump-label-may-reference-text-in-__exit.patch
> * jump_label-remove-bugh-atomich-dependencies-for-have_jump_label.patch
> * dynamic_debug-add-jump-label-support.patch
> * ipc-semc-fix-complex_count-vs-simple-op-race.patch
> * media-mtk-vcodec-remove-unused-dma_attrs.patch
> * dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * alpha-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * arc-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * arm-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * arm64-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * avr32-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * blackfin-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * c6x-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * cris-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * frv-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * drm-exynos-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * drm-mediatek-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * drm-msm-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * drm-nouveau-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * drm-rockship-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * infiniband-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * iommu-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * media-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * xen-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * swiotlb-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * powerpc-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * video-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * x86-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * iommu-intel-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * h8300-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * hexagon-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * ia64-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * m68k-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * metag-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * microblaze-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * mips-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * mn10300-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * nios2-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * openrisc-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * parisc-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * misc-mic-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * s390-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * sh-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * sparc-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * tile-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * unicore32-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * xtensa-dma-mapping-use-unsigned-long-for-dma_attrs.patch
> * remoteproc-qcom-use-unsigned-long-for-dma_attrs.patch
> * dma-mapping-remove-dma_get_attr.patch
> * dma-mapping-document-the-dma-attributes-next-to-the-declaration.patch
> * samples-kprobe-convert-the-printk-to-pr_info-pr_err.patch
> * samples-jprobe-convert-the-printk-to-pr_info-pr_err.patch
> * samples-kretprobe-convert-the-printk-to-pr_info-pr_err.patch
> * samples-kretprobe-fix-the-wrong-type.patch
> * block-remove-blk_dev_dax-config-option.patch
> * maintainers-update-email-and-list-of-samsung-hw-driver-maintainers.patch
>   mm-add-strictlimit-knob-v2.patch
>   make-sure-nobodys-leaking-resources.patch
>   releasing-resources-with-children.patch
>   make-frame_pointer-default=y.patch
>   kernel-forkc-export-kernel_thread-to-modules.patch
>   mutex-subsystem-synchro-test-module.patch
>   slab-leaks3-default-y.patch
>   add-debugging-aid-for-memory-initialisation-problems.patch
>   workaround-for-a-pci-restoring-bug.patch
>



-- 
wbr, Vitaly

--001a113ac8dc5707dd055b352b2f
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><span style=3D"color:rgb(0,0,0);font-size:16px">*=C2=A0</s=
pan><span class=3D"gmail-il" style=3D"color:rgb(0,0,0);font-size:16px;backg=
round-color:rgb(255,255,255)">ocfs2</span><span style=3D"color:rgb(0,0,0);f=
ont-size:16px">-</span><span class=3D"gmail-il" style=3D"color:rgb(0,0,0);f=
ont-size:16px;background-color:rgb(255,255,255)">dlm</span><span style=3D"c=
olor:rgb(0,0,0);font-size:16px">-</span><span class=3D"gmail-il" style=3D"c=
olor:rgb(0,0,0);font-size:16px;background-color:rgb(255,255,255)">continue<=
/span><span style=3D"color:rgb(0,0,0);font-size:16px">-to-</span><span clas=
s=3D"gmail-il" style=3D"color:rgb(0,0,0);font-size:16px;background-color:rg=
b(255,255,255)">purge</span><span style=3D"color:rgb(0,0,0);font-size:16px"=
>-</span><wbr style=3D"color:rgb(0,0,0);font-size:16px"><span class=3D"gmai=
l-il" style=3D"color:rgb(0,0,0);font-size:16px;background-color:rgb(255,255=
,255)">recovery</span><span style=3D"color:rgb(0,0,0);font-size:16px">-</sp=
an><span class=3D"gmail-il" style=3D"color:rgb(0,0,0);font-size:16px;backgr=
ound-color:rgb(255,255,255)">lockres</span><span style=3D"color:rgb(0,0,0);=
font-size:16px">-when-</span><wbr style=3D"color:rgb(0,0,0);font-size:16px"=
><span class=3D"gmail-il" style=3D"color:rgb(0,0,0);font-size:16px;backgrou=
nd-color:rgb(255,255,255)">recovery</span><span style=3D"color:rgb(0,0,0);f=
ont-size:16px">-master-goes-down.</span><wbr style=3D"color:rgb(0,0,0);font=
-size:16px"><span style=3D"color:rgb(0,0,0);font-size:16px">patch</span><br=
><div><span style=3D"color:rgb(0,0,0);font-size:16px"><br></span></div><div=
><span style=3D"color:rgb(0,0,0);font-size:16px">This one completely broke =
two node cluster use case: when one node dies, the other one either eventua=
lly crashes (~4.14-rc4) or locks up (pre-4.14).</span></div></div><div clas=
s=3D"gmail_extra"><br><div class=3D"gmail_quote">On Tue, Aug 2, 2016 at 6:5=
4 PM,  <span dir=3D"ltr">&lt;<a href=3D"mailto:akpm@linux-foundation.org" t=
arget=3D"_blank">akpm@linux-foundation.org</a>&gt;</span> wrote:<br><blockq=
uote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc =
solid;padding-left:1ex">The mm-of-the-moment snapshot 2016-08-02-15-53 has =
been uploaded to<br>
<br>
=C2=A0 =C2=A0<a href=3D"http://www.ozlabs.org/~akpm/mmotm/" rel=3D"noreferr=
er" target=3D"_blank">http://www.ozlabs.org/~akpm/<wbr>mmotm/</a><br>
<br>
mmotm-readme.txt says<br>
<br>
README for mm-of-the-moment:<br>
<br>
<a href=3D"http://www.ozlabs.org/~akpm/mmotm/" rel=3D"noreferrer" target=3D=
"_blank">http://www.ozlabs.org/~akpm/<wbr>mmotm/</a><br>
<br>
This is a snapshot of my -mm patch queue.=C2=A0 Uploaded at random hopefull=
y<br>
more than once a week.<br>
<br>
You will need quilt to apply these patches to the latest Linus release (4.x=
<br>
or 4.x-rcY).=C2=A0 The series file is in broken-out.tar.gz and is duplicate=
d in<br>
<a href=3D"http://ozlabs.org/~akpm/mmotm/series" rel=3D"noreferrer" target=
=3D"_blank">http://ozlabs.org/~akpm/mmotm/<wbr>series</a><br>
<br>
The file broken-out.tar.gz contains two datestamp files: .DATE and<br>
.DATE-yyyy-mm-dd-hh-mm-ss.=C2=A0 Both contain the string yyyy-mm-dd-hh-mm-s=
s,<br>
followed by the base kernel version against which this patch series is to<b=
r>
be applied.<br>
<br>
This tree is partially included in linux-next.=C2=A0 To see which patches a=
re<br>
included in linux-next, consult the `series&#39; file.=C2=A0 Only the patch=
es<br>
within the #NEXT_PATCHES_START/#NEXT_<wbr>PATCHES_END markers are included =
in<br>
linux-next.<br>
<br>
A git tree which contains the memory management portion of this tree is<br>
maintained at git://<a href=3D"http://git.kernel.org/pub/scm/linux/kernel/g=
it/mhocko/mm.git" rel=3D"noreferrer" target=3D"_blank">git.kernel.org/pub/s=
cm/<wbr>linux/kernel/git/mhocko/mm.git</a><br>
by Michal Hocko.=C2=A0 It contains the patches which are between the<br>
&quot;#NEXT_PATCHES_START mm&quot; and &quot;#NEXT_PATCHES_END&quot; marker=
s, from the series<br>
file, <a href=3D"http://www.ozlabs.org/~akpm/mmotm/series" rel=3D"noreferre=
r" target=3D"_blank">http://www.ozlabs.org/~akpm/<wbr>mmotm/series</a>.<br>
<br>
<br>
A full copy of the full kernel tree with the linux-next and mmotm patches<b=
r>
already applied is available through git within an hour of the mmotm<br>
release.=C2=A0 Individual mmotm releases are tagged.=C2=A0 The master branc=
h always<br>
points to the latest release, so it&#39;s constantly rebasing.<br>
<br>
<a href=3D"http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/" rel=3D"norefer=
rer" target=3D"_blank">http://git.cmpxchg.org/cgit.<wbr>cgi/linux-mmotm.git=
/</a><br>
<br>
To develop on top of mmotm git:<br>
<br>
=C2=A0 $ git remote add mmotm git://<a href=3D"http://git.kernel.org/pub/sc=
m/linux/kernel/git/mhocko/mm.git" rel=3D"noreferrer" target=3D"_blank">git.=
kernel.org/pub/scm/<wbr>linux/kernel/git/mhocko/mm.git</a><br>
=C2=A0 $ git remote update mmotm<br>
=C2=A0 $ git checkout -b topic mmotm/master<br>
=C2=A0 &lt;make changes, commit&gt;<br>
=C2=A0 $ git send-email mmotm/master.. [...]<br>
<br>
To rebase a branch with older patches to a new mmotm release:<br>
<br>
=C2=A0 $ git remote update mmotm<br>
=C2=A0 $ git rebase --onto mmotm/master &lt;topic base&gt; topic<br>
<br>
<br>
<br>
<br>
The directory <a href=3D"http://www.ozlabs.org/~akpm/mmots/" rel=3D"norefer=
rer" target=3D"_blank">http://www.ozlabs.org/~akpm/<wbr>mmots/</a> (mm-of-t=
he-second)<br>
contains daily snapshots of the -mm tree.=C2=A0 It is updated more frequent=
ly<br>
than mmotm, and is untested.<br>
<br>
A git copy of this tree is available at<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 <a href=3D"http://git.cmpxchg.org/cgit.cgi/linu=
x-mmots.git/" rel=3D"noreferrer" target=3D"_blank">http://git.cmpxchg.org/c=
git.<wbr>cgi/linux-mmots.git/</a><br>
<br>
and use of this tree is similar to<br>
<a href=3D"http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/" rel=3D"norefer=
rer" target=3D"_blank">http://git.cmpxchg.org/cgit.<wbr>cgi/linux-mmotm.git=
/</a>, described above.<br>
<br>
<br>
This mmotm tree contains the following patches against 4.7:<br>
(patches marked &quot;*&quot; will be included in linux-next)<br>
<br>
=C2=A0 origin.patch<br>
* ocfs2-insure-dlm-lockspace-is-<wbr>created-by-kernel-module.patch<br>
* ocfs2-retry-on-enospc-if-<wbr>sufficient-space-in-truncate-<wbr>log.patch=
<br>
* ocfs2-dlm-disable-bug_on-when-<wbr>dlm_lock_res_dropping_ref-is-<wbr>clea=
red-before-dlm_deref_<wbr>lockres_done_handler.patch<br>
* ocfs2-dlm-solve-a-bug-when-<wbr>deref-failed-in-dlm_drop_<wbr>lockres_ref=
.patch<br>
* ocfs2-dlm-continue-to-purge-<wbr>recovery-lockres-when-<wbr>recovery-mast=
er-goes-down.<wbr>patch<br>
* mm-fail-prefaulting-if-page-<wbr>table-allocation-fails.patch<br>
* mm-move-swap-in-anonymous-<wbr>page-into-active-list.patch<br>
* fix-bitrotted-value-in-tools-<wbr>testing-radix-tree-linux-gfph.<wbr>patc=
h<br>
* mm-hugetlb-avoid-soft-lockup-<wbr>in-set_max_huge_pages.patch<br>
* mm-hugetlb-fix-huge_pte_alloc-<wbr>bug_on.patch<br>
* memcg-put-soft-limit-reclaim-<wbr>out-of-way-if-the-excess-tree-<wbr>is-e=
mpty.patch<br>
* mm-kasan-fix-corruptions-and-<wbr>false-positive-reports.patch<br>
* mm-kasan-dont-reduce-<wbr>quarantine-in-atomic-contexts.<wbr>patch<br>
* mm-kasan-slub-dont-disable-<wbr>interrupts-when-object-leaves-<wbr>quaran=
tine.patch<br>
* mm-kasan-get-rid-of-alloc_<wbr>size-in-struct-kasan_alloc_<wbr>meta.patch=
<br>
* mm-kasan-get-rid-of-state-in-<wbr>struct-kasan_alloc_meta.patch<br>
* kasan-improve-double-free-<wbr>reports.patch<br>
* kasan-avoid-overflowing-<wbr>quarantine-size-on-low-memory-<wbr>systems.p=
atch<br>
* radix-tree-account-nodes-to-<wbr>memcg-only-if-explicitly-<wbr>requested.=
patch<br>
* mm-vmscan-fix-memcg-aware-<wbr>shrinkers-not-called-on-<wbr>global-reclai=
m.patch<br>
* sysv-ipc-fix-security-layer-<wbr>leaking.patch<br>
* ubsan-fix-typo-in-format-<wbr>string.patch<br>
* cgroup-update-cgroups-<wbr>document-path.patch<br>
* maintainers-befs-add-new-<wbr>maintainers.patch<br>
* proc_oom_score-remove-<wbr>tasklist_lock-and-pid_alive.<wbr>patch<br>
* procfs-avoid-32-bit-time_t-in-<wbr>proc-stat.patch<br>
* suppress-warnings-when-<wbr>compiling-fs-proc-task_mmuc-<wbr>with-w=3D1.p=
atch<br>
* make-compile_test-depend-on-<wbr>uml.patch<br>
* memstick-dont-allocate-unused-<wbr>major-for-ms_block.patch<br>
* treewide-replace-obsolete-_<wbr>refok-by-__ref.patch<br>
* uapi-move-forward-<wbr>declarations-of-internal-<wbr>structures.patch<br>
* mailmap-add-linus-lussing.<wbr>patch<br>
* include-mman-use-bool-instead-<wbr>of-int-for-the-return-value-<wbr>of-ar=
ch_validate_prot.patch<br>
* task_work-use-read_once-<wbr>lockless_dereference-avoid-pi_<wbr>lock-if-t=
ask_works.patch<br>
* dynamic_debug-only-add-header-<wbr>when-used.patch<br>
* printk-do-not-include-<wbr>interrupth.patch<br>
* printk-create-pr_level-<wbr>functions.patch<br>
* printk-introduce-suppress_<wbr>message_printing.patch<br>
* printk-include-asm-sectionsh-<wbr>instead-of-asm-generic-<wbr>sectionsh.p=
atch<br>
* fbdev-bfin_adv7393fb-move-<wbr>driver_name-before-its-first-<wbr>use.patc=
h<br>
* ratelimit-extend-to-print-<wbr>suppressed-messages-on-<wbr>release.patch<=
br>
* printk-add-kernel-parameter-<wbr>to-control-writes-to-dev-kmsg.<wbr>patch=
<br>
* get_maintainerpl-reduce-need-<wbr>for-command-line-option-f.<wbr>patch<br=
>
* lib-iommu-helper-skip-to-next-<wbr>segment.patch<br>
* crc32-use-ktime_get_ns-for-<wbr>measurement.patch<br>
* radix-tree-fix-comment-about-<wbr>exceptional-bits.patch<br>
* firmware-consolidate-kmap-<wbr>read-write-logic.patch<br>
* firmware-provide-<wbr>infrastructure-to-make-fw-<wbr>caching-optional.pat=
ch<br>
* firmware-support-loading-into-<wbr>a-pre-allocated-buffer.patch<br>
* checkpatch-skip-long-lines-<wbr>that-use-an-efi_guid-macro.<wbr>patch<br>
* checkpatch-allow-c99-style-<wbr>comments.patch<br>
* checkpatch-yet-another-commit-<wbr>id-improvement.patch<br>
* checkpatch-dont-complain-<wbr>about-bit-macro-in-uapi.patch<br>
* checkpatch-improve-bare-use-<wbr>of-signed-unsigned-types-<wbr>warning.pa=
tch<br>
* checkpatch-check-signoff-when-<wbr>reading-stdin.patch<br>
* checkpatch-if-no-filenames-<wbr>then-read-stdin.patch<br>
* binfmt_elf-fix-calculations-<wbr>for-bss-padding.patch<br>
* mm-refuse-wrapped-vm_brk-<wbr>requests.patch<br>
* binfmt_em86-fix-incompatible-<wbr>pointer-type.patch<br>
* nilfs2-hide-function-name-<wbr>argument-from-nilfs_error.<wbr>patch<br>
* nilfs2-add-nilfs_msg-message-<wbr>interface.patch<br>
* nilfs2-embed-a-back-pointer-<wbr>to-super-block-instance-in-<wbr>nilfs-ob=
ject.patch<br>
* nilfs2-reduce-bare-use-of-<wbr>printk-with-nilfs_msg.patch<br>
* nilfs2-replace-nilfs_warning-<wbr>with-nilfs_msg.patch<br>
* nilfs2-emit-error-message-<wbr>when-i-o-error-is-detected.<wbr>patch<br>
* nilfs2-do-not-use-yield.patch<br>
* nilfs2-refactor-parser-of-<wbr>snapshot-mount-option.patch<br>
* nilfs2-fix-misuse-of-a-<wbr>semaphore-in-sysfs-code.patch<br>
* nilfs2-use-bit-macro.patch<br>
* nilfs2-move-ioctl-interface-<wbr>and-disk-layout-to-uapi-<wbr>separately.=
patch<br>
* reiserfs-fix-new_insert_key-<wbr>may-be-used-uninitialized.<wbr>patch<br>
* signal-consolidate-tstlf_<wbr>restore_sigmask-code.patch<br>
* exit-quieten-greatest-stack-<wbr>depth-printk.patch<br>
* cpumask-fix-code-comment.patch<br>
* kexec-return-error-number-<wbr>directly.patch<br>
* arm-kdump-advertise-boot-<wbr>aliased-crash-kernel-resource.<wbr>patch<br=
>
* arm-kexec-advertise-location-<wbr>of-bootable-ram.patch<br>
* kexec-dont-invoke-oom-killer-<wbr>for-control-page-allocation.<wbr>patch<=
br>
* kexec-ensure-user-memory-<wbr>sizes-do-not-wrap.patch<br>
* kdump-arrange-for-paddr_<wbr>vmcoreinfo_note-to-return-<wbr>phys_addr_t.p=
atch<br>
* kexec-allow-architectures-to-<wbr>override-boot-mapping.patch<br>
* arm-keystone-dts-add-psci-<wbr>command-definition.patch<br>
* arm-kexec-fix-kexec-for-<wbr>keystone-2.patch<br>
* kexec-use-core_param-for-<wbr>crash_kexec_post_notifiers-<wbr>boot-option=
.patch<br>
* add-a-kexec_crash_loaded-<wbr>function.patch<br>
* allow-kdump-with-crash_kexec_<wbr>post_notifiers.patch<br>
* kexec-add-restriction-on-<wbr>kexec_load-segment-sizes.patch<br>
* rapidio-add-rapidio-<wbr>channelized-messaging-driver.<wbr>patch<br>
* rapidio-remove-unnecessary-0x-<wbr>prefixes-before-%pa-extension-<wbr>use=
s.patch<br>
* rapidio-documentation-fix-<wbr>mangled-paragraph-in-mport_<wbr>cdev.patch=
<br>
* rapidio-fix-return-value-<wbr>description-for-dma_prep-<wbr>functions.pat=
ch<br>
* rapidio-tsi721_dma-add-<wbr>channel-mask-and-queue-size-<wbr>parameters.p=
atch<br>
* rapidio-tsi721-add-pcie-mrrs-<wbr>override-parameter.patch<br>
* rapidio-tsi721-add-messaging-<wbr>mbox-selector-parameter.patch<br>
* rapidio-tsi721_dma-advance-<wbr>queue-processing-from-<wbr>transfer-submi=
t-call.patch<br>
* rapidio-fix-error-handling-in-<wbr>mbox-request-release-<wbr>functions.pa=
tch<br>
* rapidio-idt_gen2-fix-locking-<wbr>warning.patch<br>
* rapidio-change-inbound-window-<wbr>size-type-to-u64.patch<br>
* rapidio-modify-for-rev3-<wbr>specification-changes.patch<br>
* powerpc-fsl_rio-apply-changes-<wbr>for-rio-spec-rev-3.patch<br>
* rapidio-switches-add-driver-<wbr>for-idt-gen3-switches.patch<br>
* w1-remove-need-for-ida-and-<wbr>use-platform_devid_auto.patch<br>
* w1-add-helper-macro-module_w1_<wbr>family.patch<br>
* w1-omap_hdq-fix-regression.<wbr>patch<br>
* init-allow-blacklisting-of-<wbr>module_init-functions.patch<br>
* relay-add-global-mode-support-<wbr>for-buffer-only-channels.patch<br>
* ban-config_localversion_auto-<wbr>with-allmodconfig.patch<br>
* config-add-android-config-<wbr>fragments.patch<br>
* init-kconfig-add-<wbr>clarification-for-out-of-tree-<wbr>modules.patch<br=
>
* kcov-allow-more-fine-grained-<wbr>coverage-instrumentation.patch<br>
* ipc-delete-nr_ipc_ns.patch<br>
=C2=A0 arch-alpha-kernel-systblss-<wbr>remove-debug-check.patch<br>
=C2=A0 i-need-old-gcc.patch<br>
* mm-add-restriction-when-<wbr>memory_hotplug-config-enable.<wbr>patch<br>
* mm-memcontrol-fix-swap-<wbr>counter-leak-on-swapout-from-<wbr>offline-cgr=
oup.patch<br>
* mm-memcontrol-fix-memcg-id-<wbr>ref-counter-on-swap-charge-<wbr>move.patc=
h<br>
* arm-arch-arm-include-asm-<wbr>pageh-needs-personalityh.patch<br>
* kbuild-simpler-generation-of-<wbr>assembly-constants.patch<br>
* block-restore-proc-partitions-<wbr>to-not-display-non-<wbr>partitionable-=
removable-<wbr>devices.patch<br>
* kernel-watchdog-use-nmi-<wbr>registers-snapshot-in-<wbr>hardlockup-handle=
r.patch<br>
=C2=A0 mm.patch<br>
* mm-memcontrol-add-sanity-<wbr>checks-for-memcg-idref-on-get-<wbr>put.patc=
h<br>
* mm-oom-deduplicate-victim-<wbr>selection-code-for-memcg-and-<wbr>global-o=
om.patch<br>
* mm-zsmalloc-add-trace-events-<wbr>for-zs_compact.patch<br>
* mm-zsmalloc-add-per-class-<wbr>compact-trace-event.patch<br>
* mm-page_owner-align-with-<wbr>pageblock_nr-pages.patch<br>
* mm-walk-the-zone-in-pageblock_<wbr>nr_pages-steps.patch<br>
* proc-relax-proc-tid-<wbr>timerslack_ns-capability-<wbr>requirements.patch=
<br>
* proc-add-lsm-hook-checks-to-<wbr>proc-tid-timerslack_ns.patch<br>
* lib-add-crc64-ecma-module.<wbr>patch<br>
* compat-remove-compat_printk.<wbr>patch<br>
* kdump-vmcoreinfo-report-<wbr>actual-value-of-phys_base.<wbr>patch<br>
* ipc-msgc-msgsnd-use-freezable-<wbr>blocking-call.patch<br>
* msgrcv-use-freezable-blocking-<wbr>call.patch<br>
=C2=A0 linux-next.patch<br>
=C2=A0 linux-next-rejects.patch<br>
=C2=A0 linux-next-git-rejects.patch<br>
* drivers-net-wireless-intel-<wbr>iwlwifi-dvm-calibc-fix-min-<wbr>warning.p=
atch<br>
* fpga-zynq-fpga-fix-build-<wbr>failure.patch<br>
* tree-wide-replace-config_<wbr>enabled-with-is_enabled.patch<br>
* bitmap-bitmap_equal-memcmp-<wbr>optimization-fix.patch<br>
* powerpc-add-explicit-include-<wbr>asm-asm-compath-for-jump-<wbr>label.pat=
ch<br>
* sparc-support-static_key-<wbr>usage-in-non-module-__exit-<wbr>sections.pa=
tch<br>
* tile-support-static_key-usage-<wbr>in-non-module-__exit-sections.<wbr>pat=
ch<br>
* arm-jump-label-may-reference-<wbr>text-in-__exit.patch<br>
* jump_label-remove-bugh-<wbr>atomich-dependencies-for-have_<wbr>jump_label=
.patch<br>
* dynamic_debug-add-jump-label-<wbr>support.patch<br>
* ipc-semc-fix-complex_count-vs-<wbr>simple-op-race.patch<br>
* media-mtk-vcodec-remove-<wbr>unused-dma_attrs.patch<br>
* dma-mapping-use-unsigned-long-<wbr>for-dma_attrs.patch<br>
* alpha-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* arc-dma-mapping-use-unsigned-<wbr>long-for-dma_attrs.patch<br>
* arm-dma-mapping-use-unsigned-<wbr>long-for-dma_attrs.patch<br>
* arm64-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* avr32-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* blackfin-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* c6x-dma-mapping-use-unsigned-<wbr>long-for-dma_attrs.patch<br>
* cris-dma-mapping-use-unsigned-<wbr>long-for-dma_attrs.patch<br>
* frv-dma-mapping-use-unsigned-<wbr>long-for-dma_attrs.patch<br>
* drm-exynos-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br=
>
* drm-mediatek-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<=
br>
* drm-msm-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* drm-nouveau-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<b=
r>
* drm-rockship-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<=
br>
* infiniband-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br=
>
* iommu-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* media-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* xen-dma-mapping-use-unsigned-<wbr>long-for-dma_attrs.patch<br>
* swiotlb-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* powerpc-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* video-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* x86-dma-mapping-use-unsigned-<wbr>long-for-dma_attrs.patch<br>
* iommu-intel-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<b=
r>
* h8300-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* hexagon-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* ia64-dma-mapping-use-unsigned-<wbr>long-for-dma_attrs.patch<br>
* m68k-dma-mapping-use-unsigned-<wbr>long-for-dma_attrs.patch<br>
* metag-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* microblaze-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br=
>
* mips-dma-mapping-use-unsigned-<wbr>long-for-dma_attrs.patch<br>
* mn10300-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* nios2-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* openrisc-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* parisc-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* misc-mic-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* s390-dma-mapping-use-unsigned-<wbr>long-for-dma_attrs.patch<br>
* sh-dma-mapping-use-unsigned-<wbr>long-for-dma_attrs.patch<br>
* sparc-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* tile-dma-mapping-use-unsigned-<wbr>long-for-dma_attrs.patch<br>
* unicore32-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* xtensa-dma-mapping-use-<wbr>unsigned-long-for-dma_attrs.<wbr>patch<br>
* remoteproc-qcom-use-unsigned-<wbr>long-for-dma_attrs.patch<br>
* dma-mapping-remove-dma_get_<wbr>attr.patch<br>
* dma-mapping-document-the-dma-<wbr>attributes-next-to-the-<wbr>declaration=
.patch<br>
* samples-kprobe-convert-the-<wbr>printk-to-pr_info-pr_err.patch<br>
* samples-jprobe-convert-the-<wbr>printk-to-pr_info-pr_err.patch<br>
* samples-kretprobe-convert-the-<wbr>printk-to-pr_info-pr_err.patch<br>
* samples-kretprobe-fix-the-<wbr>wrong-type.patch<br>
* block-remove-blk_dev_dax-<wbr>config-option.patch<br>
* maintainers-update-email-and-<wbr>list-of-samsung-hw-driver-<wbr>maintain=
ers.patch<br>
=C2=A0 mm-add-strictlimit-knob-v2.<wbr>patch<br>
=C2=A0 make-sure-nobodys-leaking-<wbr>resources.patch<br>
=C2=A0 releasing-resources-with-<wbr>children.patch<br>
=C2=A0 make-frame_pointer-default=3Dy.<wbr>patch<br>
=C2=A0 kernel-forkc-export-kernel_<wbr>thread-to-modules.patch<br>
=C2=A0 mutex-subsystem-synchro-test-<wbr>module.patch<br>
=C2=A0 slab-leaks3-default-y.patch<br>
=C2=A0 add-debugging-aid-for-memory-<wbr>initialisation-problems.patch<br>
=C2=A0 workaround-for-a-pci-<wbr>restoring-bug.patch<br>
</blockquote></div><br><br clear=3D"all"><div><br></div>-- <br><div class=
=3D"gmail_signature" data-smartmail=3D"gmail_signature">wbr, Vitaly</div>
</div>

--001a113ac8dc5707dd055b352b2f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
