Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 842006B00D8
	for <linux-mm@kvack.org>; Sat, 30 May 2009 17:35:05 -0400 (EDT)
Date: Sat, 30 May 2009 14:33:11 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090530213311.GM6535@oblivion.subreption.com>
References: <20090530075033.GL29711@oblivion.subreption.com> <4A20E601.9070405@cs.helsinki.fi> <20090530082048.GM29711@oblivion.subreption.com> <20090530173428.GA20013@elte.hu> <20090530180333.GH6535@oblivion.subreption.com> <20090530182113.GA25237@elte.hu> <20090530184534.GJ6535@oblivion.subreption.com> <20090530190828.GA31199@elte.hu> <4A21999E.5050606@redhat.com> <84144f020905301353y2f8c232na4c5f9dfb740eec4@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020905301353y2f8c232na4c5f9dfb740eec4@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 23:53 Sat 30 May     , Pekka Enberg wrote:
> Hi Rik,
> 
> On Sat, May 30, 2009 at 11:39 PM, Rik van Riel <riel@redhat.com> wrote:
> >>> Have you benchmarked the addition of these changes? I would like to see
> >>> benchmarks done for these (crypto api included), since you are proposing
> >>> them.
> >>
> >> You have it the wrong way around. _You_ have the burden of proof here
> >> really, you are trying to get patches into the upstream kernel. I'm not
> >> obliged to do your homework for you. I might be wrong, and you can prove me
> >> wrong.
> >
> > Larry's patches do not do what you propose they
> > should do, so why would he have to benchmark your
> > idea?
> 
> It's pretty damn obvious that Larry's patches have a much bigger
> performance impact than using kzfree() for selected parts of the
> kernel. So yes, I do expect him to benchmark and demonstrate that
> kzfree() has _performance problems_ before we can look into merging
> his patches.

I was pointing out that the 'those test and jump/call branches have
performance hits' argument, while nonsensical, applies to kzfree and
with even more negative connotations (deeper call depth, more test
branches used in ksize and kfree, lack of pointer validation).

Also there's no kmem_cache_kzfree, either. There are some caches you
might want to look at.

Regarding the 'damn obvious much bigger performance impact': they have
none. You don't like it? Don't use the boot time option. And the next
version using a Kconfig option to disable it altogether is coming. Plus
I'll remove the sanitize_obj function altogether. Guess why I'm doing
that? Because there might be some benefit in trying to keep you happy
regarding that specific aspect of the patch.

Alan already pointed out this very clearly. Alan and I initially had
conflicting opinions about the first patches, we came to a point of
agreement. Rik also proposed changes, which I agreed upon and followed
up. They provided constructive critics and suggestions.

But you and the other cabal of vagueness have only sent mostly useless
comments, outright uncivil responses, obvious misdirection attempts,
unfounded critics, etc. I haven't seen more fallacies put together since
the last time I read an unreleased film script by Jerry Lewis.

If you think you have the power to decide when to cripple the kernel,
and what goes in or out by your own will, you missed the point about how
the Linux kernel became what it is today.

While we are at it, did any of you (Pekka, Ingo, Peter) bother reading
the very first paper I referenced in the very first patch?:

http://www.stanford.edu/~blp/papers/shredding.html/#kernel-appendix

Could you _please_ bother your highness with an earthly five minutes
read of that paper? If you don't have other magnificent obligations to
attend to. _Please_.

	Larry

PS: I'm still thanking myself for not implementing the kthread /
multiple page pool based approach. Lord, what could have happened if I
did.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
