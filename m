Received: from stingray.netplus.net (root@stingray.netplus.net [206.250.192.19])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA31728
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 12:00:32 -0500
Message-ID: <369A2D5E.472B7F75@netplus.net>
Date: Mon, 11 Jan 1999 10:57:02 -0600
From: Steve Bergman <steve@netplus.net>
MIME-Version: 1.0
Subject: Re: Results: pre6 vs pre6+zlatko's_patch  vs pre5 vs arcavm13
References: <Pine.LNX.3.95.990110105015.7668E-100000@penguin.transmeta.com> <36990DB5.DA6AE432@netplus.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Here are updated results including arcavm16:


116 Image test in 128MB:

pre6+zlatko's_patch             2:35
and with requested change       3:09
pre6                            2:27
pre5                            1:58
arcavm13                        9:13
arcavm15                        1:59
pre-7                           2:41
arcavm16			1:54

For the kernel compile test in 12MB:

                                Elapsed Maj.    Min.    Swaps
                                -----   ------  ------  -----
pre6+zlatko_patch               22:14   383206  204482  57823
and with requested change       22:23   378662  198194  51445
pre6                            20:54   352934  191210  48678
pre5                            19:35   334680  183732  93427
arcavm13                        19:45   344452  180243  38977
arcavm15                        20:07   N/A     N/A     N/A
pre-7                           21:14   356386  192835  50912
arcavm16			20:09	N/A	N/A	N/A


I think it's better than arcavm15 on the image test and the same on the compile
test.


-Steve
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
