Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7A28E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 04:59:36 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id s50so891543edd.11
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 01:59:36 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t17-v6si253791ejg.184.2018.12.13.01.59.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 01:59:34 -0800 (PST)
Date: Thu, 13 Dec 2018 10:59:31 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181213095931.24qovurhtpa3jxzl@pathway.suse.cz>
References: <20181212135939.GA10170@tigerII.localdomain>
 <20181212174333.GC2746@sasha-vm>
 <CAJmjG2_zey77QxMzq997ALkD56d0UtHmGjF4dhq=TbEc2gox5A@mail.gmail.com>
 <20181212214337.GD2746@sasha-vm>
 <CAJmjG2_C0YRtVmNh2sg4JqhJJ11LMmbRHqwADxyO9CGh9ixQbA@mail.gmail.com>
 <20181212215225.GE2746@sasha-vm>
 <CAJmjG28s9bz51k=5i8eoKH2crj8e7-qM_EYWMqtUKZ_nGREQOg@mail.gmail.com>
 <CAJmjG29PnAfkUsU4PuVaFvjW-okO=U-MbHZHg7Sj_bBJ6EO09w@mail.gmail.com>
 <20181213022703.GD4860@jagdpanzerIV>
 <CAJmjG2-eoKTHtChWK0fdWfy872h5N1c-NgxBKZra1+ujutF+Fw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJmjG2-eoKTHtChWK0fdWfy872h5N1c-NgxBKZra1+ujutF+Fw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wang <wonderfly@google.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sasha Levin <sashal@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, Peter Zijlstra <peterz@infradead.org>, tj@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On Wed 2018-12-12 18:39:42, Daniel Wang wrote:
> > Additionally, for dbdda842fe96f to work as expected we really
> need fd5f7cde1b85d4c. Otherwise printk() can schedule under
> console_sem and console_owner, which will deactivate the "load
> balance" logic.
> 
> It looks like fd5f7cde1b85d4c got into 4.14.82 that was released last month.
> 
> On Wed, Dec 12, 2018 at 6:27 PM Sergey Senozhatsky
> <sergey.senozhatsky.work@gmail.com> wrote:
> >
> > On (12/12/18 16:40), Daniel Wang wrote:
> > > In case this was buried in previous messages, the commit I'd like to
> > > get backported to 4.14 is dbdda842fe96f: printk: Add console owner and
> > > waiter logic to load balance console writes. But another followup
> > > patch that fixes a bug in that patch is also required. That is
> > > c14376de3a1b: printk: Wake klogd when passing console_lock owner.
> >
> > Additionally, for dbdda842fe96f to work as expected we really
> > need fd5f7cde1b85d4c. Otherwise printk() can schedule under
> > console_sem and console_owner, which will deactivate the "load
> > balance" logic.

To make it clear. Please, make sure that the following commits are
backported together:

+ dbdda842fe96f8932ba ("printk: Add console owner and waiter
		logic to load balance console writes")
+ c162d5b4338d72deed6 ("printk: Hide console waiter logic into
		helpers")
+ fd5f7cde1b85d4c8e09 ("printk: Never set console_may_schedule
		in console_trylock()")
+ c14376de3a1befa70d9 ("printk: Wake klogd when passing
		console_lock owner")


I generated this list from git log using "Fixes:" tag. It seems
to mention all commits dicussed above.

Best Regards,
Petr
