Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 71EF96B00FE
	for <linux-mm@kvack.org>; Sat, 30 May 2009 19:20:26 -0400 (EDT)
Date: Sat, 30 May 2009 16:18:13 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090530231813.GP6535@oblivion.subreption.com>
References: <20090530082048.GM29711@oblivion.subreption.com> <20090530173428.GA20013@elte.hu> <20090530180333.GH6535@oblivion.subreption.com> <20090530182113.GA25237@elte.hu> <20090530184534.GJ6535@oblivion.subreption.com> <20090530190828.GA31199@elte.hu> <4A21999E.5050606@redhat.com> <84144f020905301353y2f8c232na4c5f9dfb740eec4@mail.gmail.com> <20090530213311.GM6535@oblivion.subreption.com> <20090531001318.093e3665@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090531001318.093e3665@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 00:13 Sun 31 May     , Alan Cox wrote:
> > I was pointing out that the 'those test and jump/call branches have
> > performance hits' argument, while nonsensical, applies to kzfree and
> > with even more negative connotations (deeper call depth, more test
> > branches used in ksize and kfree, lack of pointer validation).
> 
> But they only apply to kzfree - there isn't a cost to anyone else. You've
> move the decision to compile time which for the fast path stuff when you
> just want to clear keys and other oddments is a big win.

OK, I'm going to squeeze some time and provide patches that perform the
same my original page bit ones did, but using kzfree. Behold code like
in the tty buffer management, which uses the page allocator directly for
allocations greater than PAGE_SIZE in length. That needs special
treatment, and is exactly the reason I've proposed unconditional
sanitization since the original patches were rejected.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
