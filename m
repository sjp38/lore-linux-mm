Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 50BE56B0069
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 03:57:17 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id ey11so4972458pad.21
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 00:57:17 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id dw11si9801353pac.228.2014.10.27.00.57.15
        for <linux-mm@kvack.org>;
        Mon, 27 Oct 2014 00:57:16 -0700 (PDT)
Date: Mon, 27 Oct 2014 16:58:30 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 0/4] [RFC] slub: Fastpath optimization (especially for RT)
Message-ID: <20141027075830.GF23379@js1304-P5Q-DELUXE>
References: <20141022155517.560385718@linux.com>
 <20141023080942.GA7598@js1304-P5Q-DELUXE>
 <alpine.DEB.2.11.1410230916090.19494@gentwo.org>
 <20141024045630.GD15243@js1304-P5Q-DELUXE>
 <alpine.DEB.2.11.1410240938460.29214@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1410240938460.29214@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com

On Fri, Oct 24, 2014 at 09:41:49AM -0500, Christoph Lameter wrote:
> > I found that you said retrieving tid first is sufficient to do
> > things right in old discussion. :)
> 
> Right but the tid can be obtained from a different processor.
> 
> 
> One other aspect of this patchset is that it reduces the cache footprint
> of the alloc and free functions. This typically results in a performance
> increase for the allocator. If we can avoid the page_address() and
> virt_to_head_page() stuff that is required because we drop the ->page
> field in a sufficient number of places then this may be a benefit that
> goes beyond the RT and CONFIG_PREEMPT case.

Yeah... if we can avoid those function calls, it would be good.

But, current struct kmem_cache_cpu occupies just 32 bytes on 64 bits
machine, and, that means just 1 cacheline. Reducing size of struct may have
no remarkable performance benefit in this case.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
