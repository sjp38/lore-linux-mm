Date: Wed, 19 Oct 2005 21:10:12 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] OVERCOMMIT_ALWAYS extension
In-Reply-To: <1129747855.8716.12.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.61.0510192102031.10794@goblin.wat.veritas.com>
References: <1129570219.23632.34.camel@localhost.localdomain>
 <Pine.LNX.4.61.0510171904040.6406@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0510171919150.6548@goblin.wat.veritas.com>
 <1129651502.23632.63.camel@localhost.localdomain>
 <Pine.LNX.4.61.0510191826280.8674@goblin.wat.veritas.com>
 <1129747855.8716.12.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Chris Wright <chrisw@osdl.org>, Jeff Dike <jdike@addtoit.com>, linux-mm <linux-mm@kvack.org>, Darren Hart <dvhltc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Oct 2005, Badari Pulavarty wrote:
> 
> Darren Hart is working on patch to add madvise(DISCARD) to extend
> the functionality of madvise(DONTNEED) to really drop those pages.
> I was going to ask your opinion on that approach :) 
> 
> shmget(SHM_NORESERVE) + madvise(DISCARD) should do what I was
> hoping for. (BTW, none of this has been tested with database stuff -
> I am just concentrating on reasonable extensions.

That sounds interesting, and reasonable.  But I'm afraid it's likely
to be several days (a week or more) before I get around to studying it.

If Jeff gets to look at it sooner, it would be interesting to hear if
it suits his need too (but it's entirely inappropriate for me to
expect Jeff to find time to do what I'm not).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
