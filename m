Message-ID: <1142901862.441f4c66c748e@vds.kolivas.org>
Date: Tue, 21 Mar 2006 11:44:22 +1100
From: kernel@kolivas.org
Subject: Re: [PATCH][3/3] mm: swsusp post resume aggressive swap prefetch
References: <200603200234.01472.kernel@kolivas.org> <200603202247.38576.rjw@sisk.pl> <1142889937.441f1dd19e90f@vds.kolivas.org> <200603210022.32985.rjw@sisk.pl>
In-Reply-To: <200603210022.32985.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux list <linux-kernel@vger.kernel.org>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@osdl.org>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Quoting "Rafael J. Wysocki" <rjw@sisk.pl>:
> Sorry, I was wrong.  After resume the image pages in the swap are visible as
> free, because we allocate them after we have created the image (ie. the
> image
> contains the system state in which these pages are free).
> 
> Well, this means I really don't know what happens and what causes the
> slowdown.  It certainly is related to the aggressive prefetch hook in
> swsusp_suspend().  [It seems to search the whole swap, but it doesn't
> actually prefetch anything.  Strange.]

Are you looking at swap still in use? Swap prefetch keeps a copy of prefetched
pages on backing store as well as in ram so the swap space will not be freed on
prefetching. 

> > If so, is there a way to differentiate the two so we only aggressively
> > prefetch on kernel resume - is that what you meant by doing it in the
> > other file? 
> 
> Basically, yes.  swsusp.c and snapshot.c contain common functions,
> disk.c and swap.c contain the code used by the built-in swsusp only,
> and user.c contains the userland interface.  If you want something to
> be run by the built-in swsusp only, place it in disk.c.
> 
> Still in this particular case it won't matter, I'm afraid.

I don't understand what you mean by it won't matter?

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
