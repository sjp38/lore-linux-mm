Received: from stingray.netplus.net (root@stingray.netplus.net [206.250.192.19])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA25650
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 20:14:12 -0500
Message-ID: <369943D4.6AA9AAF1@netplus.net>
Date: Sun, 10 Jan 1999 18:20:36 -0600
From: Steve Bergman <steve@netplus.net>
MIME-Version: 1.0
Subject: Re: Results: arcavm15, et. al.
References: <Pine.LNX.3.96.990110215759.2341A-100000@laser.bogus> <369920F3.E9940FAA@netplus.net> <36992ED2.D05EA28F@netplus.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>, Linus Torvalds <torvalds@transmeta.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Here are the results of pre-7:

116 Image test in 128MB:

pre6+zlatko's_patch             2:35
and with requested change       3:09
pre6                            2:27
pre5                            1:58
arcavm13                        9:13
arcavm15                        1:59
pre-7				2:41


For the kernel compile test in 12MB:

                                Elapsed Maj.    Min.    Swaps
                                -----   ------  ------  -----
pre6+zlatko_patch               22:14   383206  204482  57823
and with requested change       22:23   378662  198194  51445
pre6                            20:54   352934  191210  48678
pre5                            19:35   334680  183732  93427
arcavm13                        19:45   344452  180243  38977
arcavm15                        20:07   N/A     N/A     N/A
pre-7				21:14	356386	192835	50912


-Steve
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
