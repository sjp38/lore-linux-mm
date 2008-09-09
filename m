Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m89EP3r1023919
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 19:55:03 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m89EP3n71515546
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 19:55:03 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m89EP2ek002369
	for <linux-mm@kvack.org>; Wed, 10 Sep 2008 00:25:02 +1000
Message-ID: <48C6873B.6060700@linux.vnet.ibm.com>
Date: Tue, 09 Sep 2008 07:24:59 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 6/14]  memcg: lockless page cgroup
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com> <20080822203551.598a263c.kamezawa.hiroyu@jp.fujitsu.com> <20080909144007.48e6633a.nishimura@mxp.nes.nec.co.jp> <20080909165608.878d7182.kamezawa.hiroyu@jp.fujitsu.com> <20080909171154.f3cfdfd6.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080909171154.f3cfdfd6.nishimura@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> On Tue, 9 Sep 2008 16:56:08 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> On Tue, 9 Sep 2008 14:40:07 +0900
>> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
>>
>>>> +	/* Double counting race condition ? */
>>>> +	VM_BUG_ON(page_get_page_cgroup(page));
>>>> +
>>>>  	page_assign_page_cgroup(page, pc);
>>>>  
>>>>  	mz = page_cgroup_zoneinfo(pc);
>>> I got this VM_BUG_ON at swapoff.
>>>
>>> Trying to shmem_unuse_inode a page which has been moved
>>> to swapcache by shmem_writepage causes this BUG, because
>>> the page has not been uncharged(with all the patches applied).
>>>
>>> I made a patch which changes shmem_unuse_inode to charge with
>>> GFP_NOWAIT first and shrink usage on failure, as shmem_getpage does.
>>>
>>> But I don't stick to my patch if you handle this case :)
>>>
>> Thank you for testing and sorry for no progress in these days.
>>
>> I'm sorry to say that I'll have to postpone this to remove
>> page->page_cgroup pointer. I need some more performance-improvement
>> effort to remove page->page_cgroup pointer without significant overhead.
>>
> No problem. I know about that :)
> 
> And, I've started reviewing the radix tree patch and trying to test it.
> 

Thanks, Daisuke!

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
