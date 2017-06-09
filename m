Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0FD606B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 06:48:52 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m5so25053449pgn.1
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 03:48:52 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e67si678181pfg.409.2017.06.09.03.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 03:48:51 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v11 0/6] Virtio-balloon Enhancement
Date: Fri,  9 Jun 2017 18:41:35 +0800
Message-Id: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com

This patch series enhances the existing virtio-balloon with the following new
features:
1) fast ballooning: transfer ballooned pages between the guest and host in
chunks, instead of one by one; and
2) cmdq: a new virtqueue to send commands between the device and driver.
Currently, it supports commands to report memory stats (replace the old statq
mechanism) and report guest unused pages.

Liang Li (1):
  virtio-balloon: deflate via a page list

Wei Wang (5):
  virtio-balloon: coding format cleanup
  virtio-balloon: VIRTIO_BALLOON_F_PAGE_CHUNKS
  mm: function to offer a page block on the free list
  mm: export symbol of next_zone and first_online_pgdat
  virtio-balloon: VIRTIO_BALLOON_F_CMD_VQ

 drivers/virtio/virtio_balloon.c     | 781 ++++++++++++++++++++++++++++++++----
 drivers/virtio/virtio_ring.c        | 120 +++++-
 include/linux/mm.h                  |   5 +
 include/linux/virtio.h              |   7 +
 include/uapi/linux/virtio_balloon.h |  14 +
 include/uapi/linux/virtio_ring.h    |   3 +
 mm/mmzone.c                         |   2 +
 mm/page_alloc.c                     |  91 +++++
 8 files changed, 950 insertions(+), 73 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
