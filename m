Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 03BE28E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 04:40:02 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id y35so1385012edb.5
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 01:40:01 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k25si3761281edk.323.2019.01.08.01.40.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 01:40:00 -0800 (PST)
Date: Tue, 8 Jan 2019 10:39:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
Message-ID: <20190108093959.GQ31793@dhcp22.suse.cz>
References: <20190107143802.16847-3-mhocko@kernel.org>
 <201901081642.Q6tXklr0%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201901081642.Q6tXklr0%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 08-01-19 16:35:42, kbuild test robot wrote:
[...]
> All warnings (new ones prefixed by >>):
> 
>    include/linux/rcupdate.h:659:9: warning: context imbalance in 'find_lock_task_mm' - wrong count at exit
>    include/linux/sched/mm.h:141:37: warning: dereference of noderef expression
>    mm/oom_kill.c:225:28: warning: context imbalance in 'oom_badness' - unexpected unlock
>    mm/oom_kill.c:406:9: warning: context imbalance in 'dump_tasks' - different lock contexts for basic block
> >> mm/oom_kill.c:918:17: warning: context imbalance in '__oom_kill_process' - unexpected unlock

What exactly does this warning say? I do not see anything wrong about
the code. find_lock_task_mm returns a locked task when t != NULL and
mark_oom_victim doesn't do anything about the locking. Am I missing
something or the warning is just confused?

[...]
> 00508538 Michal Hocko          2019-01-07  915  		t = find_lock_task_mm(p);
> 00508538 Michal Hocko          2019-01-07  916  		if (!t)
> 00508538 Michal Hocko          2019-01-07  917  			continue;
> 00508538 Michal Hocko          2019-01-07 @918  		mark_oom_victim(t);
> 00508538 Michal Hocko          2019-01-07  919  		task_unlock(t);
> 647f2bdf David Rientjes        2012-03-21  920  	}

-- 
Michal Hocko
SUSE Labs
