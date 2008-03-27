Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2R9w94J019277
	for <linux-mm@kvack.org>; Thu, 27 Mar 2008 20:58:09 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2R9vOTC4403424
	for <linux-mm@kvack.org>; Thu, 27 Mar 2008 20:57:24 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2R9vNc3024055
	for <linux-mm@kvack.org>; Thu, 27 Mar 2008 20:57:24 +1100
Message-ID: <47EB6EB5.5050808@linux.vnet.ibm.com>
Date: Thu, 27 Mar 2008 15:23:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm] [PATCH 0/4] memcg : radix-tree page_cgroup v2
References: <20080327174435.e69f5b45.kamezawa.hiroyu@jp.fujitsu.com> <20080327175654.C749.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080327183415.166db9ad.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080327183415.166db9ad.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, lizf@cn.fujitsu.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 27 Mar 2008 18:12:42 +0900
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
>> Hi
>>
>>>          TEST                                BASELINE     RESULT      INDEX
>>> (1)      Execl Throughput                        43.0     2868.8      667.2
>>> (2)      Execl Throughput                        43.0     2810.3      653.6
>>> (3)      Execl Throughput                        43.0     2836.9      659.7
>>> (4)      Execl Throughput                        43.0     2846.0      661.9
>>> (5)      Execl Throughput                        43.0     2862.0      665.6
>>> (6)      Execl Throughput                        43.0     3110.0      723.3
>>>
>>> (1) .... rc5-mm1 + memory controller
>>> (2) .... patch 1/4 is applied.      (use radix-tree always.)
>>> (3) .... patch [1-3]/4 are applied. (caching by percpu)
>>> (4) .... patch [1-4]/4 are applied. (uses prefetch)
>>> (5) .... adjust sizeof(struct page) to be 64 bytes by padding.
>>> (6) .... rc5-mm1 *without* memory controller
>> I am very surprised this result. 
>> 723.3 -> 667.2 seems large performance impact.
>>
>> Why do you need count resource usage when unlimited limit.
>> Could you separate unlimited group to resource usage counting and no counting.
>> I hope default cgroup keep no counting and no decrease performance.
> 
> At first, I'd like to reduce this overhead even under memory resource
> controller's accounting ;)
> We have boot-time-disable option now. But it doesn't seem what you want.
> 
> Considering workaround....
> In current system, *unlimited* doesn't mean *no account*.
> So, I think we have an option to add "no account" flag per cgroup.
> 
> Hmm..some interface to do
> - allow "no account" -> "account"
> - disallow "account" -> "no account"
> 
> Balbir-san, how do you think ?

The reason we do accounting for default group is to allow reporting of
usage/statistics and in the future when we do hierarchial accounting and
control, it will be much more useful.

I like the interface idea, but I'd like to do two things

1. Keeping accounting on by default or have an option to do so
2. Reduce the memory controller overhead

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
