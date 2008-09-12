Date: Fri, 12 Sep 2008 18:25:17 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC PATCH] discarding swap
In-Reply-To: <20080912165038.GA12849@shareable.org>
Message-ID: <Pine.LNX.4.64.0809121812440.15514@blonde.site>
References: <Pine.LNX.4.64.0809092222110.25727@blonde.site>
 <20080910173518.GD20055@kernel.dk> <Pine.LNX.4.64.0809102015230.16131@blonde.site>
 <1221082117.13621.25.camel@macbook.infradead.org> <Pine.LNX.4.64.0809121154430.12812@blonde.site>
 <1221228567.3919.35.camel@macbook.infradead.org> <Pine.LNX.4.64.0809121631050.5142@blonde.site>
 <20080912165038.GA12849@shareable.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: David Woodhouse <dwmw2@infradead.org>, Jens Axboe <jens.axboe@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Sep 2008, Jamie Lokier wrote:
> 
> Here's an idea which is prompted by DISCARD:
> 
> One thing the request layer doesn't do is cancellations.
> But if it did:
> 
> If you schedule some swap to be written, then later it is no longer
> required before the WRITE has completed (e.g. process exits), on a
> busy system would it be worth _cancelling_ the WRITE while it's still
> in the request queue?  This is quite similar to DISCARDing, but
> internal to the kernel.

You mean, like those "So Andso wishes to recall the embarrassing
message accidentally sent to everyone in the company" which I
sometimes see from MS users?

Yes, it could be applicable when there's a huge quantity of I/O in
flight that suddenly becomes redundant, on process exit (for swap)
or file truncation.  But is the upper level likely to want submit
bios for all such pages?  And it only works so long as the bio has
not yet gone out for I/O - therefore seems of limited usefulness?

But might come pretty much for free if it were decided that DISCARD
does need more complicated detect-if-writes-already-queued semantics.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
