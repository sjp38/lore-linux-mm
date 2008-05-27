Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m4RDIhw7015403
	for <linux-mm@kvack.org>; Tue, 27 May 2008 23:18:43 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RDNOSS274162
	for <linux-mm@kvack.org>; Tue, 27 May 2008 23:23:24 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RDJEUP020368
	for <linux-mm@kvack.org>; Tue, 27 May 2008 23:19:14 +1000
Message-ID: <483C0A0D.50909@linux.vnet.ibm.com>
Date: Tue, 27 May 2008 18:48:05 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] swapcgroup(v2)
References: <483647AB.8090104@mxp.nes.nec.co.jp> <20080527073118.0D92B5A0E@siro.lan> <483BBB4C.3040501@linux.vnet.ibm.com> <483BC690.6010206@mxp.nes.nec.co.jp>
In-Reply-To: <483BC690.6010206@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, containers@lists.osdl.org, linux-mm@kvack.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, hugh@veritas.com, m-ikeda@ds.jp.nec.com
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> On 2008/05/27 16:42 +0900, Balbir Singh wrote:
>> YAMAMOTO Takashi wrote:
>>> hi,
>>>
>>>>> Thanks for looking into this. Yamamoto-San is also looking into a swap
>>>>> controller. Is there a consensus on the approach?
>>>>>
>>>> Not yet, but I think we should have some consensus each other
>>>> before going further.
>>>>
>>>>
>>>> Thanks,
>>>> Daisuke Nishimura.
>>> while nishimura-san's one still seems to have a lot of todo,
>>> it seems good enough as a start point to me.
>>> so i'd like to withdraw mine.
>>>
>>> nishimura-san, is it ok for you?
>>>
> Of cource.
> I'll work hard to make it better.
> 
>> I would suggest that me merge the good parts from both into the swap controller.
>> Having said that I'll let the two of you decide on what the good aspects of both
>> are. I cannot see any immediate overlap, but there might be some w.r.t.
>> infrastructure used.
>>
> Well, you mean you'll make another patch based on yamamoto-san's
> and mine?
> 
> Basically, I think it's difficult to merge
> because we charge different objects.
> 

Yes, I know - that's why I said infrastructure, to see the grouping and common
data structure aspects. I'll try and review the code.

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
