Date: Thu, 28 Sep 2000 16:52:16 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000928165216.J17518@athlon.random>
References: <Pine.LNX.4.21.0009280702460.1814-100000@duckman.distro.conectiva> <Pine.LNX.4.21.0009280742280.1814-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009280742280.1814-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Thu, Sep 28, 2000 at 08:16:32AM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Christoph Rohland <cr@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 28, 2000 at 08:16:32AM -0300, Rik van Riel wrote:
> Andrea, I have the strong impression that your idea of
> memory balancing is based on the idea that the OS should
> out-smart the application instead of looking at the usage
> pattern of the pages in memory.

Not sure what you mean with out-smart.

My only point is that the OS actually can only swapout such shm. If that
SHM is not supposed to be swapped out and if the OS I/O cache have more aging
then the shm cache, then the OS should tell the DBMS that it's time to shrink
some shm page by freeing it.

> of the pages in question, instead of making presumptions
> based on what kind of cache the page is in.

For the mapped pages we never make presumptions. We always check the accessed
bit and that's the most reliable info to know if the page is been accessed
recently (set from the cpu accesse through the pte not only during page faults
or cache hits).  With the current design pages mapped multiple times will be
overaged a bit but this can't be fixed until we make a page->pte reverse
lookup...

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
