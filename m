Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5468D6B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 05:52:47 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d12-v6so2656022pgv.12
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 02:52:47 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a61-v6si3476062plc.80.2018.07.27.02.52.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 02:52:46 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v2 0/2] virtio-balloon: some improvements
Date: Fri, 27 Jul 2018 17:24:53 +0800
Message-Id: <1532683495-31974-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org
Cc: wei.w.wang@intel.com

This series is split from the "Virtio-balloon: support free page
reporting" series to make some improvements.

v1->v2 ChangeLog:
- register the shrinker when VIRTIO_BALLOON_F_DEFLATE_ON_OOM is negotiated.

Wei Wang (2):
  virtio-balloon: remove BUG() in init_vqs
  virtio_balloon: replace oom notifier with shrinker

 drivers/virtio/virtio_balloon.c | 125 +++++++++++++++++++++++-----------------
 1 file changed, 72 insertions(+), 53 deletions(-)

-- 
2.7.4
