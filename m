Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2CD706B012E
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 22:44:35 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9E2iWOw019268
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 Oct 2010 11:44:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5635045DE70
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 11:44:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 336EA45DE6F
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 11:44:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 138DDEF8003
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 11:44:32 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C039A1DB803A
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 11:44:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/3] mm, mem-hotplug: recalculate lowmem_reserve when memory hotplug occur
In-Reply-To: <20101013125913.GL30667@csn.ul.ie>
References: <20101013152713.ADC0.A69D9226@jp.fujitsu.com> <20101013125913.GL30667@csn.ul.ie>
Message-Id: <20101014113504.8B86.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 Oct 2010 11:44:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

> On Wed, Oct 13, 2010 at 03:27:12PM +0900, KOSAKI Motohiro wrote:
> > Currently, memory hotplu call setup_per_zone_wmarks() and
> > calculate_zone_inactive_ratio(), but don't call setup_per_zone_lowmem_reserve.
> > 
> > It mean number of reserved pages aren't updated even if memory hot plug
> > occur. This patch fixes it.
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Ok, I see the logic although the changelog needs a better description as
> to why this matters and what the consequences are. It appears unrelated
> to Shaohua's problem for example. Otherwise the patch looks reasonable
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>

patch [1/3] and [2/3] is necessary for avoiding [3/3] break memory hotplug.
When memory hotplug occur, we need to update _all_ zone->present_pages related
vm parameters. otherwise they might become inconsistent and no workable.

more detail: [3/3] depend on setup_per_zone_wmarks() is always called after 
refresh_zone_stat_thresholds(). patch [1/3] and [2/3] does.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
