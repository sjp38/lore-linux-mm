Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CFA036B01AF
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 07:45:51 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5LBjnPN003988
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 21 Jun 2010 20:45:49 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A7C445DE50
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 509A045DE4E
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 36EEE1DB8038
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:49 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DB0D31DB8037
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 01/18] oom: filter tasks not sharing the same cpuset
In-Reply-To: <alpine.DEB.2.00.1006162028410.21446@chino.kir.corp.google.com>
References: <20100613180405.6178.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006162028410.21446@chino.kir.corp.google.com>
Message-Id: <20100621193224.B530.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Mon, 21 Jun 2010 20:45:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Sun, 13 Jun 2010, KOSAKI Motohiro wrote:
> 
> > I have no objection because it's policy matter. but if so, dump_tasks()
> > should display mem_allowed mask too, probably.
> 
> You could, but we'd want to do that all under cpuset_buffer_lock so we 
> don't have to allocate it on the stack, which can be particularly lengthy 
> when the page allocator is called.

Probably we don't need such worry. becuase a stack overflow risk depend on
deepest call path.
That's said, if out_of_memory() was called, page allocator did called
try_to_free_pages() at first. try_to_free_pages() have much deeper stack
rather than out_of_memory().



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
