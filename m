Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 25C9B6B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 09:16:44 -0400 (EDT)
Received: by obbda8 with SMTP id da8so134013885obb.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 06:16:44 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id t5si9552250oei.69.2015.09.15.06.16.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Sep 2015 06:16:43 -0700 (PDT)
Subject: Re: [RFC 0/8] Allow GFP_NOFS allocation to fail
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
	<201509080151.HDD35430.QtOMHSFLFVOJOF@I-love.SAKURA.ne.jp>
In-Reply-To: <201509080151.HDD35430.QtOMHSFLFVOJOF@I-love.SAKURA.ne.jp>
Message-Id: <201509152216.EEC57388.JLQFFFSHtVOOMO@I-love.SAKURA.ne.jp>
Date: Tue, 15 Sep 2015 22:16:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, david@fromorbit.com, tytso@mit.edu, jack@suse.cz

Tetsuo Handa wrote:
> > Thoughts? Opinions?
> 
> To me, fixing callers (adding __GFP_NORETRY to callers) in a step-by-step
> fashion after adding proactive countermeasure sounds better than changing
> the default behavior (implicitly applying __GFP_NORETRY inside).
> 

Ping?

I showed you at http://marc.info/?l=linux-mm&m=144198479931388 that
changing the default behavior can not terminate the game of Whack-A-Mole.
As long as there are unkillable threads, we can't kill context-sensitive
moles.

I believe that what we need to do now is to add a proactive countermeasure
(e.g. kill more processes) than try to reduce the possibility of hitting
this issue (e.g. allow !__GFP_FS to fail).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
