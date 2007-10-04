Date: Thu, 4 Oct 2007 14:42:01 -0600
From: Valerie Henson <val@nmt.edu>
Subject: Re: [ANNOUNCE] ebizzy 0.2 released
Message-ID: <20071004204201.GB6090@rainbow>
References: <20070823010626.GC11402@rainbow> <20070930.172703.79041329.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070930.172703.79041329.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rrbranco@br.ibm.com, twichell@us.ibm.com, ycai@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Sun, Sep 30, 2007 at 05:27:03PM -0700, David Miller wrote:
> From: Valerie Henson <val@nmt.edu>
> Date: Wed, 22 Aug 2007 19:06:26 -0600
> 
> > ebizzy is designed to generate a workload resembling common web
> > application server workloads.
> 
> I downloaded this only to be basically disappointed.
> 
> Any program which claims to generate workloads "resembling common web
> application server workloads", and yet does zero network activity and
> absolutely nothing with sockets is so far disconnected from reality
> that I truly question how useful it really is even in the context it
> was designed for.
> 
> Please describe this program differently, "a threaded cpu eater", "a
> threaded memory scanner", "a threaded hash lookup", or something
> suitably matching what it really does.
> 
> I'm sure there are at least 10 or even more programs in LTP that one
> could run under "time" and get the same exact functionality.

You're right, that part of the description is misleading. (I've even
had people ask me if it's a file systems benchmark!)

Ebizzy is based on a real web application server and does do things
that are fairly common in such applications (multithreaded memory
allocation and memory access), but it ignores networking for two
reasons: the network stack was not the bottleneck for this workload,
the VM was, and really good network benchmarks already exist. :)
ebizzy is not useful to networking (or file systems) developer, but it
has been used to improve malloc() behavior in glibc and to test VMA
handling optimizations.

In general, I try to make the source of a benchmark clear because it's
so tempting to optimize for completely artificial benchmarks.  The
trick is to do this without misleading the reader (or breaking my NDA).

ebizzy
------

ebizzy is a workload that stresses memory allocation and the virtual
memory subsystem.  It was initially written to model the local
computation portion of a web application server running a large
internet commerce site.  ebizzy is highly threaded, has a large
in-memory working set with poor locality, and allocates and
deallocates memory frequently.  When running most efficiently, ebizzy
will max out the CPU.  When running inefficiently, it will be blocked
much of the time.

-VAL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
