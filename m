Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id m716kHke004984
	for <linux-mm@kvack.org>; Fri, 1 Aug 2008 12:16:17 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m716kHPI1691694
	for <linux-mm@kvack.org>; Fri, 1 Aug 2008 12:16:17 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m716kG4j014931
	for <linux-mm@kvack.org>; Fri, 1 Aug 2008 12:16:16 +0530
Message-ID: <4892B135.4090203@linux.vnet.ibm.com>
Date: Fri, 01 Aug 2008 12:16:13 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: memcg swappiness (Re: memo: mem+swap controller)
References: <48929E60.6050608@linux.vnet.ibm.com> <20080801063712.BD59B5A5F@siro.lan>
In-Reply-To: <20080801063712.BD59B5A5F@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com, hugh@veritas.com, linux-mm@kvack.org, menage@google.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
>> YAMAMOTO Takashi wrote:
>>> hi,
>>>
>>>>>> I do intend to add the swappiness feature soon for control groups.
>>>>>>
>>>>> How does it work?
>>>>> Does it affect global page reclaim?
>>>>>
>>>> We have a swappiness parameter in scan_control. Each control group indicates
>>>> what it wants it swappiness to be when the control group is over it's limit and
>>>> reclaim kicks in.
>>> the following is an untested work-in-progress patch i happen to have.
>>> i'd appreciate it if you take care of it.
>>>
>> Looks very similar to the patch I have. You seemed to have made much more
>> progress than me, I am yet to look at the recent_* statistics. How are the test
>> results? Are they close to what you expect?  Some comments below
> 
> it's mostly untested as i said above.  i'm wondering how to test it.
> 

I did a simple test

1. Run a RSS hungry (touch malloc'ed pages) and dd in the same control group
2. Tweak swappiness to see if the result is desirable

Not a complex test, but a good starting point :)

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
