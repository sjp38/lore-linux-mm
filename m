Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA12043
	for <linux-mm@kvack.org>; Thu, 21 Jan 1999 11:51:34 -0500
Date: Thu, 21 Jan 1999 16:50:36 GMT
Message-Id: <199901211650.QAA04674@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <19990114155321.C573@Galois.suse.de>
References: <Pine.LNX.4.03.9901131557590.295-100000@mirkwood.dummy.home>
	<Pine.LNX.3.96.990113190617.185C-100000@laser.bogus>
	<199901132214.WAA07436@dax.scot.redhat.com>
	<19990114155321.C573@Galois.suse.de>
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@e-mind.com>, Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 14 Jan 1999 15:53:21 +0100, "Dr. Werner Fink" <werner@suse.de> said:

>> There is no aging on the page cache at all other than the PG_referenced
>> bit.

> I know that most of you do not like aging.  Nevertheless, on high stressed
> systems with less than 128M you will see a critical point whereas the page
> cache and readahead does not avoid that swapin I/O time needed by a program
> increases to similar size of the average program time slice.

There's no reason why timeslices should have anything to do with swapin
IO time; we do not count time spent waiting for IO against the process's
allocated timeslice.

> What's about a simple aging of program page cluster or better of the
> page cache?  Increasing the age could be done if and only if the pages
> or page clusters swapped in and the program wasn't able to use its
> time slice. Decreasing the age could be placed in shrink_mmap().

Page aging dramatically increases the amount of CPU time we spend
looking for free pages.  The selection of which pages to swap out really
shouldn't have anything to do with scheduling of CPU-bound processes
(which is the only time where timeslices actually count for anything).

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
