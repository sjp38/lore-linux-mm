Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5E9F06B01F0
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 22:57:32 -0400 (EDT)
Received: by vws16 with SMTP id 16so4808812vws.14
        for <linux-mm@kvack.org>; Mon, 16 Aug 2010 19:57:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1281951733-29466-4-git-send-email-mel@csn.ul.ie>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
	<1281951733-29466-4-git-send-email-mel@csn.ul.ie>
Date: Tue, 17 Aug 2010 11:57:31 +0900
Message-ID: <AANLkTinV74oGb6PNcZyrh8XJJL=z5g868KJDG5aa7E+x@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after direct
 reclaim allocation fails
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 16, 2010 at 6:42 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> When under significant memory pressure, a process enters direct reclaim
> and immediately afterwards tries to allocate a page. If it fails and no
> further progress is made, it's possible the system will go OOM. However,
> on systems with large amounts of memory, it's possible that a significant
> number of pages are on per-cpu lists and inaccessible to the calling
> process. This leads to a process entering direct reclaim more often than
> it should increasing the pressure on the system and compounding the problem.
>
> This patch notes that if direct reclaim is making progress but
> allocations are still failing that the system is already under heavy
> pressure. In this case, it drains the per-cpu lists and tries the
> allocation a second time before continuing.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

IPI overhead would be good rather than going OOM or nopage.
In addition, here isn't a hot path and frequent case.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
