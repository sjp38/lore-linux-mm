Date: Sun, 6 Nov 2005 10:18:32 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-Id: <20051106101832.510b0245.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0511060746170.3316@g5.osdl.org>
References: <20051104010021.4180A184531@thermo.lanl.gov>
	<Pine.LNX.4.64.0511032105110.27915@g5.osdl.org>
	<20051103221037.33ae0f53.pj@sgi.com>
	<20051104063820.GA19505@elte.hu>
	<Pine.LNX.4.64.0511040725090.27915@g5.osdl.org>
	<20051104155317.GA7281@elte.hu>
	<20051105233408.3037a6fe.pj@sgi.com>
	<Pine.LNX.4.64.0511060746170.3316@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: mingo@elte.hu, andy@thermo.lanl.gov, mbligh@mbligh.org, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Linus wrote:
> The thing is, if 99.8% of memory is cleanable, the 0.2% is still enough to 
> make pretty much _every_ hugepage in the system pinned down.

Agreed.

I realized after writing this that I wasn't clear on something.

I wasn't focused the subject of this thread, adding hugetlb pages after
the system has been up a while.

I was focusing on a related subject - freeing up most of the ordinary
size pages on the dedicated application nodes between jobs on a large
system using
 * a bootcpuset (for the classic Unix load) and
 * dedicated nodes (for the HPC apps).

I am looking to provide the combination of:
 1) specifying some hugetlb pages at system boot, plus
 2) the ability to clean off most of the ordinary sized pages
    from the application nodes between jobs.

Perhaps Andy or some of my HPC customers wish I was also looking
to provide:
 3) the ability to add lots of hugetlb pages on the application
    nodes after the system has run a while.
But if they are, then they have some more educatin' to do on me.

For now, I am sympathetic to your concerns with code and locking
complexity.  Freeing up great globs of hugetlb sized contiguous chunks
of memory after a system has run a while would be hard.

We have to be careful which hard problems we decide to take on.

We can't take on too many, and we have to pick ones that will provide
a major long term advantage to Linux, over the forseeable changes in
system hardware and architecture.

Even if most of the processors that Andy has tested against would
benefit from dynamically added hugetlb pages, if we can anticipate
that this will not be a substained opportunity for Linux (and looking
at current x86 chips doesn't require much anticipating) then that
might not be the place to invest our precious core complexity dollars.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
