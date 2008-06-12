Date: Wed, 11 Jun 2008 22:59:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: 2.6.26-rc5-mm3
Message-Id: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: kernel-testers@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc5/2.6.26-rc5-mm3/

- This is a bugfixed version of 2.6.26-rc5-mm2, which was a bugfixed
  version of 2.6.26-rc5-mm1.  None of the git trees were repulled for -mm3
  (and nor were they repulled for -mm2).

  The aim here is to get all the stupid bugs out of the way so that some
  serious MM testing can be performed.

- Please perform some serious MM testing.



Boilerplate:

- See the `hot-fixes' directory for any important updates to this patchset.

- To fetch an -mm tree using git, use (for example)

  git-fetch git://git.kernel.org/pub/scm/linux/kernel/git/smurf/linux-trees.git tag v2.6.16-rc2-mm1
  git-checkout -b local-v2.6.16-rc2-mm1 v2.6.16-rc2-mm1

- -mm kernel commit activity can be reviewed by subscribing to the
  mm-commits mailing list.

        echo "subscribe mm-commits" | mail majordomo@vger.kernel.org

- If you hit a bug in -mm and it is not obvious which patch caused it, it is
  most valuable if you can perform a bisection search to identify which patch
  introduced the bug.  Instructions for this process are at

        http://www.zip.com.au/~akpm/linux/patches/stuff/bisecting-mm-trees.txt

  But beware that this process takes some time (around ten rebuilds and
  reboots), so consider reporting the bug first and if we cannot immediately
  identify the faulty patch, then perform the bisection search.

- When reporting bugs, please try to Cc: the relevant maintainer and mailing
  list on any email.

- When reporting bugs in this kernel via email, please also rewrite the
  email Subject: in some manner to reflect the nature of the bug.  Some
  developers filter by Subject: when looking for messages to read.

- Occasional snapshots of the -mm lineup are uploaded to
  ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/mm/ and are announced on
  the mm-commits list.  These probably are at least compilable.

- More-than-daily -mm snapshots may be found at
  http://userweb.kernel.org/~akpm/mmotm/.  These are almost certainly not
  compileable.




Changes since 2.6.26-rc5-mm2:

 origin.patch
 linux-next.patch
 git-jg-misc.patch
 git-leds.patch
 git-libata-all.patch
 git-battery.patch
 git-parisc.patch
 git-regulator.patch
 git-unionfs.patch
 git-logfs.patch
 git-unprivileged-mounts.patch
 git-xtensa.patch
 git-orion.patch
 git-pekka.patch

 git trees

-fsldma-the-mpc8377mds-board-device-tree-node-for-fsldma-driver.patch

 Merged into mainline or a subsystem tree

+capabilities-add-back-dummy-support-for-keepcaps.patch
+cciss-add-new-hardware-support.patch
+cciss-add-new-hardware-support-fix.patch
+cciss-bump-version-to-20-to-reflect-new-hw-support.patch
+kprobes-fix-error-checking-of-batch-registration.patch
+m68knommu-init-coldfire-timer-trr-with-n-1-not-n.patch
+rtc-at32ap700x-fix-bug-in-at32_rtc_readalarm.patch

 2.6.26 queue

-acpi-video-balcklist-fujitsu-lifebook-s6410.patch

 Dropped

-bay-exit-if-notify-handler-cannot-be-installed.patch

 Dropped

-intel-agp-rewrite-gtt-on-resume-fix.patch
-intel-agp-rewrite-gtt-on-resume-fix-fix.patch

 Folded into intel-agp-rewrite-gtt-on-resume.patch

-kbuild-move-non-__kernel__-checking-headers-to-header-y.patch

 Dropped

+8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core-fix.patch

 Unfix
 8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core.patch

+mpc8xxx_wdt-various-renames-mostly-s-mpc83xx-mpc8xxx-g-fix.patch

 Fix mpc8xxx_wdt-various-renames-mostly-s-mpc83xx-mpc8xxx-g.patch

+intel_rng-make-device-not-found-a-warning.patch
+driver-video-cirrusfb-fix-ram-address-printk.patch
+driver-video-cirrusfb-fix-ram-address-printk-fix.patch
+driver-video-cirrusfb-fix-ram-address-printk-fix-fix.patch
+driver-char-generic_nvram-fix-banner.patch
+pagemap-pass-mm-into-pagewalkers.patch
+pagemap-fix-large-pages-in-pagemap.patch
+proc-sysvipc-shm-fix-32-bit-truncation-of-segment-sizes.patch
+console-keyboard-mapping-broken-by-04c71976.patch

 More 2.6.26 queue

+bay-exit-if-notify-handler-cannot-be-installed.patch

 ACPI Bay driver fix

+smc91x-fix-build-error-from-the-smc_get_mac_addr-api-change.patch

 netdev fix

+add-a-helper-function-to-test-if-an-object-is-on-the-stack.patch

 Infrastructure

+hugetlb-introduce-pud_huge-s390-fix.patch

 Fix hugetlb-introduce-pud_huge.patch some more

+kprobes-remove-redundant-config-check.patch
+kprobes-indirectly-call-kprobe_target.patch
+kprobes-add-tests-for-register_kprobes.patch

 kprobers updates

+not-for-merging-pnp-changes-suspend-oops.patch

 Try to debug some pnp problems

+quota-move-function-macros-from-quotah-to-quotaopsh-fix.patch

 Fix quota-move-function-macros-from-quotah-to-quotaopsh.patch some more

+memcg-remove-refcnt-from-page_cgroup-fix-2.patch

 Fix memcg-remove-refcnt-from-page_cgroup-fix.patch

+sgi-xp-eliminate-in-comments.patch
+sgi-xp-use-standard-bitops-macros-and-functions.patch
+sgi-xp-add-jiffies-to-reserved-pages-timestamp-name.patch

 Update SGI XP driver

+dma-mapping-add-the-device-argument-to-dma_mapping_error-b34-fix.patch

 Fix dma-mapping-add-the-device-argument-to-dma_mapping_error.patch som more

+include-linux-aioh-removed-duplicated-include.patch

 AIO cleanup

+kernel-call-constructors-uml-fix-1.patch
+kernel-call-constructors-uml-fix-2.patch

 Fix kernel-call-constructors.patch

+x86-support-1gb-hugepages-with-get_user_pages_lockless.patch

 Wire up x86 large large pages

+mm-speculative-page-references-hugh-fix3.patch

 Fix mm-speculative-page-references.patch som more

 vmscan-move-isolate_lru_page-to-vmscanc.patch
+vmscan-move-isolate_lru_page-to-vmscanc-fix.patch
 vmscan-use-an-indexed-array-for-lru-variables.patch
-vmscan-use-an-array-for-the-lru-pagevecs.patch
+swap-use-an-array-for-the-lru-pagevecs.patch
 vmscan-free-swap-space-on-swap-in-activation.patch
-vmscan-define-page_file_cache-function.patch
+define-page_file_cache-function.patch
 vmscan-split-lru-lists-into-anon-file-sets.patch
 vmscan-second-chance-replacement-for-anonymous-pages.patch
-vmscan-add-some-sanity-checks-to-get_scan_ratio.patch
 vmscan-fix-pagecache-reclaim-referenced-bit-check.patch
 vmscan-add-newly-swapped-in-pages-to-the-inactive-list.patch
-vmscan-more-aggressively-use-lumpy-reclaim.patch
-vmscan-pageflag-helpers-for-configed-out-flags.patch
-vmscan-noreclaim-lru-infrastructure.patch
-vmscan-noreclaim-lru-page-statistics.patch
-vmscan-ramfs-and-ram-disk-pages-are-non-reclaimable.patch
-vmscan-shm_locked-pages-are-non-reclaimable.patch
-vmscan-mlocked-pages-are-non-reclaimable.patch
-vmscan-downgrade-mmap-sem-while-populating-mlocked-regions.patch
-vmscan-handle-mlocked-pages-during-map-remap-unmap.patch
-vmscan-mlocked-pages-statistics.patch
-vmscan-cull-non-reclaimable-pages-in-fault-path.patch
-vmscan-noreclaim-and-mlocked-pages-vm-events.patch
-mm-only-vmscan-noreclaim-lru-scan-sysctl.patch
-vmscan-mlocked-pages-count-attempts-to-free-mlocked-page.patch
-vmscan-noreclaim-lru-and-mlocked-pages-documentation.patch
+more-aggressively-use-lumpy-reclaim.patch
+pageflag-helpers-for-configed-out-flags.patch
+unevictable-lru-infrastructure.patch
+unevictable-lru-page-statistics.patch
+ramfs-and-ram-disk-pages-are-unevictable.patch
+shm_locked-pages-are-unevictable.patch
+mlock-mlocked-pages-are-unevictable.patch
+mlock-mlocked-pages-are-unevictable-fix.patch
+mlock-mlocked-pages-are-unevictable-fix-fix.patch
+mlock-mlocked-pages-are-unevictable-fix-2.patch
+mlock-downgrade-mmap-sem-while-populating-mlocked-regions.patch
+mmap-handle-mlocked-pages-during-map-remap-unmap.patch
+mmap-handle-mlocked-pages-during-map-remap-unmap-cleanup.patch
+vmstat-mlocked-pages-statistics.patch
+swap-cull-unevictable-pages-in-fault-path.patch
+vmstat-unevictable-and-mlocked-pages-vm-events.patch
+vmscan-unevictable-lru-scan-sysctl.patch
+vmscan-unevictable-lru-scan-sysctl-nommu-fix.patch
+mlock-count-attempts-to-free-mlocked-page.patch
+doc-unevictable-lru-and-mlocked-pages-documentation.patch

 New iteration of Rik's page reclaim work

1390 commits in 967 patch files



All patches:

ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc5/2.6.26-rc5-mm3/patch-list


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
