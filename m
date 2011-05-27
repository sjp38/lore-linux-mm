Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 194496B0012
	for <linux-mm@kvack.org>; Fri, 27 May 2011 16:16:54 -0400 (EDT)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1QQ3T1-0004xQ-1n
	for linux-mm@kvack.org; Fri, 27 May 2011 20:17:07 +0000
Subject: Re: [RFC][PATCH v3 7/10] workqueue: add WQ_IDLEPRI
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110526093808.GE9715@htj.dyndns.org>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
	 <20110526143024.7f66e797.kamezawa.hiroyu@jp.fujitsu.com>
	 <20110526093808.GE9715@htj.dyndns.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 27 May 2011 22:20:13 +0200
Message-ID: <1306527613.2497.476.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Thu, 2011-05-26 at 11:38 +0200, Tejun Heo wrote:
> 
> We can add a mechanism to manage work item scheduler priority to
> workqueue if necessary tho, I think.  But that would be per-workqueue
> attribute which is applied during execution, not something per-gcwq.
> 
Only if we then also make PI possible ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
