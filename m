Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id D079D6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 10:54:46 -0500 (EST)
Received: by mail-la0-f54.google.com with SMTP id y1so5667854lam.27
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 07:54:46 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id b5si10641399lbp.178.2014.02.03.07.54.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Feb 2014 07:54:44 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v2 0/7] memcg-vs-slab related fixes, improvements, cleanups
Date: Mon, 3 Feb 2014 19:54:35 +0400
Message-ID: <cover.1391441746.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

Hi,

This patch set mostly cleanups memcg slab caches creation/destruction
paths fixing a couple of bugs in the meanwhile. The only serious change
it introduces is a rework of the sysfs layout for memcg slub caches (see
patch 7).

Changes in v2:
 - do not remove cgroup name part from memcg cache names
 - do not export memcg cache id to userspace

Comments are appreciated.

Thanks.

Vladimir Davydov (7):
  memcg, slab: never try to merge memcg caches
  memcg, slab: cleanup memcg cache name creation
  memcg, slab: separate memcg vs root cache creation paths
  memcg, slab: unregister cache from memcg before starting to destroy
    it
  memcg, slab: do not destroy children caches if parent has aliases
  slub: adjust memcg caches when creating cache alias
  slub: rework sysfs layout for memcg caches

 include/linux/memcontrol.h |   16 ++--
 include/linux/slab.h       |    9 +--
 include/linux/slub_def.h   |    3 +
 mm/memcontrol.c            |  104 +++++++++++-------------
 mm/slab.h                  |   36 ++++-----
 mm/slab_common.c           |  192 ++++++++++++++++++++++++++++----------------
 mm/slub.c                  |  118 +++++++++++++++++++++------
 7 files changed, 296 insertions(+), 182 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
