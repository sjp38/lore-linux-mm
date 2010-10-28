Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D20D48D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 18:40:08 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp05.in.ibm.com (8.14.4/8.13.1) with ESMTP id o9SMe3Dx029175
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 04:10:03 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9SMe3iV4403228
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 04:10:03 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9SMe3gA009828
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 09:40:03 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 29 Oct 2010 04:10:02 +0530
Message-Id: <20101028224002.32626.13015.sendpatchset@localhost.localdomain>
Subject: [RFC][PATCH 0/3] KVM page cache optimization (v3)
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, qemu-devel@nongnu.org
List-ID: <linux-mm.kvack.org>

This is version 3 of the page cache control patches

From: Balbir Singh <balbir@linux.vnet.ibm.com>

This series has three patches, the first controls
the amount of unmapped page cache usage via a boot
parameter and sysctl. The second patch controls page
and slab cache via the balloon driver. Both the patches
make heavy use of the zone_reclaim() functionality
already present in the kernel.

The last patch in the series is against QEmu to make
the ballooning hint optional.

V2 was posted a long time back (see http://lwn.net/Articles/391293/)
One of the review suggestions was to make the hint optional
(discussed in the community call as well).

I'd appreciate any test results with the patches.

TODO

1. libvirt exploits for optional hint

page-cache-control
balloon-page-cache
provide-memory-hint-during-ballooning

---
 b/balloon.c                       |   18 +++-
 b/balloon.h                       |    4
 b/drivers/virtio/virtio_balloon.c |   17 +++
 b/hmp-commands.hx                 |    7 +
 b/hw/virtio-balloon.c             |   14 ++-
 b/hw/virtio-balloon.h             |    3
 b/include/linux/gfp.h             |    8 +
 b/include/linux/mmzone.h          |    2
 b/include/linux/swap.h            |    3
 b/include/linux/virtio_balloon.h  |    3
 b/mm/page_alloc.c                 |    9 +-
 b/mm/vmscan.c                     |  162 ++++++++++++++++++++++++++++----------
 b/qmp-commands.hx                 |    7 -
 include/linux/swap.h              |    9 --
 mm/page_alloc.c                   |    3
 mm/vmscan.c                       |    2
 16 files changed, 202 insertions(+), 69 deletions(-)


-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
