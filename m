Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id EB7B36B0124
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 12:50:41 -0400 (EDT)
Date: Thu, 4 Oct 2012 18:50:08 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Message-ID: <20121004165008.GF25675@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

Subject: Re: [PATCH 29/33] autonuma: page_autonuma
Reply-To: 
In-Reply-To: <0000013a2c223da2-632aa43e-21f8-4abd-a0ba-2e1b49881e3a-000000@email.amazonses.com>

Hi Christoph,

On Thu, Oct 04, 2012 at 02:16:14PM +0000, Christoph Lameter wrote:
> On Thu, 4 Oct 2012, Andrea Arcangeli wrote:
> 
> > Move the autonuma_last_nid from the "struct page" to a separate
> > page_autonuma data structure allocated in the memsection (with
> > sparsemem) or in the pgdat (with flatmem).
> 
> Note that there is a available word in struct page before the autonuma
> patches on x86_64 with CONFIG_HAVE_ALIGNED_STRUCT_PAGE.
> 
> In fact the page_autonuma fills up the structure to nicely fit in one 64
> byte cacheline.

Good point indeed.

So we could drop page_autonuma by creating a CONFIG_SLUB=y dependency
(AUTONUMA wouldn't be available in the kernel config if SLAB=y, and it
also wouldn't be available on 32bit archs but the latter isn't a
problem).

I think it's a reasonable alternative to page_autonuma. Certainly it
looks more appealing than taking over 16 precious bits from
page->flags. There are still pros and cons. I'm neutral on it so more
comments would be welcome ;).

Andrea

PS. randomly moved some in Cc over to Bcc as I overflowed the max
header allowed on linux-kernel oops!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
