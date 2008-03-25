Date: Tue, 25 Mar 2008 10:48:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: larger default page sizes...
In-Reply-To: <20080324.144356.104645106.davem@davemloft.net>
Message-ID: <Pine.LNX.4.64.0803251045510.16206@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
 <20080324.133722.38645342.davem@davemloft.net>
 <Pine.LNX.4.64.0803241402060.7762@schroedinger.engr.sgi.com>
 <20080324.144356.104645106.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Mar 2008, David Miller wrote:

> We should fix the underlying problems.
> 
> I'm hitting issues on 128 cpu Niagara2 boxes, and it's all fundamental
> stuff like contention on the per-zone page allocator locks.
> 
> Which is very fixable, without going to larger pages.

No its not fixable. You are doing linear optimizations to a slowdown that 
grows exponentially. Going just one order up for page size reduces the
necessary locks and handling of the kernel by 50%.
 
> > powerpc also runs HPC codes. They certainly see the same results
> > that we see.
> 
> There are ways to get large pages into the process address space for
> compute bound tasks, without suffering the well known negative side
> effects of using larger pages for everything.

These hacks have limitations. F.e. they do not deal with I/O and 
require application changes.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
