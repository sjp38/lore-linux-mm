Received: from mhs.atenasio.net (root@d112.dial-1.cmb.ma.ultra.net [209.6.64.112])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA01691
	for <linux-mm@kvack.org>; Fri, 2 Apr 1999 13:56:49 -0500
Date: Fri, 2 Apr 1999 13:56:39 -0500 (EST)
From: Chris Atenasio <chrisa@ultranet.com>
Subject: Re: Somw questions [ MAYBE OFFTOPIC ]
In-Reply-To: <19990402113555.F9584@uni-koblenz.de>
Message-ID: <Pine.LNX.4.05.9904021353340.18457-100000@chris.atenasio.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Amol Mohite <amol@m-net.arbornet.org>
Cc: ralf@uni-koblenz.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> A NULL pointer is just yet another invalid address.  There is no special
> test for a NULL pointer.  Most probably for example (char *)0x12345678 will
> be invalid as a pointer as well and treated the same.  The CPU detects this
> when the TLB doesn't have a translation valid for the access being attempted.

Which is why you can do -=*fun*=- things such as:

fd = open("/dev/kmem", O_RDWR);
mmap(0,64000,PROT_READ|PROT_WRITE,MAP_SHARED|MAP_FIXED,fd,0xB8000);

:)   ^                                       ^^^^^^^^^

- Chris
-----------------------------------------------------------------------------
Chris Atenasio <chrisa@ultranet.com> - Friends don't let friends use Windows.
Send mail with subject "send pgp key" or "word of the day" for auto-response.
Today's word of the day: masculinity

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
