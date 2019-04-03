Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D66AC10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 00:17:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDE9F206C0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 00:17:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDE9F206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A7EB6B0269; Tue,  2 Apr 2019 20:17:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 156C36B026B; Tue,  2 Apr 2019 20:17:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0499E6B026D; Tue,  2 Apr 2019 20:17:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA5D46B0269
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 20:17:28 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 33so10977830pgv.17
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 17:17:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :subject:message-id:user-agent;
        bh=vMNx0paOhzgraR9LH0YynF0NeTMX15crs7vuUYBfu/A=;
        b=Gb9vrCyvWETb2xe3AeA+o4qEhhXxRdcR1hNmhdGTGQmbcvntcgksKRUGNIDs7Q1nLS
         DHVLcp470AUN4xPqQVsTLFRvhaj4CearqIlC3f8bgHlPS2bo69SS87flxN5S+ZG7JwsI
         xsnJEHGM2ny34Adf/1a7yGO4O08s+KBQZ12Rzh6qjpGD2wz/UIBEiSnvI6+9nqJkxrP9
         8GCb/Sz6pAh6FcwazPLr+bdzyZIFkzbSjqTxjrH2PE5sAnA9hzY/TuBlpGqERnXmNaJv
         aMju1cmwiGlAtI2ZKAYQJSgf9euqHK+4iHLdTMyaKKuzOu7C98IEOmyFrZuZAfXzwqxo
         gSjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAXVqcOBjdLaFDjeUE5Y/M+70l7MYfzBjDpLp824RFMbILogVV2m
	vfRZaH85p4xFtSkiox65ptwBd6jCkKxo5uULcaV7k/aKATFnQ332PkpOXqG+lHlGCK+XRdFt3+Y
	yRHkyxJ9V+YWu5EZkJUleQ8AS+jC4RAxBeVYyeZg0MGol2+yfFCwhWP9J7etYW6Qv9Q==
X-Received: by 2002:a63:4e64:: with SMTP id o36mr68186916pgl.213.1554250648219;
        Tue, 02 Apr 2019 17:17:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1VRgmhwXzGyqoZNJ9lnEyDdtVxENRVN64nJw3g63aGPc/v5nJkbkeGw3/w1wB3XYZO7F6
X-Received: by 2002:a63:4e64:: with SMTP id o36mr68186784pgl.213.1554250646689;
        Tue, 02 Apr 2019 17:17:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554250646; cv=none;
        d=google.com; s=arc-20160816;
        b=Lms4Il+iWAcXxQQAODNFbGB3hW7qd4qa0ZX4dgvRwDxva3/IeTdDYnuHyAY/0vuBk3
         aCsSMxv//UBiXS5L9NT2djdGk7htOsKFlsvvtMRRL790QFIwug2UIdI5lQoRQWl7D5+T
         fFOcokvWFjVq0WYY+tH1ftiM1Fx7Ni4hH1djVZD3u/fVAEn+yy5zZ9Tk0wLVtVFIgBlL
         R8LiHhwyHHyXewsiEhXxMm6fdj34oKmAtSoSPiH96d+wHqHM+Q6KzYsHQJy4njGGFugS
         VsmSyBWOMq4CJ7skaUdHgIZRi2foU6N27wy00PY2tLeXv0KQ3sUXn2RSaibj3kEoDqIA
         1EYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:subject:to:from:date;
        bh=vMNx0paOhzgraR9LH0YynF0NeTMX15crs7vuUYBfu/A=;
        b=DbBwH+vODkta7qKh4rYKm2iKU9b6wy6fcykDZ0rsTBcuy+hbJh3zZef6H2LkY33zFH
         ZtZPNn/9+uMBpaUiI9gYet8vo9SS4ToBCIbaebAnI6o1Ybqen5nYxhyXRUus4KdU3oWn
         i4EsLUzt18HRdGRFyEJpVdGyudjViOeZ/ucYJDNmKLfQeysATIYfvDvpBksZDpQXtR4D
         ne736iPgn4BxORI8b8CZLqUhQi8tBmHhZ9Nol9lFbV6kV6KDls7PyYgWaHLGLCXdQy8t
         wsOAP1izOs4HvNqD3nqbAWrnWU2A3QZp9OoyEy9mZMDtMmybr53nsU4NyGrckWL4zAnE
         7cxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cn16si12936382plb.174.2019.04.02.17.17.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 17:17:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id B9AF2DAB;
	Wed,  3 Apr 2019 00:17:25 +0000 (UTC)
