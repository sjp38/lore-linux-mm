Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A3DE36B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 13:33:10 -0400 (EDT)
Message-ID: <49D3A454.2070903@redhat.com>
Date: Wed, 01 Apr 2009 20:28:52 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
References: <1238457560-7613-1-git-send-email-ieidus@redhat.com>	<1238457560-7613-2-git-send-email-ieidus@redhat.com>	<1238457560-7613-3-git-send-email-ieidus@redhat.com>	<1238457560-7613-4-git-send-email-ieidus@redhat.com>	<1238457560-7613-5-git-send-email-ieidus@redhat.com>	<20090331111510.dbb712d2.kamezawa.hiroyu@jp.fujitsu.com>	<49D20AE1.4060802@redhat.com> <20090401085710.d2f0b267.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090401085710.d2f0b267.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 31 Mar 2009 15:21:53 +0300
> Izik Eidus <ieidus@redhat.com> wrote:
>   
>>>   
>>>       
>> kpage is actually what going to be KsmPage -> the shared page...
>>
>> Right now this pages are not swappable..., after ksm will be merged we 
>> will make this pages swappable as well...
>>
>>     
> sure.
>
>   
>>> If so, please
>>>  - show the amount of kpage
>>>  
>>>  - allow users to set limit for usage of kpages. or preserve kpages at boot or
>>>    by user's command.
>>>   
>>>       
>> kpage actually save memory..., and limiting the number of them, would 
>> make you limit the number of shared pages...
>>
>>     
>
> Ah, I'm working for memory control cgroup. And *KSM* will be out of control.
> It's ok to make the default limit value as INFINITY. but please add knobs.
>   
Sure, when i will post V2 i will take care for this issue (i will do it 
after i get little bit more review for ksm.c.... :-))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
