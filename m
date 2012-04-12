Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 9E17A6B007E
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 09:22:30 -0400 (EDT)
Message-ID: <4F86D6B2.2020401@parallels.com>
Date: Thu, 12 Apr 2012 10:20:50 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v1 0/7] memcg remove pre_destroy
References: <4F86B9BE.8000105@jp.fujitsu.com>
In-Reply-To: <4F86B9BE.8000105@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/12/2012 08:17 AM, KAMEZAWA Hiroyuki wrote:
> One of problem in current implementation is that memcg moves all charges to
> parent in pre_destroy(). At doing so, if use_hierarchy=0, pre_destroy() may
> hit parent's limit and may return -EBUSY. To fix this problem, this patch
> changes behavior of rmdir() as
> 
>   - if use_hierarchy=0, all remaining charges will go to root cgroup.
>   - if use_hierarchy=1, all remaining charges will go to the parent.
To be quite honest, this is one of those things that we end up
overlooking, and just don't think about it in the middle of the complexity.

Now that you mention it... When use_hierarchy=0,  there is no parent!
(At least from where memcg is concerned). So it doesn't make any sense
to have it ever have moved it to the "parent" (from the core cgroup
perspective).

I agree with this new behavior 100 %.

Just a nitpick: When use_hierarchy=1, remaining charges need not to "go
to the parent". They are already there.

I will review your series for the specifics.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
