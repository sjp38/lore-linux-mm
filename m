Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B179B280291
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 04:35:01 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id 80so1617662wmb.7
        for <linux-mm@kvack.org>; Sat, 06 Jan 2018 01:35:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r64si4803078wma.131.2018.01.06.01.35.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 06 Jan 2018 01:35:00 -0800 (PST)
Date: Sat, 6 Jan 2018 10:34:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Set ->signal->oom_mm to all thread groupssharing
 victim's memory.
Message-ID: <20180106093458.GA16576@dhcp22.suse.cz>
References: <1513682774-4416-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171219114012.GK2787@dhcp22.suse.cz>
 <201801061637.CCF78186.OOJFFtMVOLSHQF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201801061637.CCF78186.OOJFFtMVOLSHQF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com

On Sat 06-01-18 16:37:17, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 19-12-17 20:26:14, Tetsuo Handa wrote:
> > > When the OOM reaper set MMF_OOM_SKIP on the victim's mm before threads
> > > sharing that mm get ->signal->oom_mm, the comment "That thread will now
> > > get access to memory reserves since it has a pending fatal signal." no
> > > longer stands. Also, since we introduced ALLOC_OOM watermark, the comment
> > > "They don't get access to memory reserves, though, to avoid depletion of
> > > all memory." no longer stands.
> > > 
> > > This patch treats all thread groups sharing the victim's mm evenly,
> > > and updates the outdated comment.
> > 
> > Nack with a real life example where this matters.
> 
> You did not respond to
> http://lkml.kernel.org/r/201712232341.FGC64072.VFLOOJOtFSFMHQ@I-love.SAKURA.ne.jp ,

Yes I haven't because there is simply no point continuing this
discussion. You are simply immune to any arguments.

> and I observed needless OOM-killing. Therefore, I push this patch again.

Yes, the life is tough and oom heuristic might indeed kill more tasks
for some workloads. But as long as those needless oom killing happens
for artificial workloads I am not all that much interested.  Show me
some workload that is actually real and we can make the current code
more complicated. Without that my position remains.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
