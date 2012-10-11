Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 4156E6B005A
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 08:53:13 -0400 (EDT)
Date: Thu, 11 Oct 2012 14:53:10 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v4 04/14] kmem accounting basic infrastructure
Message-ID: <20121011125309.GD29295@dhcp22.suse.cz>
References: <1349690780-15988-1-git-send-email-glommer@parallels.com>
 <1349690780-15988-5-git-send-email-glommer@parallels.com>
 <20121011101119.GB29295@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121011101119.GB29295@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Suleiman Souhlal <suleiman@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, devel@openvz.org, Frederic Weisbecker <fweisbec@gmail.com>

On Thu 11-10-12 12:11:19, Michal Hocko wrote:
> On Mon 08-10-12 14:06:10, Glauber Costa wrote:
[...]
> > +static void memcg_kmem_set_active(struct mem_cgroup *memcg)
> > +{
> > +	set_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_accounted);
> > +}
> > +
> > +static bool memcg_kmem_is_accounted(struct mem_cgroup *memcg)
> > +{
> > +	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_accounted);
> > +}
> > +#endif
> 
> set_active vs. is_accounted. Is there any reason for inconsistency here?

Ahh, fixed later and 09/14 makes it memcg_kmem_is_active so this is just
a code churn. I think making it memcg_kmem_is_active here would be
better.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
