Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6E16B0260
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 18:16:36 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so1068543pfa.2
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 15:16:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id um11si28926646pab.133.2016.07.18.15.16.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jul 2016 15:16:35 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: fix for hiding mm which is shared with kthreador global init
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1468647004-5721-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160718071825.GB22671@dhcp22.suse.cz>
In-Reply-To: <20160718071825.GB22671@dhcp22.suse.cz>
Message-Id: <201607190630.DIH34854.HFOOQFLOJMVFSt@I-love.SAKURA.ne.jp>
Date: Tue, 19 Jul 2016 06:30:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, vdavydov@virtuozzo.com, rientjes@google.com

Michal Hocko wrote:
> I really do not think that this unlikely case really has to be handled
> now. We are very likely going to move to a different model of oom victim
> detection soon. So let's do not add new hacks. exit_oom_victim from
> oom_kill_process just looks like sand in eyes.

Then, please revert "mm, oom: hide mm which is shared with kthread or global init"
( http://lkml.kernel.org/r/1466426628-15074-11-git-send-email-mhocko@kernel.org ).
I don't like that patch because it is doing pointless find_lock_task_mm() test
and is telling a lie because it does not guarantee that we won't hit OOM livelock.
Merging patches with a known lie is sand in eyes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
