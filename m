Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B58686B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 20:03:01 -0400 (EDT)
Date: Tue, 28 Apr 2009 19:02:57 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Message-ID: <20090429000257.GB7601@sgi.com>
References: <20090428010907.912554629@intel.com> <20090428014920.769723618@intel.com> <20090428065507.GA2024@elte.hu> <20090428083320.GB17038@localhost> <12c511ca0904281111r10f37a5coe5a2750f4dbfbcda@mail.gmail.com> <20090428141738.77e599f4.akpm@linux-foundation.org> <1240955395.938.1031.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1240955395.938.1031.camel@calx>
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@gmail.com>, fengguang.wu@intel.com, mingo@elte.hu, rostedt@goodmis.org, fweisbec@gmail.com, lwoodman@redhat.com, a.p.zijlstra@chello.nl, penberg@cs.helsinki.fi, eduard.munteanu@linux360.ro, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, adobriyan@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 28, 2009 at 04:49:55PM -0500, Matt Mackall wrote:
> > Reading the state of all of memory in this fashion would be a somewhat
> > peculiar thing to do.
> 
> Not entirely. If you've got, say, a large NUMA box, it could be
> incredibly illustrative to see that "oh, this node is entirely dominated
> by SLAB allocations". Or on a smaller machine "oh, this is fragmented to
> hell and there's no way I'm going to get a huge page". Things you're not
> going to get from individual stats.

I have, in the past, simply used grep on
/sys/devices/system/node/node*/meminfo and gotten the individual stats
I was concerned about.  Not sure how much more detail would have been
needed or useful.  I don't think I can recall a time where I needed to
write another tool.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
