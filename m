Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 52ABF8D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:39:35 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3FCDF3EE0C3
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:39:31 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 24F6A45DE5A
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:39:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BB4C45DE54
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:39:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id ECC67E08002
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:39:30 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B4DF41DB8046
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:39:30 +0900 (JST)
Date: Fri, 22 Apr 2011 13:32:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V7 3/9] New APIs to adjust per-memcg wmarks
Message-Id: <20110422133249.272253c5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1303446260-21333-4-git-send-email-yinghan@google.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-4-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 21 Apr 2011 21:24:14 -0700
Ying Han <yinghan@google.com> wrote:

> Add memory.low_wmark_distance, memory.high_wmark_distance and reclaim_wmarks
> APIs per-memcg. The first two adjust the internal low/high wmark calculation
> and the reclaim_wmarks exports the current value of watermarks.
> 
> By default, the low/high_wmark is calculated by subtracting the distance from
> the hard_limit(limit_in_bytes). When configuring the low/high_wmark distance,
> user must setup the high_wmark_distance before low_wmark_distance. Also user
> must zero low_wmark_distance before high_wmark_distance.
> 
> $ echo 500m >/dev/cgroup/A/memory.limit_in_bytes
> $ cat /dev/cgroup/A/memory.limit_in_bytes
> 524288000
> 
> $ echo 50m >/dev/cgroup/A/memory.high_wmark_distance
> $ echo 40m >/dev/cgroup/A/memory.low_wmark_distance
> 
> $ cat /dev/cgroup/A/memory.reclaim_wmarks
> low_wmark 482344960
> high_wmark 471859200
> 
> change v5..v4
> 1. add sanity check for setting high/low_wmark_distance for root cgroup.
> 
> changelog v4..v3:
> 1. replace the "wmark_ratio" API with individual tunable for low/high_wmarks.
> 
> changelog v3..v2:
> 1. replace the "min_free_kbytes" api with "wmark_ratio". This is part of
> feedbacks
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
