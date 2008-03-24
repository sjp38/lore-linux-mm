Date: Mon, 24 Mar 2008 14:43:56 -0700 (PDT)
Message-Id: <20080324.144356.104645106.davem@davemloft.net>
Subject: Re: larger default page sizes...
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0803241402060.7762@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
	<20080324.133722.38645342.davem@davemloft.net>
	<Pine.LNX.4.64.0803241402060.7762@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 24 Mar 2008 14:05:02 -0700 (PDT)
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> On Mon, 24 Mar 2008, David Miller wrote:
> 
> > From: Christoph Lameter <clameter@sgi.com>
> > Date: Mon, 24 Mar 2008 11:27:06 -0700 (PDT)
> > 
> > > The move to 64k page size on IA64 is another way that this issue can
> > > be addressed though.
> > 
> > This is such a huge mistake I wish platforms such as powerpc and IA64
> > would not make such decisions so lightly.
> 
> Its certainly not a light decision if your customer tells you that the box 
> is almost unusable with 16k page size. For our new 2k and 4k processor 
> systems this seems to be a requirement. Customers start hacking SLES10 to 
> run with 64k pages....

We should fix the underlying problems.

I'm hitting issues on 128 cpu Niagara2 boxes, and it's all fundamental
stuff like contention on the per-zone page allocator locks.

Which is very fixable, without going to larger pages.

> powerpc also runs HPC codes. They certainly see the same results
> that we see.

There are ways to get large pages into the process address space for
compute bound tasks, without suffering the well known negative side
effects of using larger pages for everything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
