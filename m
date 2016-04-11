Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2436B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:26:23 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id td3so121703313pab.2
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 06:26:23 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q73si3551983pfi.65.2016.04.11.06.26.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 06:26:22 -0700 (PDT)
Subject: Re: [PATCH 2/3] oom, oom_reaper: Try to reap tasks which skip regular OOM killer path
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201604072038.CHC51027.MSJOFVLHOFFtQO@I-love.SAKURA.ne.jp>
	<201604082019.EDH52671.OJHQFMStOFLVOF@I-love.SAKURA.ne.jp>
	<20160408115033.GH29820@dhcp22.suse.cz>
	<201604091339.FAJ12491.FVHQFFMSJLtOOO@I-love.SAKURA.ne.jp>
	<20160411120238.GF23157@dhcp22.suse.cz>
In-Reply-To: <20160411120238.GF23157@dhcp22.suse.cz>
Message-Id: <201604112226.IFC52662.FOFVtQSJLOFMOH@I-love.SAKURA.ne.jp>
Date: Mon, 11 Apr 2016 22:26:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, oleg@redhat.com

Michal Hocko wrote:
> On Sat 09-04-16 13:39:30, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Fri 08-04-16 20:19:28, Tetsuo Handa wrote:
> > > > I looked at next-20160408 but I again came to think that we should remove
> > > > these shortcuts (something like a patch shown bottom).
> > >
> > > feel free to send the patch with the full description. But I would
> > > really encourage you to check the history to learn why those have been
> > > added and describe why those concerns are not valid/important anymore.
> > 
> > I believe that past discussions and decisions about current code are too
> > optimistic because they did not take 'The "too small to fail" memory-
> > allocation rule' problem into account.
> 
> In most cases they were driven by _real_ usecases though. And that
> is what matters. Theoretically possible issues which happen under
> crazy workloads which are DoSing the machine already are not something
> to optimize for. Sure we should try to cope with them as gracefully
> as possible, no questions about that, but we should try hard not to
> reintroduce previous issues during _sensible_ workloads.

I'm not requesting you to optimize for crazy workloads. None of my
customers intentionally put crazy workloads, but they are getting silent
hangups and I'm suspecting that something went wrong with memory management.
But there is no evidence because memory management subsystem remains silent.
You call my testcases DoS, but there is no evidence that my customers
are not hitting the same problem my testcases found.

I'm suggesting you to at least emit diagnostic messages when something went
wrong. That is what kmallocwd is for. And if you do not want to emit
diagnostic messages, I'm fine with timeout based approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
