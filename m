Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA00532
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 15:19:55 -0500
Subject: Re: Buffer handling (setting PG_referenced on access)
References: <Pine.LNX.3.95.990111094140.4886A-100000@penguin.transmeta.com>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 11 Jan 1999 21:14:11 +0100
In-Reply-To: Linus Torvalds's message of "Mon, 11 Jan 1999 09:44:41 -0800 (PST)"
Message-ID: <87g19h36uk.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Dax Kelson <dkelson@inconnect.com>, Steve Bergman <steve@netplus.net>, Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@transmeta.com> writes:

> On 11 Jan 1999, Zlatko Calusic wrote:
> > 
> > OK, implementation was easy and simple, much simpler than it was made
> > before (with BH_Touched copying...), but I must admit that even after
> > lots of testing I couldn't find any difference. Not in performance,
> > not in CPU usage, not in overall behaviour. Whatever results I have
> > accomplished, they were too much in the statistical noise, so I don't
> > have any useful data. Maybe, others can try and see.
> 
> This was what I saw in my very very inconclusive tests too - which is why
> I decided that there was no point in doing buffer cache aging at all.

Yes, looks like we finished our tests with same results.

> 
> > But, nevertheless, four lines added to the kernel look very correct to
> > me. My vote for including, if for nothing, then to make balance with
> > page cache. It won't harm anything, that's for sure.
> 
> I can easily see it harming something - I actually think that not using
> the reference bit is "safer" in that it never allows the buffer cache to
> grow very aggressively for very long (and we definitely don't want to have
> an overlarge buffer cache - it's mostly used for temporary buffers for
> write-out anyway).
> 
> Basically I don't want to enable the aging code unless somebody shows me
> that it makes a marked improvement under some (reasonably real-world)
> circumstances.. So far the jury seems to say that it doesn't.
> 

OK, I got one more idea in the meantime, and I'll try it as the time
permits. In the meantime, I agree with you. If we can't prove it's
actually worthwhile to add those four lines, then we really don't need
them.

Regards,
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
