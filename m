Date: Wed, 26 Apr 2000 14:13:13 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: 2.3.x mem balancing
In-Reply-To: <Pine.LNX.4.10.10004260929340.1492-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0004261410350.16202-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Apr 2000, Linus Torvalds wrote:
> On Wed, 26 Apr 2000, Stephen C. Tweedie wrote:
> > 
> > We just shouldn't need to keep much memory free.
> > 
> > I'd much rather see a scheme in which we have two separate goals for 
> > the VM.  Goal one would be to keep a certain number of free pages in 
> > each class, for use by atomic allocations.  Goal two would be to have
> > a minimum number of pages in each class either free or on a global LRU
> > list which contains only pages known to be clean and unmapped (and
> > hence available for instant freeing without IO).
> 
> This would work. However, there is a rather subtle issue with allocating
> contiguous chunks of memory - something that is frowned upon, but however
> hard we've triedthere has always been people that really need to do it.
> 
> And that subtle issue is that in order for the buddy system to work for
> contiguous areas, you cannot have "free" pages _outside_ the buddy system.

This is easy to fix. We can keep a fairly large amount (maybe 4
times more than pages_high?) amount of these "free" pages on the
queue. If we are low on contiguous pages, we can bypass the queue
for these pages or scan memory for pages on this queue (marked with
as special flag) and take them from the queue...

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
