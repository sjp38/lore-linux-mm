Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 76797828EB
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 16:30:29 -0500 (EST)
Received: by mail-io0-f182.google.com with SMTP id 1so316086973ion.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 13:30:29 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q6si27486211igr.96.2016.01.11.13.30.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jan 2016 13:30:28 -0800 (PST)
Subject: Re: [PATCH] mm,oom: do not loop !__GFP_FS allocation if the OOM killer is disabled.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1452488836-6772-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160111170047.GB32132@cmpxchg.org>
	<20160111172058.GK27317@dhcp22.suse.cz>
	<20160111174329.GA377@cmpxchg.org>
	<20160111174958.GM27317@dhcp22.suse.cz>
In-Reply-To: <20160111174958.GM27317@dhcp22.suse.cz>
Message-Id: <201601120630.ICG86454.FFMFVSOOtHJOQL@I-love.SAKURA.ne.jp>
Date: Tue, 12 Jan 2016 06:30:15 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, hannes@cmpxchg.org
Cc: rientjes@google.com, linux-mm@kvack.org

Michal Hocko wrote:
> > Scratch my objection to this patch then. But please do add to/update
> > that XXX comment above that line, or it'll be confusing. Hm?
> > 
> > 			/*
> > 			 * XXX: Page reclaim didn't yield anything,
> > 			 * and the OOM killer can't be invoked, but
> > 			 * keep looping as per tradition. Unless the
> > 			 * system is trying to enter a quiescent state
> > 			 * during suspend and the OOM killer has been
> > 			 * shut off already. Give up like with other
> > 			 * !__GFP_NOFAIL allocations in that case.
> > 			 */
> > 			*did_some_progress = !oom_killer_disabled;
> 
> Yes this makes it more clear IMO.
> 
If you don't want to expose oom_killer_disabled outside of the OOM proper,
can't we move this "if (!(gfp_mask & __GFP_FS)) { ... }" block to before
constraint = constrained_alloc(oc, &totalpages) line in out_of_memory() ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
