Message-ID: <430AF474.8080805@yahoo.com.au>
Date: Tue, 23 Aug 2005 20:03:32 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFT][PATCH 0/2] pagefault scalability alternative
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com> <Pine.LNX.4.62.0508221448480.8933@schroedinger.engr.sgi.com> <Pine.LNX.4.61.0508230822300.5224@goblin.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.61.0508230822300.5224@goblin.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:

> So the problem ones are i386 PAE and sparc: I haven't got down to sparc
> yet, I expect it to need a little reordering and barriers, but no great
> problem.
> 

I don't think that case is a problem because I don't think we
ever allocate or free pmd entries due to some CPU errata.

That is, unless something has changed very recently.

> I don't believe we need to read or write the PAE entries atomically.
> 

Hmm, OK. I didn't see the trickery you were doing in do_swap_page
and do_file_page etc. So actually, that seems OK.

Wrapping it in a helper function might be nice (the
recheck-under-lock for sizeof(pte_t) > sizeof(long), that is).

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
