From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH 2/3] hugetlb: fix prio_tree unit
Date: Wed, 25 Oct 2006 23:15:23 -0700
Message-ID: <000001c6f8c6$1f94b410$918c030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20061026034739.GA6046@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: 'Hugh Dickins' <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Gibson wrote on Wednesday, October 25, 2006 8:48 PM
> On Wed, Oct 25, 2006 at 04:49:29PM -0700, Chen, Kenneth W wrote:
> > It's fairly easy to reproduce.  I got a test cases that easily trigger
> > kernel oops and even got a sequence to screw up hugepage_rsvd count.
> > All I have to do is to place vm_start high enough and combined with large
> > enough v_offset, the add "vma->vm_start + v_offset" will overflow. It
> > doesn't even need to be over 4GB.
> > 
> > Hugh, if you haven't got time to reconstruct the bug sequence, don't
> > bother. I'll give my test cases to David.
> 
> I don't really understand your case1.c, though.  It didn't cause any
> oops on my laptop (i386) and I couldn't see what else was expected to
> behave differently between the "pass" and "fail" cases.  It returns an
> uninitialized variable as exit code, btw..

Yeah, case1 looked bogus by itself.  I must have some other combination
which I now unfortunately unable to recall.  This was the one that mess
up with hugepages_rsvd count. I won't pursue this any further given that
there are two other working test cases.


> So, I've integrated both Hugh's testcase and case2.c into the
> libhugetlbfs testsuite.  A patch to libhugetlbfs is below.  It would
> be good if we could get Signed-off-by lines for it from Hugh and
> Kenneth, to keep the lawyer types happy, then Adam should be able to
> merge it into libhugetlbfs.

map_high_truncate_2.c looks fine.
Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
