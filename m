Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 252096B01C5
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 14:14:47 -0400 (EDT)
Date: Tue, 23 Mar 2010 11:13:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15618] New: 2.6.18->2.6.32->2.6.33 huge
 regression in performance
Message-Id: <20100323111351.756c8752.akpm@linux-foundation.org>
In-Reply-To: <20100323173409.GA24845@elte.hu>
References: <bug-15618-10286@https.bugzilla.kernel.org/>
	<20100323102208.512c16cc.akpm@linux-foundation.org>
	<20100323173409.GA24845@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, ant.starikov@gmail.com, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Mar 2010 18:34:09 +0100
Ingo Molnar <mingo@elte.hu> wrote:

> 
> It shows a very brutal amount of page fault invoked mmap_sem spinning 
> overhead.
> 

Yes.  Note that we fall off a cliff at nine threads on a 16-way.  As
soon as a core gets two threads scheduled onto it?  Probably triggered
by an MM change, possibly triggered by a sched change which tickled a
preexisting MM shortcoming.  Who knows.

Anton, we have an executable binary in the bugzilla report but it would
be nice to also have at least a description of what that code is
actually doing.  A quick strace shows quite a lot of mprotect activity.
A pseudo-code walkthrough, perhaps?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
