Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 840A86B007E
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 05:09:03 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id 129so36662044pfw.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 02:09:03 -0800 (PST)
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com. [209.85.192.182])
        by mx.google.com with ESMTPS id g7si11509951pat.103.2016.03.09.02.09.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 02:09:02 -0800 (PST)
Received: by mail-pf0-f182.google.com with SMTP id 129so36661892pfw.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 02:09:02 -0800 (PST)
Date: Wed, 9 Mar 2016 11:08:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: drop unnecessary task_will_free_mem()
 check.
Message-ID: <20160309100859.GD27018@dhcp22.suse.cz>
References: <1457450110-6005-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160308181432.GA9091@cmpxchg.org>
 <201603090805.FGE48462.tFJSLMOFHVOOQF@I-love.SAKURA.ne.jp>
 <20160309100814.GC27018@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160309100814.GC27018@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, vdavydov@virtuozzo.com, linux-mm@kvack.org

On Wed 09-03-16 11:08:14, Michal Hocko wrote:
> On Wed 09-03-16 08:05:11, Tetsuo Handa wrote:
> [...]
> > Also, what is the reason we do not need below change?
> > I think there is a small race window because oom_killer_disabled needs to be
> > checked after oom_killer_disable() held oom_lock. Is it because all userspace
> > processes except current are frozen before oom_killer_disable() is called and
> > not-yet frozen threads (i.e. kernel threads) never call mem_cgroup_out_of_memory() ?
> 
> Please refer to c32b3cbe0d06 ("oom, PM: make OOM detection in the
> freezer path raceless"). It should explain this.

And for the N+1 time, do not conflate different topics into a single
email thread. This is really annoying.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
