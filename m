Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id CD1186B004D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 19:57:07 -0500 (EST)
Date: Mon, 5 Nov 2012 16:57:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 26/29] Aggregate memcg cache values in slabinfo
Message-Id: <20121105165706.f2f37f46.akpm@linux-foundation.org>
In-Reply-To: <1351771665-11076-27-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
	<1351771665-11076-27-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Thu,  1 Nov 2012 16:07:42 +0400
Glauber Costa <glommer@parallels.com> wrote:

> When we create caches in memcgs, we need to display their usage
> information somewhere. We'll adopt a scheme similar to /proc/meminfo,
> with aggregate totals shown in the global file, and per-group
> information stored in the group itself.
> 
> For the time being, only reads are allowed in the per-group cache.
> 
> ...
>
> +#define for_each_memcg_cache_index(_idx)	\
> +	for ((_idx) = 0; i < memcg_limited_groups_array_size; (_idx)++)

Use of this requires slab_mutex, yes?

Please add a comment, and confirm that all callers do indeed hold the
correct lock.


We could add a mutex_is_locked() check to the macro perhaps, but this
isn't the place to assume the presence of slab_mutex, so it gets messy.

>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
