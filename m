Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 6067D6B005A
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 10:03:13 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/2] mm: memcg reclaim integration followups
Date: Tue, 10 Jan 2012 16:02:50 +0100
Message-Id: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

here are two patches based on memcg-aware global reclaim, which I
dropped from the initial series to focus on the exclusive-lru changes.

The first one is per-memcg reclaim statistics.  For now, they include
only pages scanned and pages reclaimed, separately for direct reclaim
and kswapd, as well as separately for internal pressure or reclaim due
to parental memcgs.

The second one is integrating soft limit reclaim into the now
memcg-aware global reclaim path.  It kills a lot of code and performs
better as far as I have tested it.  Furthermore, Ying is working on
turning soft limits into guarantees, as discussed in Prague, and this
patch is also in preparation for that.

Sorry for the odd point in time to submit this, I guess this will mean
3.4 at the earliest.  But the soft limit removal is a bit heavy weight
so it's probably easier conflict-wise to have it at the bottom of the
-mm stack.

 Documentation/cgroups/memory.txt |    4 +
 include/linux/memcontrol.h       |   28 ++-
 mm/memcontrol.c                  |  482 +++++++++-----------------------------
 mm/vmscan.c                      |   87 ++------
 4 files changed, 144 insertions(+), 457 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
