Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 24A198D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 19:19:10 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7BDA53EE0C0
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 09:19:07 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E71845DE6D
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 09:19:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 24B1C45DE68
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 09:19:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 177F9E08004
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 09:19:07 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CFA111DB803C
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 09:19:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 6/8] Add __GFP_OTHER_NODE flag
In-Reply-To: <20110307163334.GB13384@alboin.amr.corp.intel.com>
References: <20110307173042.8A04.A69D9226@jp.fujitsu.com> <20110307163334.GB13384@alboin.amr.corp.intel.com>
Message-Id: <20110308091843.8A95.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Mar 2011 09:19:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com

> > Yes, less intrusive. But are you using current NUMA stastics on
> > practical system?
> 
> Yes I do. I know users use it too.
> 
> We unfortunately still have enough NUMA locality problems in the kernel
> so that overflowing nodes, causing fallbacks for process memory etc. are not uncommon. 
> If you get that then numastat is very useful to track down what happens.
> 
> In an ideal world with perfect NUMA balancing it wouldn't be needed,
> but we're far from that.
> 
> Also the numactl test suite depends on them.

If so, I have no objection of cource. :)

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
