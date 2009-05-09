Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id F32166B00B6
	for <linux-mm@kvack.org>; Sat,  9 May 2009 06:22:45 -0400 (EDT)
Date: Sat, 9 May 2009 12:22:54 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] tracing/mm: add page frame snapshot trace
Message-ID: <20090509102254.GA15245@elte.hu>
References: <20090508105320.316173813@intel.com> <20090508111031.020574236@intel.com> <20090508114742.GB17129@elte.hu> <20090508124433.GB15949@localhost> <20090509062758.GB21354@elte.hu> <20090509091325.GA7994@localhost> <20090509092431.GB13784@elte.hu> <20090509094316.GA5520@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090509094316.GA5520@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

> > How about changing it from 'trigger' to 'dump_range':
> 
> That's a better name!
> 
> >    echo "*" > /debug/tracing/objects/mm/pages/dump_range
> > 
> > being a shortcut for 'dump all'?
> 
> No I'm not complaining about -1. That's even better than "*",
> because the latter can easily be expanded by shell ;)
> 
> > And:
> > 
> >    echo "1000 2000" > /debug/tracing/objects/mm/pages/dump_range
> > 
> > ?
> 
> Now it's much more intuitive!
> 
> > The '1000' is the offset where the dumping starts, and 2000 is the 
> > size of the dump.
> 
> Ah the second parameter 2000 can easily be taken as "end"..

Ok ... i've changed the name to dump_range and added your fix for 
mapcount as well. I pushed it all out to -tip.

Would you be interested in having a look at that and tweaking the 
dump_range API to any variant of your liking, and sending a patch 
for that? Both "<start> <end>" and "<start> <size>" (or any other 
variant) would be fine IMHO.

The lseek hack is nice (and we can keep that) but an explicit range 
API would be nice, we try to keep all of ftrace scriptable.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
