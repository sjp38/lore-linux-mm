Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4BEC68E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 09:29:30 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id j8so1460627plb.1
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 06:29:30 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l3si1640149pld.229.2018.12.13.06.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 06:29:28 -0800 (PST)
Date: Thu, 13 Dec 2018 09:29:27 -0500
From: Sasha Levin <sashal@kernel.org>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181213142927.GH2746@sasha-vm>
References: <20181212174333.GC2746@sasha-vm>
 <CAJmjG2_zey77QxMzq997ALkD56d0UtHmGjF4dhq=TbEc2gox5A@mail.gmail.com>
 <20181212214337.GD2746@sasha-vm>
 <CAJmjG2_C0YRtVmNh2sg4JqhJJ11LMmbRHqwADxyO9CGh9ixQbA@mail.gmail.com>
 <20181212215225.GE2746@sasha-vm>
 <CAJmjG28s9bz51k=5i8eoKH2crj8e7-qM_EYWMqtUKZ_nGREQOg@mail.gmail.com>
 <CAJmjG29PnAfkUsU4PuVaFvjW-okO=U-MbHZHg7Sj_bBJ6EO09w@mail.gmail.com>
 <20181213022703.GD4860@jagdpanzerIV>
 <CAJmjG2-eoKTHtChWK0fdWfy872h5N1c-NgxBKZra1+ujutF+Fw@mail.gmail.com>
 <20181213095931.24qovurhtpa3jxzl@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20181213095931.24qovurhtpa3jxzl@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Daniel Wang <wonderfly@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, Peter Zijlstra <peterz@infradead.org>, tj@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On Thu, Dec 13, 2018 at 10:59:31AM +0100, Petr Mladek wrote:
>On Wed 2018-12-12 18:39:42, Daniel Wang wrote:
>> > Additionally, for dbdda842fe96f to work as expected we really
>> need fd5f7cde1b85d4c. Otherwise printk() can schedule under
>> console_sem and console_owner, which will deactivate the "load
>> balance" logic.
>>
>> It looks like fd5f7cde1b85d4c got into 4.14.82 that was released last month.
>>
>> On Wed, Dec 12, 2018 at 6:27 PM Sergey Senozhatsky
>> <sergey.senozhatsky.work@gmail.com> wrote:
>> >
>> > On (12/12/18 16:40), Daniel Wang wrote:
>> > > In case this was buried in previous messages, the commit I'd like to
>> > > get backported to 4.14 is dbdda842fe96f: printk: Add console owner and
>> > > waiter logic to load balance console writes. But another followup
>> > > patch that fixes a bug in that patch is also required. That is
>> > > c14376de3a1b: printk: Wake klogd when passing console_lock owner.
>> >
>> > Additionally, for dbdda842fe96f to work as expected we really
>> > need fd5f7cde1b85d4c. Otherwise printk() can schedule under
>> > console_sem and console_owner, which will deactivate the "load
>> > balance" logic.
>
>To make it clear. Please, make sure that the following commits are
>backported together:
>
>+ dbdda842fe96f8932ba ("printk: Add console owner and waiter
>		logic to load balance console writes")
>+ c162d5b4338d72deed6 ("printk: Hide console waiter logic into
>		helpers")
>+ fd5f7cde1b85d4c8e09 ("printk: Never set console_may_schedule
>		in console_trylock()")
>+ c14376de3a1befa70d9 ("printk: Wake klogd when passing
>		console_lock owner")
>
>
>I generated this list from git log using "Fixes:" tag. It seems
>to mention all commits dicussed above.

All 4 queued for 4.14, thank you.

--
Thanks,
Sasha
