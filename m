Date: Fri, 13 Aug 1999 13:24:53 -0400 (EDT)
From: Chris Atenasio <chrisa@flashcom.net>
Subject: Re: Strange  memory allocation error in 2.2.11
In-Reply-To: <Pine.LNX.3.96.990813104056.25480B-100000@mole.spellcast.com>
Message-ID: <Pine.LNX.4.10.9908131320000.4925-100000@chris.atenasio.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Roman Levenstein <romix@geocities.com>
List-ID: <linux-mm.kvack.org>

I will comment that something is definately up with MM in 2.2.11.
Although no one else I've asked had this problem, my 2.2.11 almost seems
to be unable to deallocate memory, and hangs after a few minutes when
all is used up.

2.2.10 works fine.

oh, and this *is* egcs-2.91.66...

- Chris
-----------------------------------------------------------------------------
Chris Atenasio <chrisa@flashcom.net> - Friends don't let friends use Windows.
Send mail with subject "send pgp key" or "word of the day" for auto-response.
Today's word of the day: displays

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
