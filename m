Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3B8728D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:45:52 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5D1F63EE0C8
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:45:49 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FD0845DE95
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:45:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2113045DE96
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:45:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B6C8AE1800F
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:45:48 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B766E18005
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:45:48 +0900 (JST)
Date: Fri, 22 Apr 2011 13:39:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V7 6/9] Implement the select_victim_node within memcg.
Message-Id: <20110422133909.b78d1ab6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1303446260-21333-7-git-send-email-yinghan@google.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-7-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 21 Apr 2011 21:24:17 -0700
Ying Han <yinghan@google.com> wrote:

> This add the mechanism for background reclaim which we remember the
> last scanned node and always starting from the next one each time.
> The simple round-robin fasion provide the fairness between nodes for
> each memcg.
> 
> changelog v6..v5:
> 1. fix the correct comment style.
> 
> changelog v5..v4:
> 1. initialize the last_scanned_node to MAX_NUMNODES.
> 
> changelog v4..v3:
> 1. split off from the per-memcg background reclaim patch.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
