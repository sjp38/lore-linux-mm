Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9FA446B00E2
	for <linux-mm@kvack.org>; Sat, 30 May 2009 13:38:44 -0400 (EDT)
Date: Sat, 30 May 2009 19:39:06 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090530173906.GB20013@elte.hu>
References: <20090522113809.GB13971@oblivion.subreption.com> <20090523124944.GA23042@elte.hu> <4A187BDE.5070601@redhat.com> <20090527223421.GA9503@elte.hu> <20090528072702.796622b6@lxorguk.ukuu.org.uk> <20090528090836.GB6715@elte.hu> <20090528125042.28c2676f@lxorguk.ukuu.org.uk> <84144f020905300035g1d5461f9n9863d4dcdb6adac0@mail.gmail.com> <20090530075033.GL29711@oblivion.subreption.com> <4A20E601.9070405@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A20E601.9070405@cs.helsinki.fi>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "Larry H." <research@subreption.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


* Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> Hi Larry,
>
> On 10:35 Sat 30 May, Pekka Enberg wrote:
>>> The GFP_SENSITIVE flag looks like a big hammer that we don't really
>>> need IMHO. It seems to me that most of the actual call-sites (crypto
>>> code, wireless keys, etc.) should probably just use kzfree()
>>> unconditionally to make sure we don't leak sensitive data. I did not
>>> look too closely but I don't think any of the sensitive kfree() calls
>>> are in fastpaths so the performance impact is negligible.
>
> Larry H. wrote:
>> That's hopeless, and kzfree is broken. Like I said in my earlier reply,
>> please test that yourself to see the results. Whoever wrote that ignored
>> how SLAB/SLUB work and if kzfree had been used somewhere in the kernel
>> before, it should have been noticed long time ago.
>
> An open-coded version of kzfree was being used in the kernel:
>
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=00fcf2cb6f6bb421851c3ba062c0a36760ea6e53
>
> Can we now get to the part where you explain how it's broken 
> because I obviously "ignored how SLAB/SLUB works"?

Yeah, kzfree() sounds like the right approach for all places that 
know it for sure that they dont want information to persist.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
