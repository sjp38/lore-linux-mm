Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1296660021B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 03:39:55 -0500 (EST)
Subject: Re: [RFC PATCH] asynchronous page fault.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20091228093606.9f2e666c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
	 <1261915391.15854.31.camel@laptop>
	 <20091228093606.9f2e666c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Dec 2009 09:30:47 +0100
Message-ID: <1261989047.7135.3.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-12-28 at 09:36 +0900, KAMEZAWA Hiroyuki wrote:
> 
> > The idea is to let the RCU lock span whatever length you need the vma
> > for, the easy way is to simply use PREEMPT_RCU=y for now, 
> 
> I tried to remove his kind of reference count trick but I can't do that
> without synchronize_rcu() somewhere in unmap code. I don't like that and
> use this refcnt. 

Why, because otherwise we can access page tables for an already unmapped
vma? Yeah that is the interesting bit ;-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
