Date: Sat, 12 May 2001 10:21:28 -0700 (PDT)
From: Matt Dillon <dillon@earth.backplane.com>
Message-Id: <200105121721.f4CHLSS18553@earth.backplane.com>
Subject: Re: on load control / process swapping
References: <Pine.LNX.4.21.0105121109210.5468-100000@imladris.rielhome.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: arch@freebsd.org, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

:
:Ahhh, so FreeBSD _does_ have a maxscan equivalent, just one that
:only kicks in when the system is under very heavy memory pressure.
:
:That explains why FreeBSD's thrashing detection code works... ;)
:
:(I'm not convinced, though, that limiting the speed at which we
:scan the active list is a good thing. There are some arguments
:in favour of speed limiting, but it mostly seems to come down
:to a short-cut to thrashing detection...)

    Note that there is a big distinction between limiting the page
    queue scan rate (which we do not do), and sleeping between full
    scans (which we do).  Limiting the page queue scan rate on a
    page-by-page basis does not scale.  Sleeping in between full queue
    scans (in an extreme case) does scale.

						-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
