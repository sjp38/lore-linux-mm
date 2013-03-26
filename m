Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 580666B00CA
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 04:10:08 -0400 (EDT)
Date: Tue, 26 Mar 2013 09:10:04 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
Message-ID: <20130326081004.GH2295@dhcp22.suse.cz>
References: <20130321090849.GF6094@dhcp22.suse.cz>
 <20130321102257.GH6094@dhcp22.suse.cz>
 <514BB23E.70908@huawei.com>
 <20130322080749.GB31457@dhcp22.suse.cz>
 <514C1388.6090909@huawei.com>
 <514C14BF.3050009@parallels.com>
 <20130322093141.GE31457@dhcp22.suse.cz>
 <514EAC41.5050700@huawei.com>
 <20130325090629.GN2154@dhcp22.suse.cz>
 <515153C0.5070908@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515153C0.5070908@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue 26-03-13 15:52:32, Li Zefan wrote:
[...]
> ...
> >  static struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
> >  					 struct kmem_cache *s)
> >  {
> > -	char *name;
> >  	struct kmem_cache *new;
> > +	static char *tmp_name = NULL;
> 
> (minor nitpick) why not preserve the name "name"

I wanted to make it clear that the name is just temporal

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
