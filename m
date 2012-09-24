Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id B24706B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 04:21:10 -0400 (EDT)
Message-ID: <50601721.6040805@parallels.com>
Date: Mon, 24 Sep 2012 12:17:37 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 06/16] memcg: infrastructure to match an allocation
 to the right cache
References: <1347977530-29755-1-git-send-email-glommer@parallels.com> <1347977530-29755-7-git-send-email-glommer@parallels.com> <20120921205236.GT7264@google.com>
In-Reply-To: <20120921205236.GT7264@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On 09/22/2012 12:52 AM, Tejun Heo wrote:
> Missed some stuff.
> 
> On Tue, Sep 18, 2012 at 06:12:00PM +0400, Glauber Costa wrote:
>> +static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
>> +						  struct kmem_cache *cachep)
>> +{
> ...
>> +	memcg->slabs[idx] = new_cachep;
> ...
>> +struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
>> +					  gfp_t gfp)
>> +{
> ...
>> +	return memcg->slabs[idx];
> 
> I think you need memory barriers for the above pair.
> 
> Thanks.
> 

Why is that?

We'll either see a value, or NULL. If we see NULL, we assume the cache
is not yet created. Not a big deal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
