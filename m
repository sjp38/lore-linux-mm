Received: from srv11-sao.sao.terra.com.br (srv11-sao.sao.terra.com.br [200.246.248.66])
	by emergencia.sao.terra.com.br (8.9.3/8.9.3) with ESMTP id TAA27509
	for <linux-mm@kvack.org>; Wed, 1 Nov 2000 19:25:13 -0200
Received: from einstein (root@dl-tnt6-C8B08B8C.sao.terra.com.br [200.176.139.140])
	by srv11-sao.sao.terra.com.br (8.9.3/8.9.3) with ESMTP id TAA19026
	for <linux-mm@kvack.org>; Wed, 1 Nov 2000 19:25:10 -0200
Date: Wed, 1 Nov 2000 18:51:50 -0200
From: "Rodrigo S. de Castro" <rodsc@bigfoot.com>
Subject: Re: [RFC] Structure in Compressed Cache
Message-ID: <20001101185150.A967@einstein>
References: <20001030190922.A5183@linux.ime.usp.br> <Pine.LNX.4.21.0010311404210.1475-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
In-Reply-To: <Pine.LNX.4.21.0010311404210.1475-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Tue, Oct 31, 2000 at 02:06:08PM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org, kernel@tutu.ime.usp.br
List-ID: <linux-mm.kvack.org>

On Tue, Oct 31, 2000 at 02:06:08PM -0200, Marcelo Tosatti wrote:
> On Mon, 30 Oct 2000, Rodrigo S. de Castro wrote:
> > 	In my implementation of compressed cache (kernel 2.2.16), I
> > started the project having my cache as a slab cache, structure
> > provided by kernel. I have all step 1 (a cache with no compression)
> > done, but I had a problem with marking pages in my cache. After an
> > email sent to the list about this subject, I started looking at shared
> > memory mechanism (mainly ipc/shm.c), and I saw that there's another
> > way of making it: with a page table allocation and memory mapping. I
> > could go on with my initial idea (with slab cache) but I think that
> > doing the latter way (with page table and memory mapping) would be
> > more complete (and, of course, harder). I will have a pool of
> > (compressed) pages that gotta be always in memory and will be
> > "between" physical memory and swap. As the project is growing I would
> > like to define now which path to follow, taking in account
> > completeness and upgradeability (to future versions of kernel). Which
> > way do you think that is better? Please, I also ask you to tell me in
> > case you know if there's another way, maybe better, of doing it.
> 
> Slab cache memory is physically contiguous and non swappable, so it may be
> a waste to use it to cache userspace data. 

	Today I reread Bonwick's paper (The Slab Allocator: An
Object-Caching Kernel Memory Allocator) and I saw that a slab of
objects 'consists of one or more pages of virtually contiguous memory'
and the whole cache (that has many slabs) doesn't, necessarily. I am
storing on a slab cache only a small structure that holds some
information about and a pointer to a physical page that is allocated
in its constructor. In that way, a slab will certainly have a size of
a page (since its structure is smaller than 1/8 of page), and thus
there's no problem for us at all, because there won't have actually
any continguous data. I hope you could get it. I am wondering if I
missing something, because I can't see a problem that this approach
would waste. :-) I did tried to understand some code of slab.c and
even then I couldn't see contiguous memory problem in our whole
cache. Well, I ask anyone who knows something about slab cache to join
this discussion. :-)

[]'s
-- 
Rodrigo S. de Castro   <rcastro@linux.ime.usp.br>
University of Sao Paulo - Brazil
Compressed Caching - http://tutu.ime.usp.br



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
