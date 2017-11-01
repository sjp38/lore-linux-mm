Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7A06B0283
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 11:16:04 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g6so2776576pgn.11
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 08:16:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x85si1279500pff.344.2017.11.01.08.16.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 08:16:03 -0700 (PDT)
Date: Wed, 1 Nov 2017 16:16:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm,oom: Use ALLOC_OOM for OOM victim's last second
 allocation.
Message-ID: <20171101151600.olalzdipejtylkok@dhcp22.suse.cz>
References: <1509537268-4726-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1509537268-4726-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171101135855.bqg2kuj6ao2cicqi@dhcp22.suse.cz>
 <201711020008.EHB87824.QFFOJMLOHVFSOt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711020008.EHB87824.QFFOJMLOHVFSOt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov@virtuozzo.com

On Thu 02-11-17 00:08:59, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > I am not sure about this part though. If the oom_reaper cannot take the
> > mmap_sem then it retries for 1s. Have you ever seen the race to be that
> > large?
> 
> Like shown in [2], khugepaged can prevent oom_reaper from taking the mmap_sem
> for 1 second. Also, it won't be impossible for OOM victims to spend 1 second
> between post __gfp_pfmemalloc_flags(gfp_mask) and pre mutex_trylock(&oom_lock)
> (in other words, the race window (1-2) above). Therefore, non artificial
> workloads could hit the same result.

but this is a speculation so I wouldn't mention it in the changelog. It
might confuse readers.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
