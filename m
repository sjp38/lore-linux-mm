Received: from squid.netplus.net (squid.netplus.net [206.250.192.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA03239
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 21:04:41 -0500
Message-ID: <369AAD50.E3C449BB@netplus.net>
Date: Mon, 11 Jan 1999 20:02:56 -0600
From: Steve Bergman <steve@netplus.net>
MIME-Version: 1.0
Subject: Re: Results: pre6 vs pre6+zlatko's_patch  vs pre5 vs arcavm13
References: <Pine.LNX.3.96.990111234054.5378A-100000@laser.bogus>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> 

> Here arca-vm-18 against 2.2.0-pre7 in the testing directory (sent me by
> email by Steve).
> 

(Zlatko, your patch is next. ;-)  )

Here are the results:


116 Image test in 128MB:

pre6+zlatko's_patch             2:35
and with requested change       3:09
pre6                            2:27
pre5                            1:58
arcavm13                        9:13
arcavm15                        1:59
pre-7                           2:41
arcavm16                        1:54
arcavm18			1:57

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
arcavm16                        20:09   N/A     N/A     N/A
arcavm18			21:08	363438	190763	48982


-Steve
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
