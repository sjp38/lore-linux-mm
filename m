Received: from snowcrash.cymru.net (snowcrash.cymru.net [163.164.160.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA28241
	for <linux-mm@kvack.org>; Mon, 25 Jan 1999 04:54:18 -0500
Message-Id: <m104jZz-0007U1C@the-village.bc.nu>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
Date: Mon, 25 Jan 1999 10:49:14 +0000 (GMT)
In-Reply-To: <36ABE22B.C7F0DA70@isn.net> from "Garst R. Reese" at Jan 24, 99 11:16:59 pm
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: "Garst R. Reese" <reese@isn.net>
Cc: alan@lxorguk.ukuu.org.uk, andrea@e-mind.com, torvalds@transmeta.com, sct@redhat.com, werner@suse.de, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> How much of this problem can be solved with a ramfs that takes what you
> give it at boot time?

Grabbing 4Mb for wave tables, and 4Mb for a matrox meteor at boot "just
in case" is at the "you might as well run another OS" level of "supported"
IMHO anyway. Its the right answer for any 2.2 retrofits

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
