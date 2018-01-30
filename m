Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 528C56B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 03:54:51 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id p20so9959931pfh.17
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 00:54:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6-v6si1372168plg.575.2018.01.30.00.54.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 00:54:50 -0800 (PST)
Date: Tue, 30 Jan 2018 09:54:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm v2 2/3] mm, memcg: replace cgroup aware oom killer
 mount option with tunable
Message-ID: <20180130085445.GQ21609@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801251552320.161808@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801251553030.161808@chino.kir.corp.google.com>
 <20180125160016.30e019e546125bb13b5b6b4f@linux-foundation.org>
 <alpine.DEB.2.10.1801261415090.15318@chino.kir.corp.google.com>
 <20180126143950.719912507bd993d92188877f@linux-foundation.org>
 <alpine.DEB.2.10.1801261441340.20954@chino.kir.corp.google.com>
 <20180126161735.b999356fbe96c0acd33aaa66@linux-foundation.org>
 <20180129104657.GC21609@dhcp22.suse.cz>
 <20180129191139.GA1121507@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180129191139.GA1121507@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 29-01-18 11:11:39, Tejun Heo wrote:
> Hello, Michal.
> 
> On Mon, Jan 29, 2018 at 11:46:57AM +0100, Michal Hocko wrote:
> > @@ -1292,7 +1292,11 @@ the memory controller considers only cgroups belonging to the sub-tree
> >  of the OOM'ing cgroup.
> >  
> >  The root cgroup is treated as a leaf memory cgroup, so it's compared
> > -with other leaf memory cgroups and cgroups with oom_group option set.
> > +with other leaf memory cgroups and cgroups with oom_group option
> > +set. Due to internal implementation restrictions the size of the root
> > +cgroup is a cumulative sum of oom_badness of all its tasks (in other
> > +words oom_score_adj of each task is obeyed). This might change in the
> > +future.
> 
> Thanks, we can definitely use more documentation.  However, it's a bit
> difficult to follow.  Maybe expand it to a separate paragraph on the
> current behavior with a clear warning that the default OOM heuristics
> is subject to changes?

Does this sound any better?
