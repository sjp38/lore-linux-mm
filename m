Date: Fri, 20 Dec 2002 03:13:36 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: shared pagetable benchmarking
Message-ID: <20021220111336.GH25000@holomorphy.com>
References: <3E02FACD.5B300794@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3E02FACD.5B300794@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Dave McCracken <dmccr@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 20, 2002 at 03:11:09AM -0800, Andrew Morton wrote:
> Did a bit of timing and profiling.  It's a uniprocessor
> kernel, 7G, PAE.
> The workload is application and removal of ~80 patches using
> my patch scripts.  Tons and tons of forks from bash.
> 2.5 ends up being 13% slower than 2.4, after disabling highpte
> to make it fair.  3%-odd of this is HZ=1000.  So say 10%.
> Pagetable sharing actually slowed this test down by several
> percent overall.  Which is unfortunate, because the main
> thing which Linus likes about shared pagetables is that it
> "speeds up forks".
> Is there anything we can do to fix all of this up a bit?

For testing purposes, try removing the opportunistic mmap()-time
sharing.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
