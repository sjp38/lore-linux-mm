Received: by ag-out-0708.google.com with SMTP id 22so13358731agd.8
        for <linux-mm@kvack.org>; Tue, 22 Jul 2008 14:09:31 -0700 (PDT)
Date: Wed, 23 Jul 2008 00:07:52 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [RFC PATCH 4/4] kmemtrace: SLOB hooks.
Message-ID: <20080722210751.GA14810@localhost>
References: <1216751808-14428-1-git-send-email-eduard.munteanu@linux360.ro> <1216751808-14428-2-git-send-email-eduard.munteanu@linux360.ro> <1216751808-14428-3-git-send-email-eduard.munteanu@linux360.ro> <1216751808-14428-4-git-send-email-eduard.munteanu@linux360.ro> <1216751808-14428-5-git-send-email-eduard.munteanu@linux360.ro> <1216760035.15519.113.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1216760035.15519.113.camel@calx>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: penberg@cs.helsinki.fi, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net
List-ID: <linux-mm.kvack.org>

On Tue, Jul 22, 2008 at 03:53:55PM -0500, Matt Mackall wrote:
> 
> On Tue, 2008-07-22 at 21:36 +0300, Eduard - Gabriel Munteanu wrote:
> > -static inline void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
> > +static __always_inline void *kmem_cache_alloc(struct kmem_cache *cachep,
> > +					      gfp_t flags)
> >  {
> >  	return kmem_cache_alloc_node(cachep, flags, -1);
> >  }
> 
> Why is this needed? builtin_return?

If we don't use __always_inline, we can't be sure whether it's inlined
or not. And we don't know if we need _THIS_IP_ or _RET_IP_ (equivalent
to __builtin_return_address(0)). Simple, plain 'inline' does not
guarantee GCC will inline that function, nor does it warn us if it is
not inlined.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
