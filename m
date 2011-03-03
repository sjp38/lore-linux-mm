Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D631A8D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 20:50:57 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 77B8E3EE0B6
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 10:50:54 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D84D45DE57
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 10:50:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4484B45DE55
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 10:50:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 36F8DE08005
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 10:50:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 03C0CE08004
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 10:50:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC PATCH 0/5] Add accountings for Page Cache
In-Reply-To: <AANLkTik7MA6YcrWVbjFhQsN0arR72xmH9g1M2Yi-E_B-@mail.gmail.com>
References: <AANLkTik7MA6YcrWVbjFhQsN0arR72xmH9g1M2Yi-E_B-@mail.gmail.com>
Message-Id: <20110303104430.B93F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Mar 2011 10:50:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: noname noname <namei.unix@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaxboe@fusionio.com, akpm@linux-foundation.org, fengguang.wu@intel.com

> [Summery]
> 
> In order to evaluate page cache efficiency, system admins are happy to
> know whether a block of data is cached for subsequent use, or whether
> the page is read-in but seldom used. This patch extends an effort to
> provide such kind of information. We adds three counters, which are
> exported to the user space, for the Page Cache that is almost
> transparent to the applications. This would benifit some heavy page
> cache users that might try to tune the performance in hybrid storage
> situation.

I think you need to explain exact and concrete use-case. Typically, 
cache-hit ratio doesn't help administrator at all. because merely backup
operation (eg. cp, dd, et al) makes prenty cache-miss. But it is no sign
of memory shortage. Usually, vmscan stastics may help memroy utilization
obzavation.

Plus, as ingo said, you have to consider to use trancepoint framework
at first. Because, it is zero cost if an admin don't enable such tracepoint.

At last, I don't think disk_stats have to have page cache stastics. It seems
slightly layer violation.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
