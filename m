Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA32070
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 12:45:36 -0500
Date: Mon, 11 Jan 1999 09:44:41 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Buffer handling (setting PG_referenced on access)
In-Reply-To: <87k8yuupuv.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.95.990111094140.4886A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Dax Kelson <dkelson@inconnect.com>, Steve Bergman <steve@netplus.net>, Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>



On 11 Jan 1999, Zlatko Calusic wrote:
> 
> OK, implementation was easy and simple, much simpler than it was made
> before (with BH_Touched copying...), but I must admit that even after
> lots of testing I couldn't find any difference. Not in performance,
> not in CPU usage, not in overall behaviour. Whatever results I have
> accomplished, they were too much in the statistical noise, so I don't
> have any useful data. Maybe, others can try and see.

This was what I saw in my very very inconclusive tests too - which is why
I decided that there was no point in doing buffer cache aging at all.

> But, nevertheless, four lines added to the kernel look very correct to
> me. My vote for including, if for nothing, then to make balance with
> page cache. It won't harm anything, that's for sure.

I can easily see it harming something - I actually think that not using
the reference bit is "safer" in that it never allows the buffer cache to
grow very aggressively for very long (and we definitely don't want to have
an overlarge buffer cache - it's mostly used for temporary buffers for
write-out anyway).

Basically I don't want to enable the aging code unless somebody shows me
that it makes a marked improvement under some (reasonably real-world)
circumstances.. So far the jury seems to say that it doesn't.

		Linus


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
