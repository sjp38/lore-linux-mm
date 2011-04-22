Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 65EB88D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:49:53 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9FB2B3EE0C0
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:49:50 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8392645DE5C
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:49:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6801245DE54
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:49:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 57A7AE08001
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:49:50 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 22BBF1DB8043
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:49:50 +0900 (JST)
Date: Fri, 22 Apr 2011 13:43:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V7 8/9] Add per-memcg zone "unreclaimable"
Message-Id: <20110422134310.154b86a2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1303446260-21333-9-git-send-email-yinghan@google.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-9-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 21 Apr 2011 21:24:19 -0700
Ying Han <yinghan@google.com> wrote:

> After reclaiming each node per memcg, it checks mem_cgroup_watermark_ok()
> and breaks the priority loop if it returns true. The per-memcg zone will
> be marked as "unreclaimable" if the scanning rate is much greater than the
> reclaiming rate on the per-memcg LRU. The bit is cleared when there is a
> page charged to the memcg being freed. Kswapd breaks the priority loop if
> all the zones are marked as "unreclaimable".
> 
> changelog v7..v6:
> 1. fix merge conflicts w/ the thread-pool patch.
> 
> changelog v6..v5:
> 1. make global zone_unreclaimable use the ZONE_MEMCG_RECLAIMABLE_RATE.
> 2. add comment on the zone_unreclaimable
> 
> changelog v5..v4:
> 1. reduce the frequency of updating mz->unreclaimable bit by using the existing
> memcg batch in task struct.
> 2. add new function mem_cgroup_mz_clear_unreclaimable() for recoganizing zone.
> 
> changelog v4..v3:
> 1. split off from the per-memcg background reclaim patch in V3.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
