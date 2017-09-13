Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 79A486B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 08:23:15 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m30so84703pgn.2
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 05:23:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h1si6808861pld.665.2017.09.13.05.23.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Sep 2017 05:23:14 -0700 (PDT)
Date: Wed, 13 Sep 2017 14:23:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v8 3/4] mm, oom: add cgroup v2 mount option for cgroup-aware
 OOM killer
Message-ID: <20170913122309.dsnbt3t3m5sa7qgk@dhcp22.suse.cz>
References: <20170911131742.16482-1-guro@fb.com>
 <20170911131742.16482-4-guro@fb.com>
 <alpine.DEB.2.10.1709111345320.102819@chino.kir.corp.google.com>
 <20170912200115.GA25218@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170912200115.GA25218@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 12-09-17 21:01:15, Roman Gushchin wrote:
> On Mon, Sep 11, 2017 at 01:48:39PM -0700, David Rientjes wrote:
> > On Mon, 11 Sep 2017, Roman Gushchin wrote:
> > 
> > > Add a "groupoom" cgroup v2 mount option to enable the cgroup-aware
> > > OOM killer. If not set, the OOM selection is performed in
> > > a "traditional" per-process way.
> > > 
> > > The behavior can be changed dynamically by remounting the cgroupfs.
> > 
> > I can't imagine that Tejun would be happy with a new mount option, 
> > especially when it's not required.
> > 
> > OOM behavior does not need to be defined at mount time and for the entire 
> > hierarchy.  It's possible to very easily implement a tunable as part of 
> > mem cgroup that is propagated to descendants and controls the oom scoring 
> > behavior for that hierarchy.  It does not need to be system wide and 
> > affect scoring of all processes based on which mem cgroup they are 
> > attached to at any given time.
> 
> No, I don't think that mixing per-cgroup and per-process OOM selection
> algorithms is a good idea.
> 
> So, there are 3 reasonable options:
> 1) boot option
> 2) sysctl
> 3) cgroup mount option
> 
> I believe, 3) is better, because it allows changing the behavior dynamically,
> and explicitly depends on v2 (what sysctl lacks).

I see your argument here. I would just be worried that we end up really
needing more oom strategies in future and those wouldn't fit into memcg
mount option scope. So 1/2 sounds more exensible to me long term. Boot
time would be easier because we do not have to bother dynamic selection
in that case.

> So, the only question is should it be opt-in or opt-out option.
> Personally, I would prefer opt-out, but Michal has a very strong opinion here.

Yes I still strongly believe this has to be opt-in.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
