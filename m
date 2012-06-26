Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 1A5146B009F
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 10:43:29 -0400 (EDT)
Message-ID: <4FE9C9ED.5070907@parallels.com>
Date: Tue, 26 Jun 2012 18:40:45 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/11] memcg: kmem controller infrastructure
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-7-git-send-email-glommer@parallels.com> <20120625161720.ae13ae90.akpm@linux-foundation.org>
In-Reply-To: <20120625161720.ae13ae90.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On 06/26/2012 03:17 AM, Andrew Morton wrote:
>>   }
>> >+
>> >+#define mem_cgroup_kmem_on 0
>> >+#define __mem_cgroup_new_kmem_page(a, b, c) false
>> >+#define __mem_cgroup_free_kmem_page(a,b )
>> >+#define __mem_cgroup_commit_kmem_page(a, b, c)
> I suggest that the naming consistently follow the model
> "mem_cgroup_kmem_foo".  So "mem_cgroup_kmem_" becomes the well-known
> identifier for this subsystem.
>
> Then, s/mem_cgroup/memcg/g/ - show us some mercy here!
>
I always prefer shorter names, but mem_cgroup, and not memcg, seems to 
be the default for external functions.

I am nothing but a follower =)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
