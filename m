Date: Mon, 2 Oct 2000 12:49:54 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] fix for VM  test9-pre7
In-Reply-To: <20001002120559.13349.qmail@theseus.mathematik.uni-ulm.de>
Message-ID: <Pine.LNX.4.21.0010021249030.22539-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ehrhardt@mathematik.uni-ulm.de
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000 ehrhardt@mathematik.uni-ulm.de wrote:
> On Mon, Oct 02, 2000 at 12:42:47AM -0300, Rik van Riel wrote:
> > --- linux-2.4.0-test9-pre7/fs/buffer.c.orig	Sat Sep 30 18:09:18 2000
> > +++ linux-2.4.0-test9-pre7/fs/buffer.c	Mon Oct  2 00:19:41 2000
> > @@ -706,7 +706,9 @@
> >  static void refill_freelist(int size)
> >  {
> >  	if (!grow_buffers(size)) {
> > -		try_to_free_pages(GFP_BUFFER);
> > +		wakeup_bdflush(1);
> > +		current->policy |= SCHED_YIELD;
> > +		schedule();
> >  	}
> >  }
> 
> This part looks strange! wakeup_bdflush will sleep if the
> parameter is not zero, i.e. we'll schedule twice. I doubt that
> this the intended behaviour?

Heh...

I copied back the old code because I saw some failures in
the try_to_free_pages() in this situation.

Maybe the person who wrote this code originally can comment
on this one ?

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
