Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7E2596B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 16:54:23 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id a186so2430554pge.5
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 13:54:23 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 62sor829713pfs.27.2017.08.28.13.54.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Aug 2017 13:54:22 -0700 (PDT)
Date: Mon, 28 Aug 2017 13:54:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v6 3/4] mm, oom: introduce oom_priority for memory cgroups
In-Reply-To: <20170824141108.GB21167@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.10.1708281353080.9719@chino.kir.corp.google.com>
References: <20170823165201.24086-1-guro@fb.com> <20170823165201.24086-4-guro@fb.com> <20170824121054.GI5943@dhcp22.suse.cz> <20170824125113.GB15916@castle.DHCP.thefacebook.com> <20170824134859.GO5943@dhcp22.suse.cz>
 <20170824141108.GB21167@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 24 Aug 2017, Roman Gushchin wrote:

> > > Do you have an example, which can't be effectively handled by an approach
> > > I'm suggesting?
> > 
> > No, I do not have any which would be _explicitly_ requested but I do
> > envision new requirements will emerge. The most probable one would be
> > kill the youngest container because that would imply the least amount of
> > work wasted.
> 
> I agree, this a nice feature. It can be implemented in userspace
> by setting oom_priority.
> 

Yes, the "kill the newest memory cgroup as a tiebreak" is not strictly 
required in the kernel and no cgroup should depend on this implementation 
detail to avoid being killed if it shares the same memory.oom_priority as 
another cgroup.  As you mention, it can be effectively implemented by 
userspace itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
