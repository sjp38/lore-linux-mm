Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7426B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 17:49:58 -0400 (EDT)
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20090428141738.77e599f4.akpm@linux-foundation.org>
References: <20090428010907.912554629@intel.com>
	 <20090428014920.769723618@intel.com> <20090428065507.GA2024@elte.hu>
	 <20090428083320.GB17038@localhost>
	 <12c511ca0904281111r10f37a5coe5a2750f4dbfbcda@mail.gmail.com>
	 <20090428141738.77e599f4.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 28 Apr 2009 16:49:55 -0500
Message-Id: <1240955395.938.1031.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@gmail.com>, fengguang.wu@intel.com, mingo@elte.hu, rostedt@goodmis.org, fweisbec@gmail.com, lwoodman@redhat.com, a.p.zijlstra@chello.nl, penberg@cs.helsinki.fi, eduard.munteanu@linux360.ro, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, adobriyan@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-04-28 at 14:17 -0700, Andrew Morton wrote:
> On Tue, 28 Apr 2009 11:11:52 -0700
> Tony Luck <tony.luck@gmail.com> wrote:
> 
> > On Tue, Apr 28, 2009 at 1:33 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > 1) FAST
> > >
> > > It takes merely 0.2s to scan 4GB pages:
> > >
> > > __ __ __ __./page-types __0.02s user 0.20s system 99% cpu 0.216 total
> > 
> > OK on a tiny system ... but sounds painful on a big
> > server. 0.2s for 4G scales up to 3 minutes 25 seconds
> > on a 4TB system (4TB systems were being sold two
> > years ago ... so by now the high end will have moved
> > up to 8TB or perhaps 16TB).
> > 
> > Would the resulting output be anything but noise on
> > a big system (a *lot* of pages can change state in
> > 3 minutes)?
> > 
> 
> Reading the state of all of memory in this fashion would be a somewhat
> peculiar thing to do.

Not entirely. If you've got, say, a large NUMA box, it could be
incredibly illustrative to see that "oh, this node is entirely dominated
by SLAB allocations". Or on a smaller machine "oh, this is fragmented to
hell and there's no way I'm going to get a huge page". Things you're not
going to get from individual stats.

> Generally, I think that pagemap is another of those things where we've
> failed on the follow-through.  There's a nice and powerful interface
> for inspecting the state of a process's VM, but nobody knows about it
> and there are no tools for accessing it and nobody is using it.

People keep finding bugs in the thing exercising it in new ways, so I
presume people are writing their own tools. My hope was that my original
tools would inspire someone to take it and run with it - I really have
no stomach for writing GUI tools.

However, I've recent gone and written a pretty generically useful
command-line tool that hopefully will get more traction:

http://www.selenic.com/smem/

I'm expecting it to get written up on LWN shortly, so I haven't spent
much time doing my own advertising.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
