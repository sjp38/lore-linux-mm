Date: Wed, 8 Jul 1998 23:19:51 +0200 (CEST)
From: Andrea Arcangeli <arcangeli@mbox.queen.it>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <199807081354.OAA03355@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980708231741.352A-100000@dragon.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Jul 1998, Stephen C. Tweedie wrote:

>I'm unconvinced.  It's pretty clear that the underlying problem is that
>the cache is far too agressive when you are copying large amounts of
>data around.  The fact that interactive performance is bad suggests not
>that the swapping algorithm is making bad decisions, but that it is
>being forced to work with far too little physical memory due to the
>cache size.

Yes, this is exactly what I think too.

Andrea[s] Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
