Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id C18BF6B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 05:18:57 -0500 (EST)
Date: Fri, 25 Jan 2013 11:18:54 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v4 0/6] replace cgroup_lock with memcg specific locking
Message-ID: <20130125101854.GC8876@dhcp22.suse.cz>
References: <1358862461-18046-1-git-send-email-glommer@parallels.com>
 <510258D0.6060407@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <510258D0.6060407@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lord Glauber Costa of Sealand <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On Fri 25-01-13 14:05:04, Glauber Costa wrote:
[...]
> > Glauber Costa (6):
> >   memcg: prevent changes to move_charge_at_immigrate during task attach
> >   memcg: split part of memcg creation to css_online
> >   memcg: fast hierarchy-aware child test.
> >   memcg: replace cgroup_lock with memcg specific memcg_lock
> >   memcg: increment static branch right after limit set.
> >   memcg: avoid dangling reference count in creation failure.
> > 
> 
> Tejun,
> 
> This applies ontop of your cpuset patches. Would you pick this (would be
> my choice), or would you rather have it routed through somewhere mmish ?

I would vote to -mm. Or is there any specific reason to have it in
cgroup tree? It doesn't touch any cgroup core parts, does it?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
