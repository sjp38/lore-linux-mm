Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id CBB3D6B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 02:04:29 -0500 (EST)
Message-ID: <509A07E3.5090700@parallels.com>
Date: Wed, 7 Nov 2012 08:04:03 +0100
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 19/29] memcg: infrastructure to match an allocation
 to the right cache
References: <1351771665-11076-1-git-send-email-glommer@parallels.com> <1351771665-11076-20-git-send-email-glommer@parallels.com> <20121105162837.5fdac20c.akpm@linux-foundation.org>
In-Reply-To: <20121105162837.5fdac20c.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>, JoonSoo Kim <js1304@gmail.com>

On 11/06/2012 01:28 AM, Andrew Morton wrote:
> On Thu,  1 Nov 2012 16:07:35 +0400
> Glauber Costa <glommer@parallels.com> wrote:
> 
>> +static __always_inline struct kmem_cache *
>> +memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
> 
> I still don't understand why this code uses __always_inline so much.
> 
> I don't recall seeing the compiler producing out-of-line versions of
> "static inline" functions (and perhaps it has special treatment for
> functions which were defined in a header file?).
> 
> And if the compiler *does* decide to uninline the function, perhaps it
> knows best, and the function shouldn't have been declared inline in the
> first place.
> 
> 
> If it is indeed better to use __always_inline in this code then we have
> a heck of a lot of other "static inline" definitions whcih we need to
> convert!  So, what's going on here?
> 

The original motivation is indeed performance related. We want to make
sure it is inline so it will figure out quickly the "I am not a memcg
user" case and keep it going. The slub, for instance, is full of
__always_inline functions to make sure that the fast path contains
absolutely no function calls. So I was just following this here.

I can remove the marker without a problem and leave it to the compiler
if you think it is best

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
