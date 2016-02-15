Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id BA88D6B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 15:47:29 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id c200so130740985wme.0
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 12:47:29 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id r123si27900501wmb.8.2016.02.15.12.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 12:47:28 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id g62so17542953wme.2
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 12:47:28 -0800 (PST)
Date: Mon, 15 Feb 2016 21:47:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/5] oom: clear TIF_MEMDIE after oom_reaper managed to
 unmap the address space
Message-ID: <20160215204725.GD9223@dhcp22.suse.cz>
References: <20160204144319.GD14425@dhcp22.suse.cz>
 <201602050008.HEG12919.FFOMOHVtQFSLJO@I-love.SAKURA.ne.jp>
 <20160204163113.GF14425@dhcp22.suse.cz>
 <201602052014.HBG52666.HFMOQVLFOSFJtO@I-love.SAKURA.ne.jp>
 <20160206083014.GA25220@dhcp22.suse.cz>
 <201602062023.ECG12960.QVStLJOHFOFMOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602062023.ECG12960.QVStLJOHFOFMOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 06-02-16 20:23:43, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> By always waking the OOM reaper up, we can delegate the duty of unlocking
> the OOM killer (by clearing TIF_MEMDIE or some other means) to the OOM
> reaper because the OOM reaper is tracking all TIF_MEMDIE tasks.

And again, I didn't say this would be incorrect. I am just saying that
this will get more complex if we want to handle all the cases properly.

> > I would like to target the next merge window rather than have this out
> > of tree for another release cycle which means that we should really
> > focus on the current functionality and make sure we haven't missed
> > anything. As there is no fundamental disagreement to the approach all
> > the rest are just technicalities.
> 
> Of course, we can target the OOM reaper for the next merge window. I'm
> suggesting you that my changes would help handling corner cases (bugs)
> you are not paying attention to.

I am paying attention to them. I just think that incremental changes are
preferable and we should start with simpler cases before we go further
steps. There is no reason to rush this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
