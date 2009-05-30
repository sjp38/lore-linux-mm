Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6D7C66B00C6
	for <linux-mm@kvack.org>; Sat, 30 May 2009 09:24:20 -0400 (EDT)
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1243689707.6645.134.camel@laptop>
References: <20090522073436.GA3612@elte.hu>
	 , <20090530054856.GG29711@oblivion.subreption.com>
	 , <1243679973.6645.131.camel@laptop>
	 <4A211BA8.8585.17B52182@pageexec.freemail.hu>
	 <1243689707.6645.134.camel@laptop>
Content-Type: text/plain
Date: Sat, 30 May 2009 15:24:31 +0200
Message-Id: <1243689871.6645.136.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: pageexec@freemail.hu
Cc: "Larry H." <research@subreption.com>, Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sat, 2009-05-30 at 15:21 +0200, Peter Zijlstra wrote:
> On Sat, 2009-05-30 at 13:42 +0200, pageexec@freemail.hu wrote:
> > > Why waste time on this?
> > 
> > e.g., when userland executes a syscall, it 'can run kernel code'. if that kernel
> > code (note: already exists, isn't provided by the attacker) gives unintended
> > kernel memory back to userland, there is a problem. that problem is addressed
> > in part by early sanitizing of freed data.
> 
> Right, so the whole point is to minimize the impact of actual bugs,
> right? So why not focus on fixing those actual bugs? Can we create tools
> to help us find such bugs faster? We use sparse for a lot of static
> checking, we create things like lockdep and kmemcheck to dynamically
> find trouble.
> 
> Can we instead of working around a problem, fix the actual problem?

Also, I'm not at all opposed to make crypto code use kzfree(). That code
knows it had sensitive data in memory, it can wipe the memory when it
frees it -- that makes perfect sense.

Wiping everything because we're too 'lazy' to figure out what really
matters otoh seems silly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
