Subject: Re: [rfc][patch] mm: madvise(WILLNEED) for anonymous memory
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1198162078.6821.27.camel@twins>
References: <1198155938.6821.3.camel@twins>
	 <Pine.LNX.4.64.0712201339010.18399@blonde.wat.veritas.com>
	 <1198162078.6821.27.camel@twins>
Content-Type: text/plain
Date: Thu, 20 Dec 2007 15:56:00 +0100
Message-Id: <1198162560.6821.30.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, riel <riel@redhat.com>, Lennart Poettering <mztabzr@0pointer.de>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-12-20 at 15:47 +0100, Peter Zijlstra wrote:
> On Thu, 2007-12-20 at 14:09 +0000, Hugh Dickins wrote:

> > Interesting divergence: make_pages_present faults in writable pages
> > in a writable vma, whereas the file case's force_page_cache_readahead
> > doesn't even insert the pages into the mm.
> 
> Yeah, the find_vma and write fault thing are the reason I didn't use
> make_pages_present.
> 
> I had noticed the difference in pte population between
> force_page_cache_readahead and make_pages_present, but it seemed to me
> that writing a function to walk the page tables and populate the
> swapcache but not populate the ptes wasn't worth the effort.

Ah, another, more important difference:

force_page_cache_readahead will not wait for the read to complete,
whereas get_user_pages() will be fully synchronous.

I think I'd better come up with something else then,..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
