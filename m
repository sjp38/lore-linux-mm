Received: from mail.suse.de (Cantor.suse.de [194.112.123.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA29898
	for <linux-mm@kvack.org>; Mon, 25 Jan 1999 08:16:12 -0500
Message-ID: <19990125141409.A29248@boole.suse.de>
Date: Mon, 25 Jan 1999 14:14:09 +0100
From: "Dr. Werner Fink" <werner@suse.de>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
References: <Pine.LNX.4.03.9901131557590.295-100000@mirkwood.dummy.home> <Pine.LNX.3.96.990113190617.185C-100000@laser.bogus> <199901132214.WAA07436@dax.scot.redhat.com> <19990114155321.C573@Galois.suse.de> <m1u2xjgtke.fsf@flinx.ccr.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m1u2xjgtke.fsf@flinx.ccr.net>; from Eric W. Biederman on Fri, Jan 22, 1999 at 10:29:05AM -0600
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Dr. Werner Fink" <werner@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@e-mind.com>, Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 22, 1999 at 10:29:05AM -0600, Eric W. Biederman wrote:
> 
> WF> At this point the system performance breaks down dramatically even
> WF> with 2.2.0pre[567] ...
> 
> If you could demonstrate this it would aid any plea for changing the VM system.

I'm using simple two loops in different kernel trees:

      while true; do make clean; make MAKE='make -j10'; done

which leads into load upper 30.  You can see a great performance upto
load to 25 ... 30+ *and* a brutal break down of that performance
at this point.  The system is a PentiumII 400MHz with 32, 64, 128MB
(mem=xxx) and SCSI only.  In comparision to 2.0.36 the performance
is *beside of this break down* much better ...  that means that only
the performance break down at high load is the real problem.

> 
> WF> What's about a simple aging of program page cluster or better of the
> WF> page cache? 
> 
> We do age pages.  The PG_referenced bit.  This scheme as far as I can
> tell is more effective at predicting pages we are going to use next
> than any we have used before.

What's about a `PG_recently_swapped_in' bit for pages which arn't found
anymore with the swap cache?  This isn't a prediction but a protection
against throwing out the same page in the following cycle.

> 
> WF> Increasing the age could be done if and only if the pages
> WF> or page clusters swapped in and the program wasn't able to use its
> WF> time slice. Decreasing the age could be placed in shrink_mmap().
> 
> People keep playing with ignoring PG_referenced in shrink_mmap for the swap cache,
> because it doesn't seem terribly important.  If you could demonstrate
> this is a problem we can stop ignoring it.
> 
> Eric
> 


            Werner
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
