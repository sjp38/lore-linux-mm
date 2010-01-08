Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CA3FE6B0088
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 00:10:34 -0500 (EST)
Message-ID: <4B46BE29.90207@redhat.com>
Date: Fri, 08 Jan 2010 00:10:01 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Commit f50de2d38 seems to be breaking my oom killer
References: <20100108105841.b9a030c4.minchan.kim@barrios-desktop> <20100108115531.C132.A69D9226@jp.fujitsu.com> <20100108130742.C138.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100108130742.C138.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Will Newton <will.newton@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 01/07/2010 11:08 PM, KOSAKI Motohiro wrote:

> Commit f50de2d3 (vmscan: have kswapd sleep for a short interval and
> double check it should be asleep) can cause kswapd to enter an infinite
> loop if running on a single-CPU system. If all zones are unreclaimble,
> sleeping_prematurely return 1 and kswapd will call balance_pgdat()
> again. but it's totally meaningless, balance_pgdat() doesn't anything
> against unreclaimable zone!
>
> Cc: Mel Gorman<mel@csn.ul.ie>
> Reported-by: Will Newton<will.newton@gmail.com>
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
