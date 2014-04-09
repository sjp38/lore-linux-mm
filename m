Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD816B0037
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 11:02:45 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id c11so1265700lbj.12
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 08:02:42 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id am6si1156509lbc.234.2014.04.09.08.02.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Apr 2014 08:02:41 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 0/4] memcg-vs-slab cleanup
Date: Wed, 9 Apr 2014 19:02:29 +0400
Message-ID: <cover.1397054470.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Hi,

This patchset does a bit of cleanup in the kmemcg implementation
hopefully making it more readable.

It requires the following two patches applied on top of the mmotm tree:
  [PATCH -mm v2 1/2] sl[au]b: charge slabs to kmemcg explicitly
  [PATCH -mm v2.2] mm: get rid of __GFP_KMEMCG
(see https://lkml.org/lkml/2014/4/1/100)

Thanks,

Vladimir Davydov (4):
  memcg, slab: do not schedule cache destruction when last page goes
    away
  memcg, slab: merge memcg_{bind,release}_pages to
    memcg_{un}charge_slab
  memcg, slab: change memcg::slab_caches_mutex vs slab_mutex locking
    order
  memcg, slab: remove memcg_cache_params::destroy work

 include/linux/memcontrol.h |   15 +---
 include/linux/slab.h       |    8 +-
 mm/memcontrol.c            |  209 +++++++++++++++++---------------------------
 mm/slab.c                  |    2 -
 mm/slab.h                  |   28 +-----
 mm/slab_common.c           |   22 ++---
 mm/slub.c                  |    2 -
 7 files changed, 94 insertions(+), 192 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
