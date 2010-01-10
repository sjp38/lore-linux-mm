Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6E2A96B006A
	for <linux-mm@kvack.org>; Sun, 10 Jan 2010 09:37:56 -0500 (EST)
Date: Sun, 10 Jan 2010 22:37:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Commit f50de2d38 seems to be breaking my oom killer
Message-ID: <20100110143745.GB14610@localhost>
References: <20100108105841.b9a030c4.minchan.kim@barrios-desktop> <20100108115531.C132.A69D9226@jp.fujitsu.com> <20100108130742.C138.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100108130742.C138.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Will Newton <will.newton@gmail.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Subject: [PATCH] vmscan: kswapd don't retry balance_pgdat() if all zones are unreclaimable
> 
> Commit f50de2d3 (vmscan: have kswapd sleep for a short interval and
> double check it should be asleep) can cause kswapd to enter an infinite
> loop if running on a single-CPU system. If all zones are unreclaimble,
> sleeping_prematurely return 1 and kswapd will call balance_pgdat()
> again. but it's totally meaningless, balance_pgdat() doesn't anything
> against unreclaimable zone!
 
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
