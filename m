Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC618D0040
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 06:42:09 -0400 (EDT)
Received: by iyh42 with SMTP id 42so1143453iyh.14
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 03:42:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110412193407.B52F.A69D9226@jp.fujitsu.com>
References: <20110412183010.B52A.A69D9226@jp.fujitsu.com>
	<BANLkTinORojJgOdHeRMLMkKGc-Jitu-unQ@mail.gmail.com>
	<20110412193407.B52F.A69D9226@jp.fujitsu.com>
Date: Tue, 12 Apr 2011 19:42:07 +0900
Message-ID: <BANLkTi=4jV8f23n3rp7Oo8rY_ZVPG1pMbQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm, mem-hotplug: update pcp->stat_threshold when
 memory hotplug occur
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>

On Tue, Apr 12, 2011 at 7:34 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > No good stat_threshold might makes performance hurt.
>>
>> Yes. That's I want it.
>> My intention is that if you write down log fully, it can help much
>> newbies to understand the patch in future and it would be very clear
>> Andrew to merge it.
>>
>> What I want is following as.
>> ==
>>
>> Currently, memory hotplug doesn't updates pcp->stat_threashold.
>> Then, It ends up making the wrong stat_threshold and percpu_driftmark.
>>
>> It could make confusing zoneinfo or overhead by frequent draining.
>> Even when memory is low and kswapd is awake, it can mismatch between
>> the number of real free pages and vmstat NR_FREE_PAGES so that it can
>> result in the livelock. Please look at aa4548403 for more.
>>
>> This patch solves the issue.
>> ==
>
> Now, wakeup_kswapd() are using zone_watermark_ok_safe(). (ie avoid to use
> per-cpu stat jiffies). Then, I don't think we have livelock chance.
> Am I missing something?
>

I have no idea. I just referenced the description in aa4548403.
As I look code, zone_watermark_ok_safe works well if percpu_drift_mark
is set rightly. but if memory hotplug happens, zone->present_pages
would be changed so that it can affect wmarks. It means it can affect
percpu_drift_mark, I think.

My point is to write down the description clear.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
