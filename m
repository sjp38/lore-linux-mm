Received: from CONVERSION-DAEMON.jhuml3.jhu.edu by jhuml3.jhu.edu
 (PMDF V6.0-24 #47345) id <0G2L0030128SJB@jhuml3.jhu.edu> for
 linux-mm@kvack.org; Tue, 17 Oct 2000 12:38:52 -0400 (EDT)
Date: Tue, 17 Oct 2000 12:37:17 -0400 (EDT)
From: afei@jhu.edu
Subject: Re: VM magic numbers
In-reply-to: 
        <Pine.BSF.4.10.10010170807140.18983-100000@myrile.madriver.k12.oh.us>
Message-id: <Pine.GSO.4.05.10010171236440.6140-100000@aa.eps.jhu.edu>
MIME-version: 1.0
Content-type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Lowe <elowe@myrile.madriver.k12.oh.us>
Cc: Roger Larsson <roger.larsson@norran.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

ln 323 page_alloc.c: inactive_target / 3, was /2
in earlier rounds..  I think we're trying not to launder
too many pages at once here?

This change is because of performance tuning as I remember.

Fei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
