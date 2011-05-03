Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EA58E900001
	for <linux-mm@kvack.org>; Tue,  3 May 2011 09:26:24 -0400 (EDT)
Message-ID: <4DC00254.3010603@redhat.com>
Date: Tue, 03 May 2011 09:25:40 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 1/2] Add the soft_limit reclaim in global direct reclaim.
References: <1304355025-1421-1-git-send-email-yinghan@google.com> <1304355025-1421-2-git-send-email-yinghan@google.com>
In-Reply-To: <1304355025-1421-2-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On 05/02/2011 12:50 PM, Ying Han wrote:
> We recently added the change in global background reclaim which
> counts the return value of soft_limit reclaim. Now this patch adds
> the similar logic on global direct reclaim.
>
> We should skip scanning global LRU on shrink_zone if soft_limit reclaim
> does enough work. This is the first step where we start with counting
> the nr_scanned and nr_reclaimed from soft_limit reclaim into global
> scan_control.

Would be nice to see that at some point, but simply counting
the amount reclaimed from the over softlimit groups is a good
start.

> no change since v1.
>
> Signed-off-by: Ying Han<yinghan@google.com>

Acked-by: Rik van Riel<riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
