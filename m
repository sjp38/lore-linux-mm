Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 86D386B01ED
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 02:52:51 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o536qlpw030492
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 3 Jun 2010 15:52:48 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B00EC45DE54
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:52:47 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F0E245DE53
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:52:47 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 704BA1DB8043
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:52:47 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 280C51DB8038
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:52:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 02/12] oom: introduce find_lock_task_mm() to fix !mm false  positives
In-Reply-To: <AANLkTikF0EAmKsBx28-paTg7DUdOiHLz5KHJbzLW_OBS@mail.gmail.com>
References: <20100603144948.724D.A69D9226@jp.fujitsu.com> <AANLkTikF0EAmKsBx28-paTg7DUdOiHLz5KHJbzLW_OBS@mail.gmail.com>
Message-Id: <20100603152842.726E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu,  3 Jun 2010 15:52:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> > Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> > Cc: David Rientjes <rientjes@google.com>
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Could you see my previous comment?
> http://lkml.org/lkml/2010/6/2/325
> Anyway, I added my review sign
> 
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Sorry, I had lost your comment ;)

But personally I don't like find_alive_subthread() because 
such function actually does,
  1) iterate threads in the same thread group
  2) find alive (a.k.a have ->mm) thread
  3) lock the task
and, I think (3) is most important role of this function.
So, I prefer to contain "lock" word.

Otherwise, people easily forget to cann task_unlock().
But I'm ok to rename any give me better name.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
