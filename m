Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 236E16B00D5
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 11:06:24 -0400 (EDT)
Date: Tue, 18 Sep 2012 15:06:22 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 05/13] Add a __GFP_KMEMCG flag
In-Reply-To: <1347977050-29476-6-git-send-email-glommer@parallels.com>
Message-ID: <00000139d9ea69c6-109249c2-5176-4a1e-b000-4c076d05844d-000000@email.amazonses.com>
References: <1347977050-29476-1-git-send-email-glommer@parallels.com> <1347977050-29476-6-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>

On Tue, 18 Sep 2012, Glauber Costa wrote:

> +++ b/include/linux/gfp.h
> @@ -35,6 +35,11 @@ struct vm_area_struct;
>  #else
>  #define ___GFP_NOTRACK		0
>  #endif
> +#ifdef CONFIG_MEMCG_KMEM
> +#define ___GFP_KMEMCG		0x400000u
> +#else
> +#define ___GFP_KMEMCG		0
> +#endif

Could you leave __GFP_MEMCG a simple definition and then define GFP_MEMCG
to be zer0 if !MEMCG_KMEM? I think that would be cleaner and the
__GFP_KMEMCHECK another case that would be good to fix up.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
