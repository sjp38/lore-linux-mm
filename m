Date: Mon, 25 Sep 2000 19:42:09 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
In-Reply-To: <20000926004429.D5010@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251937230.4997-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Sep 2000, Andrea Arcangeli wrote:
> On Mon, Sep 25, 2000 at 08:54:57PM +0100, Stephen C. Tweedie wrote:

> > basically the whole of memory is data cache, some of which is mapped
> > and some of which is not?
> 
> As as said in the last email aging on the cache is supposed to that.
> 
> Wasting CPU and incrasing the complexity of the algorithm is a price
> that I won't pay just to get the information on when it's time
> to recall swap_out().

You must be joking. Page replacement should be tuned to
do good page replacement, not just to be easy on the CPU.
(though a heavily thrashing system /is/ easy on the cpu,
I'll have to admit that)

> If the cache have no age it means I'd better throw it out instead
> of swapping/unmapping out stuff, simple?

Simple, yes. But completely BOGUS if you don't age the cache
and the mapped pages at the same rate!

If I age your pages twice as much as my pages, is it still
only fair that your pages will be swapped out first? ;)

> > anything since last time.  Anything that only ages per-pte, not
> > per-page, is simply going to die horribly under such load, and any
> 
> The aging on the fs cache is done per-page.

And the same should be done for other pages as well.
If you don't do that, you'll have big problems keeping
page replacement balanced and making the system work well
under various loads.

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
