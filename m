Received: from yme.mo.hiMolde.no (qmailr@yme.mo.hiMolde.no [158.38.74.10])
	by kvack.org (8.8.7/8.8.7) with SMTP id QAA11333
	for <linux-mm@kvack.org>; Tue, 12 Jan 1999 16:08:25 -0500
Date: Tue, 12 Jan 1999 22:08:07 +0100 (CET)
From: Erik Inge Bolso <knan@mo.himolde.no>
Subject: The hogmemtest on a 386 / 8MB... Updated...
Message-ID: <Pine.LNX.3.96.990112220701.9841B-100000@yme.mo.himolde.no>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

386DX-25 w/8 MB RAM, IDE disk

		./hogmem 12 3		(2x) ./hogmem 6 3

2.0.36		0.32 MB/sec		0.14+0.14 MB/sec
2.1.128		0.41 MB/sec		0.14+0.14 MB/sec
2.2.0pre6	0.61 MB/sec		0.20+0.20 MB/sec
2.2.0pre6
 + arcavm16	0.54 MB/sec		0.16+0.16 MB/sec
2.2.0pre7	0.61 MB/sec		0.27+0.27 MB/sec
2.2.0pre7
 + zlatko1	0.61 MB/sec		0.27+0.27 MB/sec

"interactive feel" is impractical to test via telnet to a 386,
to say the least... So I just test the numbers... Make of it
whatever you want :)

Zlatko's patch seem to make not a great deal of a difference in this
simple test... But I don't know whether that was his intention
either :)

I'd be happy to test more kernel variations :)... since this 386 does a
fair bit of swapping when accessed by FTP... :)

--
Erik I. Bolso <knan at mo.himolde.no>
The White Tower: http://www.mo.himolde.no/~knan/


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
