Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id A6A8B6B007E
	for <linux-mm@kvack.org>; Sat,  9 Apr 2016 00:39:39 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id td3so86119667pab.2
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 21:39:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r1si4802799pai.141.2016.04.08.21.39.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Apr 2016 21:39:38 -0700 (PDT)
Subject: Re: [PATCH 2/3] oom, oom_reaper: Try to reap tasks which skipregular OOM killer path
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
	<1459951996-12875-3-git-send-email-mhocko@kernel.org>
	<201604072038.CHC51027.MSJOFVLHOFFtQO@I-love.SAKURA.ne.jp>
	<201604082019.EDH52671.OJHQFMStOFLVOF@I-love.SAKURA.ne.jp>
	<20160408115033.GH29820@dhcp22.suse.cz>
In-Reply-To: <20160408115033.GH29820@dhcp22.suse.cz>
Message-Id: <201604091339.FAJ12491.FVHQFFMSJLtOOO@I-love.SAKURA.ne.jp>
Date: Sat, 9 Apr 2016 13:39:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, oleg@redhat.com

Michal Hocko wrote:
> On Fri 08-04-16 20:19:28, Tetsuo Handa wrote:
> > I looked at next-20160408 but I again came to think that we should remove
> > these shortcuts (something like a patch shown bottom).
>
> feel free to send the patch with the full description. But I would
> really encourage you to check the history to learn why those have been
> added and describe why those concerns are not valid/important anymore.

I believe that past discussions and decisions about current code are too
optimistic because they did not take 'The "too small to fail" memory-
allocation rule' problem into account.

If you ignore me with "check the history to learn why those have been added
and describe why those concerns are not valid/important anymore", I can do
nothing. What are valid/important concerns that have higher priority than
keeping 'The "too small to fail" memory-allocation rule' problem and continue
telling a lie to end users? Please enumerate such concerns.

> Your way of throwing a large patch based on an extreme load which is
> basically DoSing the machine is not the ideal one.

You are not paying attention to real world's limitations I'm facing.
I have to waste my resource trying to identify and fix on behalf of
customers before they determine the kernel version to use for their
systems, for your way of thinking is that "We don't need to worry about
it because I have never received such report" while the reality of
customers is that "I'm not skillful enough to catch the problematic
behavior and make a reproducer" or "I have a little skill but I'm not
permitted to modify my systems for reporting the problematic behavior".
If you listen to me, I don't need to do such thing. It is very very sad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
