Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EAC206B00C1
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 04:11:17 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N9CuqY020600
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 23 Mar 2009 18:12:56 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 339BC45DE51
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 18:12:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 135EA45DE53
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 18:12:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B6041DB8040
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 18:12:55 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FB59E38004
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 18:12:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
In-Reply-To: <20090323082441.GL24227@balbir.in.ibm.com>
References: <20090323153241.6A0F.A69D9226@jp.fujitsu.com> <20090323082441.GL24227@balbir.in.ibm.com>
Message-Id: <20090323175127.6A15.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 23 Mar 2009 18:12:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > Kamezawa-san, This implementation is suck. but I think softlimit concept 
> > itself isn't suck.
> 
> Just because of the reclaim factor? Feel free to improve it
> iteratively. Like I said to Kamezawa, don't over optimize in the first
> iteration. Pre-mature optimization is the root of all evil.

Agreed.
Then, I nacked premature optimization code everytime.


> > So, I would suggested discuss this feature based on your 
> > "memcg softlimit (Another one) v4" patch. I exept I can ack it after few spin.
> 
> Kame's implementation sucked quite badly, please see my posted test
> results. Basic, bare minimum functionality did not work.

Yes. I see.
but I think it can be fixed. the basic design of the patch is sane IMHO.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
