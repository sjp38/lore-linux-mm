Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E1B366B0055
	for <linux-mm@kvack.org>; Fri, 22 May 2009 14:21:02 -0400 (EDT)
Date: Fri, 22 May 2009 19:21:58 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
Message-ID: <20090522192158.28fe412e@lxorguk.ukuu.org.uk>
In-Reply-To: <20090522180351.GC13971@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com>
	<4A15A8C7.2030505@redhat.com>
	<20090522073436.GA3612@elte.hu>
	<20090522113809.GB13971@oblivion.subreption.com>
	<20090522143914.2019dd47@lxorguk.ukuu.org.uk>
	<20090522180351.GC13971@oblivion.subreption.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

> I'm going to present a very short analysis for different historic leaks
> which had little to do with 'padding bytes in stack', but more like

I wouldn't dispute both classes exist - and a lot of the padding leaks
probably never got a CVE either (eg some of the tty ones just got fixed)

> If the caller provided the page already allocated, the GFP_ZERO
> allocation never happened, and the page was never cleared. Interesting
> issue since my patch basically ensures this doesn't happen. Nevermind.

Which patch are we talking about ? I'm all for a security option which
clears *all* objects on freeing them (actually the poison debug is pretty
close to this). That would fix these examples too.

> At least it's not entirely deceitful. It's definitely dereferencing
> "random memory".

Which could be another task stack you didn't clear - yes ?

> was used to leak kernel memory to userland after a page was allocated at
> NULL by the exploit abusing the issue.

Including task stacks yes ?

And task stacks contain copies of important data yes ?

> My intention here is to make the kernel more secure, not proving you
> wrong or right.

Ditto - which is why I'm coming from the position of an "if we free it
clear it" option. If you need that kind of security the cost should be
more than acceptable - especially with modern processors that can do
cache bypass on the clears.

> You are a smart fellow and I respect your technical and kernel development
> acumen. Smart people don't waste their time on meaningless banter.
> 
> I'll have the modified patches ready in an hour or so, hopefully.

Excellent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
