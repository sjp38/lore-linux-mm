Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA19180
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 14:10:07 -0500
Date: Wed, 13 Jan 1999 19:10:28 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.4.03.9901131557590.295-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.96.990113190617.185C-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@humbolt.geo.uu.nl>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jan 1999, Rik van Riel wrote:

> - in allocating swap space it just doesn't make sense to read
>   into the next swap 'region'

The point is that I can't see a swap `region' looking at how
scan_swap_map() works. The more atomic region I can see in the swap space
is a block of bytes large PAGE_SIZE bytes (e.g. offset ;).

For the case of binaries the aging on the page cache should take care of
it (even if there's no aging on the swap cache as pre[567] if I remeber
well). 

Andrea Arcangeli


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
