Received: from areilly.bpc-users.org ([139.134.4.57]) by
          mailin9.bigpond.com (Netscape Messaging Server 4.15) with SMTP
          id GDJ01E00.0V7 for <linux-mm@kvack.org>; Fri, 18 May 2001
          20:05:38 +1000
From: "Andrew Reilly" <areilly@bigpond.net.au>
Date: Fri, 18 May 2001 20:00:16 +1000
Subject: Re: on load control / process swapping
Message-ID: <20010518200016.A21017@gurney.reilly.home>
References: <Pine.LNX.4.33.0105161439140.18102-100000@duckman.distro.conectiva> <200105161754.f4GHsCd73025@earth.backplane.com> <3B04BA0D.8E0CAB90@mindspring.com> <200105180620.f4I6KNd05878@earth.backplane.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200105180620.f4I6KNd05878@earth.backplane.com>; from dillon@earth.backplane.com on Thu, May 17, 2001 at 11:20:23PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Dillon <dillon@earth.backplane.com>
Cc: Terry Lambert <tlambert2@mindspring.com>, Rik van Riel <riel@conectiva.com.br>, Charles Randall <crandall@matchlogic.com>, Roger Larsson <roger.larsson@norran.net>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

On Thu, May 17, 2001 at 11:20:23PM -0700, Matt Dillon wrote:
>Terry wrote:
> :The problem in this case is _truly_ that the program in
> :question is _really_ trying to optimize its performance
> :at the expense of other programs in the system.
> 
>     The linker is seeking randomly as a side effect of
>     the linking algorithm.  It is not doing it on purpose to try
>     to save memory.  Forcing the VM system to think it's 
>     sequential causes the VM system to perform read-aheads,
>     generally reducing the actual amount of physical seeking
>     that must occur by increasing the size of the chunks
>     read from disk.  Even if the linker's dataset is huge,
>     increasing the chunk size is beneficial because linkers
>     ultimately access the entire object file anyway.  Trying
>     to save a few seeks is far more important then reading
>     extra data and having to throw half of it away.

I know that this problem is real in the case of data base index
accesses---databases have data sets larger than RAM almost by
definition---and that the problem (of dealing with "randomly"
accessed memory mapped files) should be neatly solved in
general.

But is this issue of linking really the lynch pin?

Are there _any_ programs and library sets where the union of the
code sizes is larger than physical memory?

I haven't looked at the problem myself, but (on the surface)
it doesn't seem too likely.  There is a grand total of 90M of .a
files on my system (/usr/lib, /usr/X11/lib, and /usr/local/lib),
and I doubt that even a majority of them would be needed at
once.

-- 
Andrew
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
