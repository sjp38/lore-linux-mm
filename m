Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BE82F8D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 18:10:41 -0500 (EST)
Received: by iyf13 with SMTP id 13so5873432iyf.14
        for <linux-mm@kvack.org>; Tue, 01 Mar 2011 15:10:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110301223954.GI19057@random.random>
References: <20110228222138.GP22700@random.random>
	<AANLkTingkWo6dx=0sGdmz9qNp+_TrQnKXnmASwD8LhV4@mail.gmail.com>
	<20110301223954.GI19057@random.random>
Date: Wed, 2 Mar 2011 08:10:35 +0900
Message-ID: <AANLkTim7tcPTxG9hyFiSnQ7rqfMdoUhL1wrmqNAXAvEK@mail.gmail.com>
Subject: Re: [PATCH] remove compaction from kswapd
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org

On Wed, Mar 2, 2011 at 7:39 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> On Wed, Mar 02, 2011 at 07:33:13AM +0900, Minchan Kim wrote:
>> Sorry for bothering you but I think you get the data.
>> It helps someone in future very much to know why we determined to
>> remove the feature at that time and they should do what kinds of
>> experiment to prove it has a benefit to add compaction in kswapd
>> again.
>
> This is a benchmark I'm unsure if it's ok to publish results but it
> should be possible to simulate it with a device driver.
>
> Arthur provided kswapd load usage data too, so I hope that's enough.
>
> My other patch (compaction-kswapd-3) is way better than current logic
> and retains compaction in kswapd. That shows slightly higher
> kswapd utilization with Arthur's multimedia workload, and a bit worse
> performance on the network benchmark. So I thought it was better to go
> with the fastest potion as long as we don't have a logic that uses
> compaction and shows improved performance and lower latency than with
> no compaction at all in kswapd.
>

I didn't notice Arthur's problem.
The patch seems to fix a real problem so I think it's enough.
I wished you wrote down the link url about Arthur on LKML.

You can remove compact_mode of compact_control.
Otherwise, looks good to me.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Thanks,



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
