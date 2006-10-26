Date: Thu, 26 Oct 2006 08:55:29 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 2/3] hugetlb: fix prio_tree unit
In-Reply-To: <20061026034739.GA6046@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0610260848280.6104@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0610250828020.8576@blonde.wat.veritas.com>
 <000001c6f890$373fb960$12d0180a@amr.corp.intel.com>
 <20061026034739.GA6046@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Andrew Morton <akpm@osdl.org>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Oct 2006, David Gibson wrote:
> On Wed, Oct 25, 2006 at 04:49:29PM -0700, Chen, Kenneth W wrote:
> > 
> > Hugh, if you haven't got time to reconstruct the bug sequence, don't
> > bother. I'll give my test cases to David.

Thanks a lot, Ken.

> 
> Actually, Hugh already sent me a testcase by direct mail.  But more
> testcases are already good.
> 
> I don't really understand your case1.c, though.  It didn't cause any
> oops on my laptop (i386) and I couldn't see what else was expected to
> behave differently between the "pass" and "fail" cases.  It returns an
> uninitialized variable as exit code, btw..

I found it all very confusing, and I'm relieved to hear that Ken
did too!  Much easier to fix than to work out testcases and make
sense of the resulting misbehaviour.  I wasn't even aware that it
could happen without going beyond 4GB.

> 
> So, I've integrated both Hugh's testcase and case2.c into the
> libhugetlbfs testsuite.  A patch to libhugetlbfs is below.  It would
> be good if we could get Signed-off-by lines for it from Hugh and
> Kenneth, to keep the lawyer types happy, then Adam should be able to
> merge it into libhugetlbfs.  It applies on top of my earlier patch
> adding testcases for the i_size related reserve count wraparound.

Yes, you're welcome to my
Signed-off-by: Hugh Dickins <hugh@veritas.com>

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
