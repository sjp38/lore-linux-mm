Date: Wed, 14 Jul 2004 21:39:39 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] /dev/zero page fault scaling
In-Reply-To: <Pine.SGI.4.58.0407141418280.115007@kzerza.americas.sgi.com>
Message-ID: <Pine.LNX.4.44.0407142129090.2153-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jul 2004, Brent Casavant wrote:
> 
> In a test program to measure the page fault performance, at 256P we
> see a 150x improvement in the number of page faults per cpu per
> wall-clock second (and other similar measures).  Page fault performance
> drops by about 50% at 512P compared to 256P, however this is likely
> a seperate problem (investigation has not started), but is still
> 138x better than before these changes.

Wow.  Good work.

> I'm not sure if this list is the appropriate place to submit these
> changes.  If not, please direct me to the correct lists/people to
> submit this to.  The patch is against 2.6.(something recent, maybe 7).

This list'll do fine.  I'm the (unlisted) tmpfs maintainer, I'll give
your patch a go tomorrow, and try to convert it to NULL sbinfo as I
mentioned.  I'll send you back the result, but won't send it on to
Andrew thence Linus for a couple of weeks, until after the Ottawa
Linux Symposium.

Thanks a lot!
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
