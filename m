Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D4B4F6B01CC
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 15:59:53 -0400 (EDT)
Date: Tue, 23 Mar 2010 12:54:47 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15618] New: 2.6.18->2.6.32->2.6.33 huge regression
 in performance
In-Reply-To: <9D040E9A-80F2-468F-A6CD-A4912615CD3F@gmail.com>
Message-ID: <alpine.LFD.2.00.1003231253570.18017@i5.linux-foundation.org>
References: <bug-15618-10286@https.bugzilla.kernel.org/> <20100323102208.512c16cc.akpm@linux-foundation.org> <20100323173409.GA24845@elte.hu> <alpine.LFD.2.00.1003231037410.18017@i5.linux-foundation.org> <9D040E9A-80F2-468F-A6CD-A4912615CD3F@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Anton Starikov <ant.starikov@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>



On Tue, 23 Mar 2010, Anton Starikov wrote:

> 
> On Mar 23, 2010, at 6:45 PM, Linus Torvalds wrote:
> 
> > 
> > 
> > On Tue, 23 Mar 2010, Ingo Molnar wrote:
> >> 
> >> It shows a very brutal amount of page fault invoked mmap_sem spinning 
> >> overhead.
> > 
> > Isn't this already fixed? It's the same old "x86-64 rwsemaphores are using 
> > the shit-for-brains generic version" thing, and it's fixed by
> > 
> > 	1838ef1 x86-64, rwsem: 64-bit xadd rwsem implementation
> > 	5d0b723 x86: clean up rwsem type system
> > 	59c33fa x86-32: clean up rwsem inline asm statements
> > 
> > NOTE! None of those are in 2.6.33 - they were merged afterwards. But they 
> > are in 2.6.34-rc1 (and obviously current -git). So Anton would have to 
> > compile his own kernel to test his load.
> 
> 
> Applied mentioned patches. Things didn't improve too much.

Yeah, I missed at least one commit, namely

	bafaecd x86-64: support native xadd rwsem implementation

which is the one that actually makes x86-64 able to use the xadd version.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
