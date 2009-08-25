Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4AD3F6B004F
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 15:58:57 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7PJwrn7021637
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 01:28:53 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7P8PTAV438446
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 13:58:19 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7P8PT0U023259
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:25:29 +1000
Date: Tue, 25 Aug 2009 13:55:26 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][preview] memcg: reduce lock contention at uncharge by
	batching
Message-ID: <20090825082526.GB29572@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090825112547.c2692965.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090825112547.c2692965.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-25 11:25:47]:

> Hi,
> 
> This is a preview of a patch for reduce lock contention for memcg->res_counter.
> This makes series of uncharge in batch and reduce critical lock contention in
> res_counter. This is still under developement and based on 2.6.31-rc7.
> I'll rebase this onto mmotm if I'm ready.
> 
> I have only 8cpu(4core/2socket) system now. no significant speed up but good lock_stat.
>


I'll test this on a 24 way that I have and check. I think these
patches + resource counter per cpu locking should give good results.
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
