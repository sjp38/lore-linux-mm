Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AB14F6B01BA
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 07:24:58 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5DBOue1022697
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 13 Jun 2010 20:24:56 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 58B2F45DE55
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C94C45DD77
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 109201DB803B
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:56 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C1A631DB803A
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 16/18] oom: badness heuristic rewrite
In-Reply-To: <20100608160216.bc52112b.akpm@linux-foundation.org>
References: <20100608194533.7657.A69D9226@jp.fujitsu.com> <20100608160216.bc52112b.akpm@linux-foundation.org>
Message-Id: <20100613193529.618D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Sun, 13 Jun 2010 20:24:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > >   *  Copyright (C)  1998,2000  Rik van Riel
> > >   *	Thanks go out to Claus Fischer for some serious inspiration and
> > >   *	for goading me into coding this file...
> > > + *  Copyright (C)  2010  Google, Inc.
> > > + *	Rewritten by David Rientjes
> > 
> > don't put it.
> > 
> 
> Seems OK to me.  It's a fairly substantial change and people have added
> their (c) in the past for smaller kernel changes.  I guess one could even
> do this for a one-liner.

If you are OK, I have no objection. I'm not lawyer.
But, at least in japan, usually include co-developers to author notice.
(of cource, it's not me...)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
