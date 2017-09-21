Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE066B0038
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 08:55:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b195so5740241wmb.6
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 05:55:46 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j127sor524885wma.70.2017.09.21.05.55.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Sep 2017 05:55:44 -0700 (PDT)
From: =?UTF-8?q?Tom=C3=A1=C5=A1=20Golembiovsk=C3=BD?= <tgolembi@redhat.com>
Subject: [PATCH v2 0/1] linux: Buffers/caches in VirtIO Balloon driver stats
Date: Thu, 21 Sep 2017 14:55:40 +0200
Message-Id: <cover.1505998455.git.tgolembi@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, virtualization@lists.linux-foundation.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org
Cc: Wei Wang <wei.w.wang@intel.com>, Shaohua Li <shli@fb.com>, Huang Ying <ying.huang@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, =?UTF-8?q?Tom=C3=A1=C5=A1=20Golembiovsk=C3=BD?= <tgolembi@redhat.com>

Linux driver part

v2:
- fixed typos

TomA!A! GolembiovskA 1/2  (1):
  virtio_balloon: include buffers and cached memory statistics

 drivers/virtio/virtio_balloon.c     | 11 +++++++++++
 include/uapi/linux/virtio_balloon.h |  4 +++-
 mm/swap_state.c                     |  1 +
 3 files changed, 15 insertions(+), 1 deletion(-)

-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
