Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E41386B0098
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 23:29:38 -0500 (EST)
Received: by qyk1 with SMTP id 1so1939616qyk.14
        for <linux-mm@kvack.org>; Tue, 16 Nov 2010 20:29:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4CE340BC.1010701@leadcoretech.com>
References: <20101109123246.GA11477@amd>
	<20101114182614.BEE5.A69D9226@jp.fujitsu.com>
	<20101115092452.BEF1.A69D9226@jp.fujitsu.com>
	<20101116074717.GB3460@amd>
	<AANLkTi=BhuVn8F3ioTyR8S=J3LfJbuhYsMoHf9f=bvRn@mail.gmail.com>
	<4CE23B3B.5050804@leadcoretech.com>
	<AANLkTi=10NspL2fw66De8osjUC+2xnxsLpw+x=oNQQTv@mail.gmail.com>
	<4CE23F33.5060401@leadcoretech.com>
	<AANLkTi=Da76M+s92ZZnfw7ySjp3WWfDjW6n5G=hHheKB@mail.gmail.com>
	<4CE340BC.1010701@leadcoretech.com>
Date: Wed, 17 Nov 2010 06:29:36 +0200
Message-ID: <AANLkTi==W_KHL3pd8Cq=ojV=aAAOxi4c=ZkHSednOVyH@mail.gmail.com>
Subject: Re: [patch] mm: vmscan implement per-zone shrinkers
From: Anca Emanuel <anca.emanuel@gmail.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Figo.zhang" <zhangtianfei@leadcoretech.com>
Cc: Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

2010/11/17 Figo.zhang <zhangtianfei@leadcoretech.com>:
> =D3=DA 11/16/2010 04:26 PM, Anca Emanuel =D0=B4=B5=C0:
>> On Tue, Nov 16, 2010 at 10:22 AM, Figo.zhang
>> <zhangtianfei@leadcoretech.com>  wrote:
>>> =D3=DA 11/16/2010 04:20 PM, Anca Emanuel =D0=B4=B5=C0:
>>>>
>>>> On Tue, Nov 16, 2010 at 10:05 AM, Figo.zhang
>>>> <zhangtianfei@leadcoretech.com>   wrote:
>>>>>
>>>>> =D3=DA 11/16/2010 03:53 PM, Anca Emanuel =D0=B4=B5=C0:
>>>>>>
>>>>>> Nick, I want to test your tree.
>>>>>> This is taking too long.
>>>>>> Make something available now. And test it in real configs.
>>>>>>
>>>>>
>>>>> hi Anca,
>>>>>
>>>>> would you like to give your test method?
>>>>>
>>>>
>>>> Nothig special, for now I will test on my PC.
>>>>
>>>
>>> hi KOSAKI Motohiro,
>>>
>>> is it any test suite or test scripts for test page-reclaim performance?
>>>
>>> Best,
>>> Figo.zhang
>>>
>>
>> There is http://www.phoronix.com
>
> it is not focus on page-reclaim test, or specially for MM.
>>
>
>

If you want some special test, you have to ask Michael Larabel for that.
http://www.phoronix-test-suite.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
