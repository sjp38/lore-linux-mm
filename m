Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id A4BA46B005D
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 04:42:15 -0400 (EDT)
Date: Thu, 18 Oct 2012 10:42:12 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 5/6] memcg: make mem_cgroup_reparent_charges non failing
Message-ID: <20121018084212.GA24295@dhcp22.suse.cz>
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
 <1350480648-10905-6-git-send-email-mhocko@suse.cz>
 <507FBE1B.4080906@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <507FBE1B.4080906@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

On Thu 18-10-12 16:30:19, Li Zefan wrote:
> >  static int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
> > @@ -5013,13 +5011,9 @@ free_out:
> >  static int mem_cgroup_pre_destroy(struct cgroup *cont)
> >  {
> >  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> > -	int ret;
> >  
> > -	css_get(&memcg->css);
> > -	ret = mem_cgroup_reparent_charges(memcg);
> > -	css_put(&memcg->css);
> > -
> > -	return ret;
> > +	mem_cgroup_reparent_charges(memcg);
> > +	return 0;
> >  }
> >  
> 
> Why don't you make pre_destroy() return void?

Yes I plan to do that later after I have feedback for this RFC.  I am
especially interested whether the cgroup core patch is OK, resp. has to
be reworked to pull pre_destroy outside of cgroup_lock

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
