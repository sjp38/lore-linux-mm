Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4854C6B004D
	for <linux-mm@kvack.org>; Sat, 23 May 2009 04:08:22 -0400 (EDT)
Date: Sat, 23 May 2009 09:09:10 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
Message-ID: <20090523090910.3d6c2e85@lxorguk.ukuu.org.uk>
In-Reply-To: <20090522234031.GH13971@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com>
	<4A15A8C7.2030505@redhat.com>
	<20090522073436.GA3612@elte.hu>
	<20090522113809.GB13971@oblivion.subreption.com>
	<20090522143914.2019dd47@lxorguk.ukuu.org.uk>
	<20090522180351.GC13971@oblivion.subreption.com>
	<20090522192158.28fe412e@lxorguk.ukuu.org.uk>
	<20090522234031.GH13971@oblivion.subreption.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

> Enabling SLAB poisoning by default will be a bad idea

Why ?

> I looked for unused/re-usable flags too, but found none. It's
> interesting to see SLUB and SLOB have their own page flags. Did anybody
> oppose those when they were proposed? 

Certainly they were looked at - but the memory allocator is right at the
core of the system rather than an add on.

> > Ditto - which is why I'm coming from the position of an "if we free it
> > clear it" option. If you need that kind of security the cost should be
> > more than acceptable - especially with modern processors that can do
> > cache bypass on the clears.
> 
> Are you proposing that we should simply remove the confidential flags
> and just stick to the unconditional sanitization when the boot option is
> enabled? If positive, it will make things more simple and definitely is
> better than nothing. I would have (still) preferred the other old
> approach to be merged, but whatever works at this point.

I am because
- its easy to merge
- its non controversial
- it meets the security good practice and means we don't miss any
  alloc/free cases
- it avoid providing flags to help a trojan identify "interesting" data
  to acquire
- modern cpu memory clearing can be very cheap

and if it proves to expensive (which I don't think it will based upon
distro beta builds with slab poisoning enabled etc) then the more complex
approach you put forward can be built on top of it. Going this way first
doesn't have to exclude doing the more complex job later if it proves
needed.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
