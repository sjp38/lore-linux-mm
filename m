Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C377B6B00A5
	for <linux-mm@kvack.org>; Sat, 30 May 2009 03:52:04 -0400 (EDT)
Date: Sat, 30 May 2009 00:50:33 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090530075033.GL29711@oblivion.subreption.com>
References: <4A15A8C7.2030505@redhat.com> <20090522073436.GA3612@elte.hu> <20090522113809.GB13971@oblivion.subreption.com> <20090523124944.GA23042@elte.hu> <4A187BDE.5070601@redhat.com> <20090527223421.GA9503@elte.hu> <20090528072702.796622b6@lxorguk.ukuu.org.uk> <20090528090836.GB6715@elte.hu> <20090528125042.28c2676f@lxorguk.ukuu.org.uk> <84144f020905300035g1d5461f9n9863d4dcdb6adac0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020905300035g1d5461f9n9863d4dcdb6adac0@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 10:35 Sat 30 May     , Pekka Enberg wrote:
> The GFP_SENSITIVE flag looks like a big hammer that we don't really
> need IMHO. It seems to me that most of the actual call-sites (crypto
> code, wireless keys, etc.) should probably just use kzfree()
> unconditionally to make sure we don't leak sensitive data. I did not
> look too closely but I don't think any of the sensitive kfree() calls
> are in fastpaths so the performance impact is negligible.

That's hopeless, and kzfree is broken. Like I said in my earlier reply,
please test that yourself to see the results. Whoever wrote that ignored
how SLAB/SLUB work and if kzfree had been used somewhere in the kernel
before, it should have been noticed long time ago.

It's called disregard when you ditch something in favor of something
else you have assumed to be better, when it isn't. That's not polite.

Furthermore, selective clearing doesn't solve the roots of the problem.
It's just adding bandages to a wound which never stops bleeding. I
proposed an initial page flag because we could use it later for
unconditional page clearing doing a one line change in a header file.

I see a lot of speculation on what works and what doesn't, but
there isn't much on the practical side of things, yet. I provided test
results that proved some of the comments wrong, and I've referenced
literature which shows the reasoning behind all this. What else can I do
to make you understand you are missing the point here?

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
