Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 2B9D66B0083
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 03:03:16 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4249F3EE0C2
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:03:14 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EF2D45DE56
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:03:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EAF7545DE4D
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:03:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D0F89E08008
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:03:13 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C335E08005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:03:13 +0900 (JST)
Message-ID: <4F8E66B7.3050602@jp.fujitsu.com>
Date: Wed, 18 Apr 2012 16:01:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/7] memcg: move charge to parent only when necessary.
References: <4F86B9BE.8000105@jp.fujitsu.com> <4F86BAB0.5030809@jp.fujitsu.com> <20120416222119.GC12421@google.com>
In-Reply-To: <20120416222119.GC12421@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

(2012/04/17 7:21), Tejun Heo wrote:

> On Thu, Apr 12, 2012 at 08:21:20PM +0900, KAMEZAWA Hiroyuki wrote:
>>
>> When memcg->use_hierarchy==true, the parent res_counter includes
>> the usage in child's usage. So, it's not necessary to call try_charge()
>> in the parent.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>>  mm/memcontrol.c |   39 ++++++++++++++++++++++++++++++++-------
>>  1 files changed, 32 insertions(+), 7 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index fa01106..3215880 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2409,6 +2409,20 @@ static void __mem_cgroup_cancel_charge(struct mem_cgroup *memcg,
>>  			res_counter_uncharge(&memcg->memsw, bytes);
>>  	}
>>  }
> 
> New line missing here.
> 
>> +/*
>> + * Moving usage between a child to its parent if use_hierarchy==true.
>> + */
> 
> Prolly "from a child to its parent"?
> 

Sure. will fix.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
