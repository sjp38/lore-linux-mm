Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0136B0005
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 14:45:01 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id b31-v6so3824864plb.5
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 11:45:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i8-v6sor5433715pgt.20.2018.06.06.11.45.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Jun 2018 11:45:00 -0700 (PDT)
Date: Wed, 6 Jun 2018 11:44:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
In-Reply-To: <bb08ebf7-e950-f3e2-d794-bff289fb22a9@i-love.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1806061143140.210542@chino.kir.corp.google.com>
References: <20180525083118.GI11881@dhcp22.suse.cz> <201805251957.EJJ09809.LFJHFFVOOSQOtM@I-love.SAKURA.ne.jp> <20180525114213.GJ11881@dhcp22.suse.cz> <201805252046.JFF30222.JHSFOFQFMtVOLO@I-love.SAKURA.ne.jp> <20180528124313.GC27180@dhcp22.suse.cz>
 <201805290557.BAJ39558.MFLtOJVFOHFOSQ@I-love.SAKURA.ne.jp> <20180529060755.GH27180@dhcp22.suse.cz> <20180529160700.dbc430ebbfac301335ac8cf4@linux-foundation.org> <20180601152801.GH15278@dhcp22.suse.cz> <20180601141110.34915e0a1fdbd07d25cc15cc@linux-foundation.org>
 <20180604070419.GG19202@dhcp22.suse.cz> <30c750b4-2c65-5737-3172-bddc666d0a8f@i-love.sakura.ne.jp> <alpine.DEB.2.21.1806060155120.104813@chino.kir.corp.google.com> <bb08ebf7-e950-f3e2-d794-bff289fb22a9@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, guro@fb.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

On Wed, 6 Jun 2018, Tetsuo Handa wrote:

> OK. I will use linux.git as a base.
> 
> By the way, does "[RFC] Getting rid of INFLIGHT_VICTIM" simplify or break
> your cgroup-aware oom killer? If it simplifies your work, I'd like to apply
> it as well.
> 

I think it impacts the proposal to allow the oom reaper to operate over 
several different mm's in its list without processing one, waiting to give 
up, removing it, and moving on to the next one.  It doesn't impact the 
cgroup-aware oom killer extension that I made other than trivial patch 
conflicts.  I think if we can iterate over the oom reaper list to 
determine inflight victims it's simpler.
