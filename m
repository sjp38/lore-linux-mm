Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA21097
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 17:36:49 -0500
Date: Wed, 13 Jan 1999 14:30:32 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <199901132210.WAA07391@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.990113142730.6104G-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 13 Jan 1999, Stephen C. Tweedie wrote:
> 
> The problem is that if you do this, it is easy for the swapper to
> generate huge amounts of async IO without actually freeing any real
> memory: there's a question of balancing the amount of free memory we
> have available right now with the amount which we are in the process of
> freeing.  Setting the nr_async_pages bound to 256 just makes the swapper
> keen to send a whole 1MB of memory out to disk at a time, which is a bit
> steep on an 8MB box.

Note that this should be much less of a problem with the current swapout
strategies, but yes, basically we definitely do want to have _some_ way of
maintaining a sane "maximum number of pages in flight" thing. 

The right solution may be to do the check in some other place, rather than
fairly deep inside the swap logic. 

It's not a big deal, I suspect.

Anyway, there's a real pre7 out there now, and it doesn't change a lot of
th issues discussed here. I wanted to get something stable and working. I
still need to get the recursive semaphore thing (or other approach) done,
but basically I think we're at 2.2.0 already apart from that issue, and
that we can continue this discussion as a "occasional tweaks" thing. 

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
