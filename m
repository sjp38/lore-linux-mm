Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9BA6B0005
	for <linux-mm@kvack.org>; Mon, 28 May 2018 16:57:35 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id n21-v6so11272836iob.17
        for <linux-mm@kvack.org>; Mon, 28 May 2018 13:57:35 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id y74-v6si27262499iod.102.2018.05.28.13.57.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 May 2018 13:57:33 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with oom_lock held.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180525083118.GI11881@dhcp22.suse.cz>
	<201805251957.EJJ09809.LFJHFFVOOSQOtM@I-love.SAKURA.ne.jp>
	<20180525114213.GJ11881@dhcp22.suse.cz>
	<201805252046.JFF30222.JHSFOFQFMtVOLO@I-love.SAKURA.ne.jp>
	<20180528124313.GC27180@dhcp22.suse.cz>
In-Reply-To: <20180528124313.GC27180@dhcp22.suse.cz>
Message-Id: <201805290557.BAJ39558.MFLtOJVFOHFOSQ@I-love.SAKURA.ne.jp>
Date: Tue, 29 May 2018 05:57:16 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

Michal Hocko wrote:
> On Fri 25-05-18 20:46:21, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Fri 25-05-18 19:57:32, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > What is wrong with the folliwing? should_reclaim_retry should be a
> > > > > natural reschedule point. PF_WQ_WORKER is a special case which needs a
> > > > > stronger rescheduling policy. Doing that unconditionally seems more
> > > > > straightforward than depending on a zone being a good candidate for a
> > > > > further reclaim.
> > > > 
> > > > Where is schedule_timeout_uninterruptible(1) for !PF_KTHREAD threads?
> > > 
> > > Re-read what I've said.
> > 
> > Please show me as a complete patch. Then, I will test your patch.
> 
> So how about we start as simple as the following? If we _really_ need to
> touch should_reclaim_retry then it should be done in a separate patch
> with some numbers/tracing data backing that story.

This patch is incorrect that it ignores the bug in Roman's
"mm, oom: cgroup-aware OOM killer" patch in linux-next. I suggest applying
this patch first, and then fix "mm, oom: cgroup-aware OOM killer" patch.
