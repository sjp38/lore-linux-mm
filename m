Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 627956B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 20:03:21 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5A4FB3EE0BD
	for <linux-mm@kvack.org>; Wed, 16 May 2012 09:03:19 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 40C0D45DE5B
	for <linux-mm@kvack.org>; Wed, 16 May 2012 09:03:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 288E945DE5A
	for <linux-mm@kvack.org>; Wed, 16 May 2012 09:03:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 187CA1DB803A
	for <linux-mm@kvack.org>; Wed, 16 May 2012 09:03:19 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C510E1DB8045
	for <linux-mm@kvack.org>; Wed, 16 May 2012 09:03:18 +0900 (JST)
Message-ID: <4FB2EE59.8070505@jp.fujitsu.com>
Date: Wed, 16 May 2012 09:01:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 0/6] mm: memcg: statistics implementation cleanups
References: <1337018451-27359-1-git-send-email-hannes@cmpxchg.org> <4FB1A115.2080303@jp.fujitsu.com> <20120515110302.GH1406@cmpxchg.org>
In-Reply-To: <20120515110302.GH1406@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2012/05/15 20:03), Johannes Weiner wrote:

> On Tue, May 15, 2012 at 09:19:33AM +0900, KAMEZAWA Hiroyuki wrote:
>> (2012/05/15 3:00), Johannes Weiner wrote:
>>
>>> Before piling more things (reclaim stats) on top of the current mess,
>>> I thought it'd be better to clean up a bit.
>>>
>>> The biggest change is printing statistics directly from live counters,
>>> it has always been annoying to declare a new counter in two separate
>>> enums and corresponding name string arrays.  After this series we are
>>> down to one of each.
>>>
>>>  mm/memcontrol.c |  223 +++++++++++++++++------------------------------
>>>  1 file changed, 82 insertions(+), 141 deletions(-)
>>
>> to all 1-6. Thank you.
>>
>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Thanks!
> 
>> One excuse for my old implementation of mem_cgroup_get_total_stat(),
>> which is fixed in patch 6, is that I thought it's better to touch all counters
>> in a cachineline at once and avoiding long distance for-each loop.
>>
>> What number of performance difference with some big hierarchy(100+children) tree ?
>> (But I agree your code is cleaner. I'm just curious.)
> 
> I set up a parental group with hierarchy enabled, then created 512
> children and did a 4-job kernel bench in one of them.  Every 0.1
> seconds, I read the stats of the parent, which requires reading each
> stat/event/lru item from 512 groups before moving to the next one:
> 
>                         512stats-vanilla        512stats-patched
> Walltime (s)            62.61 (  +0.00%)        62.88 (  +0.43%)
> Walltime (stddev)        0.17 (  +0.00%)         0.14 (  -3.17%)
> 
> That should be acceptable, I think.
> 
> 


Yes, thank you. 
Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
