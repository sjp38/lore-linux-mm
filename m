Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 102EF6B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 08:20:33 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e3so40713304wme.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 05:20:33 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id f123si8029132wmf.1.2016.06.03.05.20.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 05:20:32 -0700 (PDT)
Received: by mail-wm0-f52.google.com with SMTP id n184so123370728wmn.1
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 05:20:31 -0700 (PDT)
Date: Fri, 3 Jun 2016 14:20:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/10 -v3] Handle oom bypass more gracefully
Message-ID: <20160603122030.GG20676@dhcp22.suse.cz>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
 <201606032100.AIH12958.HMOOOFLJSFQtVF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606032100.AIH12958.HMOOOFLJSFQtVF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Fri 03-06-16 21:00:31, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > Patch 8 is new in this version and it addresses an issue pointed out
> > by 0-day OOM report where an oom victim was reaped several times.
> 
> I believe we need below once-you-nacked patch as well.
> 
> It would be possible to clear victim->signal->oom_flag_origin when
> that victim gets TIF_MEMDIE, but I think that moving oom_task_origin()
> test to oom_badness() will allow oom_scan_process_thread() which calls
> oom_unkillable_task() only for testing task->signal->oom_victims to be
> removed by also moving task->signal->oom_victims test to oom_badness().
> Thus, I prefer this way.

Can we please forget about oom_task_origin for _now_. At least until we
resolve the current pile? I am really skeptical oom_task_origin is a
real problem and even if you think it might be and pulling its handling
outside of oom_scan_process_thread would be better for other reasons we
can do that later. Or do you insist this all has to be done in one go?

To be honest, I feel less and less confident as the pile grows and
chances of introducing new bugs just grows after each rebase which tries
to address more subtle and unlikely issues.

Do no take me wrong but I would rather make sure that the current pile
is reviewed and no unintentional side effects are introduced than open
yet another can of worms.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
