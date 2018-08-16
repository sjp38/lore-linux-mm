Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE0956B0005
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 04:19:14 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id q2-v6so2293780plh.12
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 01:19:14 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id t7-v6si21504807pgp.18.2018.08.16.01.19.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 01:19:13 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v4 0/3] virtio-balloon: some improvements
Date: Thu, 16 Aug 2018 15:50:55 +0800
Message-Id: <1534405858-27085-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, penguin-kernel@I-love.SAKURA.ne.jp
Cc: wei.w.wang@intel.com

This series is split from the "Virtio-balloon: support free page
reporting" series to make some improvements.

ChangeLog:
v3->v4:
- use kzalloc to allocate the vb struct so that we don't need to zero
  initialize each field one by one later;
- also remove vb->shrinker.batch = 0, which is not needed now.
v2->v3:
- shrink the balloon pages according to the amount requested by the
  claimer, instead of using a user specified number;
v1->v2:
- register the shrinker when VIRTIO_BALLOON_F_DEFLATE_ON_OOM is
  negotiated.

Wei Wang (3):
  virtio-balloon: remove BUG() in init_vqs
  virtio-balloon: kzalloc the vb struct
  virtio_balloon: replace oom notifier with shrinker

 drivers/virtio/virtio_balloon.c | 125 +++++++++++++++++++++-------------------
 1 file changed, 67 insertions(+), 58 deletions(-)

-- 
2.7.4
