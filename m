Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 48CB66B002C
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 22:08:06 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 596A83EE081
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 12:08:04 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E33145DE9E
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 12:08:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 25AD645DEAD
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 12:08:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 174D11DB8041
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 12:08:04 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C65691DB8038
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 12:08:03 +0900 (JST)
Date: Tue, 14 Feb 2012 12:06:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/6 v4] memcg: remove
 EXPORT_SYMBOL(mem_cgroup_update_page_stat)
Message-Id: <20120214120640.ef2ef23a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120214120414.025625c2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120214120414.025625c2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>


This is just a cleanup.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 2 Feb 2012 12:05:41 +0900
Subject: [PATCH 1/6] memcg: remove EXPORT_SYMBOL(mem_cgroup_update_page_stat)

>From the log, I guess EXPORT was for preparing dirty accounting.
But _now_, we don't need to export this. Remove this for now.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ab315ab..4c2b759 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1897,7 +1897,6 @@ out:
 		move_unlock_page_cgroup(pc, &flags);
 	rcu_read_unlock();
 }
-EXPORT_SYMBOL(mem_cgroup_update_page_stat);
 
 /*
  * size of first charge trial. "32" comes from vmscan.c's magic value.
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
