Date: Wed, 14 Jul 2004 16:31:18 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: [PATCH] /dev/zero page fault scaling
In-Reply-To: <Pine.LNX.4.44.0407142129090.2153-100000@localhost.localdomain>
Message-ID: <Pine.SGI.4.58.0407141623220.115007@kzerza.americas.sgi.com>
References: <Pine.LNX.4.44.0407142129090.2153-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jul 2004, Hugh Dickins wrote:

> On Wed, 14 Jul 2004, Brent Casavant wrote:

> Wow.  Good work.

*blush*  Thanks.  Though of course credit for the observation about
not needing to track this info for /dev/null goes to Jack Steiner.

> > I'm not sure if this list is the appropriate place to submit these
> > changes.
>
> This list'll do fine.  I'm the (unlisted) tmpfs maintainer, I'll give
> your patch a go tomorrow, and try to convert it to NULL sbinfo as I
> mentioned.  I'll send you back the result, but won't send it on to
> Andrew thence Linus for a couple of weeks, until after the Ottawa
> Linux Symposium.

Thank you.  Actually I'm going to be *very* interested to see how the
NULL sbinfo works.  There's so much I don't understand yet.

Oh, one thing you might want to double-check in my patch: I not
only avoided updating free_blocks, but also i_blocks, since it
was under the same lock and always updated at the same time as
free_blocks.  I didn't see any problems with this from my testing,
but I also wasn't 100% sure that was the correct thing to do.  If
it's not correct we still have a problem as the i_blocks cacheline
would then need to ping-pong around the machine.

Thanks,
Brent

-- 
Brent Casavant             bcasavan@sgi.com        Forget bright-eyed and
Operating System Engineer  http://www.sgi.com/     bushy-tailed; I'm red-
Silicon Graphics, Inc.     44.8562N 93.1355W 860F  eyed and bushy-haired.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
