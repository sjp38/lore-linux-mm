Date: Fri, 5 May 2000 01:44:23 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: classzone-VM + mapped pages out of lru_cache
In-Reply-To: <3911ECCD.BA1BB24E@arcormail.de>
Message-ID: <Pine.LNX.4.21.0005050137120.8057-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shane Shrybman <shrybman@sympatico.ca>, "Juan J. Quintela" <quintela@fi.udc.es>, gandalf@wlug.westbo.se, Joerg Stroettchen <joerg.stroettchen@arcormail.de>
Cc: linux-kernel@vger.rutgers.edu, Jens Axboe <axboe@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

As somebody noticed classzone-18 had a deadlock condition. It was due a
silly bug and I fixed it in the new classzone-22:

	ftp://ftp.us.kernel.org/pub/linux/kernel/people/andrea/patches/v2.3/2.3.99-pre7-pre4/classzone-22.gz

This new one also doesn't allow read(2) to see the page that we're going
to drop from truncate(2). There are no other changes. It's against
2.3.99-pre7-pre4.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
