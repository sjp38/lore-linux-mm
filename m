Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 660938D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 21:32:26 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A18CA3EE0C1
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:32:22 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8350745DE54
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:32:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FFB345DE58
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:32:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 53E9F1DB8042
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:32:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1644BE08001
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:32:22 +0900 (JST)
Date: Thu, 3 Mar 2011 11:26:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/8] Use correct numa policy node for transparent
 hugepages
Message-Id: <20110303112604.aa4352ca.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1299113128-11349-6-git-send-email-andi@firstfloor.org>
References: <1299113128-11349-1-git-send-email-andi@firstfloor.org>
	<1299113128-11349-6-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On Wed,  2 Mar 2011 16:45:25 -0800
Andi Kleen <andi@firstfloor.org> wrote:

> From: Andi Kleen <ak@linux.intel.com>
> 
> Pass down the correct node for a transparent hugepage allocation.
> Most callers continue to use the current node, however the hugepaged
> daemon now uses the previous node of the first to be collapsed page
> instead. This ensures that khugepaged does not mess up local memory
> for an existing process which uses local policy.
> 
> The choice of node is somewhat primitive currently: it just
> uses the node of the first page in the pmd range. An alternative
> would be to look at multiple pages and use the most popular
> node. I used the simplest variant for now which should work
> well enough for the case of all pages being on the same node.
> 
> Acked-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
