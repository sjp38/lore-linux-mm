Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id E957E6B007E
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 09:35:09 -0400 (EDT)
Message-ID: <4F86D9A9.9070309@parallels.com>
Date: Thu, 12 Apr 2012 10:33:29 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/7] memcg: divide force_empty into 2 functions, avoid
 memory reclaim at rmdir
References: <4F86B9BE.8000105@jp.fujitsu.com> <4F86BC71.9070403@jp.fujitsu.com>
In-Reply-To: <4F86BC71.9070403@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/12/2012 08:28 AM, KAMEZAWA Hiroyuki wrote:
> Now, at rmdir, memory cgroup's charge will be moved to
>    - parent if use_hierarchy=1
>    - root   if use_hierarchy=0
> 
> Then, we don't have to have memory reclaim code at destroying memcg.
> 
> This patch divides force_empty to 2 functions as
> 
>   - memory_cgroup_recharge() ... try to move all charges to ancestors.
>   - memory_cgroup_force_empty().. try to reclaim all memory.
> 
> After this patch, memory.force_empty will _not_ move charges to ancestors
> but just reclaim all pages. (This meets documenation.)
> 
> rmdir() will not reclaim any memory but moves charge to other cgroup,
> parent or root.
> 
> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>

Seems fine by me...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
