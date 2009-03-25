Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9825D6B007E
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 23:19:43 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2P3hUJM022645
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Mar 2009 12:43:30 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E860F45DD78
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 12:43:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B203E45DD72
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 12:43:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A77481DB8012
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 12:43:29 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6549C1DB8013
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 12:43:29 +0900 (JST)
Date: Wed, 25 Mar 2009 12:42:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
Message-Id: <20090325124202.3607d373.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090325085505.35d14b38.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090324173414.GB24227@balbir.in.ibm.com>
	<20090325085505.35d14b38.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Mar 2009 08:55:05 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 24 Mar 2009 23:04:14 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > I've run lmbench with the soft limit patches and the results show no
> > major overhead, there are some outliers and unexpected results.
> > 
> > The outliers are at context-switch 16p/64K, in communicating
> > latencies and some unexpected results where the softlimit changes help improve
> > performance (I consider these to be in the range of noise).
> > 
> 
> ok, seems no regressions. but what is the softlimit value ?
> I think there result is of course souftlimit=0 case value...right ?
> 

I'll say no more complains to this hooks even while I don't like them.
But res_coutner_charge() looks like decolated chocolate cake as _counter_ ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
