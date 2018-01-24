Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id BBB3F800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 16:44:05 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id 102so5391940ior.2
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 13:44:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u135sor695136itb.142.2018.01.24.13.44.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jan 2018 13:44:04 -0800 (PST)
Date: Wed, 24 Jan 2018 13:44:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
In-Reply-To: <20180124082041.GD1526@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1801241340310.24330@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com> <alpine.DEB.2.10.1801161814130.28198@chino.kir.corp.google.com> <20180117154155.GU3460072@devbig577.frc2.facebook.com> <alpine.DEB.2.10.1801171348190.86895@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801191251080.177541@chino.kir.corp.google.com> <20180120123251.GB1096857@devbig577.frc2.facebook.com> <alpine.DEB.2.10.1801221420120.16871@chino.kir.corp.google.com> <20180123155301.GS1526@dhcp22.suse.cz> <alpine.DEB.2.10.1801231416330.254281@chino.kir.corp.google.com>
 <20180124082041.GD1526@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 24 Jan 2018, Michal Hocko wrote:

> > The current implementation of memory.oom_group is based on top of a 
> > selection implementation that is broken in three ways I have listed for 
> > months:
> 
> This doesn't lead to anywhere. You are not presenting any new arguments
> and you are ignoring feedback you have received so far. We have tried
> really hard. Considering different _independent_ people presented more or
> less consistent view on these points I think you should deeply
> reconsider how you take that feedback.
> 

I've responded to each email providing useful feedback on this patchset.  
I agreed with Tejun about not embedding the oom mechanism into 
memory.oom_policy.  I was trying to avoid having two files in the mem 
cgroup v2 filesystem for oom policy and mechanism.  I agreed that 
delegating the mechanism to the workload would be useful in some cases.  
I've solicited feedback on any other opinions on how that can be done 
better, but it appears another tunable is the most convenient way of 
allowing this behavior to be specified.

As a result, this would remove patch 3/4 from the series.  Do you have any 
other feedback regarding the remainder of this patch series before I 
rebase it?

I will address the unfair root mem cgroup vs leaf mem cgroup comparison in 
a separate patchset to fix an issue where any user of oom_score_adj on a 
system that is not fully containerized gets very unusual, unexpected, and 
undocumented results.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
