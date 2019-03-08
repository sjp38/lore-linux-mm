Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BA1FC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 02:01:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 231BE20840
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 02:01:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 231BE20840
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80C658E0003; Thu,  7 Mar 2019 21:01:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BE738E0002; Thu,  7 Mar 2019 21:01:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 683D58E0003; Thu,  7 Mar 2019 21:01:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2541C8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 21:01:58 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id z24so20160695pfn.7
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 18:01:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :subject:message-id:user-agent;
        bh=vz6J0sEaQsxHfRVzjSo/wiwysCUQzWIwEZ0MAPPDTic=;
        b=YCUYI9dl4lYN9lJRr03vbiVrgggGrbUICkkQTa8v81NR5gcLD84ka0F7iz2EXvh87y
         HLM9c55/kB/EiQTGSsVXad1iy8QQ9k4XdwhmZMIZeoaDXX1Y8rkjOMelFXyXBiyhDLXX
         /hnsMjS0mWcu+4UearCxB91c9DukNjiF2sEibtX/cw9j6aOayH+RmPVu8rxSbnrmr01p
         xPcQ/E0s3/TZtleBFybv+kVGbvxjVSFhnQj9Fkt6Kt7rstt6bv2LlMaNi5Hr3rsA45gs
         Z2l+UyobLP5Y60Qb9udoavWVYNpoZXWRixCDmYpgB7J0kB6AQZIjQTo96xYYzqH56R1i
         o0dQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAU58+Y6p5BMF4aAcrmV1SZ8ZVpQ9LZsguFhFvGL6R3h7zI5bIXc
	wlDdURZCh1FLREBuS38X+3WUNJXgY+u5H8emaImUhHJYmI5lj8zI7DRsfjsB8ecKbexlZbR7rnS
	A45SmD6CkUGoLO7zg+I/g1V/U+4lkwFUJu/fDor6hhySpIXUgB5R6QzULVLwit77ffg==
X-Received: by 2002:a63:8bc7:: with SMTP id j190mr14492954pge.382.1552010517680;
        Thu, 07 Mar 2019 18:01:57 -0800 (PST)
X-Google-Smtp-Source: APXvYqy7HAJkgnN5DJvuQEYC0P4kyIrAmzlKUm2GERjN8Qm6MCMiRHxDh4Pc6pDRGdyU0WIRtOmb
X-Received: by 2002:a63:8bc7:: with SMTP id j190mr14492797pge.382.1552010515864;
        Thu, 07 Mar 2019 18:01:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552010515; cv=none;
        d=google.com; s=arc-20160816;
        b=azrd+1ClwkjzpGp3Z4spVVFYx3v1VbrXiDGdzY2y2BYcloo6Ft2X7A5ChJ+LRjiiso
         Scin+HNAZsNSw3sM3FDLdO4EwG1+TvW8ZoQMCsUISsgacoaEb0xbVzZTyLYAgrOpnBd7
         zCYvRbUPnqu4rMhdaMwiVSWzJJLGIZrOa2InEzq2DKaY89RH6Ez/0w12wupvlwA2rYv4
         mPcFC4NWBqT5rRtMXSf5MskP7PGOirVmkdcxXW1T26soznRiCRenkzJrbBJfSnRCQljL
         WnuXKShnp7X1vZtKma8zPCEzIyvd3Txv/viCdB4iJP/vZRSAd9OfToYy0Wc6VrnaXfzl
         VjgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:subject:to:from:date;
        bh=vz6J0sEaQsxHfRVzjSo/wiwysCUQzWIwEZ0MAPPDTic=;
        b=MI34DyO7t1UowSn9NIT5+pxcTSbq+dTqoPbyPFGWlXD11GOtjASJhmNowlLRDGpTcC
         oC7RgN+oTIHr920IQQ5RIhFs/Nge7XBT74n1iNvlei5i84zUfDU8mYYAWnXivGhibOPg
         Hq3wuxyD5wAcMadMKm2VHdsUnsrSNxHn5R6i3e/2Ebv6Zyi0p7x9pSx9seZMtJB0A4Ve
         j7Y/m3+AUiH1AnjiaVYVWkyUxMspq7IwkSdVP7kcel5D0ItydckVtSCWpVsrTaIqU7yX
         Bq8bknBK6ZFMXLY92v/2SSUmWF2/mMON6hFIFB/FPxt9RkEKWJ3h6r09039JX0x99s8s
         rhXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d14si5315313pgn.536.2019.03.07.18.01.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 18:01:55 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 94C25CE11;
	Fri,  8 Mar 2019 02:01:54 +0000 (UTC)