Date: Tue, 02 Apr 2019 17:17:24 -0700
From: akpm@linux-foundation.org
To: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au,
 linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 mm-commits@vger.kernel.org
Subject:  mmotm 2019-04-02-17-16 uploaded
Message-ID: <20190403001724.OGyls%akpm@linux-foundation.org>
User-Agent: s-nail v14.9.10
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The mm-of-the-moment snapshot 2019-04-02-17-16 has been uploaded to

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


This mmotm tree contains the following patches against 5.1-rc3:
(patches marked "*" will be included in linux-next)

  origin.patch
* checkpatch-dont-interpret-stack-dumps-as-commit-ids.patch
* lib-stringc-implement-a-basic-bcmp.patch
* kmemleak-powerpc-skip-scanning-holes-in-the-bss-section.patch
* bitrev-fix-constant-bitrev.patch
* lib-lzo-fix-bugs-for-very-short-or-empty-input.patch
* mm-fix-vm_fault_t-cast-in-vm_fault_get_hindex.patch
* correct-zone-boundary-handling-when-resetting-pageblock-skip-hints.patch
* hugetlbfs-fix-memory-leak-for-resv_map.patch
* mm-add-sys-kernel-slab-cache-cache_dma32.patch
* mm-compaction-abort-search-if-isolation-fails-v2.patch
* coredump-fix-race-condition-between-mmget_not_zero-get_task_mm-and-core-dumping.patch
* userfaultfd-use-rcu-to-free-the-task-struct-when-fork-fails.patch
* mm-fix-modifying-of-page-protection-by-insert_pfn_pmd.patch
* psi-clarify-the-units-used-in-pressure-files.patch
* writeback-use-exact-memcg-dirty-counts.patch
* maintainers-fix-bad-pattern-in-arm-nuvoton-npcm.patch
* maintainers-add-maintainer-and-replacing-reviewer-arm-nuvoton-npcm.patch
* sh-fix-multiple-function-definition-build-errors.patch
* scripts-spellingtxt-add-more-typos-to-spellingtxt-and-sort.patch
* arch-sh-boards-mach-dreamcast-irqc-remove-duplicate-header.patch
* debugobjects-move-printk-out-of-db-lock-critical-sections.patch
* ocfs2-use-common-file-type-conversion.patch
* ocfs2-clear-zero-in-unaligned-direct-io.patch
* ocfs2-clear-zero-in-unaligned-direct-io-checkpatch-fixes.patch
* ocfs2-wait-for-recovering-done-after-direct-unlock-request.patch
* ocfs2-checkpoint-appending-truncate-log-transaction-before-flushing.patch
* ramfs-support-o_tmpfile.patch
  mm.patch
