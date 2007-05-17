Date: Thu, 17 May 2007 10:29:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
In-Reply-To: <1179385718.27354.17.camel@twins>
Message-ID: <Pine.LNX.4.64.0705171027390.17245@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
 <Pine.LNX.4.64.0705161957440.13458@schroedinger.engr.sgi.com>
 <1179385718.27354.17.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Thu, 17 May 2007, Peter Zijlstra wrote:

> I'm really not seeing why you're making such a fuzz about it; normally
> when you push the system this hard we're failing allocations left right
> and center too. Its just that the block IO path has some mempools which
> allow it to write out some (swap) pages and slowly get back to sanity.

I am weirdly confused by these patches. Among other things you told me 
that the performance does not matter since its never (or rarely) being 
used (why do it then?). Then we do these strange swizzles with reserve 
slabs that may contain an indeterminate amount of objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
