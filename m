Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1R58lmN026943
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 16:08:47 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1R59KcA352464
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 16:09:21 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1R59O9u005630
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 16:09:25 +1100
Message-ID: <47C4EF2D.90508@linux.vnet.ibm.com>
Date: Wed, 27 Feb 2008 10:33:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] page reclaim throttle take2
References: <20080227133850.4249.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080227140042.66abb805.kamezawa.hiroyu@jp.fujitsu.com> <20080227140221.424C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080227140221.424C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Hi
> 
>>> I don't think so.
>>> all modern many cpu machine stand on NUMA.
>>> it mean following,
>>>  - if cpu increases, then zone increases, too.
>>>
>>> if default value increase by #cpus, lock contension dramatically increase
>>> on large numa.
>>>
>>> Have I overlooked anything?
>>>
>> How about adding something like..
>> == 
>> CONFIG_SIMULTANEOUS_PAGE_RECLAIMERS 
>> int
>> default 3
>> depends on DEBUG
>> help
>>   This value determines the number of threads which can do page reclaim
>>   in a zone simultaneously. If this is too big, performance under heavy memory
>>   pressure will decrease.
>>   If unsure, use default.
>> ==
>>
>> Then, you can get performance reports from people interested in this
>> feature in test cycle.
> 
> hm, intersting.
> but sysctl parameter is more better, i think.
> 
> OK, I'll add it at next post.

I think sysctl should be interesting. The config option provides good
documentation, but it is static in nature (requires reboot to change). I wish we
could have the best of both worlds.

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
