Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1KBcvLK023016
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 22:38:57 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1KBd87l3944674
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 22:39:08 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1KBd8VC029323
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 22:39:08 +1100
Message-ID: <47BC1055.3000304@linux.vnet.ibm.com>
Date: Wed, 20 Feb 2008 17:04:45 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0802191449490.6254@blonde.site> <47BBC15E.5070405@linux.vnet.ibm.com> <20080220.185821.61784723.taka@valinux.co.jp> <6599ad830802200206w23955c9cn26bf768e790a6161@mail.gmail.com> <47BBFCC2.5020408@linux.vnet.ibm.com> <6599ad830802200218t41c70455u5d008c605e8b9762@mail.gmail.com> <47BC0704.9010603@linux.vnet.ibm.com> <20080220202143.4cc2fc05.kamezawa.hiroyu@jp.fujitsu.com> <47BC0C72.4080004@linux.vnet.ibm.com> <20080220203208.f7b876ef.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080220203208.f7b876ef.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, Hirokazu Takahashi <taka@valinux.co.jp>, hugh@veritas.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 20 Feb 2008 16:48:10 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> Kame, unbind->force_empty can work, but we can't force_empty the root cgroup.
>> Even if we could, the code to deal with turning on/off the entire memory
>> controller and accounting is likely to be very complex and probably racy.
>>
> Ok, just put it on my far-future-to-do-list.
> (we have another things to do now ;)
> 

Yes, too many things queued up. Avoiding the race being primary.

> But a boot option for turning off entire (memory) controller even if it is
> configured will be a good thing.
> 
> like..
>    cgroup_subsys_disable_mask = ...

I like this very much. This way, we get control over all controllers.

> or
>    memory_controller=off|on
> 

This can also be done, provided we don't do what has been suggested above.


> Thanks,
> -Kame


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
