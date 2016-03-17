Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id C00346B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 11:20:49 -0400 (EDT)
Received: by mail-ob0-f177.google.com with SMTP id m7so86746622obh.3
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 08:20:49 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k194si4995567oib.149.2016.03.17.08.20.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Mar 2016 08:20:47 -0700 (PDT)
Subject: Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160317121751.GE26017@dhcp22.suse.cz>
	<201603172200.CIE52148.QOVSOHJFMLOFtF@I-love.SAKURA.ne.jp>
	<20160317132335.GF26017@dhcp22.suse.cz>
	<201603172334.EGD54504.OLFQVJFOtMHFOS@I-love.SAKURA.ne.jp>
	<20160317145433.GG26017@dhcp22.suse.cz>
In-Reply-To: <20160317145433.GG26017@dhcp22.suse.cz>
Message-Id: <201603180020.IGB30229.LOSFJQHtFVMOOF@I-love.SAKURA.ne.jp>
Date: Fri, 18 Mar 2016 00:20:41 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> > Strictly speaking, neither debug_show_all_locks() nor debug_show_held_locks()
> > are safe enough to guarantee that the system won't crash.
> > 
> >   commit 856848737bd944c1 "lockdep: fix debug_show_all_locks()"
> >   commit 82a1fcb90287052a "softlockup: automatically detect hung TASK_UNINTERRUPTIBLE tasks"
> > 
> > They are convenient but we should avoid using them if we care about
> > possibility of crash.
> 
> I really fail to see your point. debug_show_all_locks doesn't mention
> any restriction of the risk nor it is restricted to a particular
> context. Were there some bugs in that area? Probably yes, so what?

commit 856848737bd944c1 changed that locks held by TASK_RUNNING tasks
are not reported. We might fail to report the task which is holding mmap_sem
for write when we call debug_show_all_locks() in order to find such task.
Therefore, I think guessing from sched_show_task() output can be used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
