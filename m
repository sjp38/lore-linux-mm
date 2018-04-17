Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5356B0003
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:25:01 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z7so5520171wrg.11
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 05:25:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 28si926140edv.265.2018.04.17.05.24.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 05:24:59 -0700 (PDT)
Date: Tue, 17 Apr 2018 14:24:54 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180417122454.rwkwpsfvyhpzvvx3@pathway.suse.cz>
References: <20180416153031.GA5039@amd>
 <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd>
 <20180416161412.GZ2341@sasha-vm>
 <20180416122244.146aec48@gandalf.local.home>
 <20180416163107.GC2341@sasha-vm>
 <20180416124711.048f1858@gandalf.local.home>
 <20180416165258.GH2341@sasha-vm>
 <20180416170010.GA11034@amd>
 <20180417104637.GD8445@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180417104637.GD8445@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Pavel Machek <pavel@ucw.cz>, Sasha Levin <Alexander.Levin@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue 2018-04-17 12:46:37, Greg KH wrote:
> Oh, I know why, suddenly subsystems that never were taking the time to
> mark patches for stable are getting patches backported and are getting
> nervous.

Yes, I am getting nervous because of this. The number of printk fixes
nominated for stable is increasing exponentially (just my feeling)
during last few months.

The problem is that I want to be responsible and think about possible
regressions. Sometimes it requires checking the state of the
particular kernel release. The older code base the more complicated
the decision is.

You might argue that backporting the fixes helps to get the same code
in all supported code bases. But it is not true. It never will be
the same.


Anyway, in the past the "automatically" nominated printk fixes
were trivial. They did not cause harm. But they also were not
worth it, IMHO. They fixed corner cases that were there for ages.
Most of these fixes were found by code review when working on
a feature. They were not backed by bug reports.


Last week, autosel nominated pretty non-trivial patch (started
this thread). It partly solved a problem we tried to fix last few
years.

On one side, this was an annoying problem that motivated several
people spend a lot of time on it. This might be a motivation
for a backport.

On the other hand, it took many years to come somewhere. The main
problem was the fear of regressions. We fixed/improved many things
in the mean time. It shows that the problem really is not trivial.
The same is true for the fix. We did our best to avoid regressions.
But it does not mean that there are none. Also it does not mean
that it will really give better results in all situations.

I really do not see a reason to hurry and backport this to
the older kernel releases. It means to spread the fix but also
eventual problems. It is easy to miss a dependant patch.
The less trivial fix, the more possible problems are there.



Back to the trend. Last week I got autosel mails even for
patches that were still being discussed, had issues, and
were far from upstream:

https://lkml.kernel.org/r/DM5PR2101MB1032AB19B489D46B717B50D4FBBB0@DM5PR2101MB1032.namprd21.prod.outlook.com
https://lkml.kernel.org/r/DM5PR2101MB10327FA0A7E0D2C901E33B79FBBB0@DM5PR2101MB1032.namprd21.prod.outlook.com

It might be a good idea if the mail asked to add Fixes: tag
or stable mailing list. But the mail suggested to add the
unfinished patch into stable branch directly (even before
upstreaming?).


Now, there are only hand full of printk patches in each
release, so it is still doable. I just do not understand
how other maintainers, from much more busy subsystems,
could cope with this trend.

By other words. If you want to automatize patch nomination,
you might need to automatize also patch review. Or you need
to keep the patch rate low. This might mean to nominate
only important and rather trivial fixes.


Best Regards,
Petr
