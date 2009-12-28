Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8763860021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 19:57:56 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp06.au.ibm.com (8.14.3/8.13.1) with ESMTP id nBS0vnCT028680
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:57:49 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBS0rdom1462424
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:53:39 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBS0vpTi014205
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:57:51 +1100
Date: Mon, 28 Dec 2009 06:27:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] asynchronous page fault.
Message-ID: <20091228005746.GE3601@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
 <1261912796.15854.25.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1261912796.15854.25.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <peterz@infradead.org> [2009-12-27 12:19:56]:

> Your changelog states as much.
> 
> "Even if RB-tree rotation occurs while we walk tree for look-up, we just
> miss vma without oops."
> 
> However, since this is the case, do we still need the
> rcu_assign_pointer() conversion your patch does? All I can see it do is
> slow down all RB-tree users, without any gain.

Don't we need the rcu_assign_pointer() on the read side primarily to
make sure the pointer is still valid and assignments (writes) are not
re-ordered? Are you suggesting that the pointer assignment paths be
completely atomic?

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
