Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 0D0916B006C
	for <linux-mm@kvack.org>; Sun, 30 Sep 2012 04:25:52 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so3934941pad.14
        for <linux-mm@kvack.org>; Sun, 30 Sep 2012 01:25:52 -0700 (PDT)
Date: Sun, 30 Sep 2012 17:25:42 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 06/13] memcg: kmem controller infrastructure
Message-ID: <20120930082542.GH10383@mtj.dyndns.org>
References: <1347977050-29476-1-git-send-email-glommer@parallels.com>
 <1347977050-29476-7-git-send-email-glommer@parallels.com>
 <20120926155108.GE15801@dhcp22.suse.cz>
 <5064392D.5040707@parallels.com>
 <20120927134432.GE29104@dhcp22.suse.cz>
 <50658B3B.9020303@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50658B3B.9020303@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Johannes Weiner <hannes@cmpxchg.org>

On Fri, Sep 28, 2012 at 03:34:19PM +0400, Glauber Costa wrote:
> On 09/27/2012 05:44 PM, Michal Hocko wrote:
> > Anyway, I have just noticed that __mem_cgroup_try_charge does
> > VM_BUG_ON(css_is_removed(&memcg->css)) on a given memcg so you should
> > keep css ref count up as well.
> 
> IIRC, css_get will prevent the cgroup directory from being removed.
> Because some allocations are expected to outlive the cgroup, we
> specifically don't want that.

That synchronous ref draining is going away.  Maybe we can do that
before kmemcg?  Michal, do you have some timeframe on mind?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
