Received: from castle.nmd.msu.ru (castle.nmd.msu.ru [193.232.112.53])
	by kvack.org (8.8.7/8.8.7) with SMTP id JAA30774
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 09:12:12 -0500
Message-ID: <19990111171138.A9675@castle.nmd.msu.ru>
Date: Mon, 11 Jan 1999 17:11:38 +0300
From: Savochkin Andrey Vladimirovich <saw@msu.ru>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
References: <199901101659.QAA00922@dax.scot.redhat.com> <Pine.LNX.3.95.990110103201.7668D-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.95.990110103201.7668D-100000@penguin.transmeta.com>; from "Linus Torvalds" on Sun, Jan 10, 1999 at 10:35:10AM
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jan 10, 1999 at 10:35:10AM -0800, Linus Torvalds wrote:
> The thing I want to make re-entrant is just semaphore accesses: at the
> point where we would otherwise deadlock on the writer semaphore it's much
> better to just allow nested writes. I suspect all filesystems can already
> handle nested writes - they are a lot easier to handle than truly
> concurrent ones.

You're an optimist, aren't you? :-)

In any case I've checked your recursive semaphore code on a news server
which reliably deadlocked with the previous kernels.
The code seems to work well.

Best wishes
					Andrey V.
					Savochkin
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
