Received: from mail.suse.de (Cantor.suse.de [194.112.123.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA26013
	for <linux-mm@kvack.org>; Thu, 14 Jan 1999 09:54:11 -0500
Message-ID: <19990114155321.C573@Galois.suse.de>
Date: Thu, 14 Jan 1999 15:53:21 +0100
From: "Dr. Werner Fink" <werner@suse.de>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
References: <Pine.LNX.4.03.9901131557590.295-100000@mirkwood.dummy.home> <Pine.LNX.3.96.990113190617.185C-100000@laser.bogus> <199901132214.WAA07436@dax.scot.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199901132214.WAA07436@dax.scot.redhat.com>; from Stephen C. Tweedie on Wed, Jan 13, 1999 at 10:14:02PM +0000
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@e-mind.com>
Cc: Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > For the case of binaries the aging on the page cache should take care of
> > it (even if there's no aging on the swap cache as pre[567] if I remeber
> > well). 
> 
> There is no aging on the page cache at all other than the PG_referenced
> bit.

I know that most of you do not like aging.  Nevertheless, on high stressed
systems with less than 128M you will see a critical point whereas the page
cache and readahead does not avoid that swapin I/O time needed by a program
increases to similar size of the average program time slice.

At this point the system performance breaks down dramatically even
with 2.2.0pre[567] ...

What's about a simple aging of program page cluster or better of the
page cache?  Increasing the age could be done if and only if the pages
or page clusters swapped in and the program wasn't able to use its
time slice. Decreasing the age could be placed in shrink_mmap().


        Werner

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
