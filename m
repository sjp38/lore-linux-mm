Date: Thu, 28 Sep 2000 08:16:32 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
In-Reply-To: <Pine.LNX.4.21.0009280702460.1814-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0009280742280.1814-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Rohland <cr@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Sep 2000, Rik van Riel wrote:
> On Wed, 27 Sep 2000, Andrea Arcangeli wrote:

> > But again: if the shm contains I/O cache it should be released
> > and not swapped out.  Swapping out shmfs that contains I/O cache
> > would be exactly like swapping out page-cache.
> 
> The OS has no business knowing what's inside that SHM page.

Hmm, now I woke up maybe I should formulate this in a
different way.

Andrea, I have the strong impression that your idea of
memory balancing is based on the idea that the OS should
out-smart the application instead of looking at the usage
pattern of the pages in memory.

This is fundamentally different from the idea that the OS
should make decisions based on the observed usage patterns
of the pages in question, instead of making presumptions
based on what kind of cache the page is in.

I've been away for 10 days and have been sitting on a bus
all last night so my judgement may be off. I'd certainly
like to hear I'm wrong ;)

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
