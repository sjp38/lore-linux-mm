Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 8EB4A6B0023
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 03:41:50 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 75D693EE0BC
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 16:41:45 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C1E545DE54
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 16:41:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 448FC45DD6F
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 16:41:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3836C1DB804D
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 16:41:45 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 03B4B1DB803A
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 16:41:45 +0900 (JST)
Date: Wed, 14 Sep 2011 16:40:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 04/11] mm: memcg: per-priority per-zone hierarchy scan
 generations
Message-Id: <20110914164045.f8074468.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110914055634.GA28051@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
	<1315825048-3437-5-git-send-email-jweiner@redhat.com>
	<20110913192759.ff0da031.kamezawa.hiroyu@jp.fujitsu.com>
	<20110913110301.GB18886@redhat.com>
	<20110914095504.30fca5d0.kamezawa.hiroyu@jp.fujitsu.com>
	<20110914055634.GA28051@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 14 Sep 2011 07:56:34 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> On Wed, Sep 14, 2011 at 09:55:04AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Tue, 13 Sep 2011 13:03:01 +0200
> > Johannes Weiner <jweiner@redhat.com> wrote:
> No, the hierarchy iteration in shrink_zone() is done after a single
> memcg, which is equivalent to the old code: scan all zones at all
> priority levels from a memcg, then move on to the next memcg.  This
> also works because of the per-zone per-priority last_scanned_child:
> 
> 	for each priority
> 	  for each zone
> 	    mem = mem_cgroup_iter(root)
> 	    scan(mem)
> 
> priority-12 + zone-1 will yield memcg-1.  priority-12 + zone-2 starts
> at its own last_scanned_child, so yields memcg-1 as well, etc.  A
> second reclaimer that comes in with priority-12 + zone-1 will receive
> memcg-2 for scanning.  So there is no change in behaviour for limit
> reclaim.
> 
ok, thanks.

> > If so, I need to abandon node-selection-logic for reclaim-by-limit
> > and nodemask-for-memcg which shows me very good result. 
> > I'll be sad ;)
> 
> With my clarification, do you still think so?
> 

No. Thank you. 

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
