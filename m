Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2076B0003
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 06:59:13 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u8-v6so1186652pfn.18
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 03:59:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c125-v6si3471151pga.534.2018.08.08.03.59.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 03:59:12 -0700 (PDT)
Date: Wed, 8 Aug 2018 12:59:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] introduce memory.oom.group
Message-ID: <20180808105909.GJ27972@dhcp22.suse.cz>
References: <20180730180100.25079-1-guro@fb.com>
 <alpine.DEB.2.21.1807301847000.198273@chino.kir.corp.google.com>
 <20180731235135.GA23436@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1808011437350.38896@chino.kir.corp.google.com>
 <20180801224706.GA32269@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1808061405100.43071@chino.kir.corp.google.com>
 <20180807003020.GA21483@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1808071519030.237317@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1808071519030.237317@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Tue 07-08-18 15:34:58, David Rientjes wrote:
> On Mon, 6 Aug 2018, Roman Gushchin wrote:
> 
> > > In a cgroup-aware oom killer world, yes, we need the ability to specify 
> > > that the usage of the entire subtree should be compared as a single 
> > > entity with other cgroups.  That is necessary for user subtrees but may 
> > > not be necessary for top-level cgroups depending on how you structure your 
> > > unified cgroup hierarchy.  So it needs to be configurable, as you suggest, 
> > > and you are correct it can be different than oom.group.
> > > 
> > > That's not the only thing we need though, as I'm sure you were expecting 
> > > me to say :)
> > > 
> > > We need the ability to preserve existing behavior, i.e. process based and 
> > > not cgroup aware, for subtrees so that our users who have clear 
> > > expectations and tune their oom_score_adj accordingly based on how the oom 
> > > killer has always chosen processes for oom kill do not suddenly regress.
> > 
> > Isn't the combination of oom.group=0 and oom.evaluate_together=1 describing
> > this case? This basically means that if memcg is selected as target,
> > the process inside will be selected using traditional per-process approach.
> > 
> 
> No, that would overload the policy and mechanism.  We want the ability to 
> consider user-controlled subtrees as a single entity for comparison with 
> other user subtrees to select which subtree to target.  This does not 
> imply that users want their entire subtree oom killed.

Yeah, that's why oom.group == 0, no?

Anyway, can we separate this discussion from the current series please?
We are getting more and more tangent.

Or do you still see the current state to be not mergeable?
-- 
Michal Hocko
SUSE Labs
