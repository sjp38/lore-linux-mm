Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id C4CF56B0036
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 12:00:58 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id y13so4644998pdi.15
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 09:00:58 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id bt2si16277711pdb.177.2014.09.22.09.00.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 09:00:57 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v2 0/3] memcg: trivial cleanups in kmemcg core
Date: Mon, 22 Sep 2014 20:00:43 +0400
Message-ID: <cover.1411401021.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch set does exactly the same thing as

https://lkml.org/lkml/2014/9/18/315

but it's commented better (thanks to Michal).

Vladimir Davydov (3):
  memcg: move memcg_{alloc,free}_cache_params to slab_common.c
  memcg: don't call memcg_update_all_caches if new cache id fits
  memcg: move memcg_update_cache_size to slab_common.c

 include/linux/memcontrol.h |   15 -----
 mm/memcontrol.c            |  154 ++++++++++++--------------------------------
 mm/slab_common.c           |   74 ++++++++++++++++++++-
 3 files changed, 111 insertions(+), 132 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
