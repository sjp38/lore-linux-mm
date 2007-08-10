Received: by wa-out-1112.google.com with SMTP id m33so750373wag
        for <linux-mm@kvack.org>; Thu, 09 Aug 2007 18:54:01 -0700 (PDT)
Message-ID: <4a5909270708091854n7c84ae9aj84170092a5eb61db@mail.gmail.com>
Date: Thu, 9 Aug 2007 21:54:01 -0400
From: "Daniel Phillips" <daniel.raymond.phillips@gmail.com>
Subject: Re: [PATCH 04/10] mm: slub: add knowledge of reserve pages
In-Reply-To: <20070808114636.7c6f26ab.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070806102922.907530000@chello.nl>
	 <20070806103658.603735000@chello.nl>
	 <Pine.LNX.4.64.0708071702560.4941@schroedinger.engr.sgi.com>
	 <20070808014435.GG30556@waste.org>
	 <Pine.LNX.4.64.0708081004290.12652@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0708081050590.12652@schroedinger.engr.sgi.com>
	 <20070808114636.7c6f26ab.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On 8/8/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 8 Aug 2007 10:57:13 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
>
> > I think in general irq context reclaim is doable. Cannot see obvious
> > issues on a first superficial pass through rmap.c. The irq holdoff would
> > be pretty long though which may make it unacceptable.
>
> The IRQ holdoff could be tremendous.  But if it is sufficiently infrequent
> and if the worst effect is merely a network rx ring overflow then the tradeoff
> might be a good one.

Hi Andrew,

No matter how you look at this problem, you still need to have _some_
sort of reserve, and limit access to it.  We extend existing methods,
you are proposing to what seems like an entirely new reserve
management system.  Great idea, maybe, but it does not solve the
deadlocks.  You still need some organized way of being sure that your
reserve is as big as you need (hopefully not an awful lot bigger) and
you still have to make sure that nobody dips into that reserve further
than they are allowed to.

So translation: reclaim from "easily freeable" lists is an
optimization, maybe a great one.  Probably great.  Reclaim from atomic
context is also a great idea, probably. But you are talking about a
whole nuther patch set.  Neither of those are in themselves a fix for
these deadlocks.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
