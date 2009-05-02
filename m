Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 127C26B003D
	for <linux-mm@kvack.org>; Sat,  2 May 2009 18:15:30 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 0/6] ksm changes
Date: Sun,  3 May 2009 01:16:06 +0300
Message-Id: <1241302572-4366-1-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, hugh@veritas.com, nickpiggin@yahoo.com.au, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

Following patchs touch 4 diffrent areas inside ksm:

1) Patchs 1 - 3: Change the api to be more robust and make more sense.
                 This include:
                     * Limiting the number of memory regions user can
                       register inside ksm per file descriptor that
                       he open.

                     * Reject overlap memory addresses registrations.

                     * change KSM_REMOVE_MEMORY_REGION ioctl to make
                       more sense, untill this patchs user was able
                       to register servel memory regions per file
                       descriptor, but when he called to
                       KSM_REMOVE_MEMORY_REGION, he had no way to tell
                       what memory region he want to remove, as a
                       result each call to KSM_REMOVE_MEMORY_REGION
                       nuked all the regions inside the fd.
                       Now KSM_REMOVE_MEMORY_REGION is working on
                       specific addresses.

2) Patch 4: Use generic helper functions to deal with the vma prot.
            
3) Patch 5: Return ksm to be build on all archs (Now after patch 4,
            ksm shouldnt break any arch).

4) Patch 6: change the miscdevice minor number - lets wait to Alan
            saying he is happy with this change before we apply.

Thanks.

Izik Eidus (6):
  ksm: limiting the num of mem regions user can register per fd.
  ksm: dont allow overlap memory addresses registrations.
  ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
  ksm: change the prot handling to use the generic helper functions
  ksm: build system make it compile for all archs
  ksm: use another miscdevice minor number.

 Documentation/devices.txt  |    1 +
 include/linux/miscdevice.h |    2 +-
 mm/Kconfig                 |    1 -
 mm/ksm.c                   |  112 +++++++++++++++++++++++++++++++++++++-------
 4 files changed, 96 insertions(+), 20 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
