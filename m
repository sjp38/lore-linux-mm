Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5FB9E6B0087
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 23:39:08 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2P42eis005220
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 15:02:40 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2P43PqF856114
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 15:03:25 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2P4379V013308
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 15:03:07 +1100
Date: Wed, 25 Mar 2009 09:32:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
Message-ID: <20090325040246.GD24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain> <20090324173414.GB24227@balbir.in.ibm.com> <20090325085505.35d14b38.kamezawa.hiroyu@jp.fujitsu.com> <20090325124202.3607d373.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090325124202.3607d373.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-25 12:42:02]:

> On Wed, 25 Mar 2009 08:55:05 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Tue, 24 Mar 2009 23:04:14 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > I've run lmbench with the soft limit patches and the results show no
> > > major overhead, there are some outliers and unexpected results.
> > > 
> > > The outliers are at context-switch 16p/64K, in communicating
> > > latencies and some unexpected results where the softlimit changes help improve
> > > performance (I consider these to be in the range of noise).
> > > 
> > 
> > ok, seems no regressions. but what is the softlimit value ?
> > I think there result is of course souftlimit=0 case value...right ?
> > 
> 

Yes, this result is for the soft limit being default value
(LONGLONG_MAX) case.

> I'll say no more complains to this hooks even while I don't like them.
> But res_coutner_charge() looks like decolated chocolate cake as _counter_ ;)
> 

res_counters are split out for modularity reasons, the advantage is
that we can optimize/change res_counters without affecting the memcg
code. I am glad you can see that there is no overhead as a result of
these hooks.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
