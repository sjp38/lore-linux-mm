Date: Wed, 9 Apr 2008 08:17:09 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 0 of 9] mmu notifier #v12
Message-ID: <20080409131709.GR11364@sgi.com>
References: <patchbomb.1207669443@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <patchbomb.1207669443@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

I applied this patch set with the xpmem version I am working up for
submission and the basic level-1 and level-2 tests passed.  The full mpi
regression test still tends to hang, but that appears to be a common
problem failure affecting either emm or mmu notifiers and therefore, I
am certain is a problem in my code.

Please note this is not an endorsement of one method over the other,
merely that under conditions where we would expect xpmem to pass the
regression tests, it does pass those tests.

Thanks,
Robin

On Tue, Apr 08, 2008 at 05:44:03PM +0200, Andrea Arcangeli wrote:
> The difference with #v11 is a different implementation of mm_lock that
> guarantees handling signals in O(N). It's also more lowlatency friendly. 
> 
> Note that mmu_notifier_unregister may also fail with -EINTR if there are
> signal pending or the system runs out of vmalloc space or physical memory,
> only exit_mmap guarantees that any kernel module can be unloaded in presence
> of an oom condition.
> 
> Either #v11 or the first three #v12 1,2,3 patches are suitable for inclusion
> in -mm, pick what you prefer looking at the mmu_notifier_register retval and
> mm_lock retval difference, I implemented and slighty tested both. GRU and KVM
> only needs 1,2,3, XPMEM needs the rest of the patchset too (4, ...) but all
> patches from 4 to the end can be deffered to a second merge window.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
