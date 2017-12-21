Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A72126B0268
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 11:42:48 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c82so4255195wme.8
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 08:42:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y45si15480467wrc.440.2017.12.21.08.42.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Dec 2017 08:42:47 -0800 (PST)
Date: Thu, 21 Dec 2017 17:42:44 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,oom: use ALLOC_OOM for OOM victim's last second
 allocation
Message-ID: <20171221164244.GK4831@dhcp22.suse.cz>
References: <1512646940-3388-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171211115723.GC4779@dhcp22.suse.cz>
 <201712132006.DDE78145.FMFJSOOHVFQtOL@I-love.SAKURA.ne.jp>
 <201712192336.GHG30208.MLFSVJQOHOFtOF@I-love.SAKURA.ne.jp>
 <20171219145508.GZ2787@dhcp22.suse.cz>
 <201712220034.HIC12926.OtQJOOFFVFMSLH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712220034.HIC12926.OtQJOOFFVFMSLH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, rientjes@google.com, hannes@cmpxchg.org, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov.dev@gmail.com

On Fri 22-12-17 00:34:05, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> >                                   Let me repeat something I've said a
> > long ago. We do not optimize for corner cases. We want to survive but if
> > an alternative is to kill another task then we can live with that.
> >  
> 
> Setting MMF_OOM_SKIP before all OOM-killed threads try memory reserves
> leads to needlessly selecting more OOM victims.
> 
> Unless any OOM-killed thread fails to satisfy allocation even with ALLOC_OOM,
> no OOM-killed thread needs to select more OOM victims. Commit 696453e66630ad45
> ("mm, oom: task_will_free_mem should skip oom_reaped tasks") obviously broke
> it, which is exactly a regression.

You are trying to fix a completely artificial case. Or do you have any
example of an application which uses CLONE_VM without sharing signals?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
