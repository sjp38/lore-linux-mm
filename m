Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 5112D6B0005
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 03:38:31 -0500 (EST)
Date: Mon, 21 Jan 2013 09:38:28 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 2/7] memcg: split part of memcg creation to css_online
Message-ID: <20130121083828.GB7798@dhcp22.suse.cz>
References: <1357897527-15479-1-git-send-email-glommer@parallels.com>
 <1357897527-15479-3-git-send-email-glommer@parallels.com>
 <20130118152526.GF10701@dhcp22.suse.cz>
 <50FCEF40.8040709@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50FCEF40.8040709@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Mon 21-01-13 11:33:20, Glauber Costa wrote:
> On 01/18/2013 07:25 PM, Michal Hocko wrote:
> >> -	spin_lock_init(&memcg->move_lock);
> >> > +	memcg->swappiness = mem_cgroup_swappiness(parent);
> > Please move this up to oom_kill_disable and use_hierarchy
> > initialization.
> 
> One thing: wouldn't moving it to inside use_hierarchy be a change of
> behavior here?

I do not see how it would change the behavior. But maybe I wasn't clear
enough. I just wanted to make all three:
	memcg->use_hierarchy = parent->use_hierarchy;
	memcg->oom_kill_disable = parent->oom_kill_disable;
	memcg->swappiness = mem_cgroup_swappiness(parent);

in the same visual block so that we can split the function into three
parts. Inherited values which don't depend on use_hierarchy, those that
depend on use_hierarchy and the rest that depends on the previous
decisions (kmem e.g.).
Makes sense?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
