Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 00F0F6B0006
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 07:35:57 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id e9so4029578ioj.18
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 04:35:56 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g3si2915000ioa.258.2018.03.21.04.35.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 04:35:55 -0700 (PDT)
Subject: Re: [PATCH v3] mm,page_alloc: wait for oom_lock than back off
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201803022010.BJE26043.LtSOOVFQOMJFHF@I-love.SAKURA.ne.jp>
	<20180302141000.GB12772@dhcp22.suse.cz>
	<201803031215.FCJ69722.OtJFLQVFMFOSOH@I-love.SAKURA.ne.jp>
	<201803211939.EFG92060.tFSHOFQFOMJLOV@I-love.SAKURA.ne.jp>
	<20180321112124.GF23100@dhcp22.suse.cz>
In-Reply-To: <20180321112124.GF23100@dhcp22.suse.cz>
Message-Id: <201803212035.HAD30253.OOQHFMFtVFOJLS@I-love.SAKURA.ne.jp>
Date: Wed, 21 Mar 2018 20:35:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

Michal Hocko wrote:
> On Wed 21-03-18 19:39:32, Tetsuo Handa wrote:
> > Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > > But since Michal is still worrying that adding a single synchronization
> > > > > point into the OOM path is risky (without showing a real life example
> > > > > where lock_killable() in the coldest OOM path hurts), changes made by
> > > > > this patch will be enabled only when oom_compat_mode=0 kernel command line
> > > > > parameter is specified so that users can test whether their workloads get
> > > > > hurt by this patch.
> > > > > 
> > > > Nacked with passion. This is absolutely hideous. First of all there is
> > > > absolutely no need for the kernel command line. That is just trying to
> > > > dance around the fact that you are not able to argue for the change
> > > > and bring reasonable arguments on the table. We definitely do not want
> > > > two subtly different modes for the oom handling. Secondly, and repeatedly,
> > > > you are squashing multiple changes into a single patch. And finally this
> > > > is too big of a hammer for something that even doesn't solve the problem
> > > > for PREEMPTIVE kernels which are free to schedule regardless of the
> > > > sleep or the reclaim retry you are so passion about.
> > > 
> > > So, where is your version? Offload to a kernel thread like the OOM reaper?
> > > Get rid of oom_lock? Just rejecting my proposal makes no progress.
> > > 
> > Did you come up with some idea?
> > Even CONFIG_PREEMPT=y, as far as I tested, v2 patch significantly reduces stalls than now.
> > I believe there is no valid reason not to test my v2 patch at linux-next.
> 
> There are and I've mentioned them in my review feedback.
> 
Where? When I tried to disable preemption while oom_lock is held,
you suggested not to disable preemption. Thus, I followed your feedback.
Now, you again complain about preemption.

When I tried to replace only mutex_trylock() with mutex_lock_killable() in v1,
you said we need followup changes. Thus, I added followup changes in v2.

What are still missing? I can't understand what you are saying.
