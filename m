Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 6CC396B0044
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 09:33:59 -0500 (EST)
Date: Thu, 8 Nov 2012 15:33:54 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v6 19/29] memcg: infrastructure to match an allocation to
 the right cache
Message-ID: <20121108143354.GJ31821@dhcp22.suse.cz>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
 <1351771665-11076-20-git-send-email-glommer@parallels.com>
 <20121105162837.5fdac20c.akpm@linux-foundation.org>
 <20121106080354.GA21167@dhcp22.suse.cz>
 <20121108110513.GE31821@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121108110513.GE31821@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>, JoonSoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>

On Thu 08-11-12 12:05:13, Michal Hocko wrote:
> On Tue 06-11-12 09:03:54, Michal Hocko wrote:
> > On Mon 05-11-12 16:28:37, Andrew Morton wrote:
> > > On Thu,  1 Nov 2012 16:07:35 +0400
> > > Glauber Costa <glommer@parallels.com> wrote:
> > > 
> > > > +static __always_inline struct kmem_cache *
> > > > +memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
> > > 
> > > I still don't understand why this code uses __always_inline so much.
> > 
> > AFAIU, __always_inline (resp. __attribute__((always_inline))) is the
> > same thing as inline if optimizations are enabled
> > (http://ohse.de/uwe/articles/gcc-attributes.html#func-always_inline).
> 
> And this doesn't tell the whole story because there is -fearly-inlining
> which enabled by default and it makes a difference when optimizations
> are enabled so __always_inline really enforces inlining.

and -fearly-inlining is another doc trap. I have tried with -O2
-fno-early-inlining and __always_inline code has been inlined with gcc
4.3 and 4.7 while simple inline is ignored so it really seems that
__always_inline is always inlined but man page is little a bit mean to
tell us all the details.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
