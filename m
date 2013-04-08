Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id D0ABD6B010C
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 11:43:27 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bi5so3325924pad.17
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 08:43:27 -0700 (PDT)
Date: Mon, 8 Apr 2013 08:43:19 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/8] cgroup: implement cgroup_from_id()
Message-ID: <20130408154319.GD3021@htj.dyndns.org>
References: <51627DA9.7020507@huawei.com>
 <51627DEB.4090104@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51627DEB.4090104@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Mon, Apr 08, 2013 at 04:20:59PM +0800, Li Zefan wrote:
> +/**
> + * cgroup_from_id - lookup cgroup by id
> + * @ss: cgroup subsys to be looked into.
> + * @id: the id
> + *
> + * Returns pointer to cgroup if there is valid one with id.
> + * NULL if not. Should be called under rcu_read_lock()
> + */
> +struct cgroup *cgroup_from_id(struct cgroup_subsys *ss, int id)
> +{

	rcu_lockdep_assert(rcu_read_lock_held(), ...);

> +	return idr_find(&ss->root->cgroup_idr, id);

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
