Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5ED396B00DC
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 07:32:43 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id g10so748770pdj.20
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 04:32:43 -0700 (PDT)
Received: from psmtp.com ([74.125.245.104])
        by mx.google.com with SMTP id ds3si1760992pbb.199.2013.10.23.04.32.41
        for <linux-mm@kvack.org>;
        Wed, 23 Oct 2013 04:32:42 -0700 (PDT)
From: Qiang Huang <h.huangqiang@huawei.com>
Subject: [PATCH 0/3] a few cleanups about kmem code
Date: Wed, 23 Oct 2013 19:31:12 +0800
Message-ID: <1382527875-10112-1-git-send-email-h.huangqiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, cl@linux-foundation.org, penberg@kernel.org, glommer@parallels.com, rientjes@google.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com


Qiang Huang (3):
  memcg, kmem: Use is_root_cache instead of hard code
  memcg, kmem: rename cache_from_memcg to cache_from_memcg_idx
  memcg, kmem: use cache_from_memcg_idx instead of hard code

 mm/memcontrol.c  | 15 ++++++++-------
 mm/slab.c        |  2 +-
 mm/slab.h        |  6 ++++--
 mm/slab_common.c |  2 +-
 mm/slub.c        |  2 +-
 5 files changed, 15 insertions(+), 12 deletions(-)

-- 
1.8.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
