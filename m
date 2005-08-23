Date: Tue, 23 Aug 2005 17:38:50 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFT][PATCH 2/2] pagefault scalability alternative
In-Reply-To: <430B24A6.5010906@yahoo.com.au>
Message-ID: <Pine.LNX.4.61.0508231732540.10061@goblin.wat.veritas.com>
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0508222229270.22924@goblin.wat.veritas.com>
 <430A6D08.1080707@yahoo.com.au> <Pine.LNX.4.61.0508230805040.5224@goblin.wat.veritas.com>
 <430B0662.3060509@yahoo.com.au> <Pine.LNX.4.61.0508231333330.7718@goblin.wat.veritas.com>
 <430B24A6.5010906@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Aug 2005, Nick Piggin wrote:
> Hugh Dickins wrote:
> > 
> > I'd say remove PageReserved sooner;
> > or at least your "remove it from the core" subset.
> 
> OK so long as you're still happy with that. You'd been
> a bit quiet on the subject and I had just been assuming
> that's because you've got no more big objections to it.
> Just wanted to clarify - thanks.

Sorry, as ever I just find it hard to keep up.
Yes, I'm keen for PageReserved to hurry away.

Never any big objections: we disagreed a little on how to stage it,
but in the end one absence of PageReserved will be much like another.

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
