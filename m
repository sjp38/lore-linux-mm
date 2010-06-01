Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0EBEE6B0224
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:46:27 -0400 (EDT)
Date: Tue, 1 Jun 2010 17:46:20 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
Message-ID: <20100601074620.GR9453@laptop>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1006010015030.29202@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1006010015030.29202@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 01, 2010 at 12:18:43AM -0700, David Rientjes wrote:
> This a complete rewrite of the oom killer's badness() heuristic which is
> used to determine which task to kill in oom conditions.  The goal is to
> make it as simple and predictable as possible so the results are better
> understood and we end up killing the task which will lead to the most
> memory freeing while still respecting the fine-tuning from userspace.

Do you have particular ways of testing this (and other heuristics
changes such as the forkbomb detector)?

Such that you can look at your test case or workload and see that
it is really improved?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
