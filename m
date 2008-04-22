Date: Wed, 23 Apr 2008 00:54:24 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 10 of 12] Convert mm_lock to use semaphores after
	i_mmap_lock and anon_vma_lock
Message-ID: <20080422225424.GT24536@duo.random>
References: <f8210c45f1c6f8b38d15.1208872286@duo.random> <Pine.LNX.4.64.0804221325490.3640@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804221325490.3640@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2008 at 01:26:13PM -0700, Christoph Lameter wrote:
> Doing the right patch ordering would have avoided this patch and allow 
> better review.

I didn't actually write this patch myself. This did it instead:

s/anon_vma_lock/anon_vma_sem/
s/i_mmap_lock/i_mmap_sem/
s/locks/sems/
s/spinlock_t/struct rw_semaphore/

so it didn't look a big deal to redo it indefinitely.

The right patch ordering isn't necessarily the one that reduces the
total number of lines in the patchsets. The mmu-notifier-core is
already converged and can go in. The rest isn't converged at
all... nearly nobody commented on the other part (the few comments so
far were negative), so there's no good reason to delay indefinitely
what is already converged, given it's already feature complete for
certain users of the code. My patch ordering looks more natural to
me. What is finished goes in, the rest is orthogonal anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
