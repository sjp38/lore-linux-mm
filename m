Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA21656
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 13:40:23 -0500
Date: Sun, 10 Jan 1999 10:35:10 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <199901101659.QAA00922@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.990110103201.7668D-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Savochkin Andrey Vladimirovich <saw@msu.ru>, Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, "Eric W. Biederman" <ebiederm+eric@ccr.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Sun, 10 Jan 1999, Stephen C. Tweedie wrote:
> 
> Ack.  I've been having a closer look, and making the superblock lock
> recursive doesn't work

That's fine - the superblock lock doesn't need to be re-entrant, because
__GFP_IO is quite sufficient for that one.

The thing I want to make re-entrant is just semaphore accesses: at the
point where we would otherwise deadlock on the writer semaphore it's much
better to just allow nested writes. I suspect all filesystems can already
handle nested writes - they are a lot easier to handle than truly
concurrent ones.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
