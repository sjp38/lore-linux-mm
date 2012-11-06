Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 04A686B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 19:28:38 -0500 (EST)
Date: Mon, 5 Nov 2012 16:28:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 19/29] memcg: infrastructure to match an allocation
 to the right cache
Message-Id: <20121105162837.5fdac20c.akpm@linux-foundation.org>
In-Reply-To: <1351771665-11076-20-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
	<1351771665-11076-20-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>, JoonSoo Kim <js1304@gmail.com>

On Thu,  1 Nov 2012 16:07:35 +0400
Glauber Costa <glommer@parallels.com> wrote:

> +static __always_inline struct kmem_cache *
> +memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)

I still don't understand why this code uses __always_inline so much.

I don't recall seeing the compiler producing out-of-line versions of
"static inline" functions (and perhaps it has special treatment for
functions which were defined in a header file?).

And if the compiler *does* decide to uninline the function, perhaps it
knows best, and the function shouldn't have been declared inline in the
first place.


If it is indeed better to use __always_inline in this code then we have
a heck of a lot of other "static inline" definitions whcih we need to
convert!  So, what's going on here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
