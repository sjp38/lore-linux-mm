Date: Mon, 8 Jan 2001 09:50:32 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Subtle MM bug
In-Reply-To: <Pine.LNX.4.21.0101081443360.21675-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10101080949430.3750-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "David S. Miller" <davem@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 8 Jan 2001, Rik van Riel wrote:

> On Sun, 7 Jan 2001, Linus Torvalds wrote:
> 
> > 	/*
> > 	 * Too many active pages? That implies that we don't have enough
> > 	 * of a working set for page_launder() to do a good job. Start by
> > 	 * walking the VM space..
> > 	 */
> > 	if ((nr_active_pages >> 1) > total_pages)
> > 		swap_out();
> > 
> > 	/*
> > 	 * This is where we actually free memory
> > 	 */
> > 	page_launder(..);
> 
> Ahhh, but this is NOT the balancing problem we're trying to
> pin down in 2.4...
> 
> The (possible) problem is in the balancing between swap_out()
> and refill_inactive_scan().

That _is_ the problem the above will fix. Don't read "page_launder()"
there: it's more meant to be "this is the old code that does
page_launder() etc.."

Trust me. Try my code. It will work.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
