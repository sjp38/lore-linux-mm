Date: Mon, 19 Jun 2000 18:07:34 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: shrink_mmap() change in ac-21
In-Reply-To: <87r99t8m2r.fsf@atlas.iskon.hr>
Message-ID: <Pine.LNX.4.21.0006191806130.1290-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: alan@redhat.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, "Juan J. Quintela" <quintela@fi.udc.es>
List-ID: <linux-mm.kvack.org>

On 19 Jun 2000, Zlatko Calusic wrote:

> The shrink_mmap() change in your latest prepatch (ac12) doesn't look
> very healthy. Removing the test for the wrong zone we effectively
> discard lots of wrong pages before we get to the right one. That is
> effectively flushing the page cache and we have unbalanced system.
> 
> For example, check the "vmstat 1" output below, done while I was
> reading a big file from the disk. At some point in time, the page
> cache shrunk to almost half of its size (75MB -> 42MB).
> 
> The reason is balancing of the DMA zone (which is much smaller on a
> 128MB machine than the NORMAL zone!). shrink_mmap() now happily evicts
> wrong pages from the memory and continues doing so until it finally
> frees enough pages from the DMA zone. That, of course, hurts caching
> as the page cache gets shrunk a lot without a good reason.

I already suspected this could happen.

/me looks at quintela

Juan, didn't you and Roger have a patch to solve this? ;)
(I think quintela and roger already have a patch so I'll save
writing one myself)

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
