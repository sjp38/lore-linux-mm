Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E01056B00C9
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 04:39:44 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2N9feNF002562
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 15:11:40 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2N9bu4E2306210
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 15:07:56 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2N9fNq8030568
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 20:41:24 +1100
Date: Mon, 23 Mar 2009 15:11:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
Message-ID: <20090323094111.GR24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain> <20090323125005.0d8a7219.kamezawa.hiroyu@jp.fujitsu.com> <20090323052247.GJ24227@balbir.in.ibm.com> <20090323151245.d6430aaa.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090323151245.d6430aaa.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-23 15:12:45]:

> On Mon, 23 Mar 2009 10:52:47 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > I have one large swap partition, so I could not test the partial-swap
> > scenario.
> > 
> plz go ahead as you like, Seems no landing point now and I'd like to see
> what I can, later. I'll send no ACK nor NACK, more.
> 
> But please get ack from someone resposible for glorbal memory reclaim.
> Especially for hooks in try_to_free_pages().
> 
> And please make it clear in documentation that 
>  - Depends on the system but this may increase the usage of swap.
>  - Depends on the system but this may not work as the user expected as hard-limit.
>

The documentation mentions that soft limits take a long time before
coming into affect. The use of the word "soft" over "hard" and the
usage of this terminology in resource management clearly implies what
you say in point (2).
 
> Considering corner cases, this is a very complicated/usage-is-difficult feature.
> 
> -Kame
> 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
