Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA10058
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 01:55:11 -0500
Date: Fri, 8 Jan 1999 22:53:38 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 2.2.0-pre[56] swap performance poor with > 1 thrashing task
In-Reply-To: <369709CF.E38FEE6F@ucsd.edu>
Message-ID: <Pine.LNX.3.95.990108224546.3436E-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Benjamin Redelings I <bredelin@ucsd.edu>
Cc: Dax Kelson <dkelson@inconnect.com>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Steve Bergman <steve@netplus.net>, Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>



On Fri, 8 Jan 1999, Benjamin Redelings I wrote:
>
> 	Maybe this is not really a problem with swapping, but more with
> concurrent I/O in general,

It's really easy to get really crappy performance with concurrent IO, if
you end up just seeking back and forth on the disk - which is why we
should be trying to cluster our IO. Sounds like we end up with silly
behaviour where one process is paging in from one area of the disk while
the other is paging out to another area, resulting in all the time spent
in just moving the disk head rather than moving any actual data.

Or something silly like that. The fix is probably not all that complex: 
the code is supposed to try to avoid it, but I bet I just had some idiotic
braino that just completely defeated the whole idea. It sounds like Zlatko
found my braino already.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
