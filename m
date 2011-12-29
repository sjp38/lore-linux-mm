Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id DF42F6B004D
	for <linux-mm@kvack.org>; Wed, 28 Dec 2011 19:17:54 -0500 (EST)
Received: by iacb35 with SMTP id b35so27273922iac.14
        for <linux-mm@kvack.org>; Wed, 28 Dec 2011 16:17:54 -0800 (PST)
Date: Wed, 28 Dec 2011 16:17:06 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 0/4] memcg: four fixes to current next
Message-ID: <alpine.LSU.2.00.1112281613550.8257@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

Here are four memcg fixes to mmotm/next, based on 3.2.0-rc6-next-20111222
minus Mel's 11/11 "mm: isolate pages for immediate reclaim on their own LRU"
and its two corrections - as I already reported, that soon generates memcg
accounting problems of a similar kind to those fixed in 1/4 here.

[PATCH 1/4] memcg: fix split_huge_page_refcounts
[PATCH 2/4] memcg: fix NULL mem_cgroup_try_charge
[PATCH 3/4] memcg: fix page migration to reset_owner
[PATCH 4/4] memcg: fix mem_cgroup_print_bad_page

 mm/huge_memory.c |   10 ----------
 mm/memcontrol.c  |   33 ++++++---------------------------
 mm/migrate.c     |    2 ++
 mm/swap.c        |   29 +++++++++++++++++++----------
 4 files changed, 27 insertions(+), 47 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
