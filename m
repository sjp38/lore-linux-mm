Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4B6800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 17:08:09 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id h17so2881455wmc.6
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 14:08:09 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t29si211925wra.430.2018.01.24.14.08.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 14:08:08 -0800 (PST)
Date: Wed, 24 Jan 2018 14:08:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
Message-Id: <20180124140805.b4eb437c6fe9dadb67a32e8a@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1801241340310.24330@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1801161814130.28198@chino.kir.corp.google.com>
	<20180117154155.GU3460072@devbig577.frc2.facebook.com>
	<alpine.DEB.2.10.1801171348190.86895@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1801191251080.177541@chino.kir.corp.google.com>
	<20180120123251.GB1096857@devbig577.frc2.facebook.com>
	<alpine.DEB.2.10.1801221420120.16871@chino.kir.corp.google.com>
	<20180123155301.GS1526@dhcp22.suse.cz>
	<alpine.DEB.2.10.1801231416330.254281@chino.kir.corp.google.com>
	<20180124082041.GD1526@dhcp22.suse.cz>
	<alpine.DEB.2.10.1801241340310.24330@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 24 Jan 2018 13:44:02 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> On Wed, 24 Jan 2018, Michal Hocko wrote:
> 
> > > The current implementation of memory.oom_group is based on top of a 
> > > selection implementation that is broken in three ways I have listed for 
> > > months:
> > 
> > This doesn't lead to anywhere. You are not presenting any new arguments
> > and you are ignoring feedback you have received so far. We have tried
> > really hard. Considering different _independent_ people presented more or
> > less consistent view on these points I think you should deeply
> > reconsider how you take that feedback.
> > 

Please let's remember that people/process issues are unrelated to the
technical desirability of a proposed change.  IOW, assertions along the
lines of "person X is being unreasonable" do little to affect a merge
decision.

> I've responded to each email providing useful feedback on this patchset.  
> I agreed with Tejun about not embedding the oom mechanism into 
> memory.oom_policy.  I was trying to avoid having two files in the mem 
> cgroup v2 filesystem for oom policy and mechanism.  I agreed that 
> delegating the mechanism to the workload would be useful in some cases.  
> I've solicited feedback on any other opinions on how that can be done 
> better, but it appears another tunable is the most convenient way of 
> allowing this behavior to be specified.
> 
> As a result, this would remove patch 3/4 from the series.  Do you have any 
> other feedback regarding the remainder of this patch series before I 
> rebase it?
> 
> I will address the unfair root mem cgroup vs leaf mem cgroup comparison in 
> a separate patchset to fix an issue where any user of oom_score_adj on a 
> system that is not fully containerized gets very unusual, unexpected, and 
> undocumented results.
> 

Can we please try to narrow the scope of this issue by concentrating on
the userspace interfaces?  David believes that the mount option and
memory.oom_group will disappear again in the near future, others
disagree.

What do we do about that?  For example, would it really be a big
problem to continue to support those interfaces in a future iteration
of this feature?  Or is it possible to omit them from this version of
the feature?  Or is it possible to modify them in some fashion so they
will be better compatible with a future iteration of this feature?

I'm OK with merging a probably-partial feature, expecting it to be
enhanced in the future.  What I have a problem with is merging user
interfaces which will be removed or altered in the future.  Please
solve this problem for me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
