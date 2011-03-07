Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E46B48D003B
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 11:33:45 -0500 (EST)
Date: Mon, 7 Mar 2011 08:33:34 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 6/8] Add __GFP_OTHER_NODE flag
Message-ID: <20110307163334.GB13384@alboin.amr.corp.intel.com>
References: <1299182391-6061-1-git-send-email-andi@firstfloor.org>
 <1299182391-6061-7-git-send-email-andi@firstfloor.org>
 <20110307173042.8A04.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110307173042.8A04.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com

> Yes, less intrusive. But are you using current NUMA stastics on
> practical system?

Yes I do. I know users use it too.

We unfortunately still have enough NUMA locality problems in the kernel
so that overflowing nodes, causing fallbacks for process memory etc. are not uncommon. 
If you get that then numastat is very useful to track down what happens.

In an ideal world with perfect NUMA balancing it wouldn't be needed,
but we're far from that.

Also the numactl test suite depends on them.


-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
