Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 4EDA26B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 14:48:41 -0400 (EDT)
Date: Thu, 25 Oct 2012 20:48:34 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/6] cgroups: forbid pre_destroy callback to fail
Message-ID: <20121025184834.GB20618@dhcp22.suse.cz>
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
 <1350480648-10905-5-git-send-email-mhocko@suse.cz>
 <20121018224148.GR13370@google.com>
 <20121019133244.GE799@dhcp22.suse.cz>
 <20121019202405.GR13370@google.com>
 <20121022103021.GA6367@dhcp22.suse.cz>
 <20121024192535.GG12182@atj.dyndns.org>
 <20121025143756.GI11105@dhcp22.suse.cz>
 <20121025174220.GJ11442@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121025174220.GJ11442@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

On Thu 25-10-12 10:42:20, Tejun Heo wrote:
> Hey, Michal.
> 
> On Thu, Oct 25, 2012 at 04:37:56PM +0200, Michal Hocko wrote:
> > I am not sure I understand you here. So are you suggesting
> > s/BUG_ON/WARN_ON_ONCE/ in this patch?
> 
> Oh, no, I meant that we can do upto patch 3 of this series and then
> follow up with proper cgroup core update and then stack further
> memcg cleanups on top.

I thought the later cleanups would be on top of the series.

> > > Let's create a cgroup branch and build things there.  I don't think
> > > cgroup changes are gonna be a single patch and expect to see at least
> > > some bug fixes afterwards and don't wanna keep them floating separate
> > > from other cgroup changes.  
> > 
> > > mm being based on top of -next, that should work, right?
> > 
> > Well, a tree based on -next is, ehm, impractical. I can create a bug on
> > top of my -mm git branch (where I merge your cgroup common changes) for
> > development and then when we are ready we can send it as a series and
> > push it via Andrew. Would that work for you?
> > Or we can push the core part via Andrew, wait for the merge and work on
> > the follow up cleanups later?
> > It is not like the follow up part is really urgent, isn't it? I would
> > just like the memcg part settled first because this can potentially
> > conflict with other memcg work.
> 
> Argh... can we pretty *please* just do a plain git branch?  I don't
> care where it is but I want to be able to pull it into cgroup core and

Hohumm, I have tried to apply the series on top of Linus' 3.6 and there
were no conflicts so I can create a branch which you can pull into your
cgroup branch (which I can then merge into -mm git tree).
This would however mean that those patches wouldn't fly through Andrew's
tree. Is this really what we want and what does it give to us?

> yes I do wanna make this happen in this devel cycle.  We've been
> sitting on it far too long waiting for memcg.

I can surely imagine that (for the memcg part) but it needs throughout
review.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
