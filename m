Received: from castle.nmd.msu.ru (castle.nmd.msu.ru [193.232.112.53])
	by kvack.org (8.8.7/8.8.7) with SMTP id GAA19088
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 06:56:34 -0500
Message-ID: <19990110145618.A32291@castle.nmd.msu.ru>
Date: Sun, 10 Jan 1999 14:56:18 +0300
From: Savochkin Andrey Vladimirovich <saw@msu.ru>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
References: <Pine.LNX.3.95.990109095521.2572A-100000@penguin.transmeta.com> <Pine.LNX.3.95.990109134233.3478A-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.95.990109134233.3478A-100000@penguin.transmeta.com>; from "Linus Torvalds" on Sat, Jan 09, 1999 at 01:50:14PM
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, "Eric W. Biederman" <ebiederm+eric@ccr.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jan 09, 1999 at 01:50:14PM -0800, Linus Torvalds wrote:
> 
> 
> On Sat, 9 Jan 1999, Linus Torvalds wrote:
> > 
> > The cleanest solution I can think of is actually to allow semaphores to be
> > recursive. I can do that with minimal overhead (just one extra instruction
> > in the non-contention case), so it's not too bad, and I've wanted to do it
> > for certain other things, but it's still a nasty piece of code to mess
> > around with. 
> > 
> > Oh, well. I don't think I have much choice.

Well, doesn't semaphore recursion mean that the write atomicity
is no more guaranteed by inode's i_sem semaphore?

Best wishes
					Andrey V.
					Savochkin
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
