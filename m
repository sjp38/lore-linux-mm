Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 9BA206B0044
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 18:30:17 -0400 (EDT)
Received: by dakh32 with SMTP id h32so8031412dak.9
        for <linux-mm@kvack.org>; Mon, 16 Apr 2012 15:30:16 -0700 (PDT)
Date: Mon, 16 Apr 2012 15:30:12 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/7] memcg: move charges to root at rmdir()
Message-ID: <20120416223012.GD12421@google.com>
References: <4F86B9BE.8000105@jp.fujitsu.com>
 <4F86BB02.2060607@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F86BB02.2060607@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

Hello,

On Thu, Apr 12, 2012 at 08:22:42PM +0900, KAMEZAWA Hiroyuki wrote:
> As recently discussed, Tejun Heo, the cgroup maintainer, tries to
> remove ->pre_destroy() and cgroup will never return -EBUSY at rmdir().

I'm not trying to remove ->pre_destory() per-se.  I want to remove css
ref draining and ->pre_destroy() vetoing cgroup removal.  Probably
better wording would be "tries to simplify removal path such that
removal always succeeds".

> To do that, in memcg, handling case of use_hierarchy==false is a problem.
> 
> We move memcg's charges to its parent at rmdir(). If use_hierarchy==true,
> it's already accounted in the parent, no problem. If use_hierarchy==false,
> we cannot guarantee we can move all charges to the parent.
> 
> This patch changes the behavior to move all charges to root_mem_cgroup
> if use_hierarchy=false. It seems this matches semantics of use_hierarchy==false,which means parent and child has no hierarchical relationship.

Maybe better to break the above line?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
