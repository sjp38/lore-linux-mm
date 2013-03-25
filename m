Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 540F56B005C
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 04:20:51 -0400 (EDT)
Date: Mon, 25 Mar 2013 09:20:44 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
Message-ID: <20130325082044.GM2154@dhcp22.suse.cz>
References: <514C1388.6090909@huawei.com>
 <514C14BF.3050009@parallels.com>
 <20130322093141.GE31457@dhcp22.suse.cz>
 <514C2754.4080701@parallels.com>
 <20130322094832.GG31457@dhcp22.suse.cz>
 <514C2C72.5090402@parallels.com>
 <20130322100609.GI31457@dhcp22.suse.cz>
 <514C3193.9010609@parallels.com>
 <20130322105616.GK31457@dhcp22.suse.cz>
 <514EAC9B.1010706@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <514EAC9B.1010706@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Sun 24-03-13 15:34:51, Li Zefan wrote:
> >> I read the code as lockdep_assert(memcg_cache_mutex), and then later on
> >> mutex_lock(&memcg_mutex). But reading again, that was a just an
> >> rcu_read_lock(). Good thing it is Friday
> >>
> >> You guys can add my Acked-by, and thanks again
> > 
> > Li, are you ok to take the page via your tree?
> > 
> 
> I don't have a git tree in kernel.org. It's Tejun that picks up
> cgroup patches.

Oh, I thought both of you push to that tree. Anyway, I will rework the
patch and send it again.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
