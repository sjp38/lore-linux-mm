Date: Thu, 15 Jul 2004 11:28:36 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: [PATCH] /dev/zero page fault scaling
In-Reply-To: <Pine.LNX.4.44.0407142129090.2153-100000@localhost.localdomain>
Message-ID: <Pine.SGI.4.58.0407151125150.116400@kzerza.americas.sgi.com>
References: <Pine.LNX.4.44.0407142129090.2153-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jul 2004, Hugh Dickins wrote:

> This list'll do fine.  I'm the (unlisted) tmpfs maintainer, I'll give
> your patch a go tomorrow, and try to convert it to NULL sbinfo as I
> mentioned.  I'll send you back the result, but won't send it on to
> Andrew thence Linus for a couple of weeks, until after the Ottawa
> Linux Symposium.

Hmm.  There's more of the same lurking in here.  I moved on to the next
page fault scaling problem on the list, namely with SysV shared memory
segments.  I'll give you one guess which cacheline is the culprit in that
case.

Unless I'm mistaken, we don't need to track sbinfo for SysV segments
either.  So my next task is to figure out how to turn on the SHMEM_NOSBINFO
bit for that case as well.

So there may be a new patch coming in the next day or two.

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
