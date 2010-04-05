Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 50D22600337
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 03:36:28 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o357aP6F030657
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 5 Apr 2010 16:36:26 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B4BD745DE54
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 16:36:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FDCD45DE51
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 16:36:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CD091DB804C
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 16:36:25 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 18A451DB8049
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 16:36:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 0/5] oom: fixes and cleanup
In-Reply-To: <20100402113023.GB4432@redhat.com>
References: <alpine.DEB.2.00.1004011240370.13247@chino.kir.corp.google.com> <20100402113023.GB4432@redhat.com>
Message-Id: <20100405163047.7E1E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  5 Apr 2010 16:36:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On 04/01, David Rientjes wrote:
> >
> > This patchset fixes a couple of issues with the oom killer, namely
> > tasklist_lock locking requirements and sending SIGKILLs to already
> > exiting tasks.  It also cleans up a couple functions, __oom_kill_task()
> > and oom_badness().
> 
> The whole series looks good to me.
> 
> Thanks David.

sorry for the delay. recently I'm very busy and now I still have 
>1000 unreaded mail. I haven't read this thread completely. but yes,
I also ack this series.

I have no doubt I still have a lot of yet reviewed patch. I'm going to
assimilate it as far as fast.

thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
