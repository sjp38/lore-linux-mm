Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 02E306B005C
	for <linux-mm@kvack.org>; Sun, 27 Apr 2014 05:04:16 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id c6so4300889lan.30
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 02:04:16 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id oc6si8236897lbb.94.2014.04.27.02.04.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Apr 2014 02:04:15 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 0/6] memcg/kmem: cleanup naming and callflows
Date: Sun, 27 Apr 2014 13:04:02 +0400
Message-ID: <cover.1398587474.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Hi,

In reply to "[PATCH RFC -mm v2 3/3] memcg, slab: simplify
synchronization scheme" Johannes wrote:

> I like this patch, but the API names are confusing. Could we fix up
> that whole thing by any chance?

(see https://lkml.org/lkml/2014/4/18/317)

So this patch set is about cleaning up memcg/kmem naming.

While preparing it I found that some of the ugly-named functions
constituting interface between memcontrol.c and slab_common.c can be
neatly got rid of w/o complicating the code. Quite the contrary, w/o
them call-flows look much simpler, IMO. So the first four patches do not
rename anything actually - they just rework call-flows in kmem cache
creation/destruction and memcg_caches arrays relocations paths. Finally,
patches 5 and 6 clean up the naming.

v1: http://lkml.org/lkml/2014/4/25/254

Changes in v2:
 - move memcg_params allocation/free for per memcg caches to
   slab_common.c, because this way it looks clearer (patch 4)
 - minor changes in function names and comments

Reviews are appreciated.

Thanks,

Vladimir Davydov (6):
  memcg: get rid of memcg_create_cache_name
  memcg: allocate memcg_caches array on first per memcg cache creation
  memcg: cleanup memcg_caches arrays relocation path
  memcg: get rid of memcg_{alloc,free}_cache_params
  memcg: cleanup kmem cache creation/destruction functions naming
  memcg: cleanup kmem_id-related naming

 include/linux/memcontrol.h |   40 +----
 include/linux/slab.h       |   11 +-
 mm/memcontrol.c            |  396 +++++++++++++++++++-------------------------
 mm/slab.c                  |    4 +-
 mm/slab.h                  |   24 ++-
 mm/slab_common.c           |  148 ++++++++++++-----
 mm/slub.c                  |   10 +-
 7 files changed, 314 insertions(+), 319 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
