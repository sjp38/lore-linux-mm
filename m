Date: Sun, 5 Sep 1999 09:58:56 +0200 (CEST)
From: Rik van Riel <riel@humbolt.geo.uu.nl>
Subject: bdflush defaults bugreport
Message-ID: <Pine.LNX.4.10.9909050953540.247-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

yesterday evening I've seen a 32MB machine failing to install because
mke2fs was killed due to memory shortage -- memory shortage due to
a too large number of dirty blocks (max 40% by default).

Lowering the number to 1% solved all problems, so I guess we should
lower the number in the kernel to something like 10%, which should
be _more_ than enough since the page cache can now be dirty too...

Btw, the problem happened on a 2.2.10 machine, so I guess we should
lower the 2.2 default as well (to 15%? 20%?).

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.
--
work at:	http://www.reseau.nl/
home at:	http://www.nl.linux.org/~riel/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
