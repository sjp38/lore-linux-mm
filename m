Date: Wed, 4 Aug 2004 07:30:58 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] token based thrashing control
In-Reply-To: <Pine.LNX.4.44.0408040016200.24835-100000@th139-4.cs.wm.edu>
Message-ID: <Pine.LNX.4.44.0408040728430.7628-100000@dhcp83-102.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Song Jiang <sjiang@CS.WM.EDU>
Cc: Con Kolivas <kernel@kolivas.org>, Andrew Morton <akpm@osdl.org>, fchen@CS.WM.EDU, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Aug 2004, Song Jiang wrote:

> The intention behind the score = time/size is very sound, but
> I am not sure how sensitive the performance is to the formula.
> We may need to tune it carefully to make it valid.    

[snip]

> Do we need to periodically compare the scores of registered processes?
> If yes, that would take queueing complexity.

Hmmm, good points.  And my "queue of one" idea has the danger
of registering a process that doesn't want the token any more
by the time it's handed off...

Maybe we should use the "time/size" score to influence the
chance that a process gets to try and steal the token, in
effect just modifying the odds.

After all, thrashing should be a relatively rare situation,
so the code should be as low impact as possible...

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
