Received: from yme.mo.hiMolde.no (qmailr@yme.mo.hiMolde.no [158.38.74.10])
	by kvack.org (8.8.7/8.8.7) with SMTP id PAA00660
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 15:28:08 -0500
Date: Mon, 11 Jan 1999 21:27:40 +0100 (CET)
From: Erik Inge Bolso <knan@mo.himolde.no>
Subject: The hogmemtest on a 386 / 8MB...
Message-ID: <Pine.LNX.3.96.990111212436.21349B-100000@yme.mo.himolde.no>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Test results:

386DX-25 w/8 MB RAM, IDE disk

		./hogmem 12 3		(2x) ./hogmem 6 3

2.0.36		0.32 MB/sec		0.14+0.14 MB/sec
2.1.128		0.41 MB/sec		0.14+0.14 MB/sec
2.2.0pre6	0.61 MB/sec		0.20+0.20 MB/sec
2.2.0pre7	0.61 MB/sec		0.27+0.27 MB/sec

0.61 MB/sec is probably the best this trusty old IDE can do... :)

... pre7 is noticeably better w/2 trashing processes... :)

I'd be happy to test more kernel variations :)... since this 386 does a
fair bit of swapping when accessed by FTP... :)

--
Erik I. Bolso <knan at mo.himolde.no>
The White Tower: http://www.mo.himolde.no/~knan/

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
