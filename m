Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 1F5B716C5B
	for <linux-mm@kvack.org>; Sat, 12 May 2001 18:17:17 -0300 (EST)
Date: Sat, 12 May 2001 18:17:15 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: on load control / process swapping
In-Reply-To: <200105121721.f4CHLSS18553@earth.backplane.com>
Message-ID: <Pine.LNX.4.33.0105121816190.18102-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Dillon <dillon@earth.backplane.com>
Cc: arch@freebsd.org, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

On Sat, 12 May 2001, Matt Dillon wrote:

> :Ahhh, so FreeBSD _does_ have a maxscan equivalent, just one that
> :only kicks in when the system is under very heavy memory pressure.
> :
> :That explains why FreeBSD's thrashing detection code works... ;)
>
>     Note that there is a big distinction between limiting the page
>     queue scan rate (which we do not do), and sleeping between full
>     scans (which we do).  Limiting the page queue scan rate on a
>     page-by-page basis does not scale.  Sleeping in between full queue
>     scans (in an extreme case) does scale.

I'm not convinced it's doing a very useful thing, though ;)

(see the rest of the email you replied to)

Rik
--
Linux MM bugzilla: http://linux-mm.org/bugzilla.shtml

Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
