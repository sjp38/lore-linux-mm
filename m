Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 527A28D0040
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 06:12:04 -0400 (EDT)
Received: by iyh42 with SMTP id 42so1113619iyh.14
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 03:12:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110412183010.B52A.A69D9226@jp.fujitsu.com>
References: <20110411170134.035E.A69D9226@jp.fujitsu.com>
	<BANLkTi=fEejkrPdX27bFi1x+dHpOSGxQaQ@mail.gmail.com>
	<20110412183010.B52A.A69D9226@jp.fujitsu.com>
Date: Tue, 12 Apr 2011 19:12:02 +0900
Message-ID: <BANLkTinORojJgOdHeRMLMkKGc-Jitu-unQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm, mem-hotplug: update pcp->stat_threshold when
 memory hotplug occur
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>

On Tue, Apr 12, 2011 at 6:29 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
>
>> Hi, KOSAKI
>>
>> On Mon, Apr 11, 2011 at 5:01 PM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> > Currently, cpu hotplug updates pcp->stat_threashold, but memory
>> > hotplug doesn't. there is no reason.
>> >
>> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > Acked-by: Mel Gorman <mel@csn.ul.ie>
>> > Acked-by: Christoph Lameter <cl@linux.com>
>>
>> I can think it makes sense so I don't oppose the patch merging.
>> But as you know I am very keen on the description.
>>
>> What is the problem if hotplug doesn't do it?
>> I means the patch solves what's problem?
>>
>> Please write down fully for better description.
>> Thanks.
>
> No real world issue. I found the fault by code review.

I don't mean we should solve only real world issue.
Just finding out code review is much valuable. :)

> No good stat_threshold might makes performance hurt.

Yes. That's I want it.
My intention is that if you write down log fully, it can help much
newbies to understand the patch in future and it would be very clear
Andrew to merge it.

What I want is following as.

==

Currently, memory hotplug doesn't updates pcp->stat_threashold.
Then, It ends up making the wrong stat_threshold and percpu_driftmark.

It could make confusing zoneinfo or overhead by frequent draining.
Even when memory is low and kswapd is awake, it can mismatch between
the number of real free pages and vmstat NR_FREE_PAGES so that it can
result in the livelock. Please look at aa4548403 for more.

This patch solves the issue.
==


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
