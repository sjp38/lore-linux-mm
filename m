Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3C86C6B01B6
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 05:26:25 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5U9QLX8015304
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 30 Jun 2010 18:26:22 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B3E9245DE50
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 96AC045DE4C
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 806541DB8012
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:21 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BCE01DB8015
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/9] oom: make oom_unkillable_task() helper function
In-Reply-To: <alpine.DEB.2.00.1006211314370.8367@chino.kir.corp.google.com>
References: <20100617104637.FB86.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006211314370.8367@chino.kir.corp.google.com>
Message-Id: <20100630164726.AA40.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Wed, 30 Jun 2010 18:26:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Thu, 17 Jun 2010, KOSAKI Motohiro wrote:
> 
> > 
> > Now, we have the same task check in two places. Unify it.
> > 
> 
> We should exclude tasks from select_bad_process() and oom_kill_process() 
> by having badness() return a score of 0, just like it's done for 
> OOM_DISABLE.

No. again, select_bad_process() have meaningful check order.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
