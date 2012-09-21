Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 63D6F6B0044
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 16:52:41 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so9117703pbb.14
        for <linux-mm@kvack.org>; Fri, 21 Sep 2012 13:52:40 -0700 (PDT)
Date: Fri, 21 Sep 2012 13:52:36 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 06/16] memcg: infrastructure to match an allocation
 to the right cache
Message-ID: <20120921205236.GT7264@google.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com>
 <1347977530-29755-7-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347977530-29755-7-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

Missed some stuff.

On Tue, Sep 18, 2012 at 06:12:00PM +0400, Glauber Costa wrote:
> +static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
> +						  struct kmem_cache *cachep)
> +{
...
> +	memcg->slabs[idx] = new_cachep;
...
> +struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
> +					  gfp_t gfp)
> +{
...
> +	return memcg->slabs[idx];

I think you need memory barriers for the above pair.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
