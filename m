Received: from squid.netplus.net (squid.netplus.net [206.250.192.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA03733
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 22:22:34 -0500
Message-ID: <369ABFB4.C420E5AE@netplus.net>
Date: Mon, 11 Jan 1999 21:21:24 -0600
From: Steve Bergman <steve@netplus.net>
MIME-Version: 1.0
Subject: Results: Zlatko's new vm patch
References: <Pine.LNX.3.96.990111234054.5378A-100000@laser.bogus> <369AAD50.E3C449BB@netplus.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>, Linus Torvalds <torvalds@transmeta.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Here are the results:
 
116 Image test in 128MB:
 
pre6                            2:27
pre5                            1:58
arcavm13                        9:13
arcavm15                        1:59
pre-7                           2:41
arcavm16                        1:54
arcavm18                        1:57
pre-7+zlatko's latest patch	2:14
 
For the kernel compile test in 12MB:
 
                                 Elapsed Maj.    Min.    Swaps
                                -----   ------  ------  -----
pre6                            20:54   352934  191210  48678
pre5                            19:35   334680  183732  93427
arcavm13                        19:45   344452  180243  38977
arcavm15                        20:07   N/A     N/A     N/A
pre-7                           21:14   356386  192835  50912
arcavm16                        20:09   N/A     N/A     N/A
arcavm18                        21:08   363438  190763  48982
pre-7+zlatko's latest patch	21:34	358408	193930	51813

The patch seems to help in the image test and hurt a bit in the 12MB compile
test (vs pre-7).

 
 -Steve
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
