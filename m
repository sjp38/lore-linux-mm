Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 7730716B4E
	for <linux-mm@kvack.org>; Wed, 16 May 2001 14:41:35 -0300 (EST)
Date: Wed, 16 May 2001 14:41:35 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: RE: on load control / process swapping
In-Reply-To: <200105161714.f4GHEFs72217@earth.backplane.com>
Message-ID: <Pine.LNX.4.33.0105161439140.18102-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Dillon <dillon@earth.backplane.com>
Cc: Charles Randall <crandall@matchlogic.com>, Roger Larsson <roger.larsson@norran.net>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

On Wed, 16 May 2001, Matt Dillon wrote:

>     In regards to the particular case of scanning a huge multi-gigabyte
>     file, FreeBSD has a sequential detection heuristic which does a
>     pretty good job preventing cache blow-aways by depressing the priority
>     of the data as it is read or written.  FreeBSD will still try to cache
>     a good chunk, but it won't sacrifice all available memory.  If you
>     access the data via the VM system, through mmap, you get even more
>     control through the madvise() syscall.

There's one thing "wrong" with the drop-behind idea though;
it penalises data even when it's still in core and we're
reading it for the second or third time.

Maybe it would be better to only do drop-behind when we're
actually allocating new memory for the vnode in question and
let re-use of already present memory go "unpunished" ?

Hmmm, now that I think about this more, it _could_ introduce
some different fairness issues. Darn ;)

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
