Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0B66B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 08:07:19 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id r129so133024311wmr.1
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 05:07:19 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id ck9si2750723wjc.88.2016.03.23.05.07.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 05:07:18 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id u125so3712083wmg.0
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 05:07:17 -0700 (PDT)
Date: Wed, 23 Mar 2016 13:07:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/9] oom reaper v6
Message-ID: <20160323120716.GE7059@dhcp22.suse.cz>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1603221507150.22638@chino.kir.corp.google.com>
 <201603232011.HDI05246.FFMLtVOHOQJFOS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603232011.HDI05246.FFMLtVOHOQJFOS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, hannes@cmpxchg.org, mgorman@suse.de, oleg@redhat.com, a.p.zijlstra@chello.nl, vdavydov@virtuozzo.com

On Wed 23-03-16 20:11:35, Tetsuo Handa wrote:
> David Rientjes wrote:
[...]
> > Tetsuo, have you been able to run your previous test cases on top of this 
> > version and do you have any concerns about it or possible extensions that 
> > could be made?
> > 
> 
> I think [PATCH 3/9] [PATCH 4/9] [PATCH 8/9] will be mostly reverted.
> My concerns and possible extensions are explained in
> 
>     Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task
>     http://lkml.kernel.org/r/201603152015.JAE86937.VFOLtQFOFJOSHM@I-love.SAKURA.ne.jp

I believe issues you have raised there are a matter for further
discussion as they are potential improvements of the existing
functionality rather than fixing a regression of the current code.

> . Regarding "[PATCH 4/9] mm, oom_reaper: report success/failure",
> debug_show_all_locks() may not be safe
> 
>     commit 856848737bd944c1 "lockdep: fix debug_show_all_locks()"
>     commit 82a1fcb90287052a "softlockup: automatically detect hung TASK_UNINTERRUPTIBLE tasks"

Let me ask again. What exactly is unsafe about calling
debug_show_all_locks here? It is true that 856848737bd944c1 has
changed debug_show_all_locks to ignore running tasks which limits
this functionality to some degree but I still think this might be
useful. Proposed alternatives were way too verbose and complex on its
own. This is something to be further discussed as well, though.

> and showing traces might be more useful.
> (A discussion for making printk() completely async is in progress.)
> 
> But we don't have time to update this series before merge window for 4.6 closes.
> We want to send current patchset as is for now, don't we? So, please go ahead.

I am happy that we are on the same patch here.

> My other concerns about OOM handling:

Let's stick to oom reaper here, please.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
