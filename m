Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 2A42D6B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 18:12:49 -0400 (EDT)
Date: Wed, 27 Jun 2012 00:12:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: first step towards hierarchical controller
Message-ID: <20120626221246.GB4653@tiehlicka.suse.cz>
References: <1340717428-9009-1-git-send-email-glommer@parallels.com>
 <20120626181209.GR3869@google.com>
 <4FE9FDCC.80000@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FE9FDCC.80000@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue 26-06-12 22:22:04, Glauber Costa wrote:
> On 06/26/2012 10:12 PM, Tejun Heo wrote:
> >On Tue, Jun 26, 2012 at 05:30:28PM +0400, Glauber Costa wrote:
> >>Okay, so after recent discussions, I am proposing the following
> >>patch. It won't remove hierarchy, or anything like that. Just default
> >>to true in the root cgroup, and print a warning once if you try
> >>to set it back to 0.
> >>
> >>I am not adding it to feature-removal-schedule.txt because I don't
> >>view it as a consensus. Rather, changing the default would allow us
> >>to give it a time around in the open, and see if people complain
> >>and what we can learn about that.
> >>
> >>Signed-off-by: Glauber Costa <glommer@parallels.com>
> >>CC: Michal Hocko <mhocko@suse.cz>
> >>CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >>CC: Johannes Weiner <hannes@cmpxchg.org>
> >>CC: Tejun Heo <tj@kernel.org>
> >
> >Just in case it wasn't clear in the other posting.
> >
> >  Nacked-by: Tejun Heo <tj@kernel.org>
> >
> >You can't change the default behavior silently.  Not in this scale.
> >
> >Thanks.
> >
> I certainly don't share your views of the matter here.
> 
> I would agree with you if we were changing a fundamental algorithm,
> with no way to resort back to a default setup. We are not removing any
> functionality whatsoever here.
> 
> I would agree with you if we were actually documenting explicitly
> that this is an expected default behavior.

Actually we did:
Documentation/cgroups/memory.txt
"
6.1 Enabling hierarchical accounting and reclaim

A memory cgroup by default disables the hierarchy feature. Support
can be enabled by writing 1 to memory.use_hierarchy file of the root
cgroup
"

But I do not think this is really that important. We are still
interested in making the thing sane. Flat_hierarchical trees just don't
seem right... Generic? Sure. Sane? Really?

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
