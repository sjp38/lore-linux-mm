Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 3DBF36B006E
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 13:25:49 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so4684708oag.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 10:25:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350656442-1523-6-git-send-email-glommer@parallels.com>
References: <1350656442-1523-1-git-send-email-glommer@parallels.com>
	<1350656442-1523-6-git-send-email-glommer@parallels.com>
Date: Wed, 24 Oct 2012 02:25:48 +0900
Message-ID: <CAAmzW4PVEb6WezFAjgNwYiAkNXE745ys6HejeNA4uRhUXqWe_g@mail.gmail.com>
Subject: Re: [PATCH v5 05/18] slab/slub: struct memcg_params
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, Suleiman Souhlal <suleiman@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

Hi, Glauber.

2012/10/19 Glauber Costa <glommer@parallels.com>:
> For the kmem slab controller, we need to record some extra
> information in the kmem_cache structure.
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Signed-off-by: Suleiman Souhlal <suleiman@google.com>
> CC: Christoph Lameter <cl@linux.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Tejun Heo <tj@kernel.org>
> ---
>  include/linux/slab.h     | 25 +++++++++++++++++++++++++
>  include/linux/slab_def.h |  3 +++
>  include/linux/slub_def.h |  3 +++
>  mm/slab.h                | 13 +++++++++++++
>  4 files changed, 44 insertions(+)
>
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 0dd2dfa..e4ea48a 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -177,6 +177,31 @@ unsigned int kmem_cache_size(struct kmem_cache *);
>  #define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
>  #endif
>
> +#include <linux/workqueue.h>

Why workqueue.h is includede at this time?
It may be future use, so is it better to add it later?
Adding it at proper time makes git blame works better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
