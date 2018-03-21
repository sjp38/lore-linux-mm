Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id EBA096B0024
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 06:39:42 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id d77-v6so383868oig.5
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 03:39:42 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 64si980848oid.447.2018.03.21.03.39.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 03:39:41 -0700 (PDT)
Subject: Re: [PATCH v3] mm,page_alloc: wait for oom_lock than back off
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180226121933.GC16269@dhcp22.suse.cz>
	<201802262216.ADH48949.FtQLFOHJOVSOMF@I-love.SAKURA.ne.jp>
	<201803022010.BJE26043.LtSOOVFQOMJFHF@I-love.SAKURA.ne.jp>
	<20180302141000.GB12772@dhcp22.suse.cz>
	<201803031215.FCJ69722.OtJFLQVFMFOSOH@I-love.SAKURA.ne.jp>
In-Reply-To: <201803031215.FCJ69722.OtJFLQVFMFOSOH@I-love.SAKURA.ne.jp>
Message-Id: <201803211939.EFG92060.tFSHOFQFOMJLOV@I-love.SAKURA.ne.jp>
Date: Wed, 21 Mar 2018 19:39:32 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > But since Michal is still worrying that adding a single synchronization
> > > point into the OOM path is risky (without showing a real life example
> > > where lock_killable() in the coldest OOM path hurts), changes made by
> > > this patch will be enabled only when oom_compat_mode=0 kernel command line
> > > parameter is specified so that users can test whether their workloads get
> > > hurt by this patch.
> > > 
> > Nacked with passion. This is absolutely hideous. First of all there is
> > absolutely no need for the kernel command line. That is just trying to
> > dance around the fact that you are not able to argue for the change
> > and bring reasonable arguments on the table. We definitely do not want
> > two subtly different modes for the oom handling. Secondly, and repeatedly,
> > you are squashing multiple changes into a single patch. And finally this
> > is too big of a hammer for something that even doesn't solve the problem
> > for PREEMPTIVE kernels which are free to schedule regardless of the
> > sleep or the reclaim retry you are so passion about.
> 
> So, where is your version? Offload to a kernel thread like the OOM reaper?
> Get rid of oom_lock? Just rejecting my proposal makes no progress.
> 
Did you come up with some idea?
Even CONFIG_PREEMPT=y, as far as I tested, v2 patch significantly reduces stalls than now.
I believe there is no valid reason not to test my v2 patch at linux-next.
