Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 5AF126B005C
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 02:26:46 -0500 (EST)
Received: by iacb35 with SMTP id b35so33316426iac.14
        for <linux-mm@kvack.org>; Sat, 31 Dec 2011 23:26:45 -0800 (PST)
Date: Sat, 31 Dec 2011 23:26:42 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 0/5] memcg: trivial cleanups
Message-ID: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

Obviously I've missed the boat for per-memcg per-zone LRU locking in 3.3,
but I've split out a shameless bunch of trivial cleanups from that work,
and hoping these might still sneak in unless they're controversial.

Following on from my earlier mmotm/next patches, here's five
to memcontrol.c and .h, followed by six to the rest of mm.

[PATCH 1/5] memcg: replace MEM_CONT by MEM_RES_CTLR
[PATCH 2/5] memcg: replace mem and mem_cont stragglers
[PATCH 3/5] memcg: lru_size instead of MEM_CGROUP_ZSTAT
[PATCH 4/5] memcg: enum lru_list lru
[PATCH 5/5] memcg: remove redundant returns

 include/linux/memcontrol.h |    2 
 mm/memcontrol.c            |  121 ++++++++++++++++-------------------
 2 files changed, 58 insertions(+), 65 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
