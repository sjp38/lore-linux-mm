Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA24440
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 17:33:36 -0500
Date: Sun, 10 Jan 1999 22:33:21 GMT
Message-Id: <199901102233.WAA01649@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <19990110145618.A32291@castle.nmd.msu.ru>
References: <Pine.LNX.3.95.990109095521.2572A-100000@penguin.transmeta.com>
	<Pine.LNX.3.95.990109134233.3478A-100000@penguin.transmeta.com>
	<19990110145618.A32291@castle.nmd.msu.ru>
Sender: owner-linux-mm@kvack.org
To: Savochkin Andrey Vladimirovich <saw@msu.ru>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, "Eric W. Biederman" <ebiederm+eric@ccr.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 10 Jan 1999 14:56:18 +0300, Savochkin Andrey Vladimirovich
<saw@msu.ru> said:

> Well, doesn't semaphore recursion mean that the write atomicity
> is no more guaranteed by inode's i_sem semaphore?

Yes.  That's OK from one point of view --- there's nothing in the specs
which requires us to make writes atomic.  The question is whether any
filesystems rely on it internally in their implementation.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
