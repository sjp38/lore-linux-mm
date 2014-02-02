Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 860396B0038
	for <linux-mm@kvack.org>; Sun,  2 Feb 2014 11:34:00 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id l4so4790115lbv.10
        for <linux-mm@kvack.org>; Sun, 02 Feb 2014 08:33:59 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id pc5si8945809lbb.0.2014.02.02.08.33.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Feb 2014 08:33:58 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 0/8] memcg-vs-slab related fixes, improvements, cleanups
Date: Sun, 2 Feb 2014 20:33:45 +0400
Message-ID: <cover.1391356789.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

Hi,

This patch set mostly cleanups memcg slab caches creation/destruction
paths fixing a couple of bugs in the meanwhile. However, it does
introduce some functional changes. First, it changes the memcg caches
naming convention (see patch 2). Second, it reworks sysfs layout for
memcg slub caches (see patch 6).

Comments are appreciated.

Thanks.

Vladimir Davydov (8):
  memcg: export kmemcg cache id via cgroup fs
  memcg, slab: remove cgroup name from memcg cache names
  memcg, slab: never try to merge memcg caches
  memcg, slab: separate memcg vs root cache creation paths
  slub: adjust memcg caches when creating cache alias
  slub: rework sysfs layout for memcg caches
  memcg, slab: unregister cache from memcg before starting to destroy
    it
  memcg, slab: do not destroy children caches if parent has aliases

 include/linux/memcontrol.h |   13 +--
 include/linux/slab.h       |    9 +-
 include/linux/slub_def.h   |    3 +
 mm/memcontrol.c            |   85 +++++++------------
 mm/slab.h                  |   36 ++++----
 mm/slab_common.c           |  194 ++++++++++++++++++++++++++++----------------
 mm/slub.c                  |  121 +++++++++++++++++++++------
 7 files changed, 277 insertions(+), 184 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
