Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id DFCB29000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 03:18:56 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3678F3EE0C1
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 16:18:53 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 11B6945DE5C
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 16:18:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ECCF645DE58
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 16:18:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DDD121DB8055
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 16:18:52 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A62871DB804A
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 16:18:52 +0900 (JST)
Date: Wed, 28 Sep 2011 16:18:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/9] kstaled: page_referenced_kstaled() and supporting
 infrastructure.
Message-Id: <20110928161805.8acb33c5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1317170947-17074-4-git-send-email-walken@google.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
	<1317170947-17074-4-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

On Tue, 27 Sep 2011 17:49:01 -0700
Michel Lespinasse <walken@google.com> wrote:

> Add a new page_referenced_kstaled() interface. The desired behavior
> is that page_referenced() returns page references since the last
> page_referenced() call, and page_referenced_kstaled() returns page
> references since the last page_referenced_kstaled() call, but they
> are both independent of each other and do not influence each other.
> 
> The following events are counted as kstaled page references:
> - CPU data access to the page (as noticed through pte_young());
> - mark_page_accessed() calls;
> - page being freed / reallocated.
> 
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

2 questions.

What happens at Transparent HugeTLB pages are splitted/collapsed ?
Does this feature can ignore page migration i.e. flags should not be copied ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
