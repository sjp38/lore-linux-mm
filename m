Received: from stingray.netplus.net (root@stingray.netplus.net [206.250.192.19] (may be forged))
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA24679
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 17:53:30 -0500
Message-ID: <36992ED2.D05EA28F@netplus.net>
Date: Sun, 10 Jan 1999 16:50:58 -0600
From: Steve Bergman <steve@netplus.net>
MIME-Version: 1.0
Subject: Results: arcavm15, et. al.
References: <Pine.LNX.3.96.990110215759.2341A-100000@laser.bogus> <369920F3.E9940FAA@netplus.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>, Linus Torvalds <torvalds@transmeta.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

For the image load test:

pre6+zlatko's_patch             2:35
and with requested change       3:09
pre6                            2:27
pre5                            1:58
arcavm13                        9:13
arcavm15			1:59


For the kernel compile test:

In 12MB:
                                Elapsed Maj.    Min.    Swaps
                                -----   ------  ------  -----
pre6+zlatko_patch               22:14   383206  204482  57823
and with requested change       22:23   378662  198194  51445
pre6                            20:54   352934  191210  48678
pre5                            19:35   334680  183732  93427 
arcavm13                        19:45   344452  180243  38977
arcavm15			20:07	N/A	N/A	N/A

Arcavm15 looks very good.  pre5 and arcavm13 look a bit better but of the
kernels with the anti-deadlock code it looks the best so far. ( I assume that
being based upon pre6 it's safe.)
The battery in my palmtop died so I don't have the page fault and swaps results
available for arcavm15.  I'll grab the pre-7.gz patch and see how it does.

-Steve
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
