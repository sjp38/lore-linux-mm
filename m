Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 097276B01B9
	for <linux-mm@kvack.org>; Fri, 28 May 2010 01:27:55 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4S5RrQR012073
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 28 May 2010 14:27:53 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 71C4345DE70
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:27:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 515E345DE6E
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:27:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A3EC1DB8037
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:27:53 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B31761DB803F
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:27:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: oom killer rewrite
In-Reply-To: <alpine.DEB.2.00.1005251700560.15789@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1005250246170.8045@chino.kir.corp.google.com> <alpine.DEB.2.00.1005251700560.15789@chino.kir.corp.google.com>
Message-Id: <20100528142603.7E27.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 28 May 2010 14:27:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Tue, 25 May 2010, David Rientjes wrote:
> 
> > > > oom-avoid-race-for-oom-killed-tasks-detaching-mm-prior-to-exit.patch
> > > 	no objection. but afaik Oleg already pointed out "if (!p->mm)" is bad.
> > > 	So, Don't we need push his patch instead?
> > > 
> > 
> > I think it all depends on the order in which this work is merged.
> > 
> 
> I just noticed that Oleg's patches were dropped as well from -mm so I'll 
> merge them into my set and repost them as well.

Oops, no. It shouldn't. 
His patch is important and should be merged ASAP. I believe standalone merge is best.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
