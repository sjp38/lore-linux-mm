Received: from snowcrash.cymru.net (snowcrash.cymru.net [163.164.160.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA09549
	for <linux-mm@kvack.ORG>; Thu, 28 Jan 1999 13:34:56 -0500
Message-Id: <m105x2f-0007U2C@the-village.bc.nu>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
Date: Thu, 28 Jan 1999 19:23:52 +0000 (GMT)
In-Reply-To: <Pine.LNX.3.95.990128101220.32418I-100000@penguin.transmeta.com> from "Linus Torvalds" at Jan 28, 99 10:17:37 am
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: sct@redhat.com, andrea@e-mind.com, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, davem@dm.COBALTMICRO.COM, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Anyway, for 2.2.1 I don't even want to be clever. As it is (with the bogus
> array.c race "fixes" removed), the page may get freed without any kernel
> lock, and we may return _completely_ bogus information, but that is (a) 
> extremely unlikely in the first place and (b) basically harmless and
> pretty much impossible to exploit. 

(c) you can check if the thing has disappeared after using it and clear
the buffer if so.


Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
