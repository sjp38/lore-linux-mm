Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB27JMfL017787
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 2 Dec 2008 16:19:22 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B3CB945DE54
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 16:19:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8593A45DD77
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 16:19:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5660C1DB8042
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 16:19:21 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EC8331DB8041
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 16:19:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg: mem_cgroup->prev_priority protected by lock.
In-Reply-To: <20081202161545.abb884e8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081202160949.1CFE.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081202161545.abb884e8.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20081202161837.1D04.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  2 Dec 2008 16:19:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Tue,  2 Dec 2008 16:11:07 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > 
> > Currently, mem_cgroup doesn't have own lock and almost its member doesn't need.
> >  (e.g. info is protected by zone lock, stat is per cpu variable)
> > 
> > However, there is one explict exception. mem_cgroup->prev_priorit need lock,
> > but doesn't protect.
> > Luckly, this is NOT bug because prev_priority isn't used for current reclaim code.
> > 
> > However, we plan to use prev_priority future again.
> > Therefore, fixing is better.
> > 
> > 
> > In addision, we plan to reuse this lock for another member.
> > Then "misc_lock" name is better than "prev_priority_lock".
> > 
> please use better name...reclaim_param_lock or some ?

good idea :)

Will fix.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
