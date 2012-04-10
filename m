Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 30A4C6B00E9
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 02:01:19 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 58C3C3EE0BB
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 15:01:17 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F5C145DEA6
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 15:01:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2873845DE7E
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 15:01:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0EAD11DB803E
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 15:01:17 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AEB5E1DB8040
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 15:01:16 +0900 (JST)
Message-ID: <4F83CC40.7030406@jp.fujitsu.com>
Date: Tue, 10 Apr 2012 14:59:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch v2] thp, memcg: split hugepage for memcg oom on cow
References: <alpine.DEB.2.00.1204031854530.30629@chino.kir.corp.google.com> <4F838385.9070309@jp.fujitsu.com> <alpine.DEB.2.00.1204092241180.27689@chino.kir.corp.google.com> <alpine.DEB.2.00.1204092242050.27689@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1204092242050.27689@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org

(2012/04/10 14:42), David Rientjes wrote:

> On COW, a new hugepage is allocated and charged to the memcg.  If the
> system is oom or the charge to the memcg fails, however, the fault
> handler will return VM_FAULT_OOM which results in an oom kill.
> 
> Instead, it's possible to fallback to splitting the hugepage so that the
> COW results only in an order-0 page being allocated and charged to the
> memcg which has a higher liklihood to succeed.  This is expensive because
> the hugepage must be split in the page fault handler, but it is much
> better than unnecessarily oom killing a process.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>


Seems nice to me. 
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
