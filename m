Date: Wed, 16 May 2001 10:14:15 -0700 (PDT)
From: Matt Dillon <dillon@earth.backplane.com>
Message-Id: <200105161714.f4GHEFs72217@earth.backplane.com>
Subject: Re: RE: on load control / process swapping
References: <5FE9B713CCCDD311A03400508B8B30130828EDA8@bdr-xcln.corp.matchlogic.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Charles Randall <crandall@matchlogic.com>
Cc: Roger Larsson <roger.larsson@norran.net>, Rik van Riel <riel@conectiva.com.br>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

    We've talked about implementing O_DIRECT.  I think it's a good idea.

    In regards to the particular case of scanning a huge multi-gigabyte
    file, FreeBSD has a sequential detection heuristic which does a
    pretty good job preventing cache blow-aways by depressing the priority
    of the data as it is read or written.  FreeBSD will still try to cache
    a good chunk, but it won't sacrifice all available memory.  If you
    access the data via the VM system, through mmap, you get even more 
    control through the madvise() syscall.

						-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
