Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA21327
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 13:26:28 -0500
Date: Sun, 10 Jan 1999 18:59:38 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <19990110145618.A32291@castle.nmd.msu.ru>
Message-ID: <Pine.LNX.3.96.990110185202.327D-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Savochkin Andrey Vladimirovich <saw@msu.ru>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 10 Jan 1999, Savochkin Andrey Vladimirovich wrote:

> Well, doesn't semaphore recursion mean that the write atomicity
> is no more guaranteed by inode's i_sem semaphore?

Looking first Linus's patch I guessed right what does it mean recursion
over a sempahore (not that there would be many other choices though ;). As
I just pointed out the write atomicity is not more garanteed from the
internal path of the same process (previously in such case we would
deadlock but sure we had no ways to corrupt things). It's still garanteed
that many processes working on a critical section protected by the same
semaphore will not mess up things.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
