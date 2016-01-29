Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 179AF6B0253
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:17:58 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l66so58832786wml.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 07:17:58 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id pd7si22756577wjb.47.2016.01.29.07.17.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 07:17:56 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id r129so10456070wmr.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 07:17:56 -0800 (PST)
Date: Fri, 29 Jan 2016 16:17:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/3] mm, vmscan: make zone_reclaimable_pages more precise
Message-ID: <20160129151755.GE32174@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <1454015979-9985-1-git-send-email-mhocko@kernel.org>
 <201601291935.BGJ95389.VOLMFOOHFStQFJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601291935.BGJ95389.VOLMFOOHFStQFJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 29-01-16 19:35:18, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > zone_reclaimable_pages is used in should_reclaim_retry which uses it to
> > calculate the target for the watermark check. This means that precise
> > numbers are important for the correct decision. zone_reclaimable_pages
> > uses zone_page_state which can contain stale data with per-cpu diffs
> > not synced yet (the last vmstat_update might have run 1s in the past).
> > 
> > Use zone_page_state_snapshot in zone_reclaimable_pages instead. None
> > of the current callers is in a hot path where getting the precise value
> > (which involves per-cpu iteration) would cause an unreasonable overhead.
> > 
> > Suggested-by: David Rientjes <rientjes@google.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/vmscan.c | 14 +++++++-------
> >  1 file changed, 7 insertions(+), 7 deletions(-)
> > 
> 
> I didn't know http://lkml.kernel.org/r/20151021130323.GC8805@dhcp22.suse.cz
> was forgotten. Anyway,

OK, that explains why this sounded so familiar. Sorry I comepletely
forgot about it.

> Acked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Can I change it to your Signed-off-by?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
