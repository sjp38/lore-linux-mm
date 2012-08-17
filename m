Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id B87DE6B005D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 02:39:14 -0400 (EDT)
Message-ID: <502DE655.3010305@parallels.com>
Date: Fri, 17 Aug 2012 10:36:05 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memcg: execute partial memcg freeing in mem_cgroup_destroy
References: <1345114903-20627-1-git-send-email-glommer@parallels.com> <xr93vcgiazok.fsf@gthelen.mtv.corp.google.com> <502DCDD0.3060502@parallels.com> <xr93a9xu9g7z.fsf@gthelen.mtv.corp.google.com>
In-Reply-To: <xr93a9xu9g7z.fsf@gthelen.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On 08/17/2012 10:37 AM, Greg Thelen wrote:
> I am by no means a swap expert, so I may be heading in the weeds.  But I
> think that a swapped out page is not necessarily in any memcg lru.  So
> the mem_cgroup_pre_destroy() call to mem_cgroup_force_empty() will not
> necessarily see swapped out pages.
> 
> I think this demonstrates the problem.
hummm, hummm... all right.

I'll take a look at that today

Thanks Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
