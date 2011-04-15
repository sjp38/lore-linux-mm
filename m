Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id ED12E900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 21:41:36 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 91ED53EE0BD
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:41:32 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7770645DE77
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:41:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FD4445DE97
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:41:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 51D2EE08006
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:41:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A975E08004
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:41:32 +0900 (JST)
Date: Fri, 15 Apr 2011 10:34:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V4 08/10] Enable per-memcg background reclaim.
Message-Id: <20110415103452.81057ff9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1302821669-29862-9-git-send-email-yinghan@google.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-9-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 14 Apr 2011 15:54:27 -0700
Ying Han <yinghan@google.com> wrote:

> By default the per-memcg background reclaim is disabled when the limit_in_bytes
> is set the maximum. The kswapd_run() is called when the memcg is being resized,
> and kswapd_stop() is called when the memcg is being deleted.
> 
> The per-memcg kswapd is waked up based on the usage and low_wmark, which is
> checked once per 1024 increments per cpu. The memcg's kswapd is waked up if the
> usage is larger than the low_wmark.
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

Ok, seems nice.

For now,
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I'll ack on later version.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
