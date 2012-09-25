Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id EE2476B0069
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 10:01:27 -0400 (EDT)
Message-ID: <5061B852.7070902@parallels.com>
Date: Tue, 25 Sep 2012 17:57:38 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 06/16] memcg: infrastructure to match an allocation
 to the right cache
References: <1347977530-29755-1-git-send-email-glommer@parallels.com> <1347977530-29755-7-git-send-email-glommer@parallels.com> <20120921183217.GH7264@google.com> <50601DEB.10705@parallels.com> <20120924175619.GD7694@google.com>
In-Reply-To: <20120924175619.GD7694@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On 09/24/2012 09:56 PM, Tejun Heo wrote:
> Hello, Glauber.
> 
> On Mon, Sep 24, 2012 at 12:46:35PM +0400, Glauber Costa wrote:
>>>> +#ifdef CONFIG_MEMCG_KMEM
>>>> +	/* Slab accounting */
>>>> +	struct kmem_cache *slabs[MAX_KMEM_CACHE_TYPES];
>>>> +#endif
>>>
>>> Bah, 400 entry array in struct mem_cgroup.  Can't we do something a
>>> bit more flexible?
>>>
>>
>> I guess. I still would like it to be an array, so we can easily access
>> its fields. There are two ways around this:
>>
>> 1) Do like the events mechanism and allocate this in a separate
>> structure. Add a pointer chase in the access, and I don't think it helps
>> much because it gets allocated anyway. But we could at least
>> defer it to the time when we limit the cache.
> 
> Start at some reasonable size and then double it as usage grows?  How
> many kmem_caches do we typically end up using?
> 

So my Fedora box here, recently booted on a Fedora kernel, will have 111
caches. How would 150 sound to you?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
