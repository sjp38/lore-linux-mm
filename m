Date: Tue, 31 Oct 2000 14:06:08 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [RFC] Structure in Compressed Cache
In-Reply-To: <20001030190922.A5183@linux.ime.usp.br>
Message-ID: <Pine.LNX.4.21.0010311404210.1475-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, kernel@tutu.ime.usp.br
List-ID: <linux-mm.kvack.org>


On Mon, 30 Oct 2000, Rodrigo S. de Castro wrote:

> Hello,
> 
> 	In my implementation of compressed cache (kernel 2.2.16), I
> started the project having my cache as a slab cache, structure
> provided by kernel. I have all step 1 (a cache with no compression)
> done, but I had a problem with marking pages in my cache. After an
> email sent to the list about this subject, I started looking at shared
> memory mechanism (mainly ipc/shm.c), and I saw that there's another
> way of making it: with a page table allocation and memory mapping. I
> could go on with my initial idea (with slab cache) but I think that
> doing the latter way (with page table and memory mapping) would be
> more complete (and, of course, harder). I will have a pool of
> (compressed) pages that gotta be always in memory and will be
> "between" physical memory and swap. As the project is growing I would
> like to define now which path to follow, taking in account
> completeness and upgradeability (to future versions of kernel). Which
> way do you think that is better? Please, I also ask you to tell me in
> case you know if there's another way, maybe better, of doing it.

Slab cache memory is physically contiguous and non swappable, so it may be
a waste to use it to cache userspace data. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
