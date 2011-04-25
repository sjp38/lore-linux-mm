Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 611538D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 14:50:26 -0400 (EDT)
Message-ID: <4DB5C191.3090804@parallels.com>
Date: Mon, 25 Apr 2011 22:46:41 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 1/2] change the shrink_slab by passing shrink_control
References: <1303752134-4856-1-git-send-email-yinghan@google.com> <1303752134-4856-2-git-send-email-yinghan@google.com>
In-Reply-To: <1303752134-4856-2-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/25/2011 09:22 PM, Ying Han wrote:
> This patch consolidates existing parameters to shrink_slab() to
> a new shrink_control struct. This is needed later to pass the same
> struct to shrinkers.
> 
> changelog v2..v1:
> 1. define a new struct shrink_control and only pass some values down
> to the shrinker instead of the scan_control.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Acked-by: Pavel Emelyanov <xemul@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
