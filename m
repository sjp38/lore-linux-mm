Received: from snowcrash.cymru.net (snowcrash.cymru.net [163.164.160.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA23235
	for <linux-mm@kvack.org>; Sun, 24 Jan 1999 19:43:48 -0500
Message-Id: <m104azC-0007U1C@the-village.bc.nu>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
Date: Mon, 25 Jan 1999 01:38:42 +0000 (GMT)
In-Reply-To: <Pine.LNX.3.95.990124162426.17000B-100000@penguin.transmeta.com> from "Linus Torvalds" at Jan 24, 99 04:27:51 pm
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: alan@lxorguk.ukuu.org.uk, sct@redhat.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > There are real cases where grab large linear block is needed.
> 
> Nobody has so far shown a reasonable implementation where this would be
> possible.

Thats as maybe. However someone needs to find a way to do it. Right now I
can run a matrox meteor on netbsd,freebsd,openbsd,windows95, nt but not Linux

Thats not meant as a flippant remark - its something to be stuck on the 2.3
problem chart. Its just a question of who out there is sitting on the 
solution

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
