Received: from cowboy.net (root@cowboy.net [206.103.98.250])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA09071
	for <linux-mm@kvack.org>; Tue, 12 Jan 1999 12:01:00 -0500
Date: Tue, 12 Jan 1999 10:58:06 -0600 (CST)
From: Joseph Anthony <jga@alien.cowboy.net>
Reply-To: Joseph Anthony <jga@cowboy.net>
Subject: Re: Results: Zlatko's new vm patch
In-Reply-To: <Pine.LNX.3.95.990111213013.15291A-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.05.9901121055350.723-100000@alien.cowboy.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Steve Bergman <steve@netplus.net>, Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Well, sometimes the system writes to swap before I have used half my
memory ( in X ) I view this with wmmon in windowmaker.. also on shutting
down the system, it fails to unmount partitions saying they are busy and
forcing checks next boot saying they were not cleanly unmounted.
2.2.0-pre4 - pre6 ( I do not have pre7 to test )

On Mon, 11 Jan 1999, Linus Torvalds wrote:

> 
> 
> Note that there are very few people who are testing interactive feel. I'd
> be happier with more people giving more subjective comments on how the
> system feels under heavy memory load. 
> 
> The only feedback I have so far says that pre-7 is much better than any of
> the pre-6 versions, but I'd be happier with more coverage depth and more
> comments from people in different circumstances. For example, what does it
> feel like when you're paging heavily and doing a "find" at the same time
> on a 16M machine?
> 
> I know this is harder than just trying to determine the throughput of
> something, but the pre-6 thing certainly showed how dangerous it was to
> just look at numbers.
> 
> 		Linus
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.rutgers.edu
> Please read the FAQ at http://www.tux.org/lkml/
> 


---
*************************************
*          Joseph Anthony           *
*          jga@cowboy.net           *
*     http://wasteland.cowboy.net   *
*  -------------------------------  *
*  System Administrator Cowboy.net  *
*       http://www.cowboy.net       *
*************************************

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
