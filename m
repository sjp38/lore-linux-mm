Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0801F6B0012
	for <linux-mm@kvack.org>; Thu, 12 May 2011 20:41:15 -0400 (EDT)
Message-ID: <4DCC7E00.60102@redhat.com>
Date: Thu, 12 May 2011 20:40:32 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/4] memcg: revisit soft_limit reclaim on contention
References: <1305226032-21448-1-git-send-email-yinghan@google.com>
In-Reply-To: <1305226032-21448-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org, Michel Lespinasse <walken@google.com>

On 05/12/2011 02:47 PM, Ying Han wrote:

> TODO:
> a) there was a question on how to do zone balancing w/o global LRU. This could be
> solved by building another cgroup list per-zone, where we also link cgroups under
> their soft_limit. We won't scan the list unless the first list being exhausted and
> the free pages is still under the high_wmark.

> b). one of the tricky part is to calculate the target nr_to_scan for each cgroup,
> especially combining the current heuristics with soft_limit exceeds. it depends how
> much weight we need to put on the second. One way is to make the ratio to be user
> configurable.

Johannes addresses these in his patch series.

> Ying Han (4):
>    Disable "organizing cgroups over soft limit in a RB-Tree"
>    Organize memcgs over soft limit in round-robin.
>    Implementation of soft_limit reclaim in round-robin.
>    Add some debugging stats

Looks like you also have some things Johannes doesn't have.

It may be good for the two patch series you have to get
merged into one series, before stuff gets merged upstream.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
