Received: from mail.ccr.net (ccr@alogconduit1ah.ccr.net [208.130.159.8])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA30229
	for <linux-mm@kvack.org>; Fri, 22 Jan 1999 19:36:30 -0500
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
References: <Pine.LNX.4.03.9901131557590.295-100000@mirkwood.dummy.home> <Pine.LNX.3.96.990113190617.185C-100000@laser.bogus> <199901132214.WAA07436@dax.scot.redhat.com> <19990114155321.C573@Galois.suse.de>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 22 Jan 1999 10:29:05 -0600
In-Reply-To: "Dr. Werner Fink"'s message of "Thu, 14 Jan 1999 15:53:21 +0100"
Message-ID: <m1u2xjgtke.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@e-mind.com>, Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "WF" == Werner Fink <werner@suse.de> writes:

WF> I know that most of you do not like aging.

We love aging.  We dislike the BS that called it self aging code.
It implemented something like least frequently used.  Instead of
least recently used.  We dislike least frequently used because it's a poor
predictor of pages to be used next, and a cpu hog.

WF> At this point the system performance breaks down dramatically even
WF> with 2.2.0pre[567] ...

If you could demonstrate this it would aid any plea for changing the VM system.

WF> What's about a simple aging of program page cluster or better of the
WF> page cache? 

We do age pages.  The PG_referenced bit.  This scheme as far as I can
tell is more effective at predicting pages we are going to use next
than any we have used before.

WF> Increasing the age could be done if and only if the pages
WF> or page clusters swapped in and the program wasn't able to use its
WF> time slice. Decreasing the age could be placed in shrink_mmap().

People keep playing with ignoring PG_referenced in shrink_mmap for the swap cache,
because it doesn't seem terribly important.  If you could demonstrate
this is a problem we can stop ignoring it.

Eric


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
