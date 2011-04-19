Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AD1348D0041
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 13:52:53 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 0/3] pass the scan_control into shrinkers
Date: Tue, 19 Apr 2011 10:51:33 -0700
Message-Id: <1303235496-3060-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

This patch changes the shrink_slab and shrinker APIs by consolidating existing
parameters into scan_control struct. This simplifies any further attempts to
pass extra info to the shrinker. Instead of modifying all the shrinker files
each time, we just need to extend the scan_control struct.

This patch is based on mmotm-2011-03-31-14-48.

Ying Han (3):
  move scan_control definition to header file
  change the shrink_slab by passing scan_control.
  change shrinker API by passing scan_control struct

 arch/x86/kvm/mmu.c                   |    3 +-
 drivers/gpu/drm/i915/i915_gem.c      |    5 +-
 drivers/gpu/drm/ttm/ttm_page_alloc.c |    1 +
 drivers/staging/zcache/zcache.c      |    5 ++-
 fs/dcache.c                          |    8 ++-
 fs/drop_caches.c                     |    7 ++-
 fs/gfs2/glock.c                      |    5 ++-
 fs/inode.c                           |    6 ++-
 fs/mbcache.c                         |   11 ++--
 fs/nfs/dir.c                         |    5 ++-
 fs/nfs/internal.h                    |    2 +-
 fs/quota/dquot.c                     |    6 ++-
 fs/xfs/linux-2.6/xfs_buf.c           |    4 +-
 fs/xfs/linux-2.6/xfs_sync.c          |    5 +-
 fs/xfs/quota/xfs_qm.c                |    5 +-
 include/linux/mm.h                   |   16 +++---
 include/linux/swap.h                 |   64 ++++++++++++++++++++++++++
 mm/vmscan.c                          |   84 +++++----------------------------
 net/sunrpc/auth.c                    |    5 ++-
 19 files changed, 143 insertions(+), 104 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
