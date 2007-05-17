Date: Thu, 17 May 2007 11:01:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
In-Reply-To: <1179424430.2925.7.camel@lappy>
Message-ID: <Pine.LNX.4.64.0705171059340.18085@schroedinger.engr.sgi.com>
References: <1179350433.2912.66.camel@lappy>
 <Pine.LNX.4.64.0705161435110.11642@schroedinger.engr.sgi.com>
 <1179386921.27354.29.camel@twins>  <Pine.LNX.4.64.0705171029500.17245@schroedinger.engr.sgi.com>
 <1179424430.2925.7.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Thu, 17 May 2007, Peter Zijlstra wrote:

> > > Its about ensuring ALLOC_NO_WATERMARKS memory only reaches PF_MEMALLOC
> > > processes, not joe random's pi calculator.
> > 
> > Watermarks are per zone?
> 
> Yes, but the page allocator might address multiple zones in order to
> obtain a page.

And then again it may not because the allocation is contrained to a 
particular node,a NORMAL zone or a DMA zone. One zone way be below the 
watermark and another may not. Different allocations may be allowed to 
tap into various zones for various reasons.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
