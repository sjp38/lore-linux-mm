Date: Tue, 22 Apr 2008 16:19:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 10 of 12] Convert mm_lock to use semaphores after
 i_mmap_lock and anon_vma_lock
In-Reply-To: <20080422225424.GT24536@duo.random>
Message-ID: <Pine.LNX.4.64.0804221615150.4868@schroedinger.engr.sgi.com>
References: <f8210c45f1c6f8b38d15.1208872286@duo.random>
 <Pine.LNX.4.64.0804221325490.3640@schroedinger.engr.sgi.com>
 <20080422225424.GT24536@duo.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Apr 2008, Andrea Arcangeli wrote:

> The right patch ordering isn't necessarily the one that reduces the
> total number of lines in the patchsets. The mmu-notifier-core is
> already converged and can go in. The rest isn't converged at
> all... nearly nobody commented on the other part (the few comments so
> far were negative), so there's no good reason to delay indefinitely
> what is already converged, given it's already feature complete for
> certain users of the code. My patch ordering looks more natural to
> me. What is finished goes in, the rest is orthogonal anyway.

I would not want to review code that is later reverted or essentially 
changed in later patches. I only review your patches because we have a 
high interest in the patch. I suspect that others will be more willing to 
review this material if it would be done the right way.

If you cannot produce an easily reviewable and properly formatted patchset 
that follows conventions then I will have to do it because we really need 
to get this merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
