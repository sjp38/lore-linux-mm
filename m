Received: from stingray.netplus.net (root@stingray.netplus.net [206.250.192.19])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA24796
	for <linux-mm@kvack.org>; Wed, 6 Jan 1999 22:34:53 -0500
Message-ID: <36942ACA.3F8C055D@netplus.net>
Date: Wed, 06 Jan 1999 21:32:26 -0600
From: Steve Bergman <steve@netplus.net>
MIME-Version: 1.0
Subject: Results: 2.2.0-pre5 vs arcavm10 vs arcavm9 vs arcavm7
References: <Pine.LNX.3.96.990107001448.1242B-100000@laser.bogus>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:

> I've put out a new arca-vm-10 with at least this bug fixed.
> 
> ftp://e-mind.com/pub/linux/kernel-patches/2.2.0-pre4-arca-VM-10
> 

Here are my latest numbers.  This is timing a complete kernel compile  (make
clean;make depend;make;make modules;make modules_install)  in 16MB memory with
netscape, kde, and various daemons running.  I unknowningly had two more daemons
running in the background this time than last so the numbers can't be compared
directly with my last test (Which I think I only sent to Andrea).  But all of
these numbers are consistent with *each other*.


kernel		Time	Maj pf	Min pf  Swaps
----------	-----	------	------	-----
2.2.0-pre5	18:19	522333	493803	27984
arcavm10	19:57	556299	494163	12035
arcavm9		19:55	553783	494444	12077
arcavm7		18:39	538520	493287	11526


Pre5 looks good.
Arcavm7 still looks better than arcavm10.

-Steve
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
