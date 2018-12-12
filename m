Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B38AD8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 08:59:44 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 74so15374334pfk.12
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 05:59:44 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b16sor27129829pge.50.2018.12.12.05.59.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 05:59:43 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Wed, 12 Dec 2018 22:59:39 +0900
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181212135939.GA10170@tigerII.localdomain>
References: <20181022100952.GA1147@jagdpanzerIV>
 <CAJmjG2-c4e_1999n0OV5B9ABG9rF6n=myThjgX+Ms1R-vc3z+A@mail.gmail.com>
 <20181109064740.GE599@jagdpanzerIV>
 <CAJmjG28Q8pEpr67LC+Un8m+Qii58FTd1esp6Zc47TnMsw50QEw@mail.gmail.com>
 <20181212052126.GF431@jagdpanzerIV>
 <CAJmjG29a7Fax5ZW5Q+W+-1xPEXVUqdrMYwoUpSwL1Msiso6gtw@mail.gmail.com>
 <20181212062841.GI431@jagdpanzerIV>
 <20181212064841.GB2746@sasha-vm>
 <20181212081034.GA32687@jagdpanzerIV>
 <20181212133603.yyu2zvw7g454zdqd@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181212133603.yyu2zvw7g454zdqd@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>, Sasha Levin <sashal@kernel.org>, Daniel Wang <wonderfly@google.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, Peter Zijlstra <peterz@infradead.org>, tj@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On (12/12/18 14:36), Petr Mladek wrote:
> > OK, really didn't know that! I wasn't Cc-ed on that AUTOSEL email,
> > and I wasn't Cc-ed on this whole discussion and found it purely
> > accidentally while browsing linux-mm list.
> 
> I am sorry that I did not CC you. There were so many people in CC.
> I expected that all people mentioned in the related commit message
> were included by default.

No worries! I'm not blaming anyone.

> > So if you are willing to backport this set to -stable, then I wouldn't
> > mind, probably would be more correct if we don't advertise this as a
> > "panic() deadlock fix"
> 
> This should not be a problem. I guess that stable does not modify
> the original commit messages unless there is a change.

Agreed.

> > In the meantime, I can add my Acked-by to this backport if it helps.
> 
> I am fine with back-porting the patches now. They have got much more
> testing in the meantime and nobody reported any regression. They
> seems to help in more situations than we expected. Finally, there is
> someone requesting the backport who spent non-trivial time
> on tracking the problem and testing.

Great!


Sasha, here is
	Acked-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
from me.

And expect another backport request in 1 or 2 weeks - the patch
which eliminates the existing "panic CPU != uart_port lock owner CPU"
limitation.

	-ss
