Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 0F8236B0078
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 04:50:03 -0500 (EST)
Date: Fri, 30 Nov 2012 10:49:59 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
 cgroup core
Message-ID: <20121130094959.GE29317@dhcp22.suse.cz>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
 <50B8263C.7060908@jp.fujitsu.com>
 <50B875B4.2020507@parallels.com>
 <20121130092435.GD29317@dhcp22.suse.cz>
 <50B87F84.7040206@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50B87F84.7040206@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, paul@paulmenage.org, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, bsingharora@gmail.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 30-11-12 13:42:28, Glauber Costa wrote:
[...]
> Speaking of it: Tejun's tree still lacks the kmem bits. How hard would
> it be for you to merge his branch into a temporary branch of your tree?

review-cpuset-locking is based on a post merge window merges so I cannot
merge it as is. I could cherry-pick the series after it is settled. I
have no idea how much conflicts this would bring, though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
