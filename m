Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id C45E316B54
	for <linux-mm@kvack.org>; Wed, 16 May 2001 16:59:51 -0300 (EST)
Date: Wed, 16 May 2001 16:59:51 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: RE: on load control / process swapping
In-Reply-To: <200105161754.f4GHsCd73025@earth.backplane.com>
Message-ID: <Pine.LNX.4.33.0105161658530.5251-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Dillon <dillon@earth.backplane.com>
Cc: Charles Randall <crandall@matchlogic.com>, Roger Larsson <roger.larsson@norran.net>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

On Wed, 16 May 2001, Matt Dillon wrote:

> :There's one thing "wrong" with the drop-behind idea though;
> :it penalises data even when it's still in core and we're
> :reading it for the second or third time.
>
>     It's not dropping the data, it's dropping the priority.  And yes, it
>     does penalize the data somewhat.  On the otherhand if the data happens
>     to still be in the cache and you scan it a second time, the page priority
>     gets bumped up

But doesn't it get pushed _down_ again after the process has read
the data?  Or is this a part of the code outside of vm/* which I
haven't read yet?

regards,

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
