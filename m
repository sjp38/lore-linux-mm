Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA09927
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 01:46:00 -0500
Date: Fri, 8 Jan 1999 22:44:25 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 2.2.0-pre[56] swap performance poor with > 1 thrashing task
In-Reply-To: <87sodl552m.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.95.990108223729.3436D-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: Dax Kelson <dkelson@inconnect.com>, Steve Bergman <steve@netplus.net>, Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>


Btw, if there are people there who actually like timing different things
(something I _hate_ doing - I lose interest if things become just a matter
of numbers rather than trying to get some algorithm right), then there's
one thing I'd love to hear about: the effect of trying to do some
access bit setting on buffer cache pages.

See my comments in linux/include/linux/fs.h, at around line 260 or so. 
It's the "touch_buffer()" macro which is currently a no-op, and it is
entirely possible that it really should set the PG_referenced bit. 

As a no-op, it can now randomly and unprectably result in even worthwhile
buffers just being thrown out - possibly quite soon after they've been
loaded in. I happen to believe that it doesn't actually matter (and I'm
not convinced that marking the pages referenced has no downsides), but I'm
too lazy to bother to test it. 

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
