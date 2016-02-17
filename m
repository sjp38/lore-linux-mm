Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id D9D156B0253
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:42:10 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id gc3so7825044obb.3
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 02:42:10 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k6si667677oib.75.2016.02.17.02.42.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 02:42:10 -0800 (PST)
Subject: Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
	<1454505240-23446-6-git-send-email-mhocko@kernel.org>
	<20160217094855.GC29196@dhcp22.suse.cz>
In-Reply-To: <20160217094855.GC29196@dhcp22.suse.cz>
Message-Id: <201602171941.EHF67212.HOFSFFJMtOOQLV@I-love.SAKURA.ne.jp>
Date: Wed, 17 Feb 2016 19:41:53 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> Hi Andrew,
> although this can be folded into patch 5
> (mm-oom_reaper-implement-oom-victims-queuing.patch) I think it would be
> better to have it separate and revert after we sort out the proper
> oom_kill_allocating_task behavior or handle exclusion at oom_reaper
> level.

What a rough workaround. sysctl_oom_kill_allocating_task == 1 does not
always mean we must skip OOM reaper, for OOM-unkillable callers take
sysctl_oom_kill_allocating_task == 0 path.

I've just posted a patchset which allows you to merge the OOM reaper
without correcting problems found in "[PATCH 3/5] oom: clear TIF_MEMDIE
after oom_reaper managed to unmap the address space" and "[PATCH 5/5]
mm, oom_reaper: implement OOM victims queuing".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
