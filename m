Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id C59E46B005D
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 10:14:23 -0500 (EST)
Date: Tue, 4 Dec 2012 16:14:20 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/4] memcg: replace cgroup_lock with memcg specific
 memcg_lock
Message-ID: <20121204151420.GL31319@dhcp22.suse.cz>
References: <1354282286-32278-1-git-send-email-glommer@parallels.com>
 <1354282286-32278-5-git-send-email-glommer@parallels.com>
 <20121203171532.GG17093@dhcp22.suse.cz>
 <50BDAD38.6030200@parallels.com>
 <20121204082316.GB31319@dhcp22.suse.cz>
 <50BDB4E3.4040107@parallels.com>
 <20121204084544.GC31319@dhcp22.suse.cz>
 <20121204145221.GA3885@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121204145221.GA3885@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>

On Tue 04-12-12 06:52:21, Tejun Heo wrote:
> Hello, Michal, Glauber.
> 
> On Tue, Dec 04, 2012 at 09:45:44AM +0100, Michal Hocko wrote:
> > Because such a helper might be useful in general? I didn't check if
> > somebody does the same test elsewhere though.
> 
> The problem is that whether a cgroup has a child or not may differ
> depending on the specific controller.  You can't tell whether
> something exists or not at a given time without synchronization and
> synchronization is per-controller.  IOW, if a controller cares about
> when a cgroup comes online and goes offline, it should synchronize
> those events in ->css_on/offline() and only consider cgroups marked
> online as online.

OK, I read this as "generic helper doesn't make much sense". Then I
would just ask. Does cgroup core really care whether we do
list_empty test? Is this something that we have to care about in memcg
and should fix? If yes then just try to do it as simple as possible.

My primary objection was that the full hierarchy walk is an overkill and
it doesn't fit into the patch which aims at a different task. So if
cgroup really cares about this cgroups internals abuse then let's fix it
but let's do it in a separate patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
