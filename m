Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB24oXDH030320
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Dec 2008 13:50:33 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CEC445DD79
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:50:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D721745DE62
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:50:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B9B061DB803F
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:50:32 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6714A1DB803A
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:50:32 +0900 (JST)
Date: Tue, 2 Dec 2008 13:49:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mmotm][PATCH 1/4]
 replacement-for-memcg-simple-migration-handling.patch
Message-Id: <20081202134944.f1965b1a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081202043531.GB28197@balbir.in.ibm.com>
References: <20081202131723.806f1724.kamezawa.hiroyu@jp.fujitsu.com>
	<20081202131840.6d797997.kamezawa.hiroyu@jp.fujitsu.com>
	<20081202043531.GB28197@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh@veritas.com" <hugh@veritas.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Dec 2008 10:05:31 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-12-02 13:18:40]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Now, management of "charge" under page migration is done under following
> > manner. (Assume migrate page contents from oldpage to newpage)
> > 
> >  before
> >   - "newpage" is charged before migration.
> >  at success.
> >   - "oldpage" is uncharged at somewhere(unmap, radix-tree-replace)
> >  at failure
> >   - "newpage" is uncharged.
> >   - "oldpage" is charged if necessary (*1)
> > 
> > But (*1) is not reliable....because of GFP_ATOMIC.
> >
> 
> Kamezawa,
> 
> You did share page migration test cases with me, but I would really
> like to see a page migration test scenario or rather a set of test
> scenarios for the memory controller. Sudhir has added some LTP test
> cases, but for now I would be satisfied with Documentation updates for
> testing the various memory controller features (sort of build a
> regression set of cases in documented form and automate it later). I
> can start with what I have, I would request you to update the
> migration cases and any other case you have. 
> 
Hmm. will consider some. 
But there is not some much "features" of memcg. Just "handlers" for some
memory jobs. So please be careful what is API we must keep and what is
current behavior.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
