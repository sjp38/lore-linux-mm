Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5DF476B008A
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 20:01:39 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 594AC3EE0BD
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 10:01:35 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E50045DE53
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 10:01:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FE6E45DE50
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 10:01:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 10D16E08001
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 10:01:35 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CEC431DB803B
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 10:01:34 +0900 (JST)
Date: Fri, 25 Nov 2011 10:00:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 3/5] mm: try to distribute dirty pages fairly across
 zones
Message-Id: <20111125100009.a87094fa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111124131155.GB1225@cmpxchg.org>
References: <1322055258-3254-1-git-send-email-hannes@cmpxchg.org>
	<1322055258-3254-4-git-send-email-hannes@cmpxchg.org>
	<20111124100755.d8b783a8.kamezawa.hiroyu@jp.fujitsu.com>
	<20111124131155.GB1225@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 24 Nov 2011 14:11:55 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Thu, Nov 24, 2011 at 10:07:55AM +0900, KAMEZAWA Hiroyuki wrote:
			goto this_zone_full;
> > >  
> > >  		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
> > >  		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
> > 
> > This wil call 
> > 
> >                 if (NUMA_BUILD)
> >                         zlc_mark_zone_full(zonelist, z);
> > 
> > And this zone will be marked as full. 
> > 
> > IIUC, zlc_clear_zones_full() is called only when direct reclaim ends.
> > So, if no one calls direct-reclaim, 'full' mark may never be cleared
> > even when number of dirty pages goes down to safe level ?
> > I'm sorry if this is alread discussed.
> 
> It does not remember which zones are marked full for longer than a
> second - see zlc_setup() - and also ignores this information when an
> iteration over the zonelist with the cache enabled came up
> empty-handed.
> 
Ah, thank you for clarification.
I understand how zlc_active/did_zlc_setup/zlc_setup()...complicated ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
