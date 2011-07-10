Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id EDCBC6B004A
	for <linux-mm@kvack.org>; Sun, 10 Jul 2011 17:26:42 -0400 (EDT)
Received: by pzk4 with SMTP id 4so3242544pzk.14
        for <linux-mm@kvack.org>; Sun, 10 Jul 2011 14:26:40 -0700 (PDT)
From: raghu.prabhu13@gmail.com
Subject: [PATCH] Remove incorrect usage of sysctl_vfs_cache_pressure
Date: Mon, 11 Jul 2011 02:56:23 +0530
Message-Id: <cover.1310331583.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com
Cc: keithp@keithp.com, viro@zeniv.linux.org.uk, riel@redhat.com, swhiteho@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jack@suse.cz, Raghavendra D Prabhu <rprabhu@wnohang.net>

From: Raghavendra D Prabhu <rprabhu@wnohang.net>

In shrinker functions, sysctl_vfs_cache_pressure variable is being used while
trimming slab caches in general and not restricted to inode/dentry caches as
documented for that sysctl.

Raghavendra D Prabhu (1):
  mm/vmscan: Remove sysctl_vfs_cache_pressure from non-vfs shrinkers

 drivers/gpu/drm/i915/i915_gem.c |    2 +-
 fs/gfs2/glock.c                 |    2 +-
 fs/gfs2/quota.c                 |    2 +-
 fs/mbcache.c                    |    2 +-
 fs/nfs/dir.c                    |    2 +-
 fs/quota/dquot.c                |    3 +--
 net/sunrpc/auth.c               |    2 +-
 7 files changed, 7 insertions(+), 8 deletions(-)

-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
