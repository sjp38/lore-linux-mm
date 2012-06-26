Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 08A9F6B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 14:17:36 -0400 (EDT)
Message-ID: <4FE9FC1B.6080301@parallels.com>
Date: Tue, 26 Jun 2012 22:14:51 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/11] memcg: kmem controller infrastructure
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-7-git-send-email-glommer@parallels.com> <20120625161720.ae13ae90.akpm@linux-foundation.org> <4FE9CEBB.80108@parallels.com> <20120626110142.b7cf6d7c.akpm@linux-foundation.org>
In-Reply-To: <20120626110142.b7cf6d7c.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On 06/26/2012 10:01 PM, Andrew Morton wrote:
> On Tue, 26 Jun 2012 19:01:15 +0400 Glauber Costa <glommer@parallels.com> wrote:
>
>> On 06/26/2012 03:17 AM, Andrew Morton wrote:
>>>> +	memcg_uncharge_kmem(memcg, size);
>>>>> +	mem_cgroup_put(memcg);
>>>>> +}
>>>>> +EXPORT_SYMBOL(__mem_cgroup_free_kmem_page);
>>>>>   #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
>>>>>
>>>>>   #if defined(CONFIG_INET) && defined(CONFIG_CGROUP_MEM_RES_CTLR_KMEM)
>>>>> @@ -5645,3 +5751,69 @@ static int __init enable_swap_account(char *s)
>>>>>   __setup("swapaccount=", enable_swap_account);
>>>>>
>>>>>   #endif
>>>>> +
>>>>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>>> gargh.  CONFIG_MEMCG_KMEM, please!
>>>
>>
>> Here too. I like it as much as you do.
>>
>> But that is consistent with the rest of the file, and I'd rather have
>> it this way.
>
> There's not much point in being consistent with something which is so
> unpleasant.  I'm on a little campaign to rename
> CONFIG_CGROUP_MEM_RES_CTLR to CONFIG_MEMCG, only nobody has taken my
> bait yet.  Be first!
>

If you are okay with a preparation mechanical patch to convert the whole 
file, I can change mine too.

But you'll be responsible for arguing with whoever stepping up opposing 
this =p

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
