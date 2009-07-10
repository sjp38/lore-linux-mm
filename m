Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5EB536B0092
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 03:43:02 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n6A8138h020607
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 04:01:03 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6A8607K245742
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 04:06:00 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6A83S8d025865
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 04:03:29 -0400
Date: Fri, 10 Jul 2009 13:35:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 3/5] Memory controller soft limit organize cgroups
	(v8)
Message-ID: <20090710080557.GF20129@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090709171441.8080.85983.sendpatchset@balbir-laptop> <20090709171501.8080.85138.sendpatchset@balbir-laptop> <20090710142135.8079cd22.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090710142135.8079cd22.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-07-10 14:21:35]:

> 
> As pointed out in several times, plz avoid using jiffies.

Sorry, I forgot to respond to this part. Are you suggesting we avoid
jiffies (use ktime_t) or the time based approach. I responded to the
time base versus scanning approach to the mail earlier.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
