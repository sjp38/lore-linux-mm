Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id BAAAD6B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 09:53:58 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id 3so1447166pdj.13
        for <linux-mm@kvack.org>; Thu, 04 Apr 2013 06:53:57 -0700 (PDT)
Date: Thu, 4 Apr 2013 06:53:53 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC][PATCH 5/7] cgroup: make sure parent won't be destroyed
 before its children
Message-ID: <20130404133706.GA9425@htj.dyndns.org>
References: <515BF233.6070308@huawei.com>
 <515BF2A4.1070703@huawei.com>
 <20130404113750.GH29911@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130404113750.GH29911@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

Hey,

On Thu, Apr 04, 2013 at 01:37:50PM +0200, Michal Hocko wrote:
> On Wed 03-04-13 17:13:08, Li Zefan wrote:
> > Suppose we rmdir a cgroup and there're still css refs, this cgroup won't
> > be freed. Then we rmdir the parent cgroup, and the parent is freed due
> > to css ref draining to 0. Now it would be a disaster if the child cgroup
> > tries to access its parent.
> 
> Hmm, I am not sure what is the correct layer for this to handle - cgroup
> core or memcg. But we have enforced that in mem_cgroup_css_online where
> we take an additional reference to the memcg.
> 
> Handling it in the memcg code would have an advantage of limiting an
> additional reference only to use_hierarchy cases which is sufficient
> as we never touch the parent otherwise (parent_mem_cgroup).

But what harm does an additional reference do?  And given that there
are cgroup core interfaces which access ->parent, I think it'd be a
good idea that parent always exists while there are children.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
