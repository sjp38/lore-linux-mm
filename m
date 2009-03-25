Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C5A836B0089
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 23:42:44 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2P46r0a030935
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Mar 2009 13:06:53 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 189D945DE51
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 13:06:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D3F8545DE55
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 13:06:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B564D1DB8040
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 13:06:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ACDE1DB803B
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 13:06:52 +0900 (JST)
Date: Wed, 25 Mar 2009 13:05:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
Message-Id: <20090325130526.425a4c79.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090325040246.GD24227@balbir.in.ibm.com>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090324173414.GB24227@balbir.in.ibm.com>
	<20090325085505.35d14b38.kamezawa.hiroyu@jp.fujitsu.com>
	<20090325124202.3607d373.kamezawa.hiroyu@jp.fujitsu.com>
	<20090325040246.GD24227@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Mar 2009 09:32:46 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > I'll say no more complains to this hooks even while I don't like them.
> > But res_coutner_charge() looks like decolated chocolate cake as _counter_ ;)
> > 
> 
> res_counters are split out for modularity reasons, the advantage is
> that we can optimize/change res_counters without affecting the memcg
> code. I am glad you can see that there is no overhead as a result of
> these hooks.
> 
I'll use your code in my own set. Anyway, it's merge-window now and we'll have
enough time to think of cool stuff.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
