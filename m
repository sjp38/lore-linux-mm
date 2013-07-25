Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id E19376B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 03:40:35 -0400 (EDT)
Date: Thu, 25 Jul 2013 09:40:32 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 0/8] memcg, cgroup: kill css_id
Message-ID: <20130725074032.GB12818@dhcp22.suse.cz>
References: <51EFA554.6080801@huawei.com>
 <20130724143214.GL2540@dhcp22.suse.cz>
 <20130724161407.GD20377@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130724161407.GD20377@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Wed 24-07-13 12:14:07, Tejun Heo wrote:
> On Wed, Jul 24, 2013 at 04:32:14PM +0200, Michal Hocko wrote:
> > On Wed 24-07-13 17:58:44, Li Zefan wrote:
> > > This patchset converts memcg to use cgroup->id, and then we can remove
> > > cgroup css_id.
> > > 
> > > As we've removed memcg's own refcnt, converting memcg to use cgroup->id
> > > is very straight-forward.
> > > 
> > > The patchset is based on Tejun's cgroup tree.
> > 
> > Does it depend on any particular patches? I am asking because I would
> > need to cherry pick those and apply them into my -mm git tree before
> > these.
> 
> I'll set up a branch with the prep cgroup patches bsaed on top of
> v3.10 which you can pull into your tree (let's please not cherry-pick)
> and the memcg part and actual css_id removal can be carried through
> -mm.

Great. Thanks a lot Tejun!

> 
> Thanks.
> 
> -- 
> tejun

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
