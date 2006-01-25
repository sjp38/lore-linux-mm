Date: Wed, 25 Jan 2006 07:05:13 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [patch] hugepage allocator cleanup
Message-ID: <20060125150513.GF7655@holomorphy.com>
References: <20060125091103.GA32653@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060125091103.GA32653@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 25, 2006 at 10:11:03AM +0100, Nick Piggin wrote:
> This is a slight rework of the mechanism for allocating "fresh" hugepages.
> Comments?
> --
> Insert "fresh" huge pages into the hugepage allocator by the same
> means as they are freed back into it. This reduces code size and
> allows enqueue_huge_page to be inlined into the hugepage free
> fastpath.
> Eliminate occurances of hugepages on the free list with non-zero
> refcount. This can allow stricter refcount checks in future. Also
> required for lockless pagecache.

I don't really see any particular benefit to the rearrangement for
hugetlb's own sake. Explaining more about how it it's needed for the
lockless pagecache might help.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
