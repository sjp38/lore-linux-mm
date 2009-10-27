Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6822F6B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 14:18:32 -0400 (EDT)
Subject: Re: RFC: Transparent Hugepage support
From: Andi Kleen <andi@firstfloor.org>
References: <20091026185130.GC4868@random.random>
Date: Tue, 27 Oct 2009 19:18:26 +0100
In-Reply-To: <20091026185130.GC4868@random.random> (Andrea Arcangeli's message of "Mon, 26 Oct 2009 19:51:30 +0100")
Message-ID: <87ljiwk8el.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <aarcange@redhat.com> writes:

In general the best would be to just merge hugetlbfs into
the normal VM. It has been growing for far too long as a separate
"second VM" by now. This seems like a reasonable first step,
but some comments blow.

Haven't looked at the actual code at this point.

> Second important decision (to reduce the impact of the feature on the
> existing pagetable handling code) is that at any time we can split an
> hugepage into 512 regular pages and it has to be done with an
> operation that can't fail. This way the reliability of the swapping
> isn't decreased (no need to allocate memory when we are short on
> memory to swap) and it's trivial to plug a split_huge_page* one-liner
> where needed without polluting the VM. Over time we can teach

The problem is that this will interact badly with 1GB pages -- once
you split them up you'll never get them back, because they 
can't be allocated at runtime.

Even for 2MB pages it can be a problem.

You'll likely need to fix the page table code.

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
