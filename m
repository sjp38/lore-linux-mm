Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5AA518D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 03:38:59 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 686113EE0AE
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:38:55 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E39345DE61
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:38:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 361AB45DE4D
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:38:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 28C27E08001
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:38:55 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E08291DB802C
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:38:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/8] Use correct numa policy node for transparent hugepages
In-Reply-To: <1299182391-6061-6-git-send-email-andi@firstfloor.org>
References: <1299182391-6061-1-git-send-email-andi@firstfloor.org> <1299182391-6061-6-git-send-email-andi@firstfloor.org>
Message-Id: <20110307173838.8A10.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  7 Mar 2011 17:38:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

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
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
