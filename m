Date: Fri, 10 Dec 2004 22:03:12 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: pfault V12 : correction to tasklist rss
Message-ID: <20041211060312.GV2714@holomorphy.com>
References: <Pine.LNX.4.58.0412101150490.9169@schroedinger.engr.sgi.com> <Pine.LNX.4.44.0412102054190.32422-100000@localhost.localdomain> <20041210133859.2443a856.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041210133859.2443a856.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, clameter@sgi.com, torvalds@osdl.org, benh@kernel.crashing.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote:
>>> We have no  real way of establishing the ownership of shared pages
>>> anyways. Its counted when allocated. But the page may live on afterwards
>>> in another process and then not be accounted for although its only user is
>>> the new process.

On Fri, Dec 10, 2004 at 01:38:59PM -0800, Andrew Morton wrote:
> We did lose some accounting accuracy when the pagetable walk and the big
> tasklist walks were removed.  Bill would probably have more details.  Given
> that the code as it stood was a complete showstopper, the tradeoff seemed
> reasonable.

There are several issues, not listed in order of importance here:
(1) Workload monitoring with high multiprogramming levels was infeasible.
(2) The long address space walks interfered with mmap() and page
	faults in the monitored processes, disturbing cluster membership
	and exceeding maximum response times in monitored workloads.
(3) There's a general long-running ongoing effort to take on various
	places tasklist_lock is abused one-by-one to incrementally
	resolve or otherwise mitigate the rwlock starvation issues.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
