Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 5B8DC6B0092
	for <linux-mm@kvack.org>; Mon, 14 May 2012 14:01:02 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/6] mm: memcg: statistics implementation cleanups
Date: Mon, 14 May 2012 20:00:45 +0200
Message-Id: <1337018451-27359-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Before piling more things (reclaim stats) on top of the current mess,
I thought it'd be better to clean up a bit.

The biggest change is printing statistics directly from live counters,
it has always been annoying to declare a new counter in two separate
enums and corresponding name string arrays.  After this series we are
down to one of each.

 mm/memcontrol.c |  223 +++++++++++++++++------------------------------
 1 file changed, 82 insertions(+), 141 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
