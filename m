Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 78A2C6B004D
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 02:04:29 -0500 (EST)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp05.in.ibm.com (8.14.3/8.13.1) with ESMTP id nA974NX7030627
	for <linux-mm@kvack.org>; Mon, 9 Nov 2009 12:34:23 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nA974N7O1708178
	for <linux-mm@kvack.org>; Mon, 9 Nov 2009 12:34:23 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nA974NLo010837
	for <linux-mm@kvack.org>; Mon, 9 Nov 2009 18:04:23 +1100
Date: Mon, 9 Nov 2009 12:34:21 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/2] memcg make use of new percpu implementations
Message-ID: <20091109070421.GD3042@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091106175242.6e13ee29.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091106175242.6e13ee29.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-11-06 17:52:42]:

> Hi,
> 
> Recent updates on dynamic percpu allocation looks good and I tries to rewrite
> memcg's poor implementation of percpu status counter.
> (It's not NUMA-aware ...)
> Thanks for great works.
> 
> For this time. I added Christoph to CC because I'm not fully sure my usage of
> __this_cpu_xxx is correct...I'm glad if you check the usage when you have time.
> 
> 
> Patch 1/2 is just clean up (prepare for patch 2/2)
> Patch 2/2 is for percpu.
> 
> Tested on my 8cpu box and works well.
> Pathcesa are against the latest mmotm.

How do the test results look? DO you see a significant boost? BTW,
I've been experimenting a bit with the earlier percpu counter patches,
I might post an iteration once I have some good results.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
