Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA7B3kbR013142
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 Nov 2008 20:03:46 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EFA5245DD82
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 20:03:45 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F255B45DD7D
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 20:03:44 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id AEE7D1DB8037
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 20:03:44 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id E7E811DB8040
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 20:03:40 +0900 (JST)
Date: Fri, 7 Nov 2008 20:02:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] mm: the page of MIGRATE_RESERVE don't insert into
 pcp
Message-Id: <20081107200251.15e9851a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081107104242.GC13786@csn.ul.ie>
References: <20081106091431.0D2A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081106164644.GA14012@csn.ul.ie>
	<20081107104224.1631057e.kamezawa.hiroyu@jp.fujitsu.com>
	<20081107104242.GC13786@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 7 Nov 2008 10:42:42 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> On Fri, Nov 07, 2008 at 10:42:24AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 6 Nov 2008 16:46:45 +0000
> > Mel Gorman <mel@csn.ul.ie> wrote:
> > > > otherwise, the system have unnecessary memory starvation risk
> > > > because other cpu can't use this emergency pages.
> > > > 
> > > > 
> > > > 
> > > > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > > CC: Mel Gorman <mel@csn.ul.ie>
> > > > CC: Christoph Lameter <cl@linux-foundation.org>
> > > > 
> > > 
> > > This patch seems functionally sound but as Christoph points out, this
> > > adds another branch to the fast path. Now, I ran some tests and those that
> > > completed didn't show any problems but adding branches in the fast path can
> > > eventually lead to hard-to-detect performance problems.
> > > 
> > dividing pcp-list into MIGRATE_TYPES is bad ?
> 
> I do not understand what your question is.
> 
Hmm. like this.

	 pcp = &zone_pcp(zone, get_cpu())->pcp[migrate_type];

	
Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
