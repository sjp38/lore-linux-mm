Received: from mail.suse.de (Cantor.suse.de [194.112.123.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA10093
	for <linux-mm@kvack.org>; Thu, 28 Jan 1999 14:13:56 -0500
Message-ID: <19990128201248.A18705@Galois.suse.de>
Date: Thu, 28 Jan 1999 20:12:48 +0100
From: "Dr. Werner Fink" <werner@suse.de>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
References: <19990125141409.A29248@boole.suse.de> <Pine.LNX.3.96.990125193551.422A-100000@laser.bogus> <19990125214929.A28382@Galois.suse.de> <199901271452.OAA04778@dax.scot.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199901271452.OAA04778@dax.scot.redhat.com>; from Stephen C. Tweedie on Wed, Jan 27, 1999 at 02:52:26PM +0000
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>, "Dr. Werner Fink" <werner@suse.de>
Cc: Andrea Arcangeli <andrea@e-mind.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Ok its a bit better than a single PII 400 MHz :-)
> > ... with less than 64MB the break downs are going to be the common state
> > whereas with 128MB the system is usable.  Nevertheless whenever both make
> > loops taking the filesystem tree at the same time, the system performance
> > slows down dramatically (a `break down').
> 
> Not for me.  That's probably just the advantage of having swap on a
> separate disk, but I've got both a "find /" and a "wc /usr/bin/*"
> running right now, and interactive performance is not noticeably
> degraded on 2.2.0-release with 64MB (and that is with two active users
> on the box right now).  Concurrent filesystem and swap IO on the same
> spindle is always going to suck.

I'm not talking about a simple find, ... the two "make MAKE='make -j10'"
in /usr/src/linux/ and /usr/src/newkernel/linux/ do force this
`break down' with 2.2.0-pre9 if the two makes are entering
/usr/src/linux/fs/ or /usr/src/newkernel/linux/fs/ respectively
at the same time which increases the load a `bit'.


         Werner

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
