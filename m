Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 5F6546B0062
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 21:30:07 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 52DDD3EE0C1
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 10:30:05 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 395E045DE5C
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 10:30:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1287B45DE59
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 10:30:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 049F21DB8051
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 10:30:05 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B30B51DB8050
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 10:30:04 +0900 (JST)
Message-ID: <4FCD609E.8070704@jp.fujitsu.com>
Date: Tue, 05 Jun 2012 10:27:58 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH v2 0/3] memcg : renaming and cleanup enum/macro
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, akpm@linux-foundation.org

This series 
   rename MEM_CGROUP_STAT_SWAPOUT as MEM_CGROUP_STAT_SWAP
   rename MEM_CGROUP_CHARGE_TYPE_MAPPED as MEM_CGROUP_CHARGE_TYPE_ANON
   remove MEM_CGROUP_CHARGE_TYPE_FORCE

 mm/memcontrol.c |   27 +++++++++++++--------------
 1 files changed, 13 insertions(+), 14 deletions(-)

based on feedback from community.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
