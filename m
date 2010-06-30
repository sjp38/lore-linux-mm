Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 918376B01B4
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 05:26:24 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5U9QLEN022116
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 30 Jun 2010 18:26:21 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DBC745DE4F
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F286745DE50
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BDD4A1DB8051
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:20 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AB8E1DB8048
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/9] oom: cleanup has_intersects_mems_allowed()
In-Reply-To: <alpine.DEB.2.00.1006211305590.8367@chino.kir.corp.google.com>
References: <20100617134601.FBA7.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006211305590.8367@chino.kir.corp.google.com>
Message-Id: <20100628192237.389F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Wed, 30 Jun 2010 18:26:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Mon, 21 Jun 2010, KOSAKI Motohiro wrote:
> 
> > > I disagree that the renaming of the variables is necessary, please simply 
> > > change the while (tsk != start) to use while_each_thread(tsk, start);
> > 
> > This is common naming rule of while_each_thread(). please grep.
> > 
> 
> I disagree, there's no sense in substituting variable names like "tsk" for 
> `p' and removing a very clear and obvious "start" task: it doesn't improve 
> code readability.
> 
> I'm in favor of changing the while (tsk != start) to 
> while_each_thread(tsk, start) which is very trivial to understand and much 
> more readable than while_each_thread(p, tsk).  With the latter, it's not 
> clear whether `p' or "tsk" is the iterator and which is the constant.

Heh, I'm ok this. It isn't big matter at all.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
