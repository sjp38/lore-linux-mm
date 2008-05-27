Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m4RDlkgb001139
	for <linux-mm@kvack.org>; Tue, 27 May 2008 19:17:46 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RDlSmt876594
	for <linux-mm@kvack.org>; Tue, 27 May 2008 19:17:28 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m4RDljHW004559
	for <linux-mm@kvack.org>; Tue, 27 May 2008 19:17:45 +0530
Message-ID: <483C10C0.7040503@linux.vnet.ibm.com>
Date: Tue, 27 May 2008 19:16:40 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] swapcgroup(v2)
References: <483647AB.8090104@mxp.nes.nec.co.jp> <20080527073118.0D92B5A0E@siro.lan> <483BBB4C.3040501@linux.vnet.ibm.com> <483BC690.6010206@mxp.nes.nec.co.jp> <483C0A0D.50909@linux.vnet.ibm.com> <483C0FB2.7080706@mxp.nes.nec.co.jp>
In-Reply-To: <483C0FB2.7080706@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, containers@lists.osdl.org, linux-mm@kvack.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, hugh@veritas.com, m-ikeda@ds.jp.nec.com
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> On 2008/05/27 22:18 +0900, Balbir Singh wrote:
>> Daisuke Nishimura wrote:
>>> On 2008/05/27 16:42 +0900, Balbir Singh wrote:
>>>> YAMAMOTO Takashi wrote:
>>>>> hi,
>>>>>
>>>>>>> Thanks for looking into this. Yamamoto-San is also looking into a swap
>>>>>>> controller. Is there a consensus on the approach?
>>>>>>>
>>>>>> Not yet, but I think we should have some consensus each other
>>>>>> before going further.
>>>>>>
>>>>>>
>>>>>> Thanks,
>>>>>> Daisuke Nishimura.
>>>>> while nishimura-san's one still seems to have a lot of todo,
>>>>> it seems good enough as a start point to me.
>>>>> so i'd like to withdraw mine.
>>>>>
>>>>> nishimura-san, is it ok for you?
>>>>>
>>> Of cource.
>>> I'll work hard to make it better.
>>>
>>>> I would suggest that me merge the good parts from both into the swap controller.
>>>> Having said that I'll let the two of you decide on what the good aspects of both
>>>> are. I cannot see any immediate overlap, but there might be some w.r.t.
>>>> infrastructure used.
>>>>
>>> Well, you mean you'll make another patch based on yamamoto-san's
>>> and mine?
>>>
>>> Basically, I think it's difficult to merge
>>> because we charge different objects.
>>>
>> Yes, I know - that's why I said infrastructure, to see the grouping and common
>> data structure aspects. I'll try and review the code.
>>
> OK.
> 
> I'll wait for your patch.

Hi, Daisuke-San

I am not sending out any patch (sorry for the confusion, if I caused it). I am
going to review the swapcgroup patchset.

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
