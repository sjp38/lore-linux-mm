Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
References: <20000924224303.C2615@redhat.com>
	<20000925001342.I5571@athlon.random>
	<20000925003650.A20748@home.ds9a.nl>
	<20000925014137.B6249@athlon.random> <20000925172442.J2615@redhat.com>
	<20000925190347.E27677@athlon.random>
	<20000925190657.N2615@redhat.com>
	<20000925213242.A30832@athlon.random>
	<20000925205457.Y2615@redhat.com> <qwwd7hriqxs.fsf@sap.com>
	<20000926160554.B13832@athlon.random>
From: Christoph Rohland <cr@sap.com>
Date: 26 Sep 2000 18:20:47 +0200
Message-ID: <qww7l7z86qo.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> writes:

> Could you tell me what's wrong in having an app with a 1.5G mapped executable
> (or a tiny executable but with a 1.5G shared/private file mapping if you
> prefer),

O.K. that sound more reasonable. I was reading image as program
text... and a 1.5GB program text is a something I never have seen (and
hopefully will never see :-)

> 300M of shm (or 300M of anonymous memory if you prefer) and 200M as
> filesystem cache?

I don't really see a reason for fs cache in the application. I think
that parallel applications tend to either share mostly all or nothing,
but I may be wrong here.

> The application have a misc I/O load that in some part will run out
> of the working set, what's wrong with this?
> 
> What's ridiculous? Please elaborate.

I think we fixed this misreading. 

But still IMHO you underestimate the importance of shared memory for a
lot of applications in the high end. There is not only Oracle out
there and most of the shared memory is _not_ locked.

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
