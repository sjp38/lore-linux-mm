Date: Thu, 3 Jul 2003 09:06:32 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: What to expect with the 2.6 VM
In-Reply-To: <20030703125839.GZ23578@dualathlon.random>
Message-ID: <Pine.LNX.4.44.0307030904260.16582-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: William Lee Irwin III <wli@holomorphy.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jul 2003, Andrea Arcangeli wrote:

> even if you don't use largepages as you should, the ram cost of the pte
> is nothing on 64bit archs, all you care about is to use all the mhz and
> tlb entries of the cpu.

That depends on the number of Oracle processes you have.
Say that page tables need 0.1% of the space of the virtual
space they map.  With 1000 Oracle users you'd end up needing
as much memory in page tables as your shm segment is large.

Of course, in this situation either the application should
use large pages or the kernel should simply reclaim the
page tables (possible while holding the mmap_sem for write).

> remap_file_pages is useful only for VLM in 32bit

Agreed on that.  Please let the monstrosity die together
with 32 bit machines ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
