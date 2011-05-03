Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 756C56B0012
	for <linux-mm@kvack.org>; Tue,  3 May 2011 09:55:32 -0400 (EDT)
Message-ID: <4DC0092D.2060902@redhat.com>
Date: Tue, 03 May 2011 09:54:53 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 2/2] Add stats to monitor soft_limit reclaim
References: <1304355025-1421-1-git-send-email-yinghan@google.com> <1304355025-1421-3-git-send-email-yinghan@google.com>
In-Reply-To: <1304355025-1421-3-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On 05/02/2011 12:50 PM, Ying Han wrote:
> This patch extend the soft_limit reclaim stats to both global background
> reclaim and global direct reclaim.
>
> The following stats are renamed and added:
>
> $cat /dev/cgroup/memory/A/memory.stat
> soft_kswapd_steal 1053626
> soft_kswapd_scan 1053693
> soft_direct_steal 1481810
> soft_direct_scan 1481996
>
> changelog v2..v1:
> 1. rename the stats on soft_kswapd/direct_steal/scan.
> 2. fix the documentation to match the stat name.

> Signed-off-by: Ying Han<yinghan@google.com>

Acked-by: Rik van Riel<riel@redhat.com>

I expect people to continue arguing over the names a little
longer, but feel free to keep my Acked-by: across the various
name changes :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
