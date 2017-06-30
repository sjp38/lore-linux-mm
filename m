Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B7D452802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 09:32:40 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l81so7289704wmg.8
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 06:32:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w1si6595657wrb.205.2017.06.30.06.32.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 06:32:39 -0700 (PDT)
Date: Fri, 30 Jun 2017 15:32:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-ID: <20170630133236.GM22917@dhcp22.suse.cz>
References: <20170307133057.26182-1-mhocko@kernel.org>
 <1488916356.6405.4.camel@redhat.com>
 <20170309180540.GA8678@cmpxchg.org>
 <20170310102010.GD3753@dhcp22.suse.cz>
 <201703102044.DBJ04626.FLVMFOQOJtOFHS@I-love.SAKURA.ne.jp>
 <201706300914.CEH95859.FMQOLVFHJFtOOS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706300914.CEH95859.FMQOLVFHJFtOOS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 30-06-17 09:14:22, Tetsuo Handa wrote:
[...]
> Ping? Ping? When are we going to apply this patch or watchdog patch?
> This problem occurs with not so insane stress like shown below.
> I can't test almost OOM situation because test likely falls into either
> printk() v.s. oom_lock lockup problem or this too_many_isolated() problem.

So you are saying that the patch fixes this issue. Do I understand you
corretly? And you do not see any other negative side effectes with it
applied?

I am sorry I didn't have much time to think about feedback from Johannes
yet. A more robust throttling method is surely due but also not trivial.
So I am not sure how to proceed. It is true that your last test case
with only 10 processes fighting resembles the reality much better than
hundreds (AFAIR) that you were using previously.

Rik, Johannes what do you think? Should we go with the simpler approach
for now and think of a better plan longterm?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
