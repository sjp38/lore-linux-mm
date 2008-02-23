Date: Sat, 23 Feb 2008 15:20:55 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 00/17] Slab Fragmentation Reduction V10
Message-ID: <20080223142055.GA6745@one.firstfloor.org>
References: <20080216004526.763643520@sgi.com> <20080223000722.a37983eb.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080223000722.a37983eb.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org
List-ID: <linux-mm.kvack.org>

I personally would really like to see d/icache fragmentation in
one form or another. It's a serious long standing Linux issue
that would be really good to solve finally.

> So I think the first thing we need to do is to establish that slub is
> viable as our only slab allocator (ignoring slob here).  And if that means
> tweaking the heck out of slub until it's competitive, we would be
> duty-bound to ask "how fast will slab be if we do that much tweaking to
> it as well".

There's another aspect: slab is quite unreadable and very hairy code.
slub is much cleaner. On the maintainability front slub wins easily. 

> Another basis for comparison is "which one uses the lowest-order
> allocations to achieve its performance".

That's an important point I agree. It directly translates into
reliability under load and that is very important.

> But one of these implementations needs to go away, and that decision

I don't think slab is a good candidate to keep because it's so hard 
to hack on. Especially since the slab NUMA changes the code flow and
data structures are really really hairy and I doubt there are many people 
left who understand it. e.g. I tracked down an RT bug in slab some
time ago and it was a really unpleasant experience.

In the end even if it is slightly slower today the code
that is easiest to improve will be faster/better longer term.

I'm a little sceptical about the high order allocations in slub too 
though. Christoph seems to think they're not a big deal, but that is 
against a lot of conventional Linux wisdom at least.

That is one area that probably needs to be explored more.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
