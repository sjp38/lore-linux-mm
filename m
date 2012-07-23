Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 301606B005D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 00:58:40 -0400 (EDT)
Date: Mon, 23 Jul 2012 13:58:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: +
 memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix.patch added to -mm
 tree
Message-ID: <20120723045855.GC6832@bbox>
References: <20120717233115.A8E411E005C@wpzn4.hot.corp.google.com>
 <20120718012200.GA27770@bbox>
 <20120718143810.b15564b3.akpm@linux-foundation.org>
 <20120719001002.GA6579@bbox>
 <20120719002102.GN24336@google.com>
 <20120719004845.GA7346@bbox>
 <20120719165750.GP24336@google.com>
 <20120719235057.GA21012@bbox>
 <20120720142213.f4a4a68e.akpm@linux-foundation.org>
 <20120720213641.GA6823@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120720213641.GA6823@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ralf Baechle <ralf@linux-mips.org>, aaditya.kumar.30@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Yinghai Lu <yinghai@kernel.org>

On Fri, Jul 20, 2012 at 02:36:41PM -0700, Tejun Heo wrote:
> Hello, Andrew.
> 
> On Fri, Jul 20, 2012 at 02:22:13PM -0700, Andrew Morton wrote:
> > My point is that having to ensure that each arch zeroes out this
> > structure is difficult/costly/unreliable/fragile.  It would be better
> > if we can reliably clear it at some well-known place in core MM.
> > 
> > That might mean that the memory gets cleared twice on some
> > architectures, but I doubt if that matters - it's a once-off thing.
> 
> Clearing twice isn't the problem here.  The problem is the risk of
> zapping fields which are already in use.  That would be way more
> unexpected and difficult to track down than garbage value in whatever
> field.

I would like to know what fields you are concerning because most of field
in pg_data_t are generic except bdata so they would be initialized
by free_area_init_node. So IMHO, reset pg_data_t except bdata would be
no problem and clean approach. If some arch needs some fields in pg_data_t
, we have to declare new variable struct arch_data in pg_data_t and
generic functions doesn't need to touch them.
Of course, we can skip reset of that structure, too.

Please let me know it if I am missing something.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
