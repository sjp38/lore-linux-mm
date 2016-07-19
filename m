Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 404E06B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 07:58:06 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p129so10501265wmp.3
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 04:58:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v81si19661698wma.46.2016.07.19.04.58.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jul 2016 04:58:05 -0700 (PDT)
Date: Tue, 19 Jul 2016 13:58:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, oom: fix for hiding mm which is shared with kthread
 or global init
Message-ID: <20160719115801.GH9486@dhcp22.suse.cz>
References: <201607190630.DIH34854.HFOOQFLOJMVFSt@I-love.SAKURA.ne.jp>
 <20160719064048.GA9486@dhcp22.suse.cz>
 <20160719093739.GE9486@dhcp22.suse.cz>
 <201607191936.BEJ82340.OHFOtOFFSQMJVL@I-love.SAKURA.ne.jp>
 <20160719105440.GF9486@dhcp22.suse.cz>
 <201607192043.CEI28519.VtQOMFFSFLOJOH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607192043.CEI28519.VtQOMFFSFLOJOH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, vdavydov@virtuozzo.com, rientjes@google.com

On Tue 19-07-16 20:43:32, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 19-07-16 19:36:40, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
[...]
> > > > And that being said. If you strongly disagree with the wording then what
> > > > about the following:
> > > > "
> > > >     In order to help a forward progress for the OOM killer, make sure that
> > > >     this really rare cases will not get into the way and hide the mm from the
> > > >     oom killer by setting MMF_OOM_REAPED flag for it.  oom_scan_process_thread
> > > >     will ignore any TIF_MEMDIE task if it has MMF_OOM_REAPED flag set to catch
> > > >     these oom victims.
> > > >     
> > > >     After this patch we should guarantee a forward progress for the OOM killer
> > > >     even when the selected victim is sharing memory with a kernel thread or
> > > >     global init as long as the victims mm is still alive.
> > > > "
> > > 
> > > No, I don't like "as long as the victims mm is still alive" exception.
> > 
> > Why? Because of the wording or in principle?
> 
> Making a _guarantee without exceptions now_ can allow other OOM livelock handlings

I am not convinced this particular thing would be the last piece in the
puzzle... And as already said before. Can we wait for the merge window
with the next changes please? I really do not want end up in a situation
where we would have too many oom fixes in flight again. There is no
reason to hurry.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
