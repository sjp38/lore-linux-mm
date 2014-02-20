Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2C58E6B0073
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 02:22:17 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id w7so1065500lbi.27
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 23:22:16 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id am3si2932421lac.157.2014.02.19.23.22.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Feb 2014 23:22:14 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v3 0/7] memcg-vs-slab related fixes, improvements, cleanups
Date: Thu, 20 Feb 2014 11:22:02 +0400
Message-ID: <cover.1392879001.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

Hi,

This patch set mostly cleanups memcg slab caches creation/destruction
paths fixing a couple of bugs in the meanwhile. The only serious change
it introduces is a rework of the sysfs layout for memcg slub caches (see
patch 7).

Changes in v3 (thanks to Michal Hocko):
 - improve patch descriptions
 - overall cleanup
 - rebase onto v3.14-rc3
Changes in v2 (thanks to David Rientjes):
 - do not remove cgroup name part from memcg cache names
 - do not export memcg cache id to userspace

Thanks,

Vladimir Davydov (7):
  memcg, slab: never try to merge memcg caches
  memcg, slab: cleanup memcg cache creation
  memcg, slab: separate memcg vs root cache creation paths
  memcg, slab: unregister cache from memcg before starting to destroy
    it
  memcg, slab: do not destroy children caches if parent has aliases
  slub: adjust memcg caches when creating cache alias
  slub: rework sysfs layout for memcg caches

 include/linux/memcontrol.h |    9 +-
 include/linux/slab.h       |    6 +-
 include/linux/slub_def.h   |    3 +
 mm/memcontrol.c            |  109 ++++++++-----------
 mm/slab.h                  |   21 +---
 mm/slab_common.c           |  250 +++++++++++++++++++++++++++-----------------
 mm/slub.c                  |   58 ++++++++--
 7 files changed, 261 insertions(+), 195 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
