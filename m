Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA04539
	for <linux-mm@kvack.org>; Tue, 12 Jan 1999 00:35:02 -0500
Date: Mon, 11 Jan 1999 21:33:08 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Results: Zlatko's new vm patch
In-Reply-To: <369ABFB4.C420E5AE@netplus.net>
Message-ID: <Pine.LNX.3.95.990111213013.15291A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>
Cc: Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>



Note that there are very few people who are testing interactive feel. I'd
be happier with more people giving more subjective comments on how the
system feels under heavy memory load. 

The only feedback I have so far says that pre-7 is much better than any of
the pre-6 versions, but I'd be happier with more coverage depth and more
comments from people in different circumstances. For example, what does it
feel like when you're paging heavily and doing a "find" at the same time
on a 16M machine?

I know this is harder than just trying to determine the throughput of
something, but the pre-6 thing certainly showed how dangerous it was to
just look at numbers.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
