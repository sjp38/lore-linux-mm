Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA04809
	for <linux-mm@kvack.org>; Tue, 21 Apr 1998 17:28:24 -0400
Received: from dax.dcs.ed.ac.uk (linux@dialup-83.publab.ed.ac.uk [129.215.38.83])
	by haymarket.ed.ac.uk (8.8.7/8.8.7) with ESMTP id WAA19065
	for <linux-mm@kvack.org>; Tue, 21 Apr 1998 22:28:04 +0100 (BST)
Received: (from linux@localhost) by dax.dcs.ed.ac.uk (8.8.5/8.7.3) id WAA00842 for linux-mm@kvack.org; Tue, 21 Apr 1998 22:28:00 +0100
Date: Tue, 21 Apr 1998 22:28:00 +0100
Resent-Message-Id: <199804212128.WAA00842@dax.dcs.ed.ac.uk>
Message-Id: <199804212128.WAA00842@dax.dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Subject: Re: bigphysarea in 2.2
In-Reply-To: <wd8iuogfwz9.fsf@parate.irisa.fr>
References: <199804101746.KAA15720@halibut.imedia.com>
	<wd8iuogfwz9.fsf@parate.irisa.fr>
Resent-To: linux-mm@kvack.org
Sender: owner-linux-mm@kvack.org
To: David Mentre <David.Mentre@irisa.fr>
Cc: pmonta@imedia.com, steve@icarus.icarus.com, linux-kernel@vger.rutgers.edu, torvalds@transmeta.com, linux-mm@, @kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 11 Apr 1998 12:56:10 +0200, David Mentre <David.Mentre@irisa.fr> said:

> Peter Monta <pmonta@halibut.imedia.com> writes:
>> > Is it too late to ask that the bigphysarea patch be included in the
>> > 2.1-and-soon-to-be-2.2 kernel?
>> 
>> Seconded.  Thanks for offering to maintain it.

>  With the new kernel memory manager, and if the defragmenting code which
> is under development works, wouldn't it be more useful to use standard
> kernel memory allocation. Static allocation like in bigphysarea is more
> a work-around that a real solution.

>  Maybe we should ask the memory kernel hackers (Stephen, Ben, Rick,
> Werner?) to support big allocations. I personally need 512 Kbytes
> contiguous blocks for a direct-from/to-memory network card. A possible
> problem is that those blocks should 512 Kbytes aligned (Argh!! !*%&@
> hardware). 

Unfortunately, the current code simply doesn't grok areas larger than
128KB, and even if it did, it is unlikely that it could be made to
work well in that case --- the existance of just one non-pagable
allocation (slab, kmalloc, page table etc.) in any 512K block would
render that entire region unreclaimable by the swapper.  If you need
such large physically contiguous regions, then bigphysarea is still
a better option.

--Stephen
