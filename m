Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 823A16B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 03:04:06 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id va7so169910obc.14
        for <linux-mm@kvack.org>; Tue, 06 Nov 2012 00:04:05 -0800 (PST)
Date: Tue, 6 Nov 2012 09:03:54 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v6 19/29] memcg: infrastructure to match an allocation to
 the right cache
Message-ID: <20121106080354.GA21167@dhcp22.suse.cz>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
 <1351771665-11076-20-git-send-email-glommer@parallels.com>
 <20121105162837.5fdac20c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121105162837.5fdac20c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>, JoonSoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>

On Mon 05-11-12 16:28:37, Andrew Morton wrote:
> On Thu,  1 Nov 2012 16:07:35 +0400
> Glauber Costa <glommer@parallels.com> wrote:
> 
> > +static __always_inline struct kmem_cache *
> > +memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
> 
> I still don't understand why this code uses __always_inline so much.

AFAIU, __always_inline (resp. __attribute__((always_inline))) is the
same thing as inline if optimizations are enabled
(http://ohse.de/uwe/articles/gcc-attributes.html#func-always_inline).
Which is the case for the kernel. I was always wondering why we have
this __always_inline thingy.
It has been introduced back in 2004 by Andi but the commit log doesn't
say much:
"
[PATCH] gcc-3.5 fixes
    
Trivial gcc-3.5 build fixes.
"
Andi what was the original motivation for this attribute?
 
> I don't recall seeing the compiler producing out-of-line versions of
> "static inline" functions

and if it decides then __always_inline will not help, right?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
