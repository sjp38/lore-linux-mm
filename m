Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2FEA86B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 17:08:33 -0400 (EDT)
Message-ID: <4DE6AA49.4090907@redhat.com>
Date: Wed, 01 Jun 2011 17:08:25 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 07/10] In order putback lru core
References: <cover.1306689214.git.minchan.kim@gmail.com> <e473fa18da363dfdfbd43e1862e48563f6d4e36f.1306689214.git.minchan.kim@gmail.com>
In-Reply-To: <e473fa18da363dfdfbd43e1862e48563f6d4e36f.1306689214.git.minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On 05/29/2011 02:13 PM, Minchan Kim wrote:
> This patch defines new APIs to put back the page into previous position of LRU.
> The idea I suggested in LSF/MM is simple.
>
> When we try to put back the page into lru list and if friends(prev, next) of the page
> still is nearest neighbor, we can insert isolated page into prev's next instead of
> head of LRU list. So it keeps LRU history without losing the LRU information.

> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Cc: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman<mgorman@suse.de>
> Cc: Rik van Riel<riel@redhat.com>
> Cc: Andrea Arcangeli<aarcange@redhat.com>
> Signed-off-by: Minchan Kim<minchan.kim@gmail.com>

Looks reasonable.

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
