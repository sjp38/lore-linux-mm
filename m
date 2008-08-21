Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m7LAQgcV020558
	for <linux-mm@kvack.org>; Thu, 21 Aug 2008 15:56:42 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7LAQg571261646
	for <linux-mm@kvack.org>; Thu, 21 Aug 2008 15:56:42 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m7LAQf9p002386
	for <linux-mm@kvack.org>; Thu, 21 Aug 2008 15:56:41 +0530
Message-ID: <48AD42E1.40204@linux.vnet.ibm.com>
Date: Thu, 21 Aug 2008 15:56:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [discuss] memrlimit - potential applications that can use
References: <48AA73B5.7010302@linux.vnet.ibm.com> <1219161525.23641.125.camel@nimitz> <48AAF8C0.1010806@linux.vnet.ibm.com> <1219167669.23641.156.camel@nimitz> <48ABD545.8010209@linux.vnet.ibm.com> <1219249757.8960.22.camel@nimitz> <48ACE040.2030807@linux.vnet.ibm.com> <20080821164339.679212b2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080821164339.679212b2.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>, Andrea Righi <righi.andrea@gmail.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 21 Aug 2008 08:55:52 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>>>>> So, before we expand the use of those features to control groups by
>>>>> adding a bunch of new code, let's make sure that there will be users
>>>> for
>>>>> it and that those users have no better way of doing it.
>>>> I am all ears to better ways of doing it. Are you suggesting that overcommit was
>>>> added even though we don't actually need it?
>>> It serves a purpose, certainly.  We have have better ways of doing it
>>> now, though.  "i>>?So, before we expand the use of those features to
>>> control groups by adding a bunch of new code, let's make sure that there
>>> will be users for it and that those users have no better way of doing
>>> it."
>>>
>>> The one concrete user that's been offered so far is postgres.  I've
>> No, you've been offered several, including php and apache that use memory limits.
>>
>>> suggested something that I hope will be more effective than enforcing
>>> overcommit.  
> 
> I'm sorry I miss the point. My concern on memrlimit (for overcommiting) is that
> it's not fair because an application which get -ENOMEM at mmap() is just someone
> unlucky.

It can happen today with overcommit turned on. Why is it unlucky?

 I think it's better to trigger some notifier to application or daemon
> rather than return -ENOMEM at mmap(). Notification like "Oh, it seems the VSZ
> of total application exceeds the limit you set. Although you can continue your
> operation, it's recommended that you should fix up the  situation".
> will be good.
> 

So you are suggesting that when we are running out of memory (as defined by our
current resource constraints), we don't return -ENOMEM, but instead we now
handle a new event that states that we are running out of memory?

NOTE: I am not opposed to the event, it can be useful for container
administrators to know how to size their containers, not to application
developers who want to auto-tune their applications (see my comment on autonomic
computing in an earlier thread) or to applications that want to make sure they
don't OOM without the system administrator having to do oom_adj for every
important application.

> Thanks,
> -Kame
> 


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
