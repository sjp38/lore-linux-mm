Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 0B99D6B0072
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 12:33:15 -0500 (EST)
Received: by iadk27 with SMTP id k27so7911577iad.14
        for <linux-mm@kvack.org>; Mon, 30 Jan 2012 09:33:15 -0800 (PST)
Date: Mon, 30 Jan 2012 09:33:11 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/3] percpu: use ZERO_SIZE_PTR / ZERO_OR_NULL_PTR
Message-ID: <20120130173311.GE3355@google.com>
References: <1327912654-8738-1-git-send-email-dmitry.antipov@linaro.org>
 <20120130171558.GB3355@google.com>
 <20120130171919.GC3355@google.com>
 <alpine.DEB.2.00.1201301122410.28693@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1201301122410.28693@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Dmitry Antipov <dmitry.antipov@linaro.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-dev@lists.linaro.org

On Mon, Jan 30, 2012 at 11:22:57AM -0600, Christoph Lameter wrote:
> On Mon, 30 Jan 2012, Tejun Heo wrote:
> 
> > On Mon, Jan 30, 2012 at 09:15:58AM -0800, Tejun Heo wrote:
> > > Percpu pointers are in a different address space and using
> > > ZERO_SIZE_PTR directly will trigger sparse address space warning.
> > > Also, I'm not entirely sure whether 16 is guaranteed to be unused in
> > > percpu address space (maybe it is but I don't think we have anything
> > > enforcing that).
> >
> > Another thing is that percpu address dereferencing always goes through
> > rather unintuitive translation and 1. we can't (or rather currently
> > don't) guarantee that fault will occur for any address 2. even if it
> > does, the faulting address wouldn't be anything easily
> > distinguishible.  So, unless the above shortcomings is resolved, I
> > don't really see much point of using ZERO_SIZE_PTR for percpu
> > allocator.
> 
> The same is true for the use of NULL pointers.

I'm pretty sure it never gives out NULL for a dynamic allocation.  The
base might be mapped to zero but we're guaranteed to have some static
percpu areas there and IIRC the percpu addresses aren't supposed to
wrap.

Also, if ZERO_SIZE_PTR doesn't actually help anything, it is not a
good idea to have it.  The only thing it does would be giving wrong
impressions.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
