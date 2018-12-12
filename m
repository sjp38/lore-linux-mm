Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7588E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 08:36:08 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o21so8555477edq.4
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 05:36:08 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l12si2849183edi.230.2018.12.12.05.36.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 05:36:06 -0800 (PST)
Date: Wed, 12 Dec 2018 14:36:03 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181212133603.yyu2zvw7g454zdqd@pathway.suse.cz>
References: <CAJmjG2-e6f6p=pE5uDECMc=W=81SYyGCmoabrC1ePXwL5DFdSw@mail.gmail.com>
 <20181022100952.GA1147@jagdpanzerIV>
 <CAJmjG2-c4e_1999n0OV5B9ABG9rF6n=myThjgX+Ms1R-vc3z+A@mail.gmail.com>
 <20181109064740.GE599@jagdpanzerIV>
 <CAJmjG28Q8pEpr67LC+Un8m+Qii58FTd1esp6Zc47TnMsw50QEw@mail.gmail.com>
 <20181212052126.GF431@jagdpanzerIV>
 <CAJmjG29a7Fax5ZW5Q+W+-1xPEXVUqdrMYwoUpSwL1Msiso6gtw@mail.gmail.com>
 <20181212062841.GI431@jagdpanzerIV>
 <20181212064841.GB2746@sasha-vm>
 <20181212081034.GA32687@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181212081034.GA32687@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sasha Levin <sashal@kernel.org>, Daniel Wang <wonderfly@google.com>, Steven Rostedt <rostedt@goodmis.org>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, Peter Zijlstra <peterz@infradead.org>, tj@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On Wed 2018-12-12 17:10:34, Sergey Senozhatsky wrote:
> On (12/12/18 01:48), Sasha Levin wrote:
> > > > > I guess we still don't have a really clear understanding of what exactly
> > > > is going in your system
> > > > 
> > > > I would also like to get to the bottom of it. Unfortunately I haven't
> > > > got the expertise in this area nor the time to do it yet. Hence the
> > > > intent to take a step back and backport Steven's patch to fix the
> > > > issue that has resurfaced in our production recently.
> > > 
> > > No problem.
> > > I just meant that -stable people can be a bit "unconvinced".
> > 
> > The -stable people tried adding this patch back in April, but ended up
> > getting complaints up the wazoo (https://lkml.org/lkml/2018/4/9/154)
> > about how this is not -stable material.
> 
> OK, really didn't know that! I wasn't Cc-ed on that AUTOSEL email,
> and I wasn't Cc-ed on this whole discussion and found it purely
> accidentally while browsing linux-mm list.

I am sorry that I did not CC you. There were so many people in CC.
I expected that all people mentioned in the related commit message
were included by default.


> So if you are willing to backport this set to -stable, then I wouldn't
> mind, probably would be more correct if we don't advertise this as a
> "panic() deadlock fix"

This should not be a problem. I guess that stable does not modify
the original commit messages unless there is a change.


> In the meantime, I can add my Acked-by to this backport if it helps.

I am fine with back-porting the patches now. They have got much more
testing in the meantime and nobody reported any regression. They
seems to help in more situations than we expected. Finally, there is
someone requesting the backport who spent non-trivial time
on tracking the problem and testing.

Best Regards,
Petr
