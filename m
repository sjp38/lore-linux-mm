Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id D05046B0083
	for <linux-mm@kvack.org>; Sat, 14 Apr 2012 08:19:34 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so3698151vbb.14
        for <linux-mm@kvack.org>; Sat, 14 Apr 2012 05:19:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334181407-26064-1-git-send-email-yinghan@google.com>
References: <1334181407-26064-1-git-send-email-yinghan@google.com>
Date: Sat, 14 Apr 2012 20:19:33 +0800
Message-ID: <CAJd=RBCpq5cj1_K3Q8z4-G75WiAkZ0P66_ib5TBObopbes789g@mail.gmail.com>
Subject: Re: [PATCH V2 0/5] memcg softlimit reclaim rework
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Thu, Apr 12, 2012 at 5:56 AM, Ying Han <yinghan@google.com> wrote:
> The "soft_limit" was introduced in memcg to support over-committing the
> memory resource on the host. Each cgroup configures its "hard_limit" where
> it will be throttled or OOM killed by going over the limit. However, the
> cgroup can go above the "soft_limit" as long as there is no system-wide
> memory contention. So, the "soft_limit" is the kernel mechanism for
> re-distributng system spare memory among cgroups.
>
s/re-distributng/re-distributing/

> This patch reworks the softlimit reclaim by hooking it into the new global
> reclaim scheme. So the global reclaim path including direct reclaim and
> background reclaim will respect the memcg softlimit.
>
> Note:
> 1. the new implementation of softlimit reclaim is rather simple and first
> step for further optimizations. there is no memory pressure balancing between
> memcgs for each zone, and that is something we would like to add as follow-ups.
>
> 2. this patch is slightly different from the last one posted from Johannes,
>
For those who want to see posts by Johannes, add links please.

> where his patch is closer to the reverted implementation by doing hierarchical
> reclaim for each selected memcg. However, that is not expected behavior from
> user perspective. Considering the following example:
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
