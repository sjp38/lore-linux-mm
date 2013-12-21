Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0ED166B0031
	for <linux-mm@kvack.org>; Sat, 21 Dec 2013 10:54:11 -0500 (EST)
Received: by mail-lb0-f181.google.com with SMTP id q8so1578721lbi.26
        for <linux-mm@kvack.org>; Sat, 21 Dec 2013 07:54:11 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ya3si5271633lbb.161.2013.12.21.07.54.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 21 Dec 2013 07:54:10 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 00/11] kmemcg fixes
Date: Sat, 21 Dec 2013 19:53:51 +0400
Message-ID: <cover.1387640541.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: glommer@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org

This patch-set fixes several bugs here and there in the implementation
of kmem accounting for memory cgroups and makes the code look a bit
clearer.

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
