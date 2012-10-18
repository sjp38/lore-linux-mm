Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 990E46B002B
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 02:14:57 -0400 (EDT)
Date: Thu, 18 Oct 2012 08:14:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5 09/14] memcg: kmem accounting lifecycle management
Message-ID: <20121018061451.GA21277@dhcp22.suse.cz>
References: <1350382611-20579-1-git-send-email-glommer@parallels.com>
 <1350382611-20579-10-git-send-email-glommer@parallels.com>
 <alpine.DEB.2.00.1210171624540.20813@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1210171624540.20813@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Wed 17-10-12 16:28:38, David Rientjes wrote:
> On Tue, 16 Oct 2012, Glauber Costa wrote:
[...]
> > +
> > +static void memcg_kmem_mark_dead(struct mem_cgroup *memcg)
> > +{
> > +	if (test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_accounted))
> > +		set_bit(KMEM_ACCOUNTED_DEAD, &memcg->kmem_accounted);
> > +}
> 
> The set_bit() doesn't happen atomically with the test_bit(), what 
> synchronization is required for this?

The group has to be active in order to become dead so the ordering is
natural and you do not need to test&set atomicaly. Also once a group
becomes active it is always marked that way until it goes away.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
