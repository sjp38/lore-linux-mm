Date: Mon, 8 Jan 2001 16:21:10 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Subtle MM bug
In-Reply-To: <Pine.LNX.4.10.10101080949430.3750-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0101081613530.21675-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "David S. Miller" <davem@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Jan 2001, Linus Torvalds wrote:
> On Mon, 8 Jan 2001, Rik van Riel wrote:
> > On Sun, 7 Jan 2001, Linus Torvalds wrote:
> > 
> > > 	/*
> > > 	 * Too many active pages? That implies that we don't have enough
> > > 	 * of a working set for page_launder() to do a good job. Start by
> > > 	 * walking the VM space..
> > > 	 */
> > > 	if ((nr_active_pages >> 1) > total_pages)
> > > 		swap_out();

> That _is_ the problem the above will fix. Don't read
> "page_launder()" there: it's more meant to be "this is the old
> code that does page_launder() etc.."
> 
> Trust me. Try my code. It will work.

Except for the small detail that pages inside the processes
are often not on the active list  ;)

But I agree with your idea that we really should make sure
we have enough pages available to choose from when swapping
stuff out.

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