* list-add-function-list_rotate_to_front.patch
* slob-respect-list_head-abstraction-layer.patch
* slob-use-slab_list-instead-of-lru.patch
* slob-only-use-list-functions-when-safe-to-do-so.patch
* slub-add-comments-to-endif-pre-processor-macros.patch
* slub-use-slab_list-instead-of-lru.patch
* slab-use-slab_list-instead-of-lru.patch
* mm-remove-stale-comment-from-page-struct.patch
* slub-remove-useless-kmem_cache_debug-before-remove_full.patch
* mm-slab-remove-unneed-check-in-cpuup_canceled.patch
* slub-update-the-comment-about-slab-frozen.patch
* mm-vmscan-drop-zone-id-from-kswapd-tracepoints.patch
* mm-cma_debugc-fix-the-break-condition-in-cma_maxchunk_get.patch
* userfaultfd-sysctl-add-vmunprivileged_userfaultfd.patch
* userfaultfd-sysctl-add-vmunprivileged_userfaultfd-fix.patch
* page-cache-store-only-head-pages-in-i_pages.patch
* page-cache-store-only-head-pages-in-i_pages-fix.patch
* mm-page_alloc-disallow-__gfp_comp-in-alloc_pages_exact.patch
* mm-move-recent_rotated-pages-calculation-to-shrink_inactive_list.patch
* mm-move-nr_deactivate-accounting-to-shrink_active_list.patch
* mm-move-nr_deactivate-accounting-to-shrink_active_list-fix.patch
* mm-remove-pages_to_free-argument-of-move_active_pages_to_lru.patch
* mm-generalize-putback-scan-functions.patch
* mm-gup-replace-get_user_pages_longterm-with-foll_longterm.patch
* mm-gup-change-write-parameter-to-flags-in-fast-walk.patch
* mm-gup-change-gup-fast-to-use-flags-rather-than-a-write-bool.patch
* mm-gup-add-foll_longterm-capability-to-gup-fast.patch
* ib-hfi1-use-the-new-foll_longterm-flag-to-get_user_pages_fast.patch
* ib-qib-use-the-new-foll_longterm-flag-to-get_user_pages_fast.patch
* ib-mthca-use-the-new-foll_longterm-flag-to-get_user_pages_fast.patch
* mmmemory_hotplug-unlock-1gb-hugetlb-on-x86_64.patch
* mmmemory_hotplug-drop-redundant-hugepage_migration_supported-check.patch
* mm-memory_hotplug-fix-the-wrong-usage-of-n_high_memory.patch
* mm-compaction-fix-an-undefined-behaviour.patch
* mm-compaction-fix-an-undefined-behaviour-fix.patch
* mm-cma-fix-the-bitmap-status-to-show-failed-allocation-reason.patch
* mm-compaction-show-gfp-flag-names-in-try_to_compact_pages-tracepoint.patch
* mm-compaction-some-tracepoints-should-be-defined-only-when-config_compaction-is-set.patch
* mm-change-mm_update_next_owner-to-update-mm-owner-with-write_once.patch
* mm-isolation-remove-redundant-pfn_valid_within-in-__first_valid_page.patch
* mm-vmscan-add-tracepoints-for-node-reclaim.patch
* mm-memcontrol-track-lru-counts-in-the-vmstats-array.patch
* mm-memcontrol-replace-zone-summing-with-lruvec_page_state.patch
* mm-memcontrol-replace-node-summing-with-memcg_page_state.patch
* mm-memcontrol-push-down-mem_cgroup_node_nr_lru_pages.patch
* mm-memcontrol-push-down-mem_cgroup_nr_lru_pages.patch
* mm-memcontrol-quarantine-the-mem_cgroup_nr_lru_pages-api.patch
* mm-cma-fix-crash-on-cma-allocation-if-bitmap-allocation-fails.patch
* initramfs-free-initrd-memory-if-opening-initrdimage-fails.patch
* initramfs-cleanup-initrd-freeing.patch
* initramfs-factor-out-a-helper-to-populate-the-initrd-image.patch
* initramfs-cleanup-populate_rootfs.patch
* initramfs-cleanup-populate_rootfs-fix.patch
* initramfs-move-the-legacy-keepinitrd-parameter-to-core-code.patch
* initramfs-proide-a-generic-free_initrd_mem-implementation.patch
* initramfs-poison-freed-initrd-memory.patch
* init-provide-a-generic-free_initmem-implementation.patch
* hexagon-switch-over-to-generic-free_initmem.patch
* init-free_initmem-poison-freed-init-memory.patch
* riscv-switch-over-to-generic-free_initmem.patch
* sh-advertise-gigantic-page-support.patch
* sparc-advertise-gigantic-page-support.patch
* mm-simplify-memory_isolation-compaction-cma-into-contig_alloc.patch
* hugetlb-allow-to-free-gigantic-pages-regardless-of-the-configuration.patch
* mm-introduce-put_user_page-placeholder-versions.patch
* mm-page_mkclean-vs-madv_dontneed-race.patch
* mm-vmscan-drop-may_writepage-and-classzone_idx-from-direct-reclaim-begin-template.patch
* mem-hotplug-fix-node-spanned-pages-when-we-have-a-node-with-only-zone_movable.patch
* hugetlbfs-fix-potential-over-underflow-setting-node-specific-nr_hugepages.patch
* mm-hugetlb-get-rid-of-nodemask_alloc.patch
* mm-__pagevec_lru_add_fn-typo-fix.patch
* mm-balloon-drop-unused-function-stubs.patch
* mm-sparse-clean-up-the-obsolete-code-comment.patch
* drivers-base-memoryc-clean-up-relicts-in-function-parameters.patch
* huegtlbfs-on-restore-reserve-error-path-retain-subpool-reservation.patch
* hugetlb-use-same-fault-hash-key-for-shared-and-private-mappings.patch
* memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work.patch
* memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
* psi-introduce-state_mask-to-represent-stalled-psi-states.patch
* psi-make-psi_enable-static.patch
* psi-rename-psi-fields-in-preparation-for-psi-trigger-addition.patch
* psi-rename-psi-fields-in-preparation-for-psi-trigger-addition-v6.patch
* psi-split-update_stats-into-parts.patch
* psi-track-changed-states.patch
* refactor-header-includes-to-allow-kthreadh-inclusion-in-psi_typesh.patch
* psi-introduce-psi-monitor.patch
* mm-add-priority-threshold-to-__purge_vmap_area_lazy.patch
* mm-vmap-keep-track-of-free-blocks-for-vmap-allocation.patch
* mm-vmap-keep-track-of-free-blocks-for-vmap-allocation-v3.patch
* mm-vmap-add-debug_augment_propagate_check-macro.patch
* mm-vmap-add-debug_augment_lowest_match_check-macro.patch
* mm-proportional-memorylowmin-reclaim.patch
* mm-make-memoryemin-the-baseline-for-utilisation-determination.patch
* mm-make-memoryemin-the-baseline-for-utilisation-determination-fix.patch
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
* mm-mincore-make-mincore-more-conservative.patch
* mm-mincore-make-mincore-more-conservative-v2.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* info-task-hung-in-generic_file_write_iter.patch
* info-task-hung-in-generic_file_write-fix.patch
* fs-select-avoid-clang-stack-usage-warning.patch
* kdb-get-rid-of-broken-attempt-to-print-ccversion-in-kdb-summary.patch
* remove-spdx-with-linux-syscall-note-from-kernel-space-headers.patch
* notifiers-double-register-detection.patch
* lib-bitmapc-remove-unused-export_symbols.patch
* lib-bitmapc-guard-exotic-bitmap-functions-by-config_numa.patch
* lib-genallocc-export-symbol-addr_in_gen_pool.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr-fix.patch
* lib-plist-rename-debug_pi_list-to-debug_plist.patch
* lib-sort-make-swap-functions-more-generic.patch
* lib-sort-use-more-efficient-bottom-up-heapsort-variant.patch
* lib-sort-avoid-indirect-calls-to-built-in-swap.patch
* lib-list_sort-simplify-and-remove-max_list_length_bits.patch
* lib-list_sort-optimize-number-of-calls-to-comparison-function.patch
* bitmap_parselist-dont-calculate-length-of-the-input-string.patch
* bitmap_parselist-move-non-parser-logic-to-helpers.patch
* bitmap_parselist-move-non-parser-logic-to-helpers-fix.patch
* bitmap_parselist-rework-input-string-parser.patch
* lib-test_bitmap-switch-test_bitmap_parselist-to-ktime_get.patch
* lib-test_bitmap-add-testcases-for-bitmap_parselist.patch
* lib-test_bitmap-add-tests-for-bitmap_parselist_user.patch
* lib-move-mathematic-helpers-to-separate-folder.patch
* lib-math-move-int_pow-from-pwm_blc-for-wider-use.patch
* lib-fix-possible-incorrect-result-from-rational-fractions-helper.patch
* checkpatch-fix-something.patch
* fs-binfmt_elfc-remove-unneeded-initialization-of-mm-start_stack.patch
* elf-make-scope-of-pos-variable-smaller.patch
* elf-free-pt_interp-filename-asap.patch
* elf-free-pt_interp-filename-asap-fix.patch
* elf-delete-trailing-return-in-functions-returning-void.patch
* autofs-fix-some-word-usage-odities-in-autofstxt.patch
* autofs-update-autofstxt-for-strictexpire-mount-option.patch
* autofs-update-autofs_exp_leaves-description.patch
* autofs-update-mount-control-expire-desription-with-autofs_exp_forced.patch
* autofs-add-description-of-ignore-pseudo-mount-option.patch
* signal-annotate-implicit-fall-through.patch
* rapidio-fix-a-null-pointer-derefenrece-when-create_workqueue-fails.patch
* sysctl-return-einval-if-val-violates-minmax.patch
* convert-struct-pid-count-to-refcount_t.patch
* convert-struct-pid-count-to-refcount_t-fix.patch
* eventfd-prepare-id-to-userspace-via-fdinfo.patch
* gcov-clang-move-common-gcc-code-into-gcc_basec.patch
* gcov-clang-support.patch
* gcov-clang-support-fix.patch
* gcov-docs-add-a-note-on-gcc-vs-clang-differences.patch
* pps-descriptor-based-gpio.patch
* dt-bindings-pps-pps-gpio-pps-echo-implementation.patch
* pps-pps-gpio-pps-echo-implementation.patch
* scripts-gdb-find-vmlinux-where-it-was-before.patch
* scripts-gdb-add-kernel-config-dumping-command.patch
* scripts-gdb-add-kernel-config-dumping-command-v2.patch
* scripts-gdb-add-rb-tree-iterating-utilities.patch
* scripts-gdb-add-rb-tree-iterating-utilities-v2.patch
* scripts-gdb-add-a-timer-list-command.patch
* scripts-gdb-add-a-timer-list-command-v2.patch
* scripts-gdb-silence-pep8-checks.patch
* ipc-prevent-lockup-on-alloc_msg-and-free_msg.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-16m.patch
* ipc-conserve-sequence-numbers-in-ipcmni_extend-mode.patch
* ipc-do-cyclic-id-allocation-for-the-ipc-object.patch
  linux-next.patch
  linux-next-rejects.patch
* pinctrl-fix-pxa2xxc-build-warnings.patch
* scripts-atomic-check-atomicssh-dont-assume-that-scripts-are-executable.patch
* fs-coda-psdevc-remove-duplicate-header.patch
* include-replace-tsk-to-task-in-linux-sched-signalh.patch
* fs-cachefiles-nameic-remove-duplicate-header.patch
* fs-block_devc-remove-duplicate-header.patch
* kernel-resource-use-resource_overlaps-to-simplify-region_intersects.patch
* treewide-replace-include-asm-sizesh-with-include-linux-sizesh.patch
* arch-remove-asm-sizesh-amd-asm-generic-sizesh.patch
* mm-rename-ambiguously-named-memorystat-counters-and-functions.patch
* mm-rename-ambiguously-named-memorystat-counters-and-functions-fix.patch
* mm-consider-subtrees-in-memoryevents.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch

