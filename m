Date: Mon, 25 Sep 2000 19:26:56 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
In-Reply-To: <20000926002812.C5010@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251923070.4997-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Sep 2000, Andrea Arcangeli wrote:
> On Mon, Sep 25, 2000 at 04:26:17PM -0300, Rik van Riel wrote:
> > > > It doesn't --- that is part of the design.  The vm scanner propagates
> > > 
> > > And that's the inferior part of the design IMHO.
> > 
> > Indeed, but physical page based aging is a definate
> > 2.5 thing ... ;(
> 
> I'm talking about the fact that if you have a file mmapped in
> 1.5G of RAM test9 will waste time rolling between LRUs 384000
> pages, while classzone won't ever see 1 of those pages until you
> run low on fs cache.

IMHO this is a minor issue because:
1) you need to do page replacement with shared pages
   right
2) you don't /want/ to run low on fs cache, you want
   to have a good balance between thee cache(s) and
   the processes

OTOH, if you have a way to keep fair page aging and
fix the CPU time issue at the same time, I'd love
to see it.

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
