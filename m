Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 69CE16B0039
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 14:31:45 -0400 (EDT)
Received: by mail-ye0-f169.google.com with SMTP id r13so1338291yen.0
        for <linux-mm@kvack.org>; Mon, 29 Jul 2013 11:31:44 -0700 (PDT)
Date: Mon, 29 Jul 2013 14:31:39 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 3/8] cgroup: implement cgroup_from_id()
Message-ID: <20130729183139.GE26076@mtj.dyndns.org>
References: <51F614B2.6010503@huawei.com>
 <51F614DF.9010508@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F614DF.9010508@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Mon, Jul 29, 2013 at 03:08:15PM +0800, Li Zefan wrote:
> +struct cgroup *cgroup_from_id(struct cgroup_subsys *ss, int id)
> +{
> +	rcu_lockdep_assert(rcu_read_lock_held(),
> +			   "cgroup_from_id() needs rcu_read_lock()"
> +			   " protection");

Maybe we want to add notation for &cgroup_mutex for completeness?

> +	return idr_find(&ss->root->cgroup_idr, id);
> +}

And maybe inline it?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
