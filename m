Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BA5508D0080
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 00:22:27 -0500 (EST)
Message-ID: <4CE36652.50305@leadcoretech.com>
Date: Wed, 17 Nov 2010 13:21:22 +0800
From: "Figo.zhang" <zhangtianfei@leadcoretech.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: vmscan implement per-zone shrinkers
References: <20101109123246.GA11477@amd>	<20101114182614.BEE5.A69D9226@jp.fujitsu.com>	<20101115092452.BEF1.A69D9226@jp.fujitsu.com>	<20101116074717.GB3460@amd>	<AANLkTi=BhuVn8F3ioTyR8S=J3LfJbuhYsMoHf9f=bvRn@mail.gmail.com>	<4CE23B3B.5050804@leadcoretech.com>	<AANLkTi=10NspL2fw66De8osjUC+2xnxsLpw+x=oNQQTv@mail.gmail.com>	<4CE23F33.5060401@leadcoretech.com>	<AANLkTi=Da76M+s92ZZnfw7ySjp3WWfDjW6n5G=hHheKB@mail.gmail.com>	<4CE340BC.1010701@leadcoretech.com> <AANLkTi==W_KHL3pd8Cq=ojV=aAAOxi4c=ZkHSednOVyH@mail.gmail.com>
In-Reply-To: <AANLkTi==W_KHL3pd8Cq=ojV=aAAOxi4c=ZkHSednOVyH@mail.gmail.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Anca Emanuel <anca.emanuel@gmail.com>
Cc: Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

>>>>
>>>> hi KOSAKI Motohiro,
>>>>
>>>> is it any test suite or test scripts for test page-reclaim performance?
>>>>
>>>> Best,
>>>> Figo.zhang
>>>>
>>>
>>> There is http://www.phoronix.com
>>
>> it is not focus on page-reclaim test, or specially for MM.
>>>
>>
>>
> 
> If you want some special test, you have to ask Michael Larabel for that.
> http://www.phoronix-test-suite.com/

yes, i see, the phoronix-test-suite is test such as ffmpeg, games. not
focus on MM.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email:<a href=ilto:"dont@kvack.org">  email@kvack.org</a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
