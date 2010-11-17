Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 464CC6B00AB
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 21:42:03 -0500 (EST)
Message-ID: <4CE340BC.1010701@leadcoretech.com>
Date: Wed, 17 Nov 2010 10:41:00 +0800
From: "Figo.zhang" <zhangtianfei@leadcoretech.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: vmscan implement per-zone shrinkers
References: <20101109123246.GA11477@amd>	<20101114182614.BEE5.A69D9226@jp.fujitsu.com>	<20101115092452.BEF1.A69D9226@jp.fujitsu.com>	<20101116074717.GB3460@amd>	<AANLkTi=BhuVn8F3ioTyR8S=J3LfJbuhYsMoHf9f=bvRn@mail.gmail.com>	<4CE23B3B.5050804@leadcoretech.com>	<AANLkTi=10NspL2fw66De8osjUC+2xnxsLpw+x=oNQQTv@mail.gmail.com>	<4CE23F33.5060401@leadcoretech.com> <AANLkTi=Da76M+s92ZZnfw7ySjp3WWfDjW6n5G=hHheKB@mail.gmail.com>
In-Reply-To: <AANLkTi=Da76M+s92ZZnfw7ySjp3WWfDjW6n5G=hHheKB@mail.gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Anca Emanuel <anca.emanuel@gmail.com>
Cc: Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

于 11/16/2010 04:26 PM, Anca Emanuel 写道:
> On Tue, Nov 16, 2010 at 10:22 AM, Figo.zhang
> <zhangtianfei@leadcoretech.com>  wrote:
>> 于 11/16/2010 04:20 PM, Anca Emanuel 写道:
>>>
>>> On Tue, Nov 16, 2010 at 10:05 AM, Figo.zhang
>>> <zhangtianfei@leadcoretech.com>   wrote:
>>>>
>>>> 于 11/16/2010 03:53 PM, Anca Emanuel 写道:
>>>>>
>>>>> Nick, I want to test your tree.
>>>>> This is taking too long.
>>>>> Make something available now. And test it in real configs.
>>>>>
>>>>
>>>> hi Anca,
>>>>
>>>> would you like to give your test method?
>>>>
>>>
>>> Nothig special, for now I will test on my PC.
>>>
>>
>> hi KOSAKI Motohiro,
>>
>> is it any test suite or test scripts for test page-reclaim performance?
>>
>> Best,
>> Figo.zhang
>>
> 
> There is http://www.phoronix.com

it is not focus on page-reclaim test, or specially for MM.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
