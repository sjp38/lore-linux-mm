Message-ID: <41B8060A.4050402@yahoo.com.au>
Date: Thu, 09 Dec 2004 19:00:10 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: page fault scalability patch V12 [0/7]: Overview and performance
 tests
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain> <Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org> <Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org> <Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Changes from V11->V12 of this patch:
> - dump sloppy_rss in favor of list_rss (Linus' proposal)
> - keep up against current Linus tree (patch is based on 2.6.10-rc2-bk14)
> 

[snip]

> For more than 8 cpus the page fault rate increases by orders
> of magnitude. For more than 64 cpus the improvement in performace
> is 10 times better.

Those numbers are pretty impressive. I thought you'd said with earlier
patches that performance was about doubled from 8 to 512 CPUS. Did I
remember correctly? If so, where is the improvement coming from? The
per-thread RSS I guess?


On another note, these patches are basically only helpful to new
anonymous page faults. I guess this is the main thing you are concerned
about at the moment, but I wonder if you would see improvements with
my patch to remove the ptl from the other types of faults as well?

The downside of my patch - well the main downsides - compared to yours
are its intrusiveness, and the extra cost involved in copy_page_range
which yours appears not to require.

As I've said earlier though, I wouldn't mind your patches going in. At
least they should probably get into -mm soon, when Andrew has time (and
after the 4level patches are sorted out). That wouldn't stop my patch
(possibly) being merged some time after that if and when it was found
worthy...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
