Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 06D9B6B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 22:13:11 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id r185so207667021ywf.3
        for <linux-mm@kvack.org>; Thu, 19 May 2016 19:13:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b67si15596241qke.206.2016.05.19.19.13.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 19:13:10 -0700 (PDT)
Date: Fri, 20 May 2016 04:13:07 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v3] mm,oom: speed up select_bad_process() loop.
Message-ID: <20160520021306.GA20224@redhat.com>
References: <1463574024-8372-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160518125138.GH21654@dhcp22.suse.cz>
 <201605182230.IDC73435.MVSOHLFOQFOJtF@I-love.SAKURA.ne.jp>
 <20160518141545.GI21654@dhcp22.suse.cz>
 <20160518140932.6643b963e8d3fc49ff64df8d@linux-foundation.org>
 <20160519065329.GA26110@dhcp22.suse.cz>
 <20160520015000.GA20132@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160520015000.GA20132@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com, linux-mm@kvack.org

On 05/20, Oleg Nesterov wrote:
>
> On 05/19, Michal Hocko wrote:
> >
> > Long term I
> > would like to to move this logic into the mm_struct, it would be just
> > larger surgery I guess.
>
> Why we can't do this right now? Just another MMF_ flag set only once and
> never cleared.

Just in case... yes, "never cleared" is not that simple because oom_kill_process()
can find a OOM_SCORE_ADJ_MIN process (or is_global_init) later. But to me this just
looks like another proof that select_bad_process() must not pick such a task (mm!)
as victim.

Nevermind, I said many times that I do not understand OOM-killer, please ignore me.
But sorry, can't resist, I do not think that "signal_struct has some holes[1] so
we can stitch it there." can excuse the new member ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
