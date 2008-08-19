Received: by gxk8 with SMTP id 8so6079119gxk.14
        for <linux-mm@kvack.org>; Tue, 19 Aug 2008 11:27:36 -0700 (PDT)
Date: Tue, 19 Aug 2008 21:24:23 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [PATCH 3/5] SLUB: Replace __builtin_return_address(0) with
	_RET_IP_.
Message-ID: <20080819182423.GA5520@localhost>
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-2-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-3-git-send-email-eduard.munteanu@linux360.ro> <48AB0D69.4090703@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48AB0D69.4090703@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, Aug 19, 2008 at 01:14:01PM -0500, Christoph Lameter wrote:
> Eduard - Gabriel Munteanu wrote:
> 
> >  void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
> >  {
> > -	return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
> > +	return slab_alloc(s, gfpflags, -1, (void *) _RET_IP_);
> >  }
> 
> Could you get rid of the casts by changing the type of parameter of slab_alloc()?

I just looked at it and it isn't a trivial change. slab_alloc() calls
other functions which expect a void ptr. Even if slab_alloc() were to
take an unsigned long and then cast it to a void ptr, other functions do
call slab_alloc() with void ptr arguments (so the casts would move
there).

I'd rather have this merged as it is and change things later, so that
kmemtrace gets some testing from Pekka and others. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
