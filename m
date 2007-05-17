Date: Thu, 17 May 2007 11:02:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
In-Reply-To: <20070517175327.GX11115@waste.org>
Message-ID: <Pine.LNX.4.64.0705171101360.18085@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
 <Pine.LNX.4.64.0705161957440.13458@schroedinger.engr.sgi.com>
 <1179385718.27354.17.camel@twins> <Pine.LNX.4.64.0705171027390.17245@schroedinger.engr.sgi.com>
 <20070517175327.GX11115@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Thu, 17 May 2007, Matt Mackall wrote:

> Simply stated, the problem is sometimes it's impossible to free memory
> without allocating more memory. Thus we must keep enough protected
> reserve that we can guarantee progress. This is what mempools are for
> in the regular I/O stack. Unfortunately, mempools are a bad match for
> network I/O.
> 
> It's absolutely correct that performance doesn't matter in the case
> this patch is addressing. All that matters is digging ourselves out of
> OOM. The box either survives the crisis or it doesn't.

Well we fail allocations in order to do so and these allocations may be 
even nonatomic allocs. Pretty dangerous approach.

> It's also correct that we should hardly ever get into a situation
> where we trigger this problem. But such cases are still fairly easy to
> trigger in some workloads. Swap over network is an excellent example,
> because we typically don't start swapping heavily until we're quite
> low on freeable memory.

Is it not possible to avoid failing allocs? Instead put processes to 
sleep? Run synchrononous reclaim?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
