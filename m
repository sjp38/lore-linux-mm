Received: from snowcrash.cymru.net (snowcrash.cymru.net [163.164.160.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA29941
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 13:24:31 -0500
Message-Id: <m0zyKxU-0007U3C@the-village.bc.nu>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch]
Date: Thu, 7 Jan 1999 19:19:02 +0000 (GMT)
In-Reply-To: <Pine.LNX.4.03.9901071912510.6527-100000@mirkwood.dummy.home> from "Rik van Riel" at Jan 7, 99 07:18:19 pm
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@humbolt.geo.uu.nl>
Cc: torvalds@transmeta.com, ebiederm+eric@ccr.net, andrea@e-mind.com, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, Zlatko.Calusic@CARNet.hr, bmccann@indusriver.com, alan@lxorguk.ukuu.org.uk, bredelin@ucsd.edu, sct@redhat.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> It can be solved by having a 'laundry' list like the *BSD
> folks have and maybe a special worker thread to take care
> of the laundry (optimizing placement on disk, etc).

We actually have one - on the sparc anyway there is asyncd

Alan

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
