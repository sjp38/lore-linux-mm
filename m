Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 97E236B000E
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 16:10:13 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id g36-v6so4322931plb.5
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 13:10:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u8-v6sor2402210plz.53.2018.08.09.13.10.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Aug 2018 13:10:12 -0700 (PDT)
Date: Thu, 9 Aug 2018 13:10:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/3] introduce memory.oom.group
In-Reply-To: <20180808105909.GJ27972@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1808091308210.244858@chino.kir.corp.google.com>
References: <20180730180100.25079-1-guro@fb.com> <alpine.DEB.2.21.1807301847000.198273@chino.kir.corp.google.com> <20180731235135.GA23436@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1808011437350.38896@chino.kir.corp.google.com>
 <20180801224706.GA32269@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1808061405100.43071@chino.kir.corp.google.com> <20180807003020.GA21483@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1808071519030.237317@chino.kir.corp.google.com>
 <20180808105909.GJ27972@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Wed, 8 Aug 2018, Michal Hocko wrote:

> > > > In a cgroup-aware oom killer world, yes, we need the ability to specify 
> > > > that the usage of the entire subtree should be compared as a single 
> > > > entity with other cgroups.  That is necessary for user subtrees but may 
> > > > not be necessary for top-level cgroups depending on how you structure your 
> > > > unified cgroup hierarchy.  So it needs to be configurable, as you suggest, 
> > > > and you are correct it can be different than oom.group.
> > > > 
> > > > That's not the only thing we need though, as I'm sure you were expecting 
> > > > me to say :)
> > > > 
> > > > We need the ability to preserve existing behavior, i.e. process based and 
> > > > not cgroup aware, for subtrees so that our users who have clear 
> > > > expectations and tune their oom_score_adj accordingly based on how the oom 
> > > > killer has always chosen processes for oom kill do not suddenly regress.
> > > 
> > > Isn't the combination of oom.group=0 and oom.evaluate_together=1 describing
> > > this case? This basically means that if memcg is selected as target,
> > > the process inside will be selected using traditional per-process approach.
> > > 
> > 
> > No, that would overload the policy and mechanism.  We want the ability to 
> > consider user-controlled subtrees as a single entity for comparison with 
> > other user subtrees to select which subtree to target.  This does not 
> > imply that users want their entire subtree oom killed.
> 
> Yeah, that's why oom.group == 0, no?
> 
> Anyway, can we separate this discussion from the current series please?
> We are getting more and more tangent.
> 
> Or do you still see the current state to be not mergeable?

I've said three times in this series that I am fine with it.  Roman and I 
are discussing the API for making forward progress with the cgroup aware 
oom killer itself.  When he responds, he can change the subject line if 
that would be helpful to you.
