Received: from snowcrash.cymru.net (snowcrash.cymru.net [163.164.160.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA09136
	for <linux-mm@kvack.org>; Sat, 23 Jan 1999 17:26:48 -0500
Message-Id: <m104CMO-0007U1C@the-village.bc.nu>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
Date: Sat, 23 Jan 1999 23:20:59 +0000 (GMT)
In-Reply-To: <199901211650.QAA04674@dax.scot.redhat.com> from "Stephen C. Tweedie" at Jan 21, 99 04:50:36 pm
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, torvalds@transmeta.com, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, alan@lxorguk.ukuu.org.uk, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Page aging dramatically increases the amount of CPU time we spend
> looking for free pages.  The selection of which pages to swap out really

Thats a bug in our current vm structures, like the others - inability to
throw out page tables, inability to find memory easily, inability to move
blocks to allocate large areas in a target space, inability to handle
large user spaces etc.

At least 2.3 will have plenty of fun things to do 8)

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
