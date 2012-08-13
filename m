Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id D92546B002B
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 04:04:31 -0400 (EDT)
Message-ID: <5028B450.9080309@parallels.com>
Date: Mon, 13 Aug 2012 12:01:20 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 09/11] memcg: propagate kmem limiting information to
 children
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-10-git-send-email-glommer@parallels.com> <50254A0A.3080805@jp.fujitsu.com>
In-Reply-To: <50254A0A.3080805@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On 08/10/2012 09:51 PM, Kamezawa Hiroyuki wrote:
>> +		/*
>> +		 * Once enabled, can't be disabled. We could in theory disable
>> +		 * it if we haven't yet created any caches, or if we can shrink
>> +		 * them all to death. But it is not worth the trouble
>> +		 */
>>   		static_key_slow_inc(&memcg_kmem_enabled_key);
>> -		memcg->kmem_accounted = true;
>> +
>> +		if (!memcg->use_hierarchy)
>> +			goto out;
>> +
>> +		for_each_mem_cgroup_tree(iter, memcg) {
>> +			if (iter == memcg)
>> +				continue;
>> +			memcg_kmem_account_parent(iter);
>> +		}
> 
> Could you add an explanation comment ?
> 

Of course, Kame.
Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
