Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id D3A9E6B0255
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 16:30:41 -0500 (EST)
Received: by mail-oi0-f53.google.com with SMTP id k206so55757757oia.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:30:41 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id nz3si14005536obc.61.2016.01.29.13.30.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Jan 2016 13:30:40 -0800 (PST)
Subject: Re: [PATCH 5/3] mm, vmscan: make zone_reclaimable_pages more precise
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
	<1454015979-9985-1-git-send-email-mhocko@kernel.org>
	<201601291935.BGJ95389.VOLMFOOHFStQFJ@I-love.SAKURA.ne.jp>
	<20160129151755.GE32174@dhcp22.suse.cz>
In-Reply-To: <20160129151755.GE32174@dhcp22.suse.cz>
Message-Id: <201601300630.HBC43269.JFHFQFOVOLOMtS@I-love.SAKURA.ne.jp>
Date: Sat, 30 Jan 2016 06:30:15 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 29-01-16 19:35:18, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > zone_reclaimable_pages is used in should_reclaim_retry which uses it to
> > > calculate the target for the watermark check. This means that precise
> > > numbers are important for the correct decision. zone_reclaimable_pages
> > > uses zone_page_state which can contain stale data with per-cpu diffs
> > > not synced yet (the last vmstat_update might have run 1s in the past).
> > > 
> > > Use zone_page_state_snapshot in zone_reclaimable_pages instead. None
> > > of the current callers is in a hot path where getting the precise value
> > > (which involves per-cpu iteration) would cause an unreasonable overhead.
> > > 
> > > Suggested-by: David Rientjes <rientjes@google.com>
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > ---
> > >  mm/vmscan.c | 14 +++++++-------
> > >  1 file changed, 7 insertions(+), 7 deletions(-)
> > > 
> > 
> > I didn't know http://lkml.kernel.org/r/20151021130323.GC8805@dhcp22.suse.cz
> > was forgotten. Anyway,
> 
> OK, that explains why this sounded so familiar. Sorry I comepletely
> forgot about it.
> 
> > Acked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> Can I change it to your Signed-off-by?

No problem.

> 
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
