Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 6A13C6B0069
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 05:47:06 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 0/2] slightly change shrinker behaviour for very small object sets
Date: Fri, 21 Dec 2012 14:46:48 +0400
Message-Id: <1356086810-6950-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Dave Shrinnker <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com

Hi,

* v2: fix sysctl_vfs_cache_pressure for all users.

I've recently noticed some glitches in the object shrinker mechanism when a
very small number of objects is used. Those situations are theoretically
possible, albeit unlikely. But although it may feel like it is purely
theoretical, they can become common in environments with many small containers
(cgroups) in a box.

Those patches came from some experimentation I am doing with targetted-shrinking
for kmem-limited memory cgroups (Dave Shrinnker is already aware of such work).
In such scenarios, one can set the available memory to very low limits, and it
becomes easy to see this.



Glauber Costa (2):
  super: fix calculation of shrinkable objects for small numbers
  vmscan: take at least one pass with shrinkers

 fs/gfs2/glock.c        | 2 +-
 fs/gfs2/quota.c        | 2 +-
 fs/mbcache.c           | 2 +-
 fs/nfs/dir.c           | 2 +-
 fs/quota/dquot.c       | 5 ++---
 fs/super.c             | 2 +-
 fs/xfs/xfs_qm.c        | 2 +-
 include/linux/dcache.h | 4 ++++
 mm/vmscan.c            | 4 ++--
 9 files changed, 14 insertions(+), 11 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
