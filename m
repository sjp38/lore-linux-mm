Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 101576B0006
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:33:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id i128so648441pfg.2
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 01:33:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s10si727125pge.41.2018.04.18.01.33.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Apr 2018 01:33:14 -0700 (PDT)
Date: Wed, 18 Apr 2018 10:33:09 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180418083309.kbrnhfb245tt5si7@pathway.suse.cz>
References: <20180416160608.GA7071@amd>
 <20180416161412.GZ2341@sasha-vm>
 <20180416122244.146aec48@gandalf.local.home>
 <20180416163107.GC2341@sasha-vm>
 <20180416124711.048f1858@gandalf.local.home>
 <20180416165258.GH2341@sasha-vm>
 <20180416170010.GA11034@amd>
 <20180417104637.GD8445@kroah.com>
 <20180417122454.rwkwpsfvyhpzvvx3@pathway.suse.cz>
 <20180417134557.GT2341@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180417134557.GT2341@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Greg KH <greg@kroah.com>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue 2018-04-17 13:45:59, Sasha Levin wrote:
> On Tue, Apr 17, 2018 at 02:24:54PM +0200, Petr Mladek wrote:
> >Back to the trend. Last week I got autosel mails even for
> >patches that were still being discussed, had issues, and
> >were far from upstream:
> >
> > https://lkml.kernel.org/r/DM5PR2101MB1032AB19B489D46B717B50D4FBBB0@DM5PR2101MB1032.namprd21.prod.outlook.com
> > https://lkml.kernel.org/r/DM5PR2101MB10327FA0A7E0D2C901E33B79FBBB0@DM5PR2101MB1032.namprd21.prod.outlook.com
> >
> >It might be a good idea if the mail asked to add Fixes: tag
> >or stable mailing list. But the mail suggested to add the
> >unfinished patch into stable branch directly (even before
> >upstreaming?).
> 
> I obviously didn't suggest that this patch will go in -stable before
> it's upstream.
> 
> I've started doing those because some folks can't be arsed to reply to a
> review request for a patch that is months old. I found that if I send
> these mails while the discussion is still going on I'd get a much better
> response rate from people.

I see. It makes sense.

> If you think any of these patches should go in stable there were two
> ways about it:
>
>  - You end up adding the -stable tag yourself, and it would follow the
>    usual route where Greg picks it up.
>  - You reply to that mail, and the patch would wait in a list until my
>    script notices it made it upstream, at which point it would get
>    queued for stable.

It would be great if the options are described in the mail.

I wonder if it would make sense to add also a tag that would
say that the commit is not suitable for stable. It might
help both sides. The maintainers will be able to share
their opinion and eventually reduce mails from autosel.
You would get feedback that maintainers considered
the patch for stable. It might be even useful for
teaching the AI.


> >Now, there are only hand full of printk patches in each
> >release, so it is still doable. I just do not understand
> >how other maintainers, from much more busy subsystems,
> >could cope with this trend.
> 
> So yes, I'm aware that the volume of patches is huge, but there's not
> much I can do about it because it's just a subset of the kernel's patch
> volume and since the kernel gets more and more patches each release, the
> volume of stable commits is bound to grow as well.

Yes, but the grow in the stable is much faster than the grow
in maintain at the moment. It might be fine if it was caused
just by engaging subsystems that ignored stable so far. But
I am not sure if it is the case. Also I am not sure about
your plans.

Anyway, I am surprised that the patches might go into stable
so easily (no response -> accepted). While it is pretty
hard to get through the review process for mainline.

Of course, many patches go into mainline without review
as well. But the difference is that they are pushed by
people that are familiar and responsible for the affected
area.

I could understand the pain. There are surely people that
do not care about stable, because it takes time, it is hard
to make decisions, flashbacks to the old code are painful,
etc. Well, this is the reason why the maintenance support
is and should be limited.

Anyway, I think that it cannot be done reasonably without
maintainers. You should be careful so that even the currently
cooperating maintainers will not start considering autosel
mails as a spam. (It is not my case. printk is small thing.
But I could imagine that it might stop being bearable
in bigger subsystems. As is already the case with xfs.)

Best Regards,
Petr
