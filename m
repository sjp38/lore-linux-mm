Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 76CC160044A
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 03:44:46 -0500 (EST)
Subject: Re: [RFC PATCH] asynchronous page fault.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20091228025839.GF3601@balbir.in.ibm.com>
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
	 <1261912796.15854.25.camel@laptop>
	 <20091228005746.GE3601@balbir.in.ibm.com>
	 <20091228100514.ec6f9949.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091228025839.GF3601@balbir.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Dec 2009 09:34:56 +0100
Message-ID: <1261989296.7135.6.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-12-28 at 08:28 +0530, Balbir Singh wrote:

> We can, but the data being on read-side is going to be out-of-date
> more than without the use of rcu_assign_pointer(). Do we need variants
> like to rcu_rb_next() to avoid overheads for everyone?

More or less doesn't matter! As long as you cannot get it atomic there's
holes and you need to deal with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
