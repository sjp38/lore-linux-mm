Date: Fri, 29 Sep 2000 11:39:18 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
In-Reply-To: <20000928165216.J17518@athlon.random>
Message-ID: <Pine.LNX.4.21.0009291138080.23266-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Rohland <cr@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Sep 2000, Andrea Arcangeli wrote:
> On Thu, Sep 28, 2000 at 08:16:32AM -0300, Rik van Riel wrote:
> > Andrea, I have the strong impression that your idea of
> > memory balancing is based on the idea that the OS should
> > out-smart the application instead of looking at the usage
> > pattern of the pages in memory.
> 
> Not sure what you mean with out-smart.
> 
> My only point is that the OS actually can only swapout such shm.
> If that SHM is not supposed to be swapped out and if the OS I/O
> cache have more aging then the shm cache, then the OS should
> tell the DBMS that it's time to shrink some shm page by freeing
> it.

OK, good to see that we agree on the fact that we
should age and swapout all pages equally agressively.

> > of the pages in question, instead of making presumptions
> > based on what kind of cache the page is in.
> 
> For the mapped pages we never make presumptions. We always check
> the accessed bit and that's the most reliable info to know if
> the page is been accessed recently (set from the cpu accesse
> through the pte not only during page faults or cache hits).  
> With the current design pages mapped multiple times will be
> overaged a bit but this can't be fixed until we make a page->pte
> reverse lookup...

Indeed.

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
