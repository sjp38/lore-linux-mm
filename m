Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 541CA6B0055
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 09:50:22 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6AEFM65029424
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Jul 2009 23:15:22 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9467045DE4F
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 23:15:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A37145DE4E
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 23:15:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 517051DB8043
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 23:15:22 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CCD771DB803E
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 23:15:21 +0900 (JST)
Message-ID: <fda5a0e71781c85d850573fd9166c895.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090710105620.GI20129@balbir.in.ibm.com>
References: <20090709171441.8080.85983.sendpatchset@balbir-laptop>
    <20090709171512.8080.8138.sendpatchset@balbir-laptop>
    <20090710143026.4de7d4b9.kamezawa.hiroyu@jp.fujitsu.com>
    <20090710065306.GC20129@balbir.in.ibm.com>
    <20090710163056.a9d552e2.kamezawa.hiroyu@jp.fujitsu.com>
    <20090710074906.GE20129@balbir.in.ibm.com>
    <20090710105620.GI20129@balbir.in.ibm.com>
Date: Fri, 10 Jul 2009 23:15:20 +0900 (JST)
Subject: Re: [RFC][PATCH 5/5] Memory controller soft limit reclaim on
 contention (v8)
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote：
> * Balbir Singh <balbir@linux.vnet.ibm.com> [2009-07-10 13:19:06]:
>>
>> Yes, worth experimenting with, I'll redo with the special code
>> removed.
>
>
> OK, so I experimented with it, I found the following behaviour
>
> 1. We try to reclaim, priority is high, scanned pages are low and
>    hence memory cgroup zone reclaim returns 0 (no pages could be
>    reclaimed).
> 2. Now regular reclaim from balance_pgdat() is called, it is able
>    to shrink from global LRU and hence some other mem cgroup, thus
>    breaking soft limit semantics.
>
IMO, "breaking soft limit" cannot be an excuse for delaying kswapd too much.


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
