Date: Mon, 25 Sep 2000 13:28:42 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: the new VMt
In-Reply-To: <Pine.LNX.4.21.0009251817420.9122-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0009251328200.14614-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andi Kleen <ak@suse.de>, Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Ingo Molnar wrote:
> On Mon, 25 Sep 2000, Andi Kleen wrote:
> 
> > Another thing I would worry about are ports with multiple user page
> > sizes in 2.5. Another ugly case is the x86-64 port which has 4K pages
> > but may likely need a 16K kernel stack due to the 64bit stack bloat.
> 
> yep, but these cases are not affected, i think in the order != 0
> case we should return NULL if a certain number of iterations did
> not yield any free page.

Indeed. You're right here.

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
