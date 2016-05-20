Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id B47E66B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 21:02:18 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gw7so137242183pac.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 18:02:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u2si23694511pan.192.2016.05.19.18.02.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 18:02:17 -0700 (PDT)
Date: Thu, 19 May 2016 18:02:16 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2016-05-19-18-01 uploaded
Message-ID: <573e6218.YQH2A+YBUHmPqyvU%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-05-19-18-01 has been uploaded to

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
  fsnotify-avoid-spurious-emfile-errors-from-inotify_init.patch
  time-add-missing-implementation-for-timespec64_add_safe.patch
  fs-poll-select-recvmmsg-use-timespec64-for-timeout-events.patch
  time-remove-timespec_add_safe.patch
  scripts-decode_stacktracesh-handle-symbols-in-modules.patch
  scripts-spellingtxt-add-fimware-misspelling.patch
  scripts-bloat-o-meter-print-percent-change.patch
  debugobjects-make-fixup-functions-return-bool-instead-of-int.patch
  debugobjects-correct-the-usage-of-fixup-call-results.patch
  workqueue-update-debugobjects-fixup-callbacks-return-type.patch
  timer-update-debugobjects-fixup-callbacks-return-type.patch
  rcu-update-debugobjects-fixup-callbacks-return-type.patch
  percpu_counter-update-debugobjects-fixup-callbacks-return-type.patch
  documentation-update-debugobjects-doc.patch
  debugobjects-insulate-non-fixup-logic-related-to-static-obj-from-fixup-callbacks.patch
  ocfs2-error-code-comments-and-amendments-the-comment-of-ocfs2_extended_slot-should-be-0x08.patch
  ocfs2-clean-up-an-unused-variable-wants_rotate-in-ocfs2_truncate_rec.patch
  ocfs2-clean-up-unused-parameter-count-in-o2hb_read_block_input.patch
  ocfs2-clean-up-an-unuseful-goto-in-ocfs2_put_slot-function.patch
  padata-removed-unused-code.patch
  kernel-padata-hide-unused-functions.patch
  mm-slab-fix-the-theoretical-race-by-holding-proper-lock.patch
  mm-slab-remove-bad_alien_magic-again.patch
  mm-slab-drain-the-free-slab-as-much-as-possible.patch
  mm-slab-factor-out-kmem_cache_node-initialization-code.patch
  mm-slab-clean-up-kmem_cache_node-setup.patch
  mm-slab-dont-keep-free-slabs-if-free_objects-exceeds-free_limit.patch
  mm-slab-racy-access-modify-the-slab-color.patch
  mm-slab-make-cache_grow-handle-the-page-allocated-on-arbitrary-node.patch
  mm-slab-separate-cache_grow-to-two-parts.patch
  mm-slab-refill-cpu-cache-through-a-new-slab-without-holding-a-node-lock.patch
  mm-slab-lockless-decision-to-grow-cache.patch
  mm-slub-replace-kick_all_cpus_sync-with-synchronize_sched-in-kmem_cache_shrink.patch
  mm-slab-freelist-randomization-v4.patch
  mm-slab-remove-zone_dma_flag.patch
  mm-slubc-fix-sysfs-filename-in-comment.patch
  mm-page_ref-use-page_ref-helper-instead-of-direct-modification-of-_count.patch
  mm-rename-_count-field-of-the-struct-page-to-_refcount.patch
  compilerh-add-support-for-malloc-attribute.patch
  include-linux-apply-__malloc-attribute.patch
  include-linux-nodemaskh-create-next_node_in-helper.patch
  mm-hugetlb-optimize-minimum-size-min_size-accounting.patch
  mm-hugetlb-introduce-hugetlb_bad_size.patch
  arm64-mm-use-hugetlb_bad_size.patch
  metag-mm-use-hugetlb_bad_size.patch
  powerpc-mm-use-hugetlb_bad_size.patch
  tile-mm-use-hugetlb_bad_size.patch
  x86-mm-use-hugetlb_bad_size.patch
  mm-hugetlb-is_vm_hugetlb_page-can-be-boolean.patch
  mm-memory_hotplug-is_mem_section_removable-can-be-boolean.patch
  mm-vmalloc-is_vmalloc_addr-can-be-boolean.patch
  mm-mempolicy-vma_migratable-can-be-boolean.patch
  mm-memcontrolc-mem_cgroup_select_victim_node-clarify-comment.patch
  mm-page_alloc-remove-useless-parameter-of-__free_pages_boot_core.patch
  mm-hugetlbc-use-first_memory_node.patch
  mm-mempolicyc-offset_il_node-document-and-clarify.patch
  mm-rmap-replace-bug_onanon_vma-degree-with-vm_warn_on.patch
  mm-compaction-wrap-calculating-first-and-last-pfn-of-pageblock.patch
  mm-compaction-reduce-spurious-pcplist-drains.patch
  mm-compaction-skip-blocks-where-isolation-fails-in-async-direct-compaction.patch
  mm-highmem-simplify-is_highmem.patch
  mm-uninline-page_mapped.patch
  mm-hugetlb-add-same-zone-check-in-pfn_range_valid_gigantic.patch
  mm-memory_hotplug-add-comment-to-some-functions-related-to-memory-hotplug.patch
  mm-vmstat-add-zone-range-overlapping-check.patch
  mm-page_owner-add-zone-range-overlapping-check.patch
  power-add-zone-range-overlapping-check.patch
  mm-writeback-correct-dirty-page-calculation-for-highmem.patch
  mm-page_alloc-correct-highmem-memory-statistics.patch
  mm-highmem-make-nr_free_highpages-handles-all-highmem-zones-by-itself.patch
  mm-vmstat-make-node_page_state-handles-all-zones-by-itself.patch
  mm-mmap-kill-hook-arch_rebalance_pgtables.patch
  mm-update_lru_size-warn-and-reset-bad-lru_size.patch
  mm-update_lru_size-do-the-__mod_zone_page_state.patch
  mm-use-__setpageswapbacked-and-dont-clearpageswapbacked.patch
  tmpfs-preliminary-minor-tidyups.patch
  tmpfs-mem_cgroup-charge-fault-to-vm_mm-not-current-mm.patch
  mm-proc-sys-vm-stat_refresh-to-force-vmstat-update.patch
  huge-mm-move_huge_pmd-does-not-need-new_vma.patch
  huge-pagecache-extend-mremap-pmd-rmap-lockout-to-files.patch
  arch-fix-has_transparent_hugepage.patch
  memory_hotplug-introduce-config_memory_hotplug_default_online.patch
  memory_hotplug-introduce-memhp_default_state=-command-line-parameter.patch
  mm-oom-move-gfp_nofs-check-to-out_of_memory.patch
  oom-oom_reaper-try-to-reap-tasks-which-skip-regular-oom-killer-path.patch
  mm-oom_reaper-clear-tif_memdie-for-all-tasks-queued-for-oom_reaper.patch
  mm-page_alloc-only-check-pagecompound-for-high-order-pages.patch
  mm-page_alloc-use-new-pageanonhead-helper-in-the-free-page-fast-path.patch
  mm-page_alloc-reduce-branches-in-zone_statistics.patch
  mm-page_alloc-inline-zone_statistics.patch
  mm-page_alloc-inline-the-fast-path-of-the-zonelist-iterator.patch
  mm-page_alloc-use-__dec_zone_state-for-order-0-page-allocation.patch
  mm-page_alloc-avoid-unnecessary-zone-lookups-during-pageblock-operations.patch
  mm-page_alloc-convert-alloc_flags-to-unsigned.patch
  mm-page_alloc-convert-nr_fair_skipped-to-bool.patch
  mm-page_alloc-remove-unnecessary-local-variable-in-get_page_from_freelist.patch
  mm-page_alloc-remove-unnecessary-initialisation-in-get_page_from_freelist.patch
  mm-page_alloc-remove-unnecessary-initialisation-from-__alloc_pages_nodemask.patch
  mm-page_alloc-simplify-last-cpupid-reset.patch
  mm-page_alloc-move-__gfp_hardwall-modifications-out-of-the-fastpath.patch
  mm-page_alloc-check-once-if-a-zone-has-isolated-pageblocks.patch
  mm-page_alloc-shorten-the-page-allocator-fast-path.patch
  mm-page_alloc-reduce-cost-of-fair-zone-allocation-policy-retry.patch
  mm-page_alloc-shortcut-watermark-checks-for-order-0-pages.patch
  mm-page_alloc-avoid-looking-up-the-first-zone-in-a-zonelist-twice.patch
  mm-page_alloc-remove-field-from-alloc_context.patch
  mm-page_alloc-check-multiple-page-fields-with-a-single-branch.patch
  mm-page_alloc-un-inline-the-bad-part-of-free_pages_check.patch
  mm-page_alloc-pull-out-side-effects-from-free_pages_check.patch
  mm-page_alloc-remove-unnecessary-variable-from-free_pcppages_bulk.patch
  mm-page_alloc-inline-pageblock-lookup-in-page-free-fast-paths.patch
  cpuset-use-static-key-better-and-convert-to-new-api.patch
  mm-page_alloc-defer-debugging-checks-of-freed-pages-until-a-pcp-drain.patch
  mm-page_alloc-defer-debugging-checks-of-pages-allocated-from-the-pcp.patch
  mm-page_alloc-dont-duplicate-code-in-free_pcp_prepare.patch
  mm-page_alloc-uninline-the-bad-page-part-of-check_new_page.patch
  mm-page_alloc-restore-the-original-nodemask-if-the-fast-path-allocation-failed.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
