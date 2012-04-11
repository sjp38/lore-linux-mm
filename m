Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 4896B6B0092
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 18:00:17 -0400 (EDT)
Received: by faas16 with SMTP id s16so73521faa.2
        for <linux-mm@kvack.org>; Wed, 11 Apr 2012 15:00:15 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V2 3/5] memcg: set soft_limit_in_bytes to 0 by default
Date: Wed, 11 Apr 2012 15:00:14 -0700
Message-Id: <1334181614-26836-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm@kvack.org

1. If soft_limit are all set to MAX, it wastes first three periority iterations
without scanning anything.

2. By default every memcg is eligibal for softlimit reclaim, and we can also
set the value to MAX for special memcg which is immune to soft limit reclaim.

This idea is based on discussion with Michal and Johannes from LSF.

Signed-off-by: Ying Han <yinghan@google.com>
---
 kernel/res_counter.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index d508363..8017d01 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -18,7 +18,6 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent)
 {
 	spin_lock_init(&counter->lock);
 	counter->limit = RESOURCE_MAX;
-	counter->soft_limit = RESOURCE_MAX;
 	counter->parent = parent;
 }
 
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
