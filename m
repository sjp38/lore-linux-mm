Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id CA8C36B0072
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 14:15:03 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so8861256pbb.14
        for <linux-mm@kvack.org>; Fri, 21 Sep 2012 11:15:03 -0700 (PDT)
Date: Fri, 21 Sep 2012 11:14:58 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 05/16] consider a memcg parameter in
 kmem_create_cache
Message-ID: <20120921181458.GG7264@google.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com>
 <1347977530-29755-6-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347977530-29755-6-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

Hello, Glauber.

On Tue, Sep 18, 2012 at 06:11:59PM +0400, Glauber Costa wrote:
> +void memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *cachep)
> +{
> +	int id = -1;
> +
> +	if (!memcg)
> +		id = ida_simple_get(&cache_types, 0, MAX_KMEM_CACHE_TYPES,
> +				    GFP_KERNEL);
> +	cachep->memcg_params.id = id;
> +}

I'm a bit confused.  Why is id allocated only when memcg is NULL?

Also, how would the per-memcg slab/slubs appear in slabinfo?  If they
appear separately it might be better to give them readable cgroup
names.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
