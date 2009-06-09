Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D91086B0055
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 05:14:33 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n599jYhi003076
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Jun 2009 18:45:36 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0220245DE7A
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:45:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CC32045DE70
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:45:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 983F41DB803B
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:45:31 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ECD81DB8042
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:45:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] Reintroduce zone_reclaim_interval for when zone_reclaim() scans and fails to avoid CPU spinning at 100% on NUMA
In-Reply-To: <20090609094231.GM18380@csn.ul.ie>
References: <20090609173011.DD7F.A69D9226@jp.fujitsu.com> <20090609094231.GM18380@csn.ul.ie>
Message-Id: <20090609184422.DD8B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Jun 2009 18:45:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> > > Here it is just recording the jiffies value. The real smarts with the counter
> > > use time_before() which I assumed could handle jiffie wrap-arounds. Even
> > > if it doesn't, the consequence is that one scan will occur that could have
> > > been avoided around the time of the jiffie wraparound. The value will then
> > > be reset and it will be fine.
> > 
> > time_before() assume two argument are enough nearly time.
> > if we use 32bit cpu and HZ=1000, about jiffies wraparound about one month.
> > 
> > Then, 
> > 
> > 1. zone reclaim failure occur
> > 2. system works fine for one month
> > 3. jiffies wrap and time_before() makes mis-calculation.
> > 
> 
> And the scan occurs uselessly and zone_reclaim_failure gets set again.
> I believe the one useless scan is not significant enough to warrent dealing
> with jiffie wraparound.

Thank you for kindful explanation.
I fully agreed.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
