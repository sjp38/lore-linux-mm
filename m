Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B5D286B000C
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 13:57:58 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id o8so16538115wra.12
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:57:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k13si1682880edl.344.2018.04.17.10.57.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 10:57:56 -0700 (PDT)
Date: Tue, 17 Apr 2018 19:57:54 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180417175754.w4slhmwtf46hq3hm@quack2.suse.cz>
References: <20180416121224.2138b806@gandalf.local.home>
 <20180416161911.GA2341@sasha-vm>
 <20180416123019.4d235374@gandalf.local.home>
 <20180416163754.GD2341@sasha-vm>
 <20180416170604.GC11034@amd>
 <20180416172327.GK2341@sasha-vm>
 <20180417114144.ov27khlig5thqvyo@quack2.suse.cz>
 <20180417133149.GR2341@sasha-vm>
 <20180417155549.6lxmoiwnlwtwdgld@quack2.suse.cz>
 <20180417161933.GY2341@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180417161933.GY2341@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Jan Kara <jack@suse.cz>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue 17-04-18 16:19:35, Sasha Levin wrote:
> On Tue, Apr 17, 2018 at 05:55:49PM +0200, Jan Kara wrote:
> >> Even regression chance is tricky, look at the commits I've linked
> >> earlier in the thread. Even the most trivial looking commits that end up
> >> in stable have a chance for regression.
> >
> >Sure, you can never be certain and I think people (including me)
> >underestimate the chance of regressions for "trivial" patches. But you just
> >estimate a chance, you may be lucky, you may not...
> >
> >> >Another point I wanted to make is that if chance a patch causes a
> >> >regression is about 2% as you said somewhere else in a thread, then by
> >> >adding 20 patches that "may fix a bug that is annoying for someone" you've
> >> >just increased a chance there's a regression in the release by 34%. And
> >>
> >> So I've said that the rejection rate is less than 2%. This includes
> >> all commits that I have proposed for -stable, but didn't end up being
> >> included in -stable.
> >>
> >> This includes commits that the author/maintainers NACKed, commits that
> >> didn't do anything on older kernels, commits that were buggy but were
> >> caught before the kernel was released, commits that failed to build on
> >> an arch I didn't test it on originally and so on.
> >>
> >> After thousands of merged AUTOSEL patches I can count the number of
> >> times a commit has caused a regression and had to be removed on one
> >> hand.
> >>
> >> >this is not just a math game, this also roughly matches a real experience
> >> >with maintaining our enterprise kernels. Do 20 "maybe" fixes outweight such
> >> >regression chance? And I also note that for a regression to get reported so
> >> >that it gets included into your 2% estimate of a patch regression rate,
> >> >someone must be bothered enough by it to triage it and send an email
> >> >somewhere so that already falls into a category of "serious" stuff to me.
> >>
> >> It is indeed a numbers game, but the regression rate isn't 2%, it's
> >> closer to 0.05%.
> >
> >Honestly, I think 0.05% is too optimististic :) Quick grepping of 4.14
> >stable tree suggests some 13 commits were reverted from stable due to bugs.
> >That's some 0.4% and that doesn't count fixes that were applied to
> >fix other regressions.
> 
> 0.05% is for commits that were merged in stable but later fixed or
> reverted because they introduced a regression. By grepping for reverts
> you also include things such as:
> 
>  - Reverts of commits that were in the corresponding mainline tree
>  - Reverts of commits that didn't introduce regressions

Actually I was careful enough to include only commits that got merged as
part of the stable process into 4.14.x but got later reverted in 4.14.y.
That's where the 0.4% number came from. So I believe all of those cases
(13 in absolute numbers) were user visible regressions during the stable
process.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
