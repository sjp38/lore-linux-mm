Date: Mon, 9 Jun 2008 22:31:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: 2.6.26-rc5-mm2
Message-Id: <20080609223145.5c9a2878.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: kernel-testers@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc5/2.6.26-rc5-mm2/

- This is a bugfixed version of 2.6.26-rc5-mm1 - mainly to repair a
  vmscan.c bug which would have prevented testing of the other vmscan.c
  bugs^Wchanges.


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



Changes since 2.6.26-rc5-mm1:

 origin.patch
 linux-next.patch
 git-jg-misc.patch
 git-leds.patch
 git-libata-all.patch
 git-battery.patch
 git-parisc.patch
 git-regulator.patch
 git-scsi-misc-fix-scsi_dh-build-errors.patch
 git-unionfs.patch
 git-logfs.patch
 git-unprivileged-mounts.patch
 git-xtensa.patch
 git-orion.patch
 git-pekka.patch

 git trees

+cpusets-provide-another-web-page-url-in-maintainers-file.patch
+maintainers-update-pppoe-maintainer-address.patch
+proc_fsh-move-struct-mm_struct-forward-declaration.patch

 2.6.26 queue

-drivers-net-wireless-iwlwifi-iwl-4965-rsc-config_iwl4965_ht=n-hack.patch

 Unneeded

+drivers-mtd-nand-nandsimc-needs-div64h.patch

 mtd fix

-intel-agp-rewrite-gtt-on-resume-update.patch
-intel-agp-rewrite-gtt-on-resume-update-checkpatch-fixes.patch

 Folded into intel-agp-rewrite-gtt-on-resume.patch

+intel-agp-rewrite-gtt-on-resume-fix.patch
+intel-agp-rewrite-gtt-on-resume-fix-fix.patch

 Fix it some more.

-powerpc-fix-for-oprofile-callgraph-for-power-64-bit-user-apps.patch

 Dropped

-arch-powerpc-platforms-pseries-eeh_driverc-fix-warning-checkpatch-fixes.patch

 Folded into arch-powerpc-platforms-pseries-eeh_driverc-fix-warning.patch

-bluetooth-hci_bcspc-small-cleanups-api-users-fix.patch

 Folded into bluetooth-hci_bcspc-small-cleanups-api-users.patch

-net-sh_eth-add-support-for-renesas-superh-ethernet-checkpatch-fixes.patch

 Folded into net-sh_eth-add-support-for-renesas-superh-ethernet.patch

+selinux-change-handling-of-invalid-classes.patch

 selinux fix

-usb-host-use-get-put_unaligned_-helpers-to-fix-more-potential-unaligned-issues-fix.patch
-usb-host-use-get-put_unaligned_-helpers-to-fix-more-potential-unaligned-issues-fix-2.patch

 Folded into
 usb-host-use-get-put_unaligned_-helpers-to-fix-more-potential-unaligned-issues.patch

-at91sam9-cap9-watchdog-driver.patch

 Dropped

-watchdog-pcwd-clean-up-unlocked_ioctl-usage-fix.patch

 Folded into watchdog-pcwd-clean-up-unlocked_ioctl-usage.patch

-watchdog-wdt501-pci-clean-up-coding-style-and-switch-to-unlocked_ioctl-fix.patch

 Folded into
 watchdog-wdt501-pci-clean-up-coding-style-and-switch-to-unlocked_ioctl.patch

+iwlwifi-remove-iwl4965_ht-config.patch

 wireless fix

+drivers-isdn-sc-ioctlc-add-missing-kfree.patch

 ISDM fix

-mtd-m25p80-fix-bug-atmel-spi-flash-fails-to-be-copied-to-fix-up.patch

 Folded into mtd-m25p80-fix-bug-atmel-spi-flash-fails-to-be-copied-to.patch

-pnpacpi-fix-irq-flag-decoding-comment-fix.patch

 Folded into pnpacpi-fix-irq-flag-decoding.patch

-vfs-utimensat-fix-error-checking-for-utime_nowutime_omit-case-cleanup.patch

 Folded into
 vfs-utimensat-fix-error-checking-for-utime_nowutime_omit-case.patch

-jbd-strictly-check-for-write-errors-on-data-buffers.patch
-jbd-ordered-data-integrity-fix.patch
-jbd-abort-when-failed-to-log-metadata-buffers.patch
-jbd-fix-error-handling-for-checkpoint-io.patch
-ext3-abort-ext3-if-the-journal-has-aborted.patch
-ext3-abort-ext3-if-the-journal-has-aborted-warning-fix.patch

 Dropped

+memrlimit-add-memrlimit-controller-accounting-and-control-fix.patch

 Fix memrlimit-add-memrlimit-controller-accounting-and-control.patch

+memstick-use-fully-asynchronous-request-processing-fix.patch

 Folded into memstick-use-fully-asynchronous-request-processing.patch

-x86-lockless-get_user_pages_fast-fix-2-fix.patch

 Folded into other patches

+mm-speculative-page-references-fix-fix.patch

 Fix mm-speculative-page-references-fix.patch

+reiser4-tree_lock-fixes-fix.patch

 More reiser4 repairs


1354 commits in 931 patch files

All patches:

ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc5/2.6.26-rc5-mm2/patch-list


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
