Date: Mon, 9 Oct 2000 17:15:53 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <20001009221104.J19583@athlon.random>
Message-ID: <Pine.LNX.4.21.0010091713520.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Andrea Arcangeli wrote:
> On Mon, Oct 09, 2000 at 10:06:02PM +0200, Ingo Molnar wrote:
> > i think the OOM algorithm should not kill processes that have
> > process that has child processes likely results in unexpected behavior of
> 
> You just know what I think about those heuristics. I think all
> we need is a per-task pagefault/allocation rate avoiding any
> other complication that tries to do the right thing but that it
> will end doing the wrong thing eventually, but obviously nobody
> agreeed with me and before I implement that myself it will still
> take some time.

Furthermore, keeping track of these allocations will mean that you
/ALWAYS/ rack up the overhead of keeping track of this, even though
most machines probably won't run out of memory ever, or no more
than twice a year or so ;)

> Even the total_vm information will be wrong for example if the
> task was a netscape iconized and completly swapped out that
> wasn't running since two days. Killing it is going to only delay
> the killing of the real offender that is generating a flood of
> page faults at high frequency.

However true this may be, I wonder if we really care /that/ much.

OOM is a very rare situation and as long as you don't do something
that's really a bad surprise to the user, everything should be ok.

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
