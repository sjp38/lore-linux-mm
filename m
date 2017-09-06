Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF18280449
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 13:41:14 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id h80so5310360lfe.7
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 10:41:14 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id q125si122406ljq.171.2017.09.06.10.41.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Sep 2017 10:41:12 -0700 (PDT)
Date: Wed, 6 Sep 2017 18:40:43 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
Message-ID: <20170906174043.GA12579@castle.DHCP.thefacebook.com>
References: <20170904142108.7165-1-guro@fb.com>
 <20170904142108.7165-6-guro@fb.com>
 <20170905134412.qdvqcfhvbdzmarna@dhcp22.suse.cz>
 <20170905143021.GA28599@castle.dhcp.TheFacebook.com>
 <20170905151251.luh4wogjd3msfqgf@dhcp22.suse.cz>
 <20170905191609.GA19687@castle.dhcp.TheFacebook.com>
 <20170906084242.l4rcx6n3hdzxvil6@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170906084242.l4rcx6n3hdzxvil6@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

sOn Wed, Sep 06, 2017 at 10:42:42AM +0200, Michal Hocko wrote:
> On Tue 05-09-17 20:16:09, Roman Gushchin wrote:
> > On Tue, Sep 05, 2017 at 05:12:51PM +0200, Michal Hocko wrote:
> [...]
> > > > Then we should probably hide corresponding
> > > > cgroup interface (oom_group and oom_priority knobs) by default,
> > > > and it feels as unnecessary complication and is overall against
> > > > cgroup v2 interface design.
> > > 
> > > Why. If we care enough, we could simply return EINVAL when those knobs
> > > are written while the corresponding strategy is not used.
> > 
> > It doesn't look as a nice default interface.
> 
> I do not have a strong opinion on this. A printk_once could explain why
> the knob is ignored and instruct the admin how to enable the feature
> completely.
>  
> > > > > I think we should instead go with
> > > > > oom_strategy=[alloc_task,biggest_task,cgroup]
> > > > 
> > > > It would be a really nice interface; although I've no idea how to implement it:
> > > > "alloc_task" is an existing sysctl, which we have to preserve;
> > > 
> > > I would argue that we should simply deprecate and later drop the sysctl.
> > > I _strongly_ suspect anybody is using this. If yes it is not that hard
> > > to change the kernel command like rather than select the sysctl.
> > 
> > I agree. And if so, why do we need a new interface for an useless feature?
> 
> Well, I won't be opposed just deprecating the sysfs and only add a
> "real" kill-allocate strategy if somebody explicitly asks for it.


I think we should select this approach.
Let's check that nobody actually uses it.

Thanks!

--
