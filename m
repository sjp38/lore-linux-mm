Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6F64C6B0087
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 00:29:26 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp08.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7S4SgDf020732
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 09:58:42 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7S4TLoV2089084
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 09:59:21 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7S4TKUu026245
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 14:29:21 +1000
Date: Fri, 28 Aug 2009 09:58:36 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/5] memcg: reduce lock conetion
Message-ID: <20090828042836.GD4889@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-28 13:20:15]:

> Hi,
> 
> Recently, memcg's res_counter->lock contention on big server is reported and
> Balbir wrote a workaround for root memcg.
> It's good but we need some fix for children, too.
> 
> This set is for reducing lock conetion of memcg's children cgroup based on mmotm-Aug27.
> 
> I'm sorry I have only 8cpu machine and can't reproduce very troublesome lock conention.
> Here is lock_stat of make -j 12 on my 8cpu box, befre-after this patch series.
>

Kamezawa-San,

I've been unable to get mmotm to boot (24th August, I'll try the 27th
Aug and debug). Once that is done, I'll test on a large machine.
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
