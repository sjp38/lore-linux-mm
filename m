Received: from stingray.netplus.net (root@stingray.netplus.net [206.250.192.19])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA22925
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 15:31:29 -0500
Message-ID: <36990DB5.DA6AE432@netplus.net>
Date: Sun, 10 Jan 1999 14:29:41 -0600
From: Steve Bergman <steve@netplus.net>
MIME-Version: 1.0
Subject: Re: Results: pre6 vs pre6+zlatko's_patch  vs pre5 vs arcavm13
References: <Pine.LNX.3.95.990110105015.7668E-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:

> The logic for that would be something like the attached patch to
> page_alloc.c..


I tried the patch in the 'image test' and it helped little if any.  Still a lot
of swapping in and the numbers are close enough that I'm not sure it helped at
all.  This was a comparison between vanilla pre6 and vanilla
pre6+page_alloc_patch with no other patches applied.

-Steve
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
