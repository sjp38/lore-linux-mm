Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA20770
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 17:10:40 -0500
Date: Wed, 13 Jan 1999 22:10:12 GMT
Message-Id: <199901132210.WAA07391@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.96.990113191421.185E-100000@laser.bogus>
References: <199901131755.RAA06476@dax.scot.redhat.com>
	<Pine.LNX.3.96.990113191421.185E-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 13 Jan 1999 19:52:03 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> Note that we don't need nr_async_pages at all. Here when the limit of
> nr_async_pages is low it's only a bottleneck for swapout performances. I
> have not removed it (because it could be useful to decrease swapout I/O if
> somebody needs this strange feature), but I have added a
> page_daemon.max_async_pages and set it to something like 256. Now I check
> nr_async_pages against the new max_async_pages. 

The problem is that if you do this, it is easy for the swapper to
generate huge amounts of async IO without actually freeing any real
memory: there's a question of balancing the amount of free memory we
have available right now with the amount which we are in the process of
freeing.  Setting the nr_async_pages bound to 256 just makes the swapper
keen to send a whole 1MB of memory out to disk at a time, which is a bit
steep on an 8MB box.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
