Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 89E296B004D
	for <linux-mm@kvack.org>; Sat, 13 Jun 2009 11:05:30 -0400 (EDT)
Date: Sat, 13 Jun 2009 16:04:40 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 0/4] RFC - ksm api change into madvise
In-Reply-To: <20090608225756.GB8642@random.random>
Message-ID: <Pine.LNX.4.64.0906131547560.6589@sister.anvils>
References: <1242261048-4487-1-git-send-email-ieidus@redhat.com>
 <Pine.LNX.4.64.0906081555360.22943@sister.anvils> <20090608225756.GB8642@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, chrisw@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrea,

On Tue, 9 Jun 2009, Andrea Arcangeli wrote:
> 
> So let us know what you think about the rmap_item/tree_item out of
> sync, or in sync with mmu notifier. As said Izik already did a
> preliminary patch with mmu notifier registration. I doubt we want to
> invest in that direction unless there's 100% agreement that it is
> definitely the way to go, and the expectation that it will make a
> substantial difference to the KSM users. Minor optimizations that
> increase complexity a lot, can be left for later.

Thanks for your detailed mail, of which this is merely the final
paragraph.  Thought I'd better respond with a little reassurance,
though I'm not yet ready to write in detail.

I agree 100% that KSM is entitled to be as "lazy" about clearing
up pages as it is about merging them in the first place: you're
absolutely right to avoid the unnecessary overhead of keeping
strictly in synch, and I recognize the lock ordering problems
that keeping strictly in synch would be likely to entail.

My remarks about "lost" pages came from the belief that operations
upon the vmas could move pages to where they thereafter escaped
the attention of KSM's scans for an _indefinite_ period (until
the process exited or even after): that's what has worried me,
but I've yet to demonstrate such a problem, and the rework
naturally changes what happens here.

So, rest assured, I'm not wanting to impose a stricter discipline and
tighter linkage, unless it's to fix a proven indefinite discrepancy.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
