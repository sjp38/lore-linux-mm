Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D193D6B0033
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 15:53:45 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id y200so2983808itc.7
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 12:53:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q39sor5649532ioi.274.2018.01.19.12.53.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jan 2018 12:53:44 -0800 (PST)
Date: Fri, 19 Jan 2018 12:53:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
In-Reply-To: <alpine.DEB.2.10.1801171348190.86895@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1801191251080.177541@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com> <alpine.DEB.2.10.1801161814130.28198@chino.kir.corp.google.com> <20180117154155.GU3460072@devbig577.frc2.facebook.com>
 <alpine.DEB.2.10.1801171348190.86895@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 17 Jan 2018, David Rientjes wrote:

> Yes, this is a valid point.  The policy of "tree" and "all" are identical 
> policies and then the mechanism differs wrt to whether one process is 
> killed or all eligible processes are killed, respectively.  My motivation 
> for this was to avoid having two different tunables, especially because 
> later we'll need a way for userspace to influence the decisionmaking to 
> protect (bias against) important subtrees.  What would really be nice is 
> cgroup.subtree_control-type behavior where we could effect a policy and a 
> mechanism at the same time.  It's not clear how that would be handled to 
> allow only one policy and one mechanism, however, in a clean way.  The 
> simplest for the user would be a new file, to specify the mechanism and 
> leave memory.oom_policy alone.  Would another file really be warranted?  
> Not sure.
> 

Hearing no response, I'll implement this as a separate tunable in a v2 
series assuming there are no better ideas proposed before next week.  One 
of the nice things about a separate tunable is that an admin can control 
the overall policy and they can delegate the mechanism (killall vs one 
process) to a user subtree.  I agree with your earlier point that killall 
vs one process is a property of the workload and is better defined 
separately.

I'll also look to fix the breakage wrt root mem cgroup comparison with 
leaf mem cgroup comparison that is currently in -mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
