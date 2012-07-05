Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 39F5C6B0070
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 20:45:40 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 00/11] mm: memcg: charge/uncharge improvements
Date: Thu,  5 Jul 2012 02:44:52 +0200
Message-Id: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

the biggest thing is probably #1, no longer trying (and failing) to
charge replacement pages during migration and thus compaction.  The
rest is cleanups and tiny optimizations that move some checks out of
the charge and uncharge core paths that do not apply to all types of
pages alike.

 include/linux/memcontrol.h |   11 +--
 mm/memcontrol.c            |  205 +++++++++++++++++++++++---------------------
 mm/migrate.c               |   27 ++-----
 mm/shmem.c                 |   11 ++-
 mm/swapfile.c              |    3 +-
 5 files changed, 124 insertions(+), 133 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
