Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAJ8Zwci028961
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 03:35:58 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAJ8YKKb107946
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 03:34:20 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAJ8YJv0011628
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 03:34:19 -0500
Message-ID: <47414A8F.8020807@linux.vnet.ibm.com>
Date: Mon, 19 Nov 2007 14:04:23 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] memory controller per zone patches take 2 [9/10]
 per-zone-lru for memory cgroup
References: <20071116191107.46dd523a.kamezawa.hiroyu@jp.fujitsu.com> <20071116192642.8c7f07c9.kamezawa.hiroyu@jp.fujitsu.com> <473F2A1A.8000703@linux.vnet.ibm.com> <20071119104826.e4ba02ca.kamezawa.hiroyu@jp.fujitsu.com> <47412B5B.80409@linux.vnet.ibm.com> <20071119153549.d6f6f1de.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071119153549.d6f6f1de.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 19 Nov 2007 11:51:15 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>> =
>>> /cgroup/group_A/group_A_1
>>>             .  /group_A_2
>>>                /group_A_3
>>> (LRU(s) will be used for maintaining parent/child groups.)
>>>
>> The LRU's will be shared, my vision is
>>
>> 		LRU
>> 		^ ^
>> 		| |
>> 	Mem-----+ +----Mem
>>
>>
>> That two or more mem_cgroup's can refer to the same LRU list and have
>> their own resource counters. This setup will be used in the case
>> of a hierarchy, so that a child can share memory with its parent
>> and have it's own limit.
>>
>> The mem_cgroup will basically then only contain a reference
>> to the LRU list.
>>
> Hmm, interesting. 
> 
> Then, 
>    group_A_1's usage + group_A_2's usage + group_A_3's usgae < group_A's limit.
>    group_A_1, group_A_2, group_A_3 has its own limit.

Yes that is correct

> In plan.
> 
> I wonder if we want rich control functions, we need "share" or "priority" among
> childs. (but maybe this will be complicated one.)
> 

That would nice and the end goal of providing this feature. We also need
to provide soft-limits (more complex) and guarantees (with the kernel
memory controller coming in - nice to have, but not necessary for now)

> Thank you for explanation.
> 
> Regards,
> -Kame
> 

Thanks for helping out the memory controller.

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
