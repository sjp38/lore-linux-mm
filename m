Date: Wed, 29 Aug 2007 15:45:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch][rfc] radix-tree: be a nice citizen
Message-Id: <20070829154531.fd6d67bc.akpm@linux-foundation.org>
In-Reply-To: <20070829094503.GC32236@wotan.suse.de>
References: <20070829085039.GA32236@wotan.suse.de>
	<20070829015702.7c8567c2.akpm@linux-foundation.org>
	<20070829090301.GB32236@wotan.suse.de>
	<20070829022044.9730888e.akpm@linux-foundation.org>
	<20070829094503.GC32236@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 29 Aug 2007 11:45:03 +0200 Nick Piggin <npiggin@suse.de> wrote:

> Yeah I'm sure the radix_tree_insert isn't failing, but the
> first kmem_cache_alloc in radix_tree_node_alloc is failing (page
> allocator is giving the backtrace). Because it is GFP_ATOMIC and
> being done under the spinlock.

OK, that's expected.  Add a __GFP_NOWARN to the caller's gfp_t?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
