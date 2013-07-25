Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id B54F96B0033
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 03:41:47 -0400 (EDT)
Date: Thu, 25 Jul 2013 09:41:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 0/8] memcg, cgroup: kill css_id
Message-ID: <20130725074146.GC12818@dhcp22.suse.cz>
References: <51EFA554.6080801@huawei.com>
 <20130724143214.GL2540@dhcp22.suse.cz>
 <51F07863.2070705@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F07863.2070705@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Thu 25-07-13 08:59:15, Li Zefan wrote:
> On 2013/7/24 22:32, Michal Hocko wrote:
> > On Wed 24-07-13 17:58:44, Li Zefan wrote:
> >> This patchset converts memcg to use cgroup->id, and then we can remove
> >> cgroup css_id.
> >>
> >> As we've removed memcg's own refcnt, converting memcg to use cgroup->id
> >> is very straight-forward.
> >>
> >> The patchset is based on Tejun's cgroup tree.
> > 
> > Does it depend on any particular patches? I am asking because I would
> > need to cherry pick those and apply them into my -mm git tree before
> > these.
> > 
> 
> Nope, but you should see a few but small conflicts if you apply them to
> your git tree.
 
Ohh, then there is no problem at all and Tejun, doesn't have to prepare
any special branch.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
