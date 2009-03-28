Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C17656B003D
	for <linux-mm@kvack.org>; Sat, 28 Mar 2009 14:11:14 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2SIBJkj001182
	for <linux-mm@kvack.org>; Sat, 28 Mar 2009 23:41:19 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2SIBRPS4096190
	for <linux-mm@kvack.org>; Sat, 28 Mar 2009 23:41:28 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2SIBICP006960
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 05:11:18 +1100
Date: Sat, 28 Mar 2009 23:41:00 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] memcg soft limit (yet another new design) v1
Message-ID: <20090328181100.GB26686@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-27 13:59:33]:

> ==brief test result==
> On 2CPU/1.6GB bytes machine. create group A and B
>   A.  soft limit=300M
>   B.  no soft limit
> 
>   Run a malloc() program on B and allcoate 1G of memory. The program just
>   sleeps after allocating memory and no memory refernce after it.
>   Run make -j 6 and compile the kernel.
> 
>   When vm.swappiness = 60  => 60MB of memory are swapped out from B.
>   When vm.swappiness = 10  => 1MB of memory are swapped out from B    
> 
>   If no soft limit, 350MB of swap out will happen from B.(swapiness=60)
>

I ran the same tests, booted the machine with mem=1700M and maxcpus=2

Here is what I see with

A has a swapout of 344M and B has not swapout at all, since B is
always under its soft limit. vm.swappiness is set to 60

I think the above is more along the lines of the expected functional behaviour. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
