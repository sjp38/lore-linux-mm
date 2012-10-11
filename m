Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 63AF56B0068
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 08:56:07 -0400 (EDT)
Date: Thu, 11 Oct 2012 14:56:03 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v4 06/14] memcg: kmem controller infrastructure
Message-ID: <20121011125603.GE29295@dhcp22.suse.cz>
References: <1349690780-15988-1-git-send-email-glommer@parallels.com>
 <1349690780-15988-7-git-send-email-glommer@parallels.com>
 <20121011124212.GC29295@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121011124212.GC29295@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Suleiman Souhlal <suleiman@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, devel@openvz.org, Frederic Weisbecker <fweisbec@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu 11-10-12 14:42:12, Michal Hocko wrote:
[...]
> 	/*
> 	 * Keep reference on memcg while the page is charged to prevent
> 	 * group from vanishing because allocation can outlive their
> 	 * tasks. The reference is dropped in __memcg_kmem_uncharge_page
> 	 */
> 
> please
> > +	mem_cgroup_get(memcg);

Ahh, this will go away. The it doesn't make much sense to add the
comment here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
