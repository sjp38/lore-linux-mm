Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 02D9E9000BD
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 06:05:12 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B16C63EE0BC
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 19:05:08 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 96BE345DE5F
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 19:05:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 747D845DE5D
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 19:05:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 629521DB804C
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 19:05:08 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D4731DB803A
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 19:05:08 +0900 (JST)
Date: Mon, 3 Oct 2011 19:04:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 00/10] memcg naturalization -rc4
Message-Id: <20111003190411.2c8c6b29.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110930093231.GE30857@redhat.com>
References: <1317330064-28893-1-git-send-email-jweiner@redhat.com>
	<20110930170510.4695b8f0.kamezawa.hiroyu@jp.fujitsu.com>
	<20110930093231.GE30857@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 30 Sep 2011 11:32:31 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> On Fri, Sep 30, 2011 at 05:05:10PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 29 Sep 2011 23:00:54 +0200
> > Thank you for your work. Now, I'm ok this series to be tested in -mm.
> > Ack. to all.
> 
> Thanks!
> 
> > Do you have any plan, concerns ?
> 
> I would really like to get them into 3.2.  While it's quite intrusive,
> I stress-tested various scenarios for quite some time - tests that
> revealed more bugs in the existing memcg code than in my changes - so
> I don't expect too big surprises.  AFAICS, Google uses these patches
> internally already and their bug reports early on also helped iron out
> the most obvious problems.
> 
> What I am concerned about is the scalability on setups with thousands
> of tiny memcgs that go into global reclaim, as this would try to scan
> pages from all existing memcgs.  There is a mitigating factor in that
> concurrent reclaimers divide the memcgs to scan among themselves (the
> shared mem_cgroup_reclaim_iter), and with hundreds or thousands of
> memcgs, I expect several threads to go into reclaim upon global memory
> pressure at the same time in the common case.  I don't have the means
> to test this and I also don't know if such setups exist or are within
> the realm of sanity that we would like to support, anyway. 

As far as I hear, some users use hundreds of memcg in a host.

> If this
> shows up, I think the fix would be as easy as bailing out early from
> the hierarchy walk, but I would like to cross that bridge when we come
> to it.
> 
> Other than that, I see no reason to hold it off.  Traditional reclaim
> without memcgs except root_mem_cgroup - what most people care about -
> is mostly unaffected.  There is a real interest in the series, and
> maintaining it out-of-tree is a major pain and quite error prone.
> 
> What do you think?
> 

I think this should be merged/tested as soon as possible because this patch
must be a base for memcg patches which are now being developped.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
