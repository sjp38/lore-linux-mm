Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA10440
	for <linux-mm@kvack.org>; Tue, 12 Jan 1999 14:07:14 -0500
Date: Tue, 12 Jan 1999 20:05:21 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <87d84kl49u.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.96.990112200143.1382B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12 Jan 1999, Zlatko Calusic wrote:

> Could somebody spare a minute to explain why is that so, and what
> needs to be done to make SHM swapping asynchronous?

Maybe because nobody care about shm? I think shm can wait for 2.3 to be
improved.

> Also, while we're at MM fixes, I'm appending below a small patch that
> will improve interactive feel.

This is just in my latest arca patches as you have just noticed. Don't
think that this thing make some difference though. But sometimes
could improve performances and make tons of sense.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
