Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA26433
	for <linux-mm@kvack.org>; Wed, 27 Jan 1999 09:52:45 -0500
Date: Wed, 27 Jan 1999 14:52:26 GMT
Message-Id: <199901271452.OAA04778@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <19990125214929.A28382@Galois.suse.de>
References: <19990125141409.A29248@boole.suse.de>
	<Pine.LNX.3.96.990125193551.422A-100000@laser.bogus>
	<19990125214929.A28382@Galois.suse.de>
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: Andrea Arcangeli <andrea@e-mind.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 25 Jan 1999 21:49:29 +0100, "Dr. Werner Fink" <werner@suse.de>
said:

> Ok its a bit better than a single PII 400 MHz :-)
> ... with less than 64MB the break downs are going to be the common state
> whereas with 128MB the system is usable.  Nevertheless whenever both make
> loops taking the filesystem tree at the same time, the system performance
> slows down dramatically (a `break down').

Not for me.  That's probably just the advantage of having swap on a
separate disk, but I've got both a "find /" and a "wc /usr/bin/*"
running right now, and interactive performance is not noticeably
degraded on 2.2.0-release with 64MB (and that is with two active users
on the box right now).  Concurrent filesystem and swap IO on the same
spindle is always going to suck.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
