Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A614F6B000D
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 05:00:44 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w18-v6so2999545plp.3
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 02:00:44 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id h5-v6si4893081pfd.112.2018.08.03.02.00.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 02:00:42 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v3 0/2] virtio-balloon: some improvements
Date: Fri,  3 Aug 2018 16:32:24 +0800
Message-Id: <1533285146-25212-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, penguin-kernel@I-love.SAKURA.ne.jp
Cc: wei.w.wang@intel.com

This series is split from the "Virtio-balloon: support free page
reporting" series to make some improvements.

ChangeLog:
v2->v3:
- shrink the balloon pages according to the amount requested by the
  claimer, instead of using a user specified number;
v1->v2:
- register the shrinker when VIRTIO_BALLOON_F_DEFLATE_ON_OOM is
  negotiated.

Wei Wang (2):
  virtio-balloon: remove BUG() in init_vqs
  virtio_balloon: replace oom notifier with shrinker

 drivers/virtio/virtio_balloon.c | 121 ++++++++++++++++++++++------------------
 1 file changed, 67 insertions(+), 54 deletions(-)

-- 
2.7.4
