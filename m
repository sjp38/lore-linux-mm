Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 29D276B003D
	for <linux-mm@kvack.org>; Mon, 11 May 2009 14:39:30 -0400 (EDT)
Date: Mon, 11 May 2009 11:31:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/8] proc: export more page flags in /proc/kpageflags
Message-Id: <20090511113157.b2c56e70.akpm@linux-foundation.org>
In-Reply-To: <20090511114554.GC4748@elte.hu>
References: <20090508105320.316173813@intel.com>
	<20090508111031.020574236@intel.com>
	<20090508114742.GB17129@elte.hu>
	<20090508132452.bafa287a.akpm@linux-foundation.org>
	<20090509104409.GB16138@elte.hu>
	<20090509222612.887b96e3.akpm@linux-foundation.org>
	<20090511114554.GC4748@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: fengguang.wu@intel.com, fweisbec@gmail.com, rostedt@goodmis.org, a.p.zijlstra@chello.nl, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, mpm@selenic.com, adobriyan@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 May 2009 13:45:54 +0200
Ingo Molnar <mingo@elte.hu> wrote:

> > Yes, we could place pagemap's two auxiliary files into debugfs but 
> > it would be rather stupid to split the feature's control files 
> > across two pseudo filesystems, one of which may not even exist.  
> > Plus pagemap is not a kernel debugging feature.
> 
> That's not what i'm suggesting though.
> 
> What i'm suggesting is that there's a zillion ways to enumerate and 
> index various kernel objects, doing that in /proc is fundamentally 
> wrong. And there's no need to create a per PID/TID directory 
> structure in /debug either, to be able to list and access objects by 
> their PID.

The problem with procfs was that it was growing a lot of random
non-process-related stuff.  We never deprecated procfs - we decided
that it should be retained for its original purpose and that
non-process-realted things shouldn't go in there.

The /proc/<pid>/pagemap file clearly _is_ process-related, and
/proc/<pid> is the natural and correct place for it to live.

Yes, sure, there are any number of ways in which that data could be
presented to userspace in other locations and via other means.  But
there would need to be an extraordinarily good reason for violating the
existing paradigm/expectation/etc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
