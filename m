Date: Tue, 25 Apr 2000 12:25:05 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: pressuring dirty pages (2.3.99-pre6)
In-Reply-To: <20000425103552.A4627@redhat.com>
Message-ID: <Pine.LNX.4.21.0004251210080.10408-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Apr 2000, Stephen C. Tweedie wrote:
> On Mon, Apr 24, 2000 at 07:42:12PM -0300, Rik van Riel wrote:
> > 
> > That will not work. The problem isn't that kswapd eats cpu,
> > but the problem is that the dirty pages completely dominate
> > physical memory.
> 
> That isn't a "problem".  That's a state.  Of _course_ memory
> usage is going to be dominated by whichever sort of page is
> being predominantly used.
> 
> So we need to identify the real problem.  Is 2.3 much worse than
> 2.2 at this dirty-write-mmap test?  Are we seeing swap
> fragmentation reducing swap throughput?  Is the VM simply
> keeping insufficient memory available for tasks other than the
> highly paging one?

The highly paging task is pushing other tasks out of memory, even
though it doesn't do the task itself any good. In fact, some of
the typical memory hogs are found to run *faster* when we age their
pages better...

The combination of the above "push harder" logic together with my
anti hog code may work the way we want .. I've just compiled it and
will be testing it for a while now.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
