Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4702F8D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:51:46 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 860503EE0AE
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:51:43 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E3D945DE98
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:51:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DBBE745DE97
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:51:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CCCFAE08002
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:51:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 970601DB803B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:51:39 +0900 (JST)
Date: Fri, 22 Apr 2011 13:44:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V7 9/9] Enable per-memcg background reclaim.
Message-Id: <20110422134455.6bd83c7c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1303446260-21333-10-git-send-email-yinghan@google.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-10-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 21 Apr 2011 21:24:20 -0700
Ying Han <yinghan@google.com> wrote:

> By default the per-memcg background reclaim is disabled when the limit_in_bytes
> is set the maximum. The kswapd_run() is called when the memcg is being resized,
> and kswapd_stop() is called when the memcg is being deleted.
> 
> The per-memcg kswapd is waked up based on the usage and low_wmark, which is
> checked once per 1024 increments per cpu. The memcg's kswapd is waked up if the
> usage is larger than the low_wmark.
> 
> changelog v7..v6:
> 1. merge the thread-pool and add memcg_kswapd_stop(), memcg_kswapd_init() based
> on thread-pool.
> 
> changelog v4..v3:
> 1. move kswapd_stop to mem_cgroup_destroy based on comments from KAMAZAWA
> 2. move kswapd_run to setup_mem_cgroup_wmark, since the actual watermarks
> determines whether or not enabling per-memcg background reclaim.
> 
> changelog v3..v2:
> 1. some clean-ups
> 
> changelog v2..v1:
> 1. start/stop the per-cgroup kswapd at create/delete cgroup stage.
> 2. remove checking the wmark from per-page charging. now it checks the wmark
> periodically based on the event counter.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

seems ok to me. Maybe we need to revisit the suitable number of threads after
seeing real world workload.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
