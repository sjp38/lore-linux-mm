Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 117458E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 01:28:47 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id x7so12235452pll.23
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 22:28:47 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f22sor23758062plr.54.2018.12.11.22.28.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 22:28:45 -0800 (PST)
Date: Wed, 12 Dec 2018 15:28:41 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181212062841.GI431@jagdpanzerIV>
References: <20181004074442.GA12879@jagdpanzerIV>
 <20181004083609.kcziz2ynwi2w7lcm@pathway.suse.cz>
 <20181004085515.GC12879@jagdpanzerIV>
 <CAJmjG2-e6f6p=pE5uDECMc=W=81SYyGCmoabrC1ePXwL5DFdSw@mail.gmail.com>
 <20181022100952.GA1147@jagdpanzerIV>
 <CAJmjG2-c4e_1999n0OV5B9ABG9rF6n=myThjgX+Ms1R-vc3z+A@mail.gmail.com>
 <20181109064740.GE599@jagdpanzerIV>
 <CAJmjG28Q8pEpr67LC+Un8m+Qii58FTd1esp6Zc47TnMsw50QEw@mail.gmail.com>
 <20181212052126.GF431@jagdpanzerIV>
 <CAJmjG29a7Fax5ZW5Q+W+-1xPEXVUqdrMYwoUpSwL1Msiso6gtw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJmjG29a7Fax5ZW5Q+W+-1xPEXVUqdrMYwoUpSwL1Msiso6gtw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wang <wonderfly@google.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, Peter Zijlstra <peterz@infradead.org>, tj@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On (12/11/18 22:08), Daniel Wang wrote:
>
> I've been meaning to try it but kept getting distracted by other
> things. I'll try to find some time for it this week or next. Right now
> my intent is to get Steven's patch into 4.14 stable as it evidently
> fixed the particular issue I was seeing, and as Steven said it has
> been in upstream since 4.16 so it's not like backporting it will raise
> any red flags. I will start another thread on -stable for it.

OK.

> > I guess we still don't have a really clear understanding of what exactly
> is going in your system
> 
> I would also like to get to the bottom of it. Unfortunately I haven't
> got the expertise in this area nor the time to do it yet. Hence the
> intent to take a step back and backport Steven's patch to fix the
> issue that has resurfaced in our production recently.

No problem.
I just meant that -stable people can be a bit "unconvinced".

> Which two sets are you referring to specifically?

I guess I used the wrong word:

The first set (actually just one patch) is the one that makes consoles
re-entrant from panic().
The other set - those 4 patches (Steven's patch, + Petr's patch + a
patch that makes printk() atomic again).

	-ss
