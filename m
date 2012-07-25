Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 72B906B005A
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 15:28:30 -0400 (EDT)
Message-ID: <5010482B.1040009@parallels.com>
Date: Wed, 25 Jul 2012 23:25:31 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] slab/slub: struct memcg_params
References: <1343227101-14217-1-git-send-email-glommer@parallels.com> <1343227101-14217-2-git-send-email-glommer@parallels.com> <20120725192650.GA5163@shutemov.name>
In-Reply-To: <20120725192650.GA5163@shutemov.name>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Frederic Weisbecker <fweisbec@gmail.com>, devel@openvz.org, cgroups@vger.kernel.org, Suleiman Souhlal <suleiman@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 07/25/2012 11:26 PM, Kirill A. Shutemov wrote:
> On Wed, Jul 25, 2012 at 06:38:12PM +0400, Glauber Costa wrote:
>> For the kmem slab controller, we need to record some extra
>> information in the kmem_cache structure.
>>
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>> Signed-off-by: Suleiman Souhlal <suleiman@google.com>
>> CC: Christoph Lameter <cl@linux.com>
>> CC: Pekka Enberg <penberg@cs.helsinki.fi>
>> CC: Michal Hocko <mhocko@suse.cz>
>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Johannes Weiner <hannes@cmpxchg.org>
>> ---
>>  include/linux/slab.h     |    7 +++++++
>>  include/linux/slab_def.h |    4 ++++
>>  include/linux/slub_def.h |    3 +++
>>  3 files changed, 14 insertions(+)
>>
>> diff --git a/include/linux/slab.h b/include/linux/slab.h
>> index 0dd2dfa..3152bcd 100644
>> --- a/include/linux/slab.h
>> +++ b/include/linux/slab.h
>> @@ -177,6 +177,13 @@ unsigned int kmem_cache_size(struct kmem_cache *);
>>  #define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
>>  #endif
>>  
>> +#ifdef CONFIG_MEMCG_KMEM
>> +struct mem_cgroup_cache_params {
>> +	struct mem_cgroup *memcg;
>> +	int id;
>> +};
> 
> IIUC, we only need the id to make slab name unique.  Why can't we embed
> the id to struct mem_cgroup? Is it possible to have multiple slabs with
> the same combination of type, size, and memcg?
> 
Humm, The id does not serve this purpose (perhaps deserves a comment here)

The purpose of the id is that given a slab, we can access it's memcg
equivalent in constant time through the cache array in memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
