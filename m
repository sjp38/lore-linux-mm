Date: Mon, 9 Oct 2000 18:05:57 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.10.10010091350030.1438-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0010091759400.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Linus Torvalds wrote:
> On Mon, 9 Oct 2000, Andi Kleen wrote:
> > 
> > netscape usually has child processes: the dns helper. 
> 
> Yeah.
> 
> One thing we _can_ (and probably should do) is to do a per-user
> memory pressure thing - we have easy access to the "struct
> user_struct" (every process has a direct pointer to it), and it
> should not be too bad to maintain a per-user "VM pressure"
> counter.
> 
> Then, instead of trying to use heuristics like "does this
> process have children" etc, you'd have things like "is this user
> a nasty user", which is a much more valid thing to do and can be
> used to find people who fork tons of processes that are
> mid-sized but use a lot of memory due to just being many..

Sure we could do all of this, but does OOM really happen that
often that we want to make the algorithm this complex ?

The current algorithm seems to work quite well and is already
at the limit of how complex I'd like to see it. Having a less
complex OOM killer turned out to not work very well, but having
a more complex one is - IMHO - probably overkill ...

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
