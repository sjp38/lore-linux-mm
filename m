Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 106916B007B
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 15:47:53 -0400 (EDT)
Date: Fri, 19 Oct 2012 19:47:51 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v5 14/18] memcg/sl[au]b: shrink dead caches
In-Reply-To: <1350656442-1523-15-git-send-email-glommer@parallels.com>
Message-ID: <0000013a7a9144d1-de184c46-2a7d-4e6c-8606-927cc1f48969-000000@email.amazonses.com>
References: <1350656442-1523-1-git-send-email-glommer@parallels.com> <1350656442-1523-15-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Fri, 19 Oct 2012, Glauber Costa wrote:

> An unlikely branch is used to make sure this case does not affect
> performance in the usual slab_free path.
>
> The slab allocator has a time based reaper that would eventually get rid
> of the objects, but we can also call it explicitly, since dead caches
> are not a likely event.

This is also something that could be done from slab_common since all
allocators have kmem_cache_shrink and kmem_cache_shrink can be used to
drain the caches and free up empty slab pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
