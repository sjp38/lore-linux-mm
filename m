Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id DC4FB16B8F
	for <linux-mm@kvack.org>; Fri, 18 May 2001 17:12:01 -0300 (EST)
Date: Fri, 18 May 2001 17:12:01 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Linux 2.4.4-ac10
In-Reply-To: <20010518205843.T806@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.LNX.4.33.0105181710540.5251-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Mike Galbraith <mikeg@wen-online.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 May 2001, Ingo Oeser wrote:
> On Fri, May 18, 2001 at 03:23:03PM -0300, Rik van Riel wrote:

> > "such a tradeoff" ?
> >
> > While this sounds reasonable, I have to point out that
> > up to now nobody has described exactly WHAT tradeoff
> > they'd like to make tunable and why...
>
> Amount of pages reclaimed from swapout_mm() versus amount of
> pages reclaimed from caches.
>
> A value that says: "use XX% of my main memory for RSS of
> processes, even if I run heavy disk loadf now" would be nice.
>
> For general purpose machines, where I run several services but
> also play games, this would allow both to survive.
>
> The external services would go slower. Who cares, if some CVS
> updates or NFS services go slower, if I can play my favorite game
> at full speed? ;-)

Remember that the executable and data of that game reside
in the filesystem cache. This "double counting" makes it
quite a bit harder to actually implement what seems like
a simple tradeoff.

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
