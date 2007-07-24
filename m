Date: Tue, 24 Jul 2007 00:14:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] add __GFP_ZERO to GFP_LEVEL_MASK
In-Reply-To: <1185259732.8197.30.camel@twins>
Message-ID: <Pine.LNX.4.64.0707240011070.3128@schroedinger.engr.sgi.com>
References: <1185185020.8197.11.camel@twins>  <20070723112143.GB19437@skynet.ie>
 <1185190711.8197.15.camel@twins>  <Pine.LNX.4.64.0707231615310.427@schroedinger.engr.sgi.com>
  <1185256869.8197.27.camel@twins> <1185259732.8197.30.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mel@skynet.ie>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Daniel Phillips <phillips@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Jul 2007, Peter Zijlstra wrote:

> > Personally I like the consistency of adding __GFP_ZERO here (removes
> > this odd exception) and just masking it in the sl[aou]b thingies.

Adds more code. GFP_LEVEL_MASK are the flags passed through to the 
page allocator. Neither __GFP_ZERO nor __GFP_DMA are passed through and 
therefore they are not part of the GFP_LEVEL_MASK.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
