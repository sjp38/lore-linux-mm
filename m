Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 259576B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 04:38:21 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 34so22991489wrb.20
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 01:38:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c133si14340276wme.67.2017.04.03.01.38.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 01:38:19 -0700 (PDT)
Date: Mon, 3 Apr 2017 10:38:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: oom: Bogus "sysrq: OOM request ignored because killer is
 disabled" message
Message-ID: <20170403083800.GF24661@dhcp22.suse.cz>
References: <201704021252.GIF21549.QFFOFOMVJtHSLO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201704021252.GIF21549.QFFOFOMVJtHSLO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: vdavydov@virtuozzo.com, hannes@cmpxchg.org, rientjes@google.com, linux-mm@kvack.org

On Sun 02-04-17 12:52:55, Tetsuo Handa wrote:
> I noticed that SysRq-f prints
> 
>   "sysrq: OOM request ignored because killer is disabled"
> 
> when no process was selected (rather than when oom killer was disabled).
> This message was not printed until Linux 4.8 because commit 7c5f64f84483bd13
> ("mm: oom: deduplicate victim selection code for memcg and global oom") changed
>  from "return true;" to "return !!oc->chosen;" when is_sysrq_oom(oc) is true.
> 
> Is this what we meant?
> 
> [  713.805315] sysrq: SysRq : Manual OOM execution
> [  713.808920] Out of memory: Kill process 4468 ((agetty)) score 0 or sacrifice child
> [  713.814913] Killed process 4468 ((agetty)) total-vm:43704kB, anon-rss:1760kB, file-rss:0kB, shmem-rss:0kB
> [  714.004805] sysrq: SysRq : Manual OOM execution
> [  714.005936] Out of memory: Kill process 4469 (systemd-cgroups) score 0 or sacrifice child
> [  714.008117] Killed process 4469 (systemd-cgroups) total-vm:10704kB, anon-rss:120kB, file-rss:0kB, shmem-rss:0kB
> [  714.189310] sysrq: SysRq : Manual OOM execution
> [  714.193425] sysrq: OOM request ignored because killer is disabled
> [  714.381313] sysrq: SysRq : Manual OOM execution
> [  714.385158] sysrq: OOM request ignored because killer is disabled
> [  714.573320] sysrq: SysRq : Manual OOM execution
> [  714.576988] sysrq: OOM request ignored because killer is disabled

So, what about this?
---
