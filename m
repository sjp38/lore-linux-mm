Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA60C6B0069
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 04:20:58 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e64so13648130wmi.0
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 01:20:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i33si23388wra.310.2017.09.27.01.20.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 01:20:57 -0700 (PDT)
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: [PATCH 0/6] Add kmalloc_array_node() and kcalloc_node()
Date: Wed, 27 Sep 2017 10:20:32 +0200
Message-Id: <20170927082038.3782-1-jthumshirn@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Damien Le Moal <damien.lemoal@wdc.com>, Christoph Hellwig <hch@lst.de>, Johannes Thumshirn <jthumshirn@suse.de>

Our current memeory allocation routines suffer form an API imbalance,
for one we have kmalloc_array() and kcalloc() which check for
overflows in size multiplication and we have kmalloc_node() and
kzalloc_node() which allow for memory allocation on a certain NUMA
node but don't check for eventual overflows.

Johannes Thumshirn (6):
  mm: add kmalloc_array_node and kcalloc_node
  block: use kmalloc_array_node
  IB/qib: use kmalloc_array_node
  IB/rdmavt: use kmalloc_array_node
  mm, mempool: use kmalloc_array_node
  rds: ib: use kmalloc_array_node

 block/blk-mq.c                       |  2 +-
 drivers/infiniband/hw/qib/qib_init.c |  5 +++--
 drivers/infiniband/sw/rdmavt/qp.c    |  2 +-
 include/linux/slab.h                 | 16 ++++++++++++++++
 mm/mempool.c                         |  2 +-
 net/rds/ib_fmr.c                     |  4 ++--
 6 files changed, 24 insertions(+), 7 deletions(-)

-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
