Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BECBB6B0005
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 05:02:09 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a12-v6so2669943pfn.12
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 02:02:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i1-v6sor19720096pld.99.2018.06.06.02.02.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Jun 2018 02:02:07 -0700 (PDT)
Date: Wed, 6 Jun 2018 02:02:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
In-Reply-To: <30c750b4-2c65-5737-3172-bddc666d0a8f@i-love.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1806060155120.104813@chino.kir.corp.google.com>
References: <20180525083118.GI11881@dhcp22.suse.cz> <201805251957.EJJ09809.LFJHFFVOOSQOtM@I-love.SAKURA.ne.jp> <20180525114213.GJ11881@dhcp22.suse.cz> <201805252046.JFF30222.JHSFOFQFMtVOLO@I-love.SAKURA.ne.jp> <20180528124313.GC27180@dhcp22.suse.cz>
 <201805290557.BAJ39558.MFLtOJVFOHFOSQ@I-love.SAKURA.ne.jp> <20180529060755.GH27180@dhcp22.suse.cz> <20180529160700.dbc430ebbfac301335ac8cf4@linux-foundation.org> <20180601152801.GH15278@dhcp22.suse.cz> <20180601141110.34915e0a1fdbd07d25cc15cc@linux-foundation.org>
 <20180604070419.GG19202@dhcp22.suse.cz> <30c750b4-2c65-5737-3172-bddc666d0a8f@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, guro@fb.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

On Mon, 4 Jun 2018, Tetsuo Handa wrote:

> Is current version of "mm, oom: cgroup-aware OOM killer" patchset going to be
> dropped for now? I want to know which state should I use for baseline for my patch.
> 

My patchset to fix the issues with regard to the cgroup-aware oom killer 
to fix its calculations (current version in -mm is completey buggy for 
oom_score_adj, fixed in my patch 4/6), its context based errors 
(discounting mempolicy oom kills, fixed in my patch 6/6) and make it 
generally useful beyond highly specialized usecases in a backwards 
compatible way was posted on March 22 at 
https://marc.info/?l=linux-kernel&m=152175564104466.

The base patchset is seemingly abandoned in -mm, unfortunately, so I think 
all oom killer patches should be based on Linus's tree.
