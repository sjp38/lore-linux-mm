Date: Wed, 8 Jul 1998 14:54:53 +0100
Message-Id: <199807081354.OAA03355@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.95.980707125719.613B-100000@as200.spellcast.com>
References: <Pine.LNX.3.96.980707175139.18757A-100000@mirkwood.dummy.home>
	<Pine.LNX.3.95.980707125719.613B-100000@as200.spellcast.com>
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <arcangeli@mbox.queen.it>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 7 Jul 1998 13:32:34 -0400 (8UU), "Benjamin C.R. LaHaise"
<blah@kvack.org> said:

> This is the wrong fix for the case that Andrea is complaining about -
> tossing out chunks of processes piecemeal, resulting in a length page-in
> time when the process becomes active again.  Two things that might help
> with this are: read-ahead on swapins, and *true* swapping.  

I'm unconvinced.  It's pretty clear that the underlying problem is that
the cache is far too agressive when you are copying large amounts of
data around.  The fact that interactive performance is bad suggests not
that the swapping algorithm is making bad decisions, but that it is
being forced to work with far too little physical memory due to the
cache size.

There's no doubt that swap readahead and true full-process swapping can
give us performance benefits, but Andrea is quite clearly seeing
enormous resident cache sizes when copying large files to /dev/null, and
that's a problem which we need to tackle independently of the swapper's
own page selection algorithms.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
