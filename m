Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A34A6B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 07:22:54 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id w95so4040570wrc.20
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 04:22:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n47si3897104wrn.542.2017.12.07.04.22.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 04:22:52 -0800 (PST)
Date: Thu, 7 Dec 2017 13:22:49 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,oom: use ALLOC_OOM for OOM victim's last second
 allocation
Message-ID: <20171207122249.GI20234@dhcp22.suse.cz>
References: <1512646940-3388-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171207115127.GH20234@dhcp22.suse.cz>
 <201712072059.HAJ04643.QSJtVMFLFOOOHF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712072059.HAJ04643.QSJtVMFLFOOOHF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, rientjes@google.com, hannes@cmpxchg.org, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov.dev@gmail.com

On Thu 07-12-17 20:59:34, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 07-12-17 20:42:20, Tetsuo Handa wrote:
> > > Manish Jaggi noticed that running LTP oom01/oom02 ltp tests with high core
> > > count causes random kernel panics when an OOM victim which consumed memory
> > > in a way the OOM reaper does not help was selected by the OOM killer [1].
> > > Since commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
> > > oom_reaped tasks") changed task_will_free_mem(current) in out_of_memory()
> > > to return false as soon as MMF_OOM_SKIP is set, many threads sharing the
> > > victim's mm were not able to try allocation from memory reserves after the
> > > OOM reaper gave up reclaiming memory.
> > > 
> > > Therefore, this patch allows OOM victims to use ALLOC_OOM watermark for
> > > last second allocation attempt.
> > > 
> > > [1] http://lkml.kernel.org/r/e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com
> > > 
> > > Fixes: 696453e66630ad45 ("mm, oom: task_will_free_mem should skip oom_reaped tasks")
> > > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Reported-by: Manish Jaggi <mjaggi@caviumnetworks.com>
> > > Acked-by: Michal Hocko <mhocko@suse.com>
> > 
> > I haven't acked _this_ patch! I will have a look but the patch is
> > different enough from the original that keeping any acks or reviews is
> > inappropriate. Do not do it again!
> 
> I see. But nothing has changed except that this is called before entering
> into the OOM killer. I assumed that this is a trivial change.

Let the reviewers judge and have them add their acks/reviewed-bys again.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
