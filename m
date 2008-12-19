Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 757796B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 02:58:00 -0500 (EST)
Date: Thu, 18 Dec 2008 23:59:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc][patch] unlock_page speedup
Message-Id: <20081218235957.d657b7ac.akpm@linux-foundation.org>
In-Reply-To: <20081219075328.GD26419@wotan.suse.de>
References: <20081219072909.GC26419@wotan.suse.de>
	<20081218233549.cb451bc8.akpm@linux-foundation.org>
	<20081219075328.GD26419@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Dec 2008 08:53:28 +0100 Nick Piggin <npiggin@suse.de> wrote:

> On Thu, Dec 18, 2008 at 11:35:49PM -0800, Andrew Morton wrote:
> > On Fri, 19 Dec 2008 08:29:09 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > 
> > > Introduce a new page flag, PG_waiters
> > 
> > Leaving how many?
> 
> Don't know...

Need to know!  page.flags is prime real estate and we should decide
whether gaining 2% in a particular microbenchmark is our best use of it

> I thought the page-flags.h obfuscation project was
> supposed to make that clearer to work out. There are what, 21 flags
> used now. If everything is coded properly, then the memory model
> should automatically kick its metadata out of page flags if it gets
> too big.

That would be nice :)

> But most likely it will just blow up.

If we use them all _now_, as I proposed, we'll find out about that.

> Probably we want
> at least a few flags for memory model on 32-bit for smaller systems
> (big NUMA 32-bit systems probably don't matter much anymore).
> 
> 
> >  fs-cache wants to take two more.
> 
> fs-cache is getting merged?

See thread titled "Pull request for FS-Cache, including NFS patches"

> Wow, I've wanted to review that.

That would be good.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
