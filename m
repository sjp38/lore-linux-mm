Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m59AYiQT017481
	for <linux-mm@kvack.org>; Mon, 9 Jun 2008 20:34:44 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m59AcKjj043310
	for <linux-mm@kvack.org>; Mon, 9 Jun 2008 20:38:20 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m59AY9Zi019319
	for <linux-mm@kvack.org>; Mon, 9 Jun 2008 20:34:09 +1000
Message-ID: <484D070D.4010209@linux.vnet.ibm.com>
Date: Mon, 09 Jun 2008 16:03:49 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/2] memcg: hierarchy support (v3)
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com> <484CF82E.1010508@linux.vnet.ibm.com> <20080609185505.4259019f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080609185505.4259019f.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 09 Jun 2008 15:00:22 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>> Hi, this is third version.
>>>
>>> While small changes in codes, the whole _tone_ of code is changed.
>>> I'm not in hurry, any comments are welcome.
>>>
>>> based on 2.6.26-rc2-mm1 + memcg patches in -mm queue.
>>>
>> Hi, Kamezawa-San,
>>
>> Sorry for the delay in responding. Like we discussed last time, I'd prefer a
>> shares based approach for hierarchial memcg management. I'll review/try these
>> patches and provide more feedback.
>>
> Hi,
> 
> I'm now totally re-arranging patches, so just see concepts.
> 
> In previous e-mail, I thought that there was a difference between 'your share'
> and 'my share'. So, please explain again ? 
> 
> My 'share' has following characteristics.
> 
>   - work as soft-limit. not hard-limit.
>   - no limit when there are not high memory pressure.
>   - resource usage will be proportionally fair to each group's share (priority)
>     under memory pressure.
> 

My share is very similar to yours.

A group might have a share of 100% and a hard limit of 1G. In this case the hard
limit applies if the system has more than 1G of memory. I think of hard limit as
the final controlling factor and shares are suggestive.

Yes, my shares also have the same factors, but can be overridden by hard limits.


> If you want to work on this, I can stop this for a while and do other important
> patches, like background reclaim, mlock limitter, guarantee, etc.. because my 
> priority to hierarchy is not very high (but it seems better to do this before
> other misc works, so I did.). 
> 

I do, but I don't want to stop you from doing it. mlock limitter is definitely
important, along with some control for large pages. Hierarchy is definitely
important, since we cannot add other major functionality without first solving
this proble, After that, High on my list is

1. Soft limits
2. Performance/space trade-offs

> Anyway, we have to test the new LRU (RvR LRU) at first in the next -mm ;)

Yes :) I just saw that going in


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