Date: Thu, 07 Mar 2019 18:01:53 -0800
From: akpm@linux-foundation.org
To: broonie@kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org,
 sfr@canb.auug.org.au
Subject:  mmotm 2019-03-07-18-01 uploaded
Message-ID: <20190308020153.uTBnKyNQb%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The mm-of-the-moment snapshot 2019-03-07-18-01 has been uploaded to

   http://www.ozlabs.org/~akpm/mmotm/

mmotm-readme.txt says

README for mm-of-the-moment:

http://www.ozlabs.org/~akpm/mmotm/

This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
more than once a week.

You will need quilt to apply these patches to the latest Linus release (5.x
or 5.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
http://ozlabs.org/~akpm/mmotm/series

The file broken-out.tar.gz contains two datestamp files: .DATE and
.DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
followed by the base kernel version against which this patch series is to
be applied.

This tree is partially included in linux-next.  To see which patches are
included in linux-next, consult the `series' file.  Only the patches
within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included in
linux-next.


A full copy of the full kernel tree with the linux-next and mmotm patches
already applied is available through git within an hour of the mmotm
release.  Individual mmotm releases are tagged.  The master branch always
points to the latest release, so it's constantly rebasing.

http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/



The directory http://www.ozlabs.org/~akpm/mmots/ (mm-of-the-second)
contains daily snapshots of the -mm tree.  It is updated more frequently
than mmotm, and is untested.

A git copy of this tree is available at

	http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/

and use of this tree is similar to
http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/, described above.


This mmotm tree contains the following patches against 5.0:
(patches marked "*" will be included in linux-next)

  origin.patch
* hugetlb-allow-to-free-gigantic-pages-regardless-of-the-configuration.patch
* mm-hugetlb-fix-unsigned-overflow-in-__nr_hugepages_store_common.patch
* kernelh-unconditionally-include-asm-div64h-for-do_div.patch
* taint-fix-debugfs_simple_attrcocci-warnings.patch
* linux-kernelh-drop-the-gcc-33-const-hack-in-roundup.patch
* include-linux-typesh-use-unsigned-int-instead-of-unsigned.patch
* kernel-hung_taskc-fix-sparse-warnings.patch
* kernel-hung_taskc-use-continuously-blocked-time-when-reporting.patch
* kernel-sys-annotate-implicit-fall-through.patch
* spellingtxt-add-more-spellings-to-spellingtxt.patch
* build_bugh-add-wrapper-for-_static_assert.patch
* lib-vsprintfc-move-sizeofstruct-printf_spec-next-to-its-definition.patch
* linux-fsh-move-member-alignment-check-next-to-definition-of-struct-filename.patch
* linux-kernelh-use-short-to-define-ushrt_max-shrt_max-shrt_min.patch
* linux-kernelh-split-_max-and-_min-macros-into-linux-limitsh.patch
* pid-remove-next_pidmap-declaration.patch
* linux-deviceh-use-dynamic_debug_branch-in-dev_dbg_ratelimited.patch
* linux-neth-use-dynamic_debug_branch-in-net_dbg_ratelimited.patch
* linux-printkh-use-dynamic_debug_branch-in-pr_debug_ratelimited.patch
* dynamic_debug-consolidate-define_dynamic_debug_metadata-definitions.patch
* dynamic_debug-dont-duplicate-modname-in-ddebug_add_module.patch
* dynamic_debug-use-pointer-comparison-in-ddebug_remove_module.patch
* dynamic_debug-remove-unused-export_symbols.patch
* dynamic_debug-move-pr_err-from-modulec-to-ddebug_add_module.patch
* dynamic_debug-add-static-inline-stub-for-ddebug_add_module.patch
* dynamic_debug-refactor-dynamic_pr_debug-and-friends.patch
* btrfs-implement-btrfs_debug-in-terms-of-helper-macro.patch
* acpi-use-proper-dynamic_debug_branch-macro.patch
* acpi-remove-unused-__acpi_handle_debug-macro.patch
* acpi-implement-acpi_handle_debug-in-terms-of-_dynamic_func_call.patch
* bitopsh-set_mask_bits-to-return-old-value.patch
* lib-div64-off-by-one-in-shift.patch
* lib-test_ubsan-vla-no-longer-used-in-kernel.patch
* assoc_array-mark-expected-switch-fall-through.patch
* test_firmware-remove-some-dead-code.patch
* checkpatch-verify-spdx-comment-style.patch
* checkpatch-add-some-new-alloc-functions-to-various-tests.patch
* checkpatch-allow-reporting-c99-style-comments.patch
* checkpatch-add-test-for-spdx-license-identifier-on-wrong-line.patch
* epoll-make-sure-all-elements-in-ready-list-are-in-fifo-order.patch
* epoll-unify-awaking-of-wakeup-source-on-ep_poll_callback-path.patch
* epoll-use-rwlock-in-order-to-reduce-ep_poll_callback-contention.patch
* elf-dont-be-afraid-of-overflow.patch
* elf-use-list_for_each_entry.patch
* elf-spread-const-a-little.patch
* init-calibratec-provide-proper-prototype.patch
* autofs-add-ignore-mount-option.patch
* autofs-use-seq_puts-for-simple-strings-in-autofs_show_options.patch
* autofs-clear-o_nonblock-on-the-pipe.patch
* fat-enable-splice_write-to-support-splice-on-o_direct-file.patch
* coredump-replace-opencoded-set_mask_bits.patch
* exec-increase-binprm_buf_size-to-256.patch
* kernel-workqueue-clarify-wq_worker_last_func-caller-requirements.patch
* rapidio-potential-oops-in-riocm_ch_listen.patch
* rapidio-mport_cdev-mark-expected-switch-fall-through.patch
* sysctl-handle-overflow-in-proc_get_long.patch
* sysctl-handle-overflow-for-file-max.patch
* gcov-use-struct_size-in-kzalloc.patch
* configs-get-rid-of-obsolete-config_enable_warn_deprecated.patch
* kernel-configs-use-incbin-directive-to-embed-config_datagz.patch
* kcov-no-need-to-check-return-value-of-debugfs_create-functions.patch
* kcov-convert-kcovrefcount-to-refcount_t.patch
* scripts-gdb-replace-flags-ms_xyz-sb_xyz.patch
* lib-ubsan-default-ubsan_alignment-to-not-set.patch
* initramfs-provide-more-details-in-error-messages.patch
* ipc-annotate-implicit-fall-through.patch
* ipc-semc-replace-kvmalloc-memset-with-kvzalloc-and-use-struct_size.patch
* lib-lzo-tidy-up-ifdefs.patch
* lib-lzo-64-bit-ctz-on-arm64.patch
* lib-lzo-fast-8-byte-copy-on-arm64.patch
* lib-lzo-implement-run-length-encoding.patch
* lib-lzo-separate-lzo-rle-from-lzo.patch
* powerpc-prefer-memblock-apis-returning-virtual-address.patch
* microblaze-prefer-memblock-api-returning-virtual-address.patch
* sh-prefer-memblock-apis-returning-virtual-address.patch
* openrisc-simplify-pte_alloc_one_kernel.patch
* arch-simplify-several-early-memory-allocations.patch
* arm-s390-unicore32-remove-oneliner-wrappers-for-memblock_alloc.patch
* mm-create-the-new-vm_fault_t-type.patch
* maintainers-fix-gta02-entry-and-mark-as-orphan.patch
* unicore32-stop-printing-the-virtual-memory-layout.patch
* mm-remove-duplicate-header.patch
* relay-fix-percpu-annotation-in-struct-rchan.patch
* fork-remove-duplicated-include-from-forkc.patch
* samples-mic-mpssd-remove-duplicate-header.patch
* checkpatch-dont-interpret-stack-dumps-as-commit-ids.patch
* zram-default-to-lzo-rle-instead-of-lzo.patch
* proc-test-with-vsyscall-in-mind.patch
* kasan-fix-variable-tag-set-but-not-used-warning.patch
* debugobjects-move-printk-out-of-db-lock-critical-sections.patch
* ocfs2-clear-zero-in-unaligned-direct-io.patch
* ocfs2-clear-zero-in-unaligned-direct-io-checkpatch-fixes.patch
* ocfs2-wait-for-recovering-done-after-direct-unlock-request.patch
* ocfs2-checkpoint-appending-truncate-log-transaction-before-flushing.patch
* ramfs-support-o_tmpfile.patch
  mm.patch
* memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work.patch
* memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
* psi-introduce-state_mask-to-represent-stalled-psi-states.patch
* psi-rename-psi-fields-in-preparation-for-psi-trigger-addition.patch
* psi-introduce-psi-monitor.patch
* psi-introduce-psi-monitor-fix.patch
* psi-introduce-psi-monitor-fix-fix.patch
* psi-introduce-psi-monitor-fix-3.patch
* mm-add-priority-threshold-to-__purge_vmap_area_lazy.patch
* mm-proportional-memorylowmin-reclaim.patch
* mm-make-memoryemin-the-baseline-for-utilisation-determination.patch
* mm-hmm-use-reference-counting-for-hmm-struct.patch
* mm-hmm-do-not-erase-snapshot-when-a-range-is-invalidated.patch
* mm-hmm-improve-and-rename-hmm_vma_get_pfns-to-hmm_range_snapshot.patch
* mm-hmm-improve-and-rename-hmm_vma_fault-to-hmm_range_fault.patch
* mm-hmm-improve-driver-api-to-work-and-wait-over-a-range.patch
* mm-hmm-improve-driver-api-to-work-and-wait-over-a-range-fix.patch
* mm-hmm-improve-driver-api-to-work-and-wait-over-a-range-fix-fix.patch
* mm-hmm-add-default-fault-flags-to-avoid-the-need-to-pre-fill-pfns-arrays.patch
* mm-hmm-add-an-helper-function-that-fault-pages-and-map-them-to-a-device.patch
* mm-hmm-support-hugetlbfs-snap-shoting-faulting-and-dma-mapping.patch
* mm-hmm-allow-to-mirror-vma-of-a-file-on-a-dax-backed-filesystem.patch
* mm-hmm-allow-to-mirror-vma-of-a-file-on-a-dax-backed-filesystem-fix.patch
* mm-hmm-add-helpers-for-driver-to-safely-take-the-mmap_sem.patch
* mm-add-probe_user_read.patch
* mm-add-probe_user_read-fix.patch
* powerpc-use-probe_user_read.patch
* mm-vmalloc-convert-vmap_lazy_nr-to-atomic_long_t.patch
* mm-shuffle-initial-free-memory-to-improve-memory-side-cache-utilization.patch
* mm-shuffle-initial-free-memory-to-improve-memory-side-cache-utilization-fix.patch
* mm-move-buddy-list-manipulations-into-helpers.patch
* mm-move-buddy-list-manipulations-into-helpers-fix.patch
* mm-move-buddy-list-manipulations-into-helpers-fix2.patch
* mm-maintain-randomization-of-page-free-lists.patch
* mm-maintain-randomization-of-page-free-lists-checkpatch-fixes.patch
* mm-vmscan-remove-unused-lru_pages-argument.patch
* mm-hmm-fix-unused-variable-warnings.patch
* mm-mincore-make-mincore-more-conservative.patch
* mm-use-mm_zero_struct_page-from-sparc-on-all-64b-architectures.patch
* mm-drop-meminit_pfn_in_nid-as-it-is-redundant.patch
* mm-implement-new-zone-specific-memblock-iterator.patch
* mm-initialize-max_order_nr_pages-at-a-time-instead-of-doing-larger-sections.patch
* mm-move-hot-plug-specific-memory-init-into-separate-functions-and-optimize.patch
* mm-add-reserved-flag-setting-to-set_page_links.patch
* mm-use-common-iterator-for-deferred_init_pages-and-deferred_free_pages.patch
* mm-page_alloc-calculate-first_deferred_pfn-directly.patch
* filemap-kill-page_cache_read-usage-in-filemap_fault.patch
* filemap-kill-page_cache_read-usage-in-filemap_fault-fix.patch
* filemap-pass-vm_fault-to-the-mmap-ra-helpers.patch
* filemap-drop-the-mmap_sem-for-all-blocking-operations.patch
* filemap-drop-the-mmap_sem-for-all-blocking-operations-v6.patch
* filemap-drop-the-mmap_sem-for-all-blocking-operations-fix.patch
* filemap-drop-the-mmap_sem-for-all-blocking-operations-checkpatch-fixes.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* info-task-hung-in-generic_file_write_iter.patch
* info-task-hung-in-generic_file_write-fix.patch
* lib-genallocc-export-symbol-addr_in_gen_pool.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr-fix.patch
* checkpatch-fix-something.patch
* ptrace-take-into-account-saved_sigmask-in-ptrace_getsetsigmask.patch
* signal-allow-the-null-signal-in-rt_sigqueueinfo.patch
* test_sysctl-add-tests-for-32-bit-values-written-to-32-bit-integers.patch
* kernel-sysctlc-add-missing-range-check-in-do_proc_dointvec_minmax_conv.patch
* kernel-sysctlc-define-minmax-conv-functions-in-terms-of-non-minmax-versions.patch
* sysctl-return-einval-if-val-violates-minmax.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-16m.patch
* ipc-conserve-sequence-numbers-in-ipcmni_extend-mode.patch
* ipc-do-cyclic-id-allocation-with-ipcmni_extend-mode.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
* pinctrl-fix-pxa2xxc-build-warnings.patch
* scripts-atomic-check-atomicssh-dont-assume-that-scripts-are-executable.patch
* mm-hmm-convert-to-use-vm_fault_t.patch
* mm-hmm-convert-to-use-vm_fault_t-fix.patch
* fs-fs_parser-fix-printk-format-warning.patch
* mm-refactor-readahead-defines-in-mmh.patch
* mm-refactor-readahead-defines-in-mmh-fix.patch
* proc-calculate-end-pointer-for-proc-lookup-at-compile-time.patch
* proc-calculate-end-pointer-for-proc-lookup-at-compile-time-fix.patch
* include-replace-tsk-to-task-in-linux-sched-signalh.patch
* openrisc-prefer-memblock-apis-returning-virtual-address.patch
* powerpc-use-memblock-functions-returning-virtual-address.patch
* powerpc-use-memblock-functions-returning-virtual-address-fix.patch
* memblock-replace-memblock_alloc_baseanywhere-with-memblock_phys_alloc.patch
* memblock-drop-memblock_alloc_base_nid.patch
* memblock-emphasize-that-memblock_alloc_range-returns-a-physical-address.patch
* memblock-memblock_phys_alloc_try_nid-dont-panic.patch
* memblock-memblock_phys_alloc-dont-panic.patch
* memblock-drop-__memblock_alloc_base.patch
* memblock-drop-memblock_alloc_base.patch
* memblock-refactor-internal-allocation-functions.patch
* memblock-refactor-internal-allocation-functions-fix.patch
* memblock-make-memblock_find_in_range_node-and-choose_memblock_flags-static.patch
* arch-use-memblock_alloc-instead-of-memblock_alloc_fromsize-align-0.patch
* arch-dont-memset0-memory-returned-by-memblock_alloc.patch
* ia64-add-checks-for-the-return-value-of-memblock_alloc.patch
* sparc-add-checks-for-the-return-value-of-memblock_alloc.patch
* mm-percpu-add-checks-for-the-return-value-of-memblock_alloc.patch
* init-main-add-checks-for-the-return-value-of-memblock_alloc.patch
* swiotlb-add-checks-for-the-return-value-of-memblock_alloc.patch
* treewide-add-checks-for-the-return-value-of-memblock_alloc.patch
* treewide-add-checks-for-the-return-value-of-memblock_alloc-fix.patch
* treewide-add-checks-for-the-return-value-of-memblock_alloc-fix-2.patch
* treewide-add-checks-for-the-return-value-of-memblock_alloc-fix-3.patch
* treewide-add-checks-for-the-return-value-of-memblock_alloc-fix-3-fix.patch
* memblock-memblock_alloc_try_nid-dont-panic.patch
* memblock-drop-memblock_alloc__nopanic-variants.patch
* memblock-remove-memblock_setclear_region_flags.patch
* memblock-split-checks-whether-a-region-should-be-skipped-to-a-helper-function.patch
* memblock-update-comments-and-kernel-doc.patch
* memblock-update-comments-and-kernel-doc-fix.patch
* of-fix-kmemleak-crash-caused-by-imbalance-in-early-memory-reservation.patch
* of-fix-kmemleak-crash-caused-by-imbalance-in-early-memory-reservation-fix.patch
* mm-rename-ambiguously-named-memorystat-counters-and-functions.patch
* mm-consider-subtrees-in-memoryevents.patch
* openvswitch-convert-to-kvmalloc.patch
* md-convert-to-kvmalloc.patch
* selinux-convert-to-kvmalloc.patch
* generic-radix-trees.patch
* proc-commit-to-genradix.patch
* sctp-convert-to-genradix.patch
* drop-flex_arrays.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch

