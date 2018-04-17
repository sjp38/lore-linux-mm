Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA1316B000E
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 14:10:29 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b10so5648813wrf.3
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 11:10:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m13si12756329edi.197.2018.04.17.11.10.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 11:10:28 -0700 (PDT)
Date: Tue, 17 Apr 2018 20:10:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180417181025.GJ17484@dhcp22.suse.cz>
References: <20180416163107.GC2341@sasha-vm>
 <20180416124711.048f1858@gandalf.local.home>
 <20180416165258.GH2341@sasha-vm>
 <20180416170010.GA11034@amd>
 <20180417104637.GD8445@kroah.com>
 <20180417122454.rwkwpsfvyhpzvvx3@pathway.suse.cz>
 <20180417124924.GE17484@dhcp22.suse.cz>
 <20180417133931.GS2341@sasha-vm>
 <20180417142246.GH17484@dhcp22.suse.cz>
 <20180417143641.GV2341@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180417143641.GV2341@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Petr Mladek <pmladek@suse.com>, Greg KH <greg@kroah.com>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue 17-04-18 14:36:44, Sasha Levin wrote:
> On Tue, Apr 17, 2018 at 04:22:46PM +0200, Michal Hocko wrote:
> >On Tue 17-04-18 13:39:33, Sasha Levin wrote:
> >[...]
> >> But mm/ commits don't come only from these people. Here's a concrete
> >> example we can discuss:
> >>
> >> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c61611f70958d86f659bca25c02ae69413747a8d
> >
> >I would be really careful. Because that reqiures to audit all callers to
> >be compliant with the change. This is just _too_ easy to backport
> >without noticing a failure. Now consider the other side. Is there any
> >real bug report backing this? This behavior was like that for quite some
> >time but I do not remember any actual bug report and the changelog
> >doesn't mention one either. It is about theoretical problem.
> 
> https://lkml.org/lkml/2018/3/19/430
> 
> There's even a fun little reproducer that allowed me to confirm it's an
> issue (at least) on 4.15.
> 
> Heck, it might even qualify as a CVE.
> 
> >So if this was to be merged to stable then the changelog should contain
> >a big fat warning about the existing users and how they should be
> >checked.
> 
> So what I'm asking is why *wasn't* it sent to stable? Yes, it requires
> additional work backporting this, but what I'm saying is that this
> didn't happen at all.

Do not ask me. I wasn't involved. But I would _guess_ that the original
bug is not all that serious because it requires some specific privileges
and it is quite unlikely that somebody privileged would want to shoot
its feet. But this is just my wild guess.

Anyway, I am pretty sure that if the triggering BUG was serious enough
then it would be much safer to remove it for stable backports.
-- 
Michal Hocko
SUSE Labs
