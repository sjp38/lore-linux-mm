Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE556B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 06:33:19 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id g62so232984160wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 03:33:19 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id s9si1304158wjf.71.2016.02.17.03.33.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 03:33:18 -0800 (PST)
Received: by mail-wm0-f50.google.com with SMTP id c200so208513625wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 03:33:18 -0800 (PST)
Date: Wed, 17 Feb 2016 12:33:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for
Message-ID: <20160217113316.GD29196@dhcp22.suse.cz>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
 <1454505240-23446-6-git-send-email-mhocko@kernel.org>
 <20160217094855.GC29196@dhcp22.suse.cz>
 <201602171941.EHF67212.HOFSFFJMtOOQLV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602171941.EHF67212.HOFSFFJMtOOQLV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 17-02-16 19:41:53, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > Hi Andrew,
> > although this can be folded into patch 5
> > (mm-oom_reaper-implement-oom-victims-queuing.patch) I think it would be
> > better to have it separate and revert after we sort out the proper
> > oom_kill_allocating_task behavior or handle exclusion at oom_reaper
> > level.
> 
> What a rough workaround. sysctl_oom_kill_allocating_task == 1 does not
> always mean we must skip OOM reaper, for OOM-unkillable callers take
> sysctl_oom_kill_allocating_task == 0 path.

Yes it is indeed rough but also shouldn't add new issues. I consider
oom_kill_allocating_task as a borderline which can be sorted out later.
So while I do not like workarounds like this in general I would rather
go with obvious code first before going for more complex solutions.

> I've just posted a patchset which allows you to merge the OOM reaper
> without correcting problems found in "[PATCH 3/5] oom: clear TIF_MEMDIE
> after oom_reaper managed to unmap the address space" and "[PATCH 5/5]
> mm, oom_reaper: implement OOM victims queuing".

I will try to look at your patches but the series seems unnecessarily
heavy to be a pre-requisite for the oom_reaper.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
