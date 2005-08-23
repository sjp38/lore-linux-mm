Message-ID: <430B24A6.5010906@yahoo.com.au>
Date: Tue, 23 Aug 2005 23:29:10 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFT][PATCH 2/2] pagefault scalability alternative
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com> <Pine.LNX.4.61.0508222229270.22924@goblin.wat.veritas.com> <430A6D08.1080707@yahoo.com.au> <Pine.LNX.4.61.0508230805040.5224@goblin.wat.veritas.com> <430B0662.3060509@yahoo.com.au> <Pine.LNX.4.61.0508231333330.7718@goblin.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.61.0508231333330.7718@goblin.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Tue, 23 Aug 2005, Nick Piggin wrote:
> 
>>Which brings up another issue - this surely conflicts rather
>>badly with PageReserved removal :( Not that there is anything
>>wrong with that, but I don't like to create these kinds of
>>problems for people...
> 
> 
> Conflicts in the sense that I'm messing all over source files which
> removing PageReserved touches?
> 
> Or in some deeper sense, that it makes the whole project of removing
> PageReserved more difficult (I don't see how)?
> 

No, just diff conflicts.

> 
>>Do we still want to remove PageReserved sooner rather than
>>later?
> 
> 
> I'd say remove PageReserved sooner;
> or at least your "remove it from the core" subset.
> 

OK so long as you're still happy with that. You'd been
a bit quiet on the subject and I had just been assuming
that's because you've got no more big objections to it.
Just wanted to clarify - thanks.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
