Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA266B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 03:04:22 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b12-v6so5783016wrs.10
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 00:04:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j2-v6si668256edp.51.2018.06.04.00.04.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Jun 2018 00:04:20 -0700 (PDT)
Date: Mon, 4 Jun 2018 09:04:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180604070419.GG19202@dhcp22.suse.cz>
References: <20180525083118.GI11881@dhcp22.suse.cz>
 <201805251957.EJJ09809.LFJHFFVOOSQOtM@I-love.SAKURA.ne.jp>
 <20180525114213.GJ11881@dhcp22.suse.cz>
 <201805252046.JFF30222.JHSFOFQFMtVOLO@I-love.SAKURA.ne.jp>
 <20180528124313.GC27180@dhcp22.suse.cz>
 <201805290557.BAJ39558.MFLtOJVFOHFOSQ@I-love.SAKURA.ne.jp>
 <20180529060755.GH27180@dhcp22.suse.cz>
 <20180529160700.dbc430ebbfac301335ac8cf4@linux-foundation.org>
 <20180601152801.GH15278@dhcp22.suse.cz>
 <20180601141110.34915e0a1fdbd07d25cc15cc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180601141110.34915e0a1fdbd07d25cc15cc@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

On Fri 01-06-18 14:11:10, Andrew Morton wrote:
> On Fri, 1 Jun 2018 17:28:01 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Tue 29-05-18 16:07:00, Andrew Morton wrote:
> > > On Tue, 29 May 2018 09:17:41 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > > 
> > > > > I suggest applying
> > > > > this patch first, and then fix "mm, oom: cgroup-aware OOM killer" patch.
> > > > 
> > > > Well, I hope the whole pile gets merged in the upcoming merge window
> > > > rather than stall even more.
> > > 
> > > I'm more inclined to drop it all.  David has identified significant
> > > shortcomings and I'm not seeing a way of addressing those shortcomings
> > > in a backward-compatible fashion.  Therefore there is no way forward
> > > at present.
> > 
> > Well, I thought we have argued about those "shortcomings" back and forth
> > and expressed that they are not really a problem for workloads which are
> > going to use the feature. The backward compatibility has been explained
> > as well AFAICT.
> 
> Feel free to re-explain.  It's the only way we'll get there.

OK, I will go and my points to the last version of the patchset.

> David has proposed an alternative patchset.  IIRC Roman gave that a
> one-line positive response but I don't think it has seen a lot of
> attention?

I plan to go and revisit that. My preliminary feedback is that a more
generic policy API is really tricky and the patchset has many holes
there. But I will come with a more specific feedback in the respective
thread.

-- 
Michal Hocko
SUSE Labs
