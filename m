Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 33E856B004D
	for <linux-mm@kvack.org>; Thu, 21 May 2009 11:21:24 -0400 (EDT)
Date: Thu, 21 May 2009 10:21:40 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090521152140.GB29447@sgi.com>
References: <20090520183045.GB10547@oblivion.subreption.com> <1242852158.6582.231.camel@laptop> <20090520212413.GF10756@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090520212413.GF10756@oblivion.subreption.com>
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

> > Seems like a particularly wasteful use of a pageflag. Why not simply
> > erase the buffer before freeing in those few places where we know its
> > important (ie. exactly those places you now put the pageflag in)?
...
> The idea of the patch is not merely "protecting" those few places, but
> providing a clean, effective generalized method for this purpose. Your
> approach means forcing all developers to remember where they have to
> place this explicit clearing, and introducing unnecessary code
> duplication and an ever growing list of places adding these calls.

I agree with the earlier.  If you know enough to set the flag, then
you know enough to call a function which does a clear before free.
Does seem like a waste of a page flag.

> Also, this let's third-party code (and other kernel interfaces)
> use this feature effortlessly. Moreover, this flag allows easy
> integration with MAC/security frameworks (for instance, SELinux) to mark
> a process as requiring sensitive mappings, in higher level APIs. There are
> plans to work on such a patch, which could be independently proposed
> to the SELinux maintainers.

That sounds like either a thread group flag or a VMA flag, not a page
flag.  If you make it a page flag, you would still need to track it
on the vma or process to handle the event where the page gets migrated
or swapped out.  Really doesn't feel like a page flag is right, but I
reserve the right to be wrong.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
