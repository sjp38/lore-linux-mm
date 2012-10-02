Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 90D056B0068
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 10:46:15 -0400 (EDT)
Date: Tue, 2 Oct 2012 16:46:10 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 05/16] consider a memcg parameter in kmem_create_cache
Message-ID: <20121002144610.GA4662@dhcp22.suse.cz>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com>
 <1347977530-29755-6-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347977530-29755-6-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Johannes Weiner <hannes@cmpxchg.org>

On Tue 18-09-12 18:11:59, Glauber Costa wrote:
> Allow a memcg parameter to be passed during cache creation.
> When the slub allocator is being used, it will only merge
> caches that belong to the same memcg.
> 
> Default function is created as a wrapper, passing NULL
> to the memcg version. We only merge caches that belong
> to the same memcg.
> 
> From the memcontrol.c side, 3 helper functions are created:
> 
> 1) memcg_css_id: because slub needs a unique cache name
>    for sysfs. Since this is visible, but not the canonical
>    location for slab data, the cache name is not used, the
>    css_id should suffice.
> 
> 2) mem_cgroup_register_cache: is responsible for assigning
>     a unique index to each cache, and other general purpose
>     setup. The index is only assigned for the root caches. All
>     others are assigned index == -1.

It would be nice to describe what is memcg_params.id intended for. There
is no usage in this patch (except for create_unique_id in slub).
I guess that by root caches you mean all default caches with
memcg==NULL, right?

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
