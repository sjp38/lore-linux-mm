Message-ID: <391AE1A7.8C2783A0@sgi.com>
Date: Thu, 11 May 2000 09:36:55 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Recent VM fiasco - fixed (pre7-9)
References: <Pine.LNX.4.10.10005101720050.1580-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dbench runs well on pre7-9. As far as I can tell,
there were NO failures in 15 hours of running,
the longest I've ever run this test. The performance has been
pretty good. Swapping was initially very low, although
it didn't affect performance. Later, guessing that
more periodic system processes started to run, swap
level increased, but stayed to "usual" levels observed
before ... the swap build-up was gradual likely indicating
that the right things were swapped out only when necessary.

regards,

ananth.

--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
