Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA02308
	for <linux-mm@kvack.org>; Mon, 25 Jan 1999 15:59:21 -0500
Date: Mon, 25 Jan 1999 12:56:21 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <19990125214929.A28382@Galois.suse.de>
Message-ID: <Pine.LNX.3.95.990125125512.411B-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: Andrea Arcangeli <andrea@e-mind.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 25 Jan 1999, Dr. Werner Fink wrote:
> 
> This hypothetical bit should only be set if the page is read physical
> from the swap device/file.  That means it would take one step more
> to swap out this page again (test_and_clear_bit of both 
> PG_recently_swapped_in and PG_referenced).

Ehh - it is already marked "accessed" in the page tables, which
essentially amounts to exactly that kind of two-level aging (the
PG_referenced bit only takes effect once the swapped-in page has once more
been evicted from the page tables) 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
