Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA22669
	for <linux-mm@kvack.org>; Tue, 19 Jan 1999 21:29:03 -0500
Date: Tue, 19 Jan 1999 21:35:33 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: VM20 behavior on a 486DX/66Mhz with 16mb of RAM
In-Reply-To: <Pine.BSF.4.05.9901191505560.2608-100000@earl-grey.cloud9.net>
Message-ID: <Pine.LNX.3.96.990119212155.402A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: John Alvord <jalvo@cloud9.net>, Nimrod Zimerman <zimerman@deskmail.com>, Linux Kernel mailing list <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This written by Stephen:

> > Horrible --- smells like the old problem of "oh, our VM is hopeless at
> > tuning performance itself, so let's rely on magic numbers to constrain
> > it to reasonable performance".  I'd much much much much rather see a VM

My point is that the algorithm to do something of useful and safe needs an
objective to reach. The algorithm need to know what has to do. I learn to
the algorithm what to do, nothing more.

Swapping out when shrink_mmap fails, means nothing. You don't know what
will happens to the memory levels. This is the reason it works worse than
my way (and that slowdown machines after some day).

And btw, I don't care `work with magic'. I care that everything works
efficient, stable, and confortable. 1 only level of cache percentage
tunable looks fine to me (everything else works with magic and works fine,
but I need at least 1 fixed point to learn at the algorithm what to do). 
You can write a gtk app that allow the sysadm to move up and down the
_only_ cache percentage level. I dropped all others bogus percentage
levels. So at least my code is 6/1 times less Horrible than pre8 (and
sctvm) from your `must work (and mess) with magic' point of view.

If I am missing something (again ;) comments are always welcome.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
