Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7EC9160021B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 06:06:41 -0500 (EST)
Subject: Re: [RFC PATCH] asynchronous page fault.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <50863609fb8263f3a0f9111a304a9dbc.squirrel@webmail-b.css.fujitsu.com>
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
	 <1261915391.15854.31.camel@laptop>
	 <20091228093606.9f2e666c.kamezawa.hiroyu@jp.fujitsu.com>
	 <1261989047.7135.3.camel@laptop>
	 <27db4d47e5a95e7a85942c0278892467.squirrel@webmail-b.css.fujitsu.com>
	 <1261996258.7135.67.camel@laptop>
	 <50863609fb8263f3a0f9111a304a9dbc.squirrel@webmail-b.css.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Dec 2009 12:06:01 +0100
Message-ID: <1261998361.7135.78.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-12-28 at 19:57 +0900, KAMEZAWA Hiroyuki wrote:
>   - because pmd has some trobles because of quicklists..I don't wanted to
>     touch free routine of them. 

I really doubt the value of that quicklist horror. IIRC x86 stopped
supporting that a while ago as well.

I would suspect the page-table retention scheme possible with RCU freed
page tables could be far more efficient than quicklists, but then that's
all speculation since I don't know what kind of workloads we're talking
about and this glaring lack of implementation to compare.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
