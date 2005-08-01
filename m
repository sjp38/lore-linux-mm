Date: Mon, 1 Aug 2005 21:51:48 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
In-Reply-To: <20050801131240.4e8b1873.akpm@osdl.org>
Message-ID: <Pine.LNX.4.61.0508012144590.6323@goblin.wat.veritas.com>
References: <20050801032258.A465C180EC0@magilla.sf.frob.com>
 <42EDDB82.1040900@yahoo.com.au> <Pine.LNX.4.61.0508012045050.5373@goblin.wat.veritas.com>
 <20050801131240.4e8b1873.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: nickpiggin@yahoo.com.au, holt@sgi.com, torvalds@osdl.org, mingo@elte.hu, roland@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Aug 2005, Andrew Morton wrote:
> static inline int handle_mm_fault(...)
> {
> 	int ret = __handle_mm_fault(...);
> 
> 	if (unlikely(ret == VM_FAULT_RACE))
> 		ret = VM_FAULT_MINOR;
> 	return ret;
> }
> because VM_FAULT_RACE is some internal private thing.
> It does add another test-n-branch to the pagefault path though.

Good idea, at least to avoid changing all arches at this moment;
though I don't think handle_mm_fault itself can be static inline.

But let's set this VM_FAULT_RACE approach aside for now: I think
we're agreed that the pte_dirty-with-mods-to-s390 route is more
attractive, so I'll now try to find fault with that approach.

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
