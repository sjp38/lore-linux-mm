Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 886BA6B0069
	for <linux-mm@kvack.org>; Fri, 28 Nov 2014 02:15:40 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id w10so6139851pde.19
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 23:15:40 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id nr9si14941235pbc.1.2014.11.27.23.15.37
        for <linux-mm@kvack.org>;
        Thu, 27 Nov 2014 23:15:39 -0800 (PST)
Message-ID: <54782118.5040405@lge.com>
Date: Fri, 28 Nov 2014 16:15:36 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: [LSF/MM ATTEND] Improving CMA
References: <5473E146.7000503@codeaurora.org> <20141127061204.GA6850@js1304-P5Q-DELUXE> <5476D60D.4030506@lge.com>
In-Reply-To: <5476D60D.4030506@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <lauraa@codeaurora.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, zhuhui@xiaomi.com, minchan@kernel.org, SeongJae Park <sj38.park@gmail.com>, mgorman@suse.de


>
>
> 2014-11-27 i??i?? 3:12i?? Joonsoo Kim i?'(e??) i?' e,?:
>> On Mon, Nov 24, 2014 at 05:54:14PM -0800, Laura Abbott wrote:
>>> There have been a number of patch series posted designed to improve various
>>> aspects of CMA. A sampling:
>>>
>>> https://lkml.org/lkml/2014/10/15/623
>>> http://marc.info/?l=linux-mm&m=141571797202006&w=2
>>> https://lkml.org/lkml/2014/6/26/549
>>>
>>> As far as I can tell, these are all trying to fix real problems with CMA but
>>> none of them have moved forward very much from what I can tell. The goal of
>>> this session would be to come out with an agreement on what are the biggest
>>> problems with CMA and the best ways to solve them.
>>
>> I also tried to solve problem from CMA, that is, reserved memory
>> utilization.
>>
>> https://lkml.org/lkml/2014/5/28/64
>>
>> While playing that patchset, I found serious problem about free page
>> counting, so I stopped to develop it for a while and tried to fix it.
>> Now, it is fixed by me and I can continue my patchset.
>>
>> https://lkml.org/lkml/2014/10/31/69
>>
>> I heard that Minchan suggests new CMA zone like movable zone, and, I
>> think that it would be the way to go. But, it would be a long-term goal
>> and I'd like to solve utilization problem with my patchset for now.
>> It is the biggest issue and it already forces someone to develop
>> out of tree solution. It's not good that out of tree solution is used
>> more and more in the product so I'd like to fix it quickly at first
>> stage.
>>
>> I think that CMA have big potential. If we fix problems of CMA
>> completely, it can be used for many places. One such case in my mind
>> is hugetlb or THP. Until now, hugetlb uses reserved approach, that is
>> very inefficient. System administrator carefully set the number of
>> reserved hugepage according to whole system workload. And application
>> can't use it freely, because it is very limited and managed resource.
>> If we use CMA for hugetlb, we can easily allocate hugepage and
>> application can use hugepages more freely.
>>
>> Anyway, I'd like to attend LSF/MM and discuss this topic.
>>
>> Thanks.
>>
>
> Until now, I've used CMA with 2 out-of-tree patches:
> 1. https://lkml.org/lkml/2012/8/31/313 : Laura's patch
> 2. https://lkml.org/lkml/2014/5/28/64 : Joonsoo's patch
>
> And one merged patch by me: https://lkml.org/lkml/2014/9/4/78
>
> With them, my platform could've worked but it still had free-page-counting problem.
>
> I think if Joonsoo's patch [2] is merged into mainline, CMA can be stable and useful.
> Allocation latency Minchan mentioned is not problem for my platform.
> CMA allocation is not often and limited to only one drivers.
>
> Allocation guarantee is, I hope, fixed with my patch (https://lkml.org/lkml/2014/9/4/78) at least in my platform.
> My platform had worked for several hours but it lacks heavy load test.
> I have a plan to use CMA for massive product next year.
>
> I'd like to attend LSF/MM and discuss this topic too.

I'm sending LSF/MM attend request as Joonsoo did.
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
