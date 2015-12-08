Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2FFDF6B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:34:42 -0500 (EST)
Received: by wmuu63 with SMTP id u63so192227859wmu.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:34:41 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id kl9si5933128wjb.30.2015.12.08.10.34.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 10:34:41 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/8] mm: memcontrol: account "kmem" in cgroup2
Date: Tue,  8 Dec 2015 13:34:17 -0500
Message-Id: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi,

this series adds accounting of the historical "kmem" memory consumers
to the cgroup2 memory controller.

These consumers include the dentry cache, the inode cache, kernel
stack pages, and a few others that are pointed out in patch 7/8. The
footprint of these consumers is directly tied to userspace activity in
common workloads, and so they have to be part of the minimally viable
configuration in order to present a complete feature to our users.

The cgroup2 interface of the memory controller is far from complete,
but this series, along with the socket memory accounting series,
provides the final semantic changes for the existing memory knobs in
the cgroup2 interface, which is scheduled for initial release in the
next merge window.

Thanks!

 include/linux/list_lru.h     |   4 +-
 include/linux/memcontrol.h   | 330 +++++++++++++++++++++--------------------
 include/linux/sched.h        |   2 -
 include/linux/slab.h         |   2 +-
 include/linux/slab_def.h     |   3 +-
 include/linux/slub_def.h     |   2 +-
 include/net/tcp_memcontrol.h |   3 +-
 init/Kconfig                 |  10 +-
 mm/list_lru.c                |  12 +-
 mm/memcontrol.c              | 246 ++++++++++++++----------------
 mm/slab.h                    |   6 +-
 mm/slab_common.c             |  14 +-
 mm/slub.c                    |  10 +-
 mm/vmscan.c                  |   2 +-
 net/ipv4/Makefile            |   2 +-
 net/ipv4/tcp_memcontrol.c    |   2 +-
 16 files changed, 319 insertions(+), 331 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
