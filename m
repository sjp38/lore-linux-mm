Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id C91A16B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 03:45:15 -0500 (EST)
Received: by mail-la0-f49.google.com with SMTP id er20so9427752lab.8
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 00:45:15 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id dw4si35759264lbc.80.2014.01.06.00.45.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 00:45:14 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RESEND 00/11] kmemcg-fixes
Date: Mon, 6 Jan 2014 12:44:51 +0400
Message-ID: <cover.1388996525.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org

Hi,

This patch-set fixes several bugs here and there in the implementation
of kmem accounting for memory cgroups and hopefully makes the code look
a bit clearer.

Links to discussion threads that led to this patch-set:
http://www.spinics.net/lists/cgroups/msg09512.html
http://www.spinics.net/lists/cgroups/msg09695.html
http://www.spinics.net/lists/cgroups/msg09796.html

Any comments are highly appreciated.

Thanks.

Vladimir Davydov (11):
  slab: cleanup kmem_cache_create_memcg() error handling
  memcg, slab: kmem_cache_create_memcg(): fix memleak on fail path
  memcg, slab: cleanup memcg cache initialization/destruction
  memcg, slab: fix barrier usage when accessing memcg_caches
  memcg: fix possible NULL deref while traversing memcg_slab_caches
    list
  memcg, slab: fix races in per-memcg cache creation/destruction
  memcg: get rid of kmem_cache_dup
  slab: do not panic if we fail to create memcg cache
  memcg, slab: RCU protect memcg_params for root caches
  memcg: remove KMEM_ACCOUNTED_ACTIVATED flag
  memcg: rework memcg_update_kmem_limit synchronization

 include/linux/memcontrol.h |   23 +--
 include/linux/slab.h       |    9 +-
 mm/memcontrol.c            |  405 +++++++++++++++++++++-----------------------
 mm/slab.h                  |   26 ++-
 mm/slab_common.c           |   90 ++++++----
 5 files changed, 292 insertions(+), 261 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
