Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB0546B0008
	for <linux-mm@kvack.org>; Tue, 29 May 2018 03:17:43 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id n9-v6so8499642wmh.6
        for <linux-mm@kvack.org>; Tue, 29 May 2018 00:17:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c5-v6si63415edn.411.2018.05.29.00.17.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 May 2018 00:17:42 -0700 (PDT)
Date: Tue, 29 May 2018 09:17:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180529060755.GH27180@dhcp22.suse.cz>
References: <20180525083118.GI11881@dhcp22.suse.cz>
 <201805251957.EJJ09809.LFJHFFVOOSQOtM@I-love.SAKURA.ne.jp>
 <20180525114213.GJ11881@dhcp22.suse.cz>
 <201805252046.JFF30222.JHSFOFQFMtVOLO@I-love.SAKURA.ne.jp>
 <20180528124313.GC27180@dhcp22.suse.cz>
 <201805290557.BAJ39558.MFLtOJVFOHFOSQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805290557.BAJ39558.MFLtOJVFOHFOSQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Tue 29-05-18 05:57:16, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 25-05-18 20:46:21, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Fri 25-05-18 19:57:32, Tetsuo Handa wrote:
> > > > > Michal Hocko wrote:
> > > > > > What is wrong with the folliwing? should_reclaim_retry should be a
> > > > > > natural reschedule point. PF_WQ_WORKER is a special case which needs a
> > > > > > stronger rescheduling policy. Doing that unconditionally seems more
> > > > > > straightforward than depending on a zone being a good candidate for a
> > > > > > further reclaim.
> > > > > 
> > > > > Where is schedule_timeout_uninterruptible(1) for !PF_KTHREAD threads?
> > > > 
> > > > Re-read what I've said.
> > > 
> > > Please show me as a complete patch. Then, I will test your patch.
> > 
> > So how about we start as simple as the following? If we _really_ need to
> > touch should_reclaim_retry then it should be done in a separate patch
> > with some numbers/tracing data backing that story.
> 
> This patch is incorrect that it ignores the bug in Roman's
> "mm, oom: cgroup-aware OOM killer" patch in linux-next.

I've expected Roman to comment on that. The fix should be trivial. But
does that prevent from further testing of this patch? Are you actually
using cgroup OOM killer? If not the bug should be a non-issue, right?

> I suggest applying
> this patch first, and then fix "mm, oom: cgroup-aware OOM killer" patch.

Well, I hope the whole pile gets merged in the upcoming merge window
rather than stall even more. This patch however can wait some more.
There is no hurry to merge it right away.
-- 
Michal Hocko
SUSE Labs
