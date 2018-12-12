Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C4C258E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 00:21:31 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id h11so14547178pfj.13
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 21:21:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t7sor23735933plo.3.2018.12.11.21.21.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 21:21:30 -0800 (PST)
Date: Wed, 12 Dec 2018 14:21:26 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181212052126.GF431@jagdpanzerIV>
References: <20181003133704.43a58cf5@gandalf.local.home>
 <CAJmjG291w2ZPRiAevSzxGNcuR6vTuqyk6z4SG3xRsbaQh5U3zQ@mail.gmail.com>
 <20181004074442.GA12879@jagdpanzerIV>
 <20181004083609.kcziz2ynwi2w7lcm@pathway.suse.cz>
 <20181004085515.GC12879@jagdpanzerIV>
 <CAJmjG2-e6f6p=pE5uDECMc=W=81SYyGCmoabrC1ePXwL5DFdSw@mail.gmail.com>
 <20181022100952.GA1147@jagdpanzerIV>
 <CAJmjG2-c4e_1999n0OV5B9ABG9rF6n=myThjgX+Ms1R-vc3z+A@mail.gmail.com>
 <20181109064740.GE599@jagdpanzerIV>
 <CAJmjG28Q8pEpr67LC+Un8m+Qii58FTd1esp6Zc47TnMsw50QEw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJmjG28Q8pEpr67LC+Un8m+Qii58FTd1esp6Zc47TnMsw50QEw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wang <wonderfly@google.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, Peter Zijlstra <peterz@infradead.org>, tj@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On (12/11/18 17:16), Daniel Wang wrote:
> > Let's first figure out if it works.
> 
> I would still like to try applying your patches that went into
> printk.git, but for now I wonder if we can get Steven's patch into
> 4.14 first, for at least we know it mitigated the issue if not
> fundamentally addressed it, and we've agreed it's an innocuous change
> that doesn't risk breaking stable.

So... did my patch address the deadlock you are seeing or it didn't?

> I haven't done this before so I'll need your help. What's the next
> step to actually get Steven's patch *in* linux-4.14.y? According to
> https://www.kernel.org/doc/html/latest/process/stable-kernel-rules.html
> I am supposed to send an email with the patch ID and subject, which
> are both mentioned in this email. Should I send another one? What's
> the process like? Thanks!

I'm not doing any -stable releases, so can't really answer, sorry.
Probably would be better to re-address this question to 4.14 -stable
maintainers.


---
I guess we still don't have a really clear understanding of what exactly
is going in your system. We don't even know for sure which one of the locks
is deadlocking the system. And why exactly Steven's patch helps. If it
is uart_port->lock, then it's one thing; if it's console_sem ->lock then
it's another thing. But those two are just theories, not supported by any
logs/backtraces from your systems.

If it's uart_port->lock and there will be 2 patch sets to choose from
for -stable, then -stable guys can pick up the one that requires less
effort: 1 two-liner patch vs. 3 or 4 bigger patches.

	-ss
