Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 9761F6B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 08:34:15 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so4200981vbb.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 05:34:14 -0700 (PDT)
Date: Wed, 30 May 2012 14:34:08 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH v3 16/28] memcg: kmem controller charge/uncharge
 infrastructure
Message-ID: <20120530123406.GC25094@somewhere.redhat.com>
References: <1337951028-3427-1-git-send-email-glommer@parallels.com>
 <1337951028-3427-17-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1337951028-3427-17-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, May 25, 2012 at 05:03:36PM +0400, Glauber Costa wrote:
> +bool __mem_cgroup_new_kmem_page(struct page *page, gfp_t gfp)
> +{
> +	struct mem_cgroup *memcg;
> +	struct page_cgroup *pc;
> +	bool ret = true;
> +	size_t size;
> +	struct task_struct *p;
> +
> +	if (!current->mm || in_interrupt())
> +		return true;
> +
> +	rcu_read_lock();
> +	p = rcu_dereference(current->mm->owner);
> +	memcg = mem_cgroup_from_task(p);

So this takes the memcg of the group owner rather than the
task? I understand why we want this for user memory, but for
kernel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
