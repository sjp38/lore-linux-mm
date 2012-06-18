Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id AD0626B0073
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 08:29:32 -0400 (EDT)
Message-ID: <4FDF1E89.2020007@parallels.com>
Date: Mon, 18 Jun 2012 16:26:49 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 19/25] memcg: disable kmem code when not in use.
References: <1340015298-14133-1-git-send-email-glommer@parallels.com> <1340015298-14133-20-git-send-email-glommer@parallels.com> <4FDF1D76.4060406@jp.fujitsu.com>
In-Reply-To: <4FDF1D76.4060406@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

>>
>>    static void drain_all_stock_async(struct mem_cgroup *memcg);
>> @@ -4344,8 +4358,13 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
>>    			 *
>>    			 * But it is not worth the trouble
>>    			 */
>> -			if (!memcg->kmem_accounted&&  val != RESOURCE_MAX)
>> +			mutex_lock(&set_limit_mutex);
>> +			if (!memcg->kmem_accounted&&  val != RESOURCE_MAX
>> +			&&  !memcg->kmem_accounted) {
> 
> I'm sorry why you check the value twice ?
> 

Hi Kame,

For no reason, it should be removed. I never noticed this because 1)
This is the kind of thing testing will never reveal, and 2), this
actually goes away in a later patch (memcg: propagate kmem limiting
information to children)

In any case, I will update my tree here.

Thanks for spotting this

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
