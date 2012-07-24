Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id D128E6B004D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 21:11:23 -0400 (EDT)
Date: Tue, 24 Jul 2012 10:11:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: +
 memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix.patch added to -mm
 tree
Message-ID: <20120724011143.GA13155@bbox>
References: <20120718143810.b15564b3.akpm@linux-foundation.org>
 <20120719001002.GA6579@bbox>
 <20120719002102.GN24336@google.com>
 <20120719004845.GA7346@bbox>
 <20120719165750.GP24336@google.com>
 <20120719235057.GA21012@bbox>
 <20120720142213.f4a4a68e.akpm@linux-foundation.org>
 <20120720213641.GA6823@google.com>
 <20120723045855.GC6832@bbox>
 <20120723154247.GE6823@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120723154247.GE6823@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ralf Baechle <ralf@linux-mips.org>, aaditya.kumar.30@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Yinghai Lu <yinghai@kernel.org>

On Mon, Jul 23, 2012 at 08:42:47AM -0700, Tejun Heo wrote:
> Hello, Minchan.
> 
> On Mon, Jul 23, 2012 at 01:58:55PM +0900, Minchan Kim wrote:
> > I would like to know what fields you are concerning because most of field
> 
> The above question itself is a problem.  It's subtle to hell.  Some
> fields of this data structure is used during early boot but at some
> point all are reset to zero, so we have to be careful about how those
> fields are used before and after.
> 
> This might seem clear now but things like this are likely to make
> people later working on the code go WTF.  Let's say for whatever
> reason ->bdata needs to be accessed after free_area_init - e.g.
> arch_add_memory() needs some info from bdata, what then?
> 
> What if we end up having to add a new property field which is
> determined by platform code but used by generic code.  I would add a
> field to pgdat, init it from numa.c and then later use it in generic
> code.  If the field gets zeroed inbetween, I would get pretty annoyed.
> 
> I really don't think this subject is worth the amount of discussion we
> had in this thread.  Just make the archs clear the data structure on
> creation.  Anything else is silly.

I sent patchset and will wait of akpm's opinion.
Thanks for the comment, Tejun.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
