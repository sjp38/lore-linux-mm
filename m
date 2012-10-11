Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id A36C06B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 09:39:04 -0400 (EDT)
Date: Thu, 11 Oct 2012 15:38:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v4 04/14] kmem accounting basic infrastructure
Message-ID: <20121011133855.GG29295@dhcp22.suse.cz>
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

> > +	cgroup_lock();
> > +	mutex_lock(&set_limit_mutex);
> > +	if (!memcg->kmem_accounted && val != RESOURCE_MAX) {
> 
> Just a nit but wouldn't memcg_kmem_is_accounted(memcg) be better than
> directly checking kmem_accounted?

OK, I see that jump lable patch changes this and we set activated inside
the conditional so kmem_accounted check catches both flags. That could
be changed to memcg_kmem_is_activated in that patch but what ever.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
