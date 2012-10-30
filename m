Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 52EAB6B0071
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 19:37:43 -0400 (EDT)
Date: Wed, 31 Oct 2012 00:37:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg/cgroup: do not fail fail on pre_destroy callbacks
Message-ID: <20121030233356.GA19496@dhcp22.suse.cz>
References: <1351251453-6140-1-git-send-email-mhocko@suse.cz>
 <20121029232602.GF4066@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121029232602.GF4066@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@parallels.com>

On Mon 29-10-12 16:26:02, Tejun Heo wrote:
> Hello, Michal.
> 
> > Tejun is planning to build on top of that and make some more cleanups
> > in the cgroup core (namely get rid of of the whole retry code in
> > cgroup_rmdir).
> 
> I applied 1-3 to the following branch which is based on top of v3.6.
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git cgroup-destroy-updates

Ok, Andrew droped all the patches from his tree and I set up this
branch for automerging to -mm git tree.

> I'll follow up with updates to the destroy path which will replace #4.
> #5 and #6 should be stackable on top.

Could you take care of them and apply those two on top of the first one
which guarantees that css_tryget fails and no new task can appear in the
group (aka #4 without follow up cleanups)? So that Andrew doesn't have
to care about them later.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
