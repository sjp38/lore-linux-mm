Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 30D686B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 06:44:56 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id x2-v6so13167515plv.0
        for <linux-mm@kvack.org>; Thu, 31 May 2018 03:44:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d8-v6si28109040pgn.428.2018.05.31.03.44.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 May 2018 03:44:54 -0700 (PDT)
Date: Thu, 31 May 2018 12:44:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180531104450.GN15278@dhcp22.suse.cz>
References: <20180525083118.GI11881@dhcp22.suse.cz>
 <201805251957.EJJ09809.LFJHFFVOOSQOtM@I-love.SAKURA.ne.jp>
 <20180525114213.GJ11881@dhcp22.suse.cz>
 <201805252046.JFF30222.JHSFOFQFMtVOLO@I-love.SAKURA.ne.jp>
 <20180528124313.GC27180@dhcp22.suse.cz>
 <201805290557.BAJ39558.MFLtOJVFOHFOSQ@I-love.SAKURA.ne.jp>
 <20180529060755.GH27180@dhcp22.suse.cz>
 <20180529160700.dbc430ebbfac301335ac8cf4@linux-foundation.org>
 <16eca862-5fa6-2333-8a81-94a2c2692758@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16eca862-5fa6-2333-8a81-94a2c2692758@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org

On Thu 31-05-18 19:10:48, Tetsuo Handa wrote:
> On 2018/05/30 8:07, Andrew Morton wrote:
> > On Tue, 29 May 2018 09:17:41 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > 
> >>> I suggest applying
> >>> this patch first, and then fix "mm, oom: cgroup-aware OOM killer" patch.
> >>
> >> Well, I hope the whole pile gets merged in the upcoming merge window
> >> rather than stall even more.
> > 
> > I'm more inclined to drop it all.  David has identified significant
> > shortcomings and I'm not seeing a way of addressing those shortcomings
> > in a backward-compatible fashion.  Therefore there is no way forward
> > at present.
> > 
> 
> Can we apply my patch as-is first?

No. As already explained before. Sprinkling new sleeps without a strong
reason is not acceptable. The issue you are seeing is pretty artificial
and as such doesn're really warrant an immediate fix. We should rather
go with a well thought trhough fix. In other words we should simply drop
the sleep inside the oom_lock for starter unless it causes some really
unexpected behavior change.
-- 
Michal Hocko
SUSE Labs
