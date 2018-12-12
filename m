Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D9A368E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 01:48:44 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id q62so11565895pgq.9
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 22:48:44 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g21si13197702pgl.114.2018.12.11.22.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 22:48:43 -0800 (PST)
Date: Wed, 12 Dec 2018 01:48:42 -0500
From: Sasha Levin <sashal@kernel.org>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181212064841.GB2746@sasha-vm>
References: <20181004083609.kcziz2ynwi2w7lcm@pathway.suse.cz>
 <20181004085515.GC12879@jagdpanzerIV>
 <CAJmjG2-e6f6p=pE5uDECMc=W=81SYyGCmoabrC1ePXwL5DFdSw@mail.gmail.com>
 <20181022100952.GA1147@jagdpanzerIV>
 <CAJmjG2-c4e_1999n0OV5B9ABG9rF6n=myThjgX+Ms1R-vc3z+A@mail.gmail.com>
 <20181109064740.GE599@jagdpanzerIV>
 <CAJmjG28Q8pEpr67LC+Un8m+Qii58FTd1esp6Zc47TnMsw50QEw@mail.gmail.com>
 <20181212052126.GF431@jagdpanzerIV>
 <CAJmjG29a7Fax5ZW5Q+W+-1xPEXVUqdrMYwoUpSwL1Msiso6gtw@mail.gmail.com>
 <20181212062841.GI431@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20181212062841.GI431@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Daniel Wang <wonderfly@google.com>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, Peter Zijlstra <peterz@infradead.org>, tj@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On Wed, Dec 12, 2018 at 03:28:41PM +0900, Sergey Senozhatsky wrote:
>On (12/11/18 22:08), Daniel Wang wrote:
>>
>> I've been meaning to try it but kept getting distracted by other
>> things. I'll try to find some time for it this week or next. Right now
>> my intent is to get Steven's patch into 4.14 stable as it evidently
>> fixed the particular issue I was seeing, and as Steven said it has
>> been in upstream since 4.16 so it's not like backporting it will raise
>> any red flags. I will start another thread on -stable for it.
>
>OK.
>
>> > I guess we still don't have a really clear understanding of what exactly
>> is going in your system
>>
>> I would also like to get to the bottom of it. Unfortunately I haven't
>> got the expertise in this area nor the time to do it yet. Hence the
>> intent to take a step back and backport Steven's patch to fix the
>> issue that has resurfaced in our production recently.
>
>No problem.
>I just meant that -stable people can be a bit "unconvinced".

The -stable people tried adding this patch back in April, but ended up
getting complaints up the wazoo (https://lkml.org/lkml/2018/4/9/154)
about how this is not -stable material.

So yes, testing/acks welcome :)

--
Thanks,
Sasha
