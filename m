Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BD41C8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 14:35:32 -0400 (EDT)
Message-ID: <4DB5BED1.7060407@redhat.com>
Date: Mon, 25 Apr 2011 14:34:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 2/2] change shrinker API by passing shrink_control
 struct
References: <1303752134-4856-1-git-send-email-yinghan@google.com> <1303752134-4856-3-git-send-email-yinghan@google.com>
In-Reply-To: <1303752134-4856-3-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On 04/25/2011 01:22 PM, Ying Han wrote:
> The patch changes each shrinkers API by consolidating the existing
> parameters into shrink_control struct. This will simplify any further
> features added w/o touching each file of shrinker.
>
> changelog v2..v1:
> 1. replace the scan_control to shrink_control, and only pass the set
> of values down to the shrinker.
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
