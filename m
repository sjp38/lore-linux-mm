Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 75DBD6B0389
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 03:13:11 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v190so72485444pfb.5
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 00:13:11 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id k124si4374304pgk.356.2017.03.16.00.13.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 00:13:10 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH kernel v8 0/4] Extend virtio-balloon for fast (de)inflating & fast live migration
Date: Thu, 16 Mar 2017 15:08:43 +0800
Message-Id: <1489648127-37282-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com

This patch series implements two optimizations:
1) transfer pages in chuncks between the guest and host;
2) transfer the guest unused pages to the host so that they
can be skipped to migrate in live migration.

Please read each patch commit log for details.

Changes:
v7->v8:
1) Use only one chunk format, instead of two.
2) re-write the virtio-balloon implementation patch.
3) commit changes
4) patch re-org

Liang Li (4):
  virtio-balloon: deflate via a page list
  virtio-balloon: VIRTIO_BALLOON_F_CHUNK_TRANSFER
  mm: add inerface to offer info about unused pages
  virtio-balloon: VIRTIO_BALLOON_F_HOST_REQ_VQ

 drivers/virtio/virtio_balloon.c     | 533 ++++++++++++++++++++++++++++++++----
 include/linux/mm.h                  |   3 +
 include/uapi/linux/virtio_balloon.h |  31 +++
 mm/page_alloc.c                     | 114 ++++++++
 4 files changed, 635 insertions(+), 46 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
