Date: Mon, 23 Jul 2007 15:41:36 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] add __GFP_ZERP to GFP_LEVEL_MASK
In-Reply-To: <20070723151306.86e3e0ce.akpm@linux-foundation.org>
Message-ID: <alpine.LFD.0.999.0707231539520.3607@woody.linux-foundation.org>
References: <1185185020.8197.11.camel@twins> <20070723113712.c0ee29e5.akpm@linux-foundation.org>
 <1185216048.5535.1.camel@lappy> <20070723144323.1ac34b16@schroedinger.engr.sgi.com>
 <20070723151306.86e3e0ce.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel <linux-kernel@vger.kernel.org>, Daniel Phillips <phillips@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Mon, 23 Jul 2007, Andrew Morton wrote:
> 
> OK, well that was weird.  So
> 
> 	kmalloc(42, GFP_KERNEL|__GFP_ZERO);
> 
> duplicates
> 
> 	kzalloc(42, GFP_KERNEL);
> 
> Why do it both ways?

Both ways? The latter *is* the former. That's how kzalloc() is implemented 
these days.

Andrew - all these patches came through you. You didn't realize?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
