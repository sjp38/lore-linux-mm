Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E44B6B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 22:15:25 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id 100so6392007oti.19
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 19:15:25 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id h15si2397089otk.17.2018.03.02.19.15.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Mar 2018 19:15:24 -0800 (PST)
Subject: Re: [PATCH v3] mm,page_alloc: wait for oom_lock than back off
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201802261958.JDE18780.SFHOFOMOJFQVtL@I-love.SAKURA.ne.jp>
	<20180226121933.GC16269@dhcp22.suse.cz>
	<201802262216.ADH48949.FtQLFOHJOVSOMF@I-love.SAKURA.ne.jp>
	<201803022010.BJE26043.LtSOOVFQOMJFHF@I-love.SAKURA.ne.jp>
	<20180302141000.GB12772@dhcp22.suse.cz>
In-Reply-To: <20180302141000.GB12772@dhcp22.suse.cz>
Message-Id: <201803031215.FCJ69722.OtJFLQVFMFOSOH@I-love.SAKURA.ne.jp>
Date: Sat, 3 Mar 2018 12:15:07 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

Michal Hocko wrote:
> > But since Michal is still worrying that adding a single synchronization
> > point into the OOM path is risky (without showing a real life example
> > where lock_killable() in the coldest OOM path hurts), changes made by
> > this patch will be enabled only when oom_compat_mode=0 kernel command line
> > parameter is specified so that users can test whether their workloads get
> > hurt by this patch.
> > 
> Nacked with passion. This is absolutely hideous. First of all there is
> absolutely no need for the kernel command line. That is just trying to
> dance around the fact that you are not able to argue for the change
> and bring reasonable arguments on the table. We definitely do not want
> two subtly different modes for the oom handling. Secondly, and repeatedly,
> you are squashing multiple changes into a single patch. And finally this
> is too big of a hammer for something that even doesn't solve the problem
> for PREEMPTIVE kernels which are free to schedule regardless of the
> sleep or the reclaim retry you are so passion about.

So, where is your version? Offload to a kernel thread like the OOM reaper?
Get rid of oom_lock? Just rejecting my proposal makes no progress.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
