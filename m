Received: from z.ml.org (z.ml.org [209.208.36.5])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA18994
	for <linux-mm@kvack.org>; Sun, 24 Jan 1999 12:35:42 -0500
Date: Sun, 24 Jan 1999 13:33:53 -0500 (EST)
From: Gregory Maxwell <linker@z.ml.org>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.95.990123161758.12138B-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990124133131.18613A-100000@z.ml.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 23 Jan 1999, Linus Torvalds wrote:

> On Sat, 23 Jan 1999, Alan Cox wrote:
> > 
> > Thats a bug in our current vm structures, like the others - inability to
> > throw out page tables, inability to find memory easily, inability to move
> > blocks to allocate large areas in a target space, inability to handle
> > large user spaces etc.
> 
> What? None of those are bugs, they are features.
> 
> Complexity is not a goal to be reached. Complexity is something to be
> avoided at all cost. If you don't believe me, look at NT.
> 
> 		Linus

Make things as simple as possible, but no simpler.

Do you really think "inability to handle large user spaces" or "inability
to find memory easily" are features? 

Perhaps all the current solutions have been overly complex, however, that
doesn't mean there is no simple way to accomplish the same thing. 



--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
