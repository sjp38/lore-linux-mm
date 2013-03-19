Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id CD5166B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 08:55:10 -0400 (EDT)
Date: Tue, 19 Mar 2013 13:55:09 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 2/5] memcg: provide root figures from system totals
Message-ID: <20130319125509.GF7869@dhcp22.suse.cz>
References: <1362489058-3455-1-git-send-email-glommer@parallels.com>
 <1362489058-3455-3-git-send-email-glommer@parallels.com>
 <20130319124650.GE7869@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130319124650.GE7869@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, handai.szj@gmail.com, anton.vorontsov@linaro.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

On Tue 19-03-13 13:46:50, Michal Hocko wrote:
> On Tue 05-03-13 17:10:55, Glauber Costa wrote:
> > For the root memcg, there is no need to rely on the res_counters if hierarchy
> > is enabled The sum of all mem cgroups plus the tasks in root itself, is
> > necessarily the amount of memory used for the whole system. Since those figures
> > are already kept somewhere anyway, we can just return them here, without too
> > much hassle.
> > 
> > Limit and soft limit can't be set for the root cgroup, so they are left at
> > RESOURCE_MAX. Failcnt is left at 0, because its actual meaning is how many
> > times we failed allocations due to the limit being hit. We will fail
> > allocations in the root cgroup, but the limit will never the reason.
> 
> I do not like this very much to be honest. It just adds more hackery...
> Why cannot we simply not account if nr_cgroups == 1 and move relevant
> global counters to the root at the moment when a first group is
> created?

OK, it seems that the very next patch does what I was looking for. So
why all the churn in this patch?
Why do you want to make root even more special?
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
