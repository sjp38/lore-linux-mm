Received: from snowcrash.cymru.net (snowcrash.cymru.net [163.164.160.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA12278
	for <linux-mm@kvack.org>; Tue, 26 Jan 1999 09:52:06 -0500
Message-Id: <m105Ah6-0007U1C@the-village.bc.nu>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
Date: Tue, 26 Jan 1999 15:46:23 +0000 (GMT)
In-Reply-To: <199901261436.HAA01099@chelm.cs.nmt.edu> from "yodaiken@chelm.cs.nmt.edu" at Jan 26, 99 07:36:50 am
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: yodaiken@chelm.cs.nmt.edu
Cc: mingo@chiara.csoma.elte.hu, alan@lxorguk.ukuu.org.uk, sct@redhat.com, groudier@club-internet.fr, torvalds@transmeta.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > the toughest part is the 'moving' stuff, which is not yet present and
> > hard/impossible to implement in a clean and maintainable way. We need this
> > eg. for sockets, files, (not inodes fortunately), task structures, vmas,
> 
> What's the benefit?  If you need big chunks of physical memory, then you
> obviously are willing to sacrifice efficient use of every last byte.
> 
> > yes it restricts and complicates the way kernel subsystems can allocate
> > buffers, but we _have_ to do that iff we want to solve the problem 100%.
> 
> So for that last 10% of "solve" we introduce a lot of complexity into 
> every subsystem?

We don't need to solve the 100% case. Simply being sure we can (slowly)
allocate up to 25% of RAM in huge chunks is going to be enough. Good point
Ingo on one thing I'd missed - the big chunks themselves need some kind
of handles since the moment we hand out 512K chunks we may not be able to 
shuffle and get a 4Mb block

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
