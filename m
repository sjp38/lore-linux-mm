Subject: Re: [RESEND PATCH] kmemtrace: SLAB hooks.
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20080714183734.GB3960@localhost>
References: <487B7F99.4060004@linux-foundation.org>
	 <1216057334-27239-1-git-send-email-eduard.munteanu@linux360.ro>
	 <1216059588.6762.20.camel@penberg-laptop> <20080714183734.GB3960@localhost>
Date: Tue, 15 Jul 2008 10:17:18 +0300
Message-Id: <1216106238.6762.22.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: eduard.munteanu@linux360.ro
Cc: cl@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-07-14 at 21:37 +0300, eduard.munteanu@linux360.ro wrote:
> > I'm okay with this approach but then you need to do
> > s/__kmem_cache_alloc/kmem_cache_alloc_trace/ or similar. In the kernel,
> > it's always the *upper* level function that doesn't have the
> > underscores.
> 
> Hmm, doesn't really make sense:
> 1. This should be called kmem_cache_alloc_notrace, not *_trace.
> __kmem_cache_alloc() _disables_ tracing.

kmem_cache_alloc_notrace() sounds good to me.

> 2. __kmem_cache_alloc is not really upper level now, since it's called
> only in kmalloc. So it's an internal function which is not supposed to
> be used by other kernel code.
> 
> Are you sure I should do this?

Yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
