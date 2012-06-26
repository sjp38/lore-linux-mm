Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 14C6D6B013E
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 03:11:23 -0400 (EDT)
Message-ID: <4FE95FF0.3000300@parallels.com>
Date: Tue, 26 Jun 2012 11:08:32 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/11] Add a __GFP_KMEMCG flag
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-6-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206252123230.26640@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206252123230.26640@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On 06/26/2012 08:25 AM, David Rientjes wrote:
> On Mon, 25 Jun 2012, Glauber Costa wrote:
>
>> >This flag is used to indicate to the callees that this allocation will be
>> >serviced to the kernel. It is not supposed to be passed by the callers
>> >of kmem_cache_alloc, but rather by the cache core itself.
>> >
> Not sure what "serviced to the kernel" means, does this mean that the
> memory will not be accounted for to the root memcg?
>
In this context, it means that is a kernel allocation, not a userspace 
one (but in process context, of course), *and* it is to be accounted a
specific memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
