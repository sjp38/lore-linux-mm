Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 33BFF60021B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 04:58:50 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS9wlS7023387
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Dec 2009 18:58:47 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DB65B45DE4F
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 18:58:46 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C116B45DE4E
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 18:58:46 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id AAEEB1DB8037
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 18:58:46 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C60E1DB803E
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 18:58:43 +0900 (JST)
Message-ID: <27db4d47e5a95e7a85942c0278892467.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <1261989047.7135.3.camel@laptop>
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
    <1261915391.15854.31.camel@laptop>
    <20091228093606.9f2e666c.kamezawa.hiroyu@jp.fujitsu.com>
    <1261989047.7135.3.camel@laptop>
Date: Mon, 28 Dec 2009 18:58:43 +0900 (JST)
Subject: Re: [RFC PATCH] asynchronous page fault.
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Peter Zijlstra さんは書きました：
> On Mon, 2009-12-28 at 09:36 +0900, KAMEZAWA Hiroyuki wrote:
>>
>> > The idea is to let the RCU lock span whatever length you need the vma
>> > for, the easy way is to simply use PREEMPT_RCU=y for now,
>>
>> I tried to remove his kind of reference count trick but I can't do that
>> without synchronize_rcu() somewhere in unmap code. I don't like that and
>> use this refcnt.
>
> Why, because otherwise we can access page tables for an already unmapped
> vma? Yeah that is the interesting bit ;-)
>
Without that
  vma->a_ops->fault()
and
  vma->a_ops->unmap()
can be called at the same time. and vma->vm_file can be dropped while
vma->a_ops->fault() is called. etc...
Ah, I may miss something. I'll consider in the next year.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
