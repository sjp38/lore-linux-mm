Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 437165F0001
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 01:52:49 -0400 (EDT)
Date: Fri, 10 Apr 2009 13:53:17 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/14] filemap and readahead fixes
Message-ID: <20090410055317.GA11854@localhost>
References: <20090407115039.780820496@intel.com> <20090409213643.0e80fdcf.akpm@linux-foundation.org> <20090410045440.GA8937@localhost> <20090409220815.22ef8b21.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090409220815.22ef8b21.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Mike Waychison <mikew@google.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rohit Seth <rohitseth@google.com>, Edwin <edwintorok@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 10, 2009 at 01:08:15PM +0800, Andrew Morton wrote:
> On Fri, 10 Apr 2009 12:54:40 +0800 Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > On Fri, Apr 10, 2009 at 12:36:43PM +0800, Andrew Morton wrote:
> > > On Tue, 07 Apr 2009 19:50:39 +0800 Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > 
> > > > This is a set of fixes and cleanups for filemap and readahead.
> > > 
> > > Unfortunately page_fault-retry-with-nopage_retry.patch got dropped so
> > > the first five patches are no longer applicable.  Patch #11 also died.
> > > 
> > > Can you please respin the remains against current mainline?
> > 
> > Do you mean rebase them onto linux-next, bypassing Ying Hans' patches?
> > 
> 
> Those patches are still several akpm-hours ahead in my backlog queue. 
> They don't seem to have generated much attention and someone (ie: you)
> had substantial comments which haven't been replied to yet.  So I'd
> expect another version to be forthcoming.

OK. The truth on my part is that I'll be able to submit my patches
much earlier if her patches are not in the way. I have to understand
what her patches do and resolve conflicts and retest and resolve the
side effects.

So I became a big tester of her patches and cleared several bugs out
of it. Now I feel confident on the fault-retry patches.

I can imagine one major benefited workload to be concurrent threads
reading on the same mmap file. Before her patch:
- minor faults are blocked waiting for major faults doing IO
- major faults block each other, leading to _serialized_ IO
So her patches not only reduce unnecessary long waited locks,
but also make _parallel_ IOs happen.

> But I don't mind either way.  I guess the main question here is: do we
> see a need to squeeze any of these things into 2.6.30?

Linus and mine filemap/readahead patches are in fact pretty old bug
fixing and cleanup ones, they should be safe for 2.6.30 :-)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
