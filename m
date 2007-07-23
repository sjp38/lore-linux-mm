Date: Mon, 23 Jul 2007 14:43:23 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] add __GFP_ZERP to GFP_LEVEL_MASK
Message-ID: <20070723144323.1ac34b16@schroedinger.engr.sgi.com>
In-Reply-To: <1185216048.5535.1.camel@lappy>
References: <1185185020.8197.11.camel@twins>
	<20070723113712.c0ee29e5.akpm@linux-foundation.org>
	<1185216048.5535.1.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Daniel Phillips <phillips@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

__GFP_ZERO is implemented by the slab allocators (the page allocator
has no knowledge about the length of the object to be zeroed). The slab
allocators do not pass __GFP_ZERO to the page allocator.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
