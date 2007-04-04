Date: Wed, 4 Apr 2007 16:03:15 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc] no ZERO_PAGE?
In-Reply-To: <20070404144421.GA13762@localdomain>
Message-ID: <Pine.LNX.4.64.0704041553220.18202@blonde.wat.veritas.com>
References: <20070329075805.GA6852@wotan.suse.de>
 <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com>
 <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de>
 <Pine.LNX.4.64.0704041023040.17341@blonde.wat.veritas.com>
 <20070404102407.GA529@wotan.suse.de> <20070404122701.GB19587@v2.random>
 <20070404135530.GA29026@localdomain> <20070404141457.GF19587@v2.random>
 <20070404144421.GA13762@localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dan Aloni <da-x@monatomic.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Apr 2007, Dan Aloni wrote:
> 
> To refine that example, you could replace the file with a large anonymous 
> memory pool and a lot of swap space committed to it. In that case - with 
> no ZERO_PAGE, would the kernel needlessly swap-out the zeroed pages? 
> Perhaps it's an example too far-fetched to worth considering...

Nice point, not far-fetched, though I don't know whether it's worth
worrying about or not.  Yes, as things stand, the kernel will
needlessly write them out to swap: because we're in the habit of
marking a writable pte as dirty, partly to save the processor (how
i386-centric am I being?) from having to do that work just after,
partly because of some race too ancient for me to know anything
about - do_no_page (though not the function in question here) says:

	 * This silly early PAGE_DIRTY setting removes a race
	 * due to the bad i386 page protection. But it's valid
	 * for other architectures too.

Maybe Nick will decide to not to mark the readfaults as dirty.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
