Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE626B0089
	for <linux-mm@kvack.org>; Thu, 28 May 2009 02:26:00 -0400 (EDT)
Date: Thu, 28 May 2009 07:27:02 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
Message-ID: <20090528072702.796622b6@lxorguk.ukuu.org.uk>
In-Reply-To: <20090527223421.GA9503@elte.hu>
References: <20090520183045.GB10547@oblivion.subreption.com>
	<4A15A8C7.2030505@redhat.com>
	<20090522073436.GA3612@elte.hu>
	<20090522113809.GB13971@oblivion.subreption.com>
	<20090523124944.GA23042@elte.hu>
	<4A187BDE.5070601@redhat.com>
	<20090527223421.GA9503@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Rik van Riel <riel@redhat.com>, "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

> > As for being swapped out - I do not believe that kernel stacks can 
> > ever be swapped out in Linux.
> 
> yes, i referred to that as an undesirable option - because it slows 
> down pthread_create() quite substantially.
> 
> This needs before/after pthread_create() benchmark results.

kernel stacks can end up places you don't expect on hypervisor based
systems.

In most respects the benchmarks are pretty irrelevant - wiping stuff has
a performance cost, but its the sort of thing you only want to do when
you have a security requirement that needs it. At that point the
performance is secondary.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
