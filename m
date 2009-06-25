Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 833B06B008A
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 01:01:06 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5P4oKhE008655
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 00:50:20 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5P5147E255572
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 01:01:04 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5P4wfW4029746
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 00:58:42 -0400
Date: Thu, 25 Jun 2009 10:31:02 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] Reduce the resource counter lock overhead
Message-ID: <20090625050102.GY8642@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090624170516.GT8642@balbir.in.ibm.com> <20090624161028.b165a61a.akpm@linux-foundation.org> <20090625085347.a64654a7.kamezawa.hiroyu@jp.fujitsu.com> <20090625032717.GX8642@balbir.in.ibm.com> <20090624204426.3dc9e108.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090624204426.3dc9e108.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, menage@google.com, xemul@openvz.org, linux-mm@kvack.org, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> [2009-06-24 20:44:26]:

> On Thu, 25 Jun 2009 08:57:17 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > We do a read everytime before we charge.
> 
> See, a good way to fix that is to not do it.  Instead of
> 
> 	if (under_limit())
> 		charge_some_more(amount);
> 	else
> 		goto fail;
> 
> one can do 
> 
> 	if (try_to_charge_some_more(amount) < 0)
> 		goto fail;
> 
> which will halve the locking frequency.  Which may not be as beneficial
> as avoiding the locking altogether on the read side, dunno.
>

My bad, we do it all under one lock. We do a read within the charge
lock. I should get some Tea or coffee before responding to emails in
the morning. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
