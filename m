Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 944E36B009A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 18:55:07 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so7974909pad.14
        for <linux-mm@kvack.org>; Wed, 03 Oct 2012 15:55:06 -0700 (PDT)
Date: Thu, 4 Oct 2012 07:54:58 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
Message-ID: <20121003225458.GE19248@localhost>
References: <50635F46.7000700@parallels.com>
 <20120926201629.GB20342@google.com>
 <50637298.2090904@parallels.com>
 <20120927120806.GA29104@dhcp22.suse.cz>
 <20120927143300.GA4251@mtj.dyndns.org>
 <20120927144307.GH3429@suse.de>
 <20120927145802.GC4251@mtj.dyndns.org>
 <50649B4C.8000208@parallels.com>
 <20120930082358.GG10383@mtj.dyndns.org>
 <50695817.2030201@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50695817.2030201@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Hello, Glauber.

On Mon, Oct 01, 2012 at 12:45:11PM +0400, Glauber Costa wrote:
> > where kmemcg_slab_idx is updated from sched notifier (or maybe add and
> > use current->kmemcg_slab_idx?).  You would still need __GFP_* and
> > in_interrupt() tests but current->mm and PF_KTHREAD tests can be
> > rolled into index selection.
> 
> How big would this array be? there can be a lot more kmem_caches than
> there are memcgs. That is why it is done from memcg side.

The total number of memcgs are pretty limited due to the ID thing,
right?  And kmemcg is only applied to subset of caches.  I don't think
the array size would be a problem in terms of memory overhead, would
it?  If so, RCU synchronize and dynamically grow them?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
