Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 686636B0005
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 11:28:04 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id t185-v6so928904wmt.8
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 08:28:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h34-v6si1085290edc.132.2018.06.01.08.28.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Jun 2018 08:28:03 -0700 (PDT)
Date: Fri, 1 Jun 2018 17:28:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180601152801.GH15278@dhcp22.suse.cz>
References: <20180525083118.GI11881@dhcp22.suse.cz>
 <201805251957.EJJ09809.LFJHFFVOOSQOtM@I-love.SAKURA.ne.jp>
 <20180525114213.GJ11881@dhcp22.suse.cz>
 <201805252046.JFF30222.JHSFOFQFMtVOLO@I-love.SAKURA.ne.jp>
 <20180528124313.GC27180@dhcp22.suse.cz>
 <201805290557.BAJ39558.MFLtOJVFOHFOSQ@I-love.SAKURA.ne.jp>
 <20180529060755.GH27180@dhcp22.suse.cz>
 <20180529160700.dbc430ebbfac301335ac8cf4@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180529160700.dbc430ebbfac301335ac8cf4@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

On Tue 29-05-18 16:07:00, Andrew Morton wrote:
> On Tue, 29 May 2018 09:17:41 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > I suggest applying
> > > this patch first, and then fix "mm, oom: cgroup-aware OOM killer" patch.
> > 
> > Well, I hope the whole pile gets merged in the upcoming merge window
> > rather than stall even more.
> 
> I'm more inclined to drop it all.  David has identified significant
> shortcomings and I'm not seeing a way of addressing those shortcomings
> in a backward-compatible fashion.  Therefore there is no way forward
> at present.

Well, I thought we have argued about those "shortcomings" back and forth
and expressed that they are not really a problem for workloads which are
going to use the feature. The backward compatibility has been explained
as well AFAICT. Anyway if this is your position on the matter then I
just give up. I've tried to do my best to review the feature (as !author
nor the end user) and I cannot do really much more. I find it quite sad
though to be honest.
-- 
Michal Hocko
SUSE Labs
