Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5814F6B005A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 21:50:28 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6A2BRb4001021
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 10 Jul 2009 11:11:27 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3534845DE59
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 11:11:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 102D945DE58
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 11:11:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EB1871DB803A
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 11:11:26 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A290C1DB8040
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 11:11:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/5] add isolate pages vmstat
In-Reply-To: <alpine.DEB.1.10.0907091638330.17835@gentwo.org>
References: <20090709171247.23C6.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0907091638330.17835@gentwo.org>
Message-Id: <20090710094934.17CA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 10 Jul 2009 11:11:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

> On Thu, 9 Jul 2009, KOSAKI Motohiro wrote:
> 
> > Subject: [PATCH] add isolate pages vmstat
> >
> > If the system have plenty threads or processes, concurrent reclaim can
> > isolate very much pages.
> > Unfortunately, current /proc/meminfo and OOM log can't show it.
> 
> "
> If the system is running a heavy load of processes then concurrent reclaim
> can isolate a large numbe of pages from the LRU. /proc/meminfo and the
> output generated for an OOM do not show how many pages were isolated.
> "
> 
> > This patch provide the way of showing this information.
> 
> "
> This patch shows the information about isolated pages.
> "
> 
> 
> Page migration can also isolate a large number of pages from the LRU. But
> the new counters are not used there.

Correct. Will fix.

Plus, current reclaim logic depend on the system have enough much pages on LRU.
Maybe we don't only need to limit #-of-reclaimer, but also need to limit #-of-migrator.
I think we can use similar logic.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
