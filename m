Received: from ripspost.aist.go.jp (ripspost.aist.go.jp [150.29.9.2])
	by kvack.org (8.8.7/8.8.7) with ESMTP id XAA01789
	for <linux-mm@kvack.ORG>; Wed, 27 Jan 1999 23:23:18 -0500
Date: Thu, 28 Jan 1999 13:20:27 +0900 (JST)
From: Tom Holroyd <tomh@taz.ccs.fau.edu>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses 
In-Reply-To: <Pine.LNX.3.96.990128023440.8338A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990128131323.2461A-100000@bhalpha1.nibh.go.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.COM>, Linus Torvalds <torvalds@transmeta.com>, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mmm, yes.  Both of Andrea's patches (the one in arca-4 and the most recent
one posted here) fix the problem with procs stuck in the D state, on my
Alpha PC164LX.

Hmpf.  Even though I have only 1 processor, make "MAKE=make -j5" dep is
consistently faster than make dep.  128M box...

Ah well, I guess I'll try loading some modules and crashing it that way.
:-)

Dr. Tom Holroyd
I would dance and be merry,
Life would be a ding-a-derry,
If I only had a brain.
	-- The Scarecrow

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
