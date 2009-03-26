Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CC7D36B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 03:01:18 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2Q7pLe3032125
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 13:21:21 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2Q7lmqf4222982
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 13:17:49 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2Q7pKPB005693
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 18:51:20 +1100
Date: Thu, 26 Mar 2009 13:21:01 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH} - There appears  to be a minor race condition in
	sched.c
Message-ID: <20090326075101.GE24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <49CAFA83.1000005@tensilica.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <49CAFA83.1000005@tensilica.com>
Sender: owner-linux-mm@kvack.org
To: Piet Delaney <piet.delaney@tensilica.com>
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Johannes Weiner <jw@emlix.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* Piet Delaney <piet.delaney@tensilica.com> [2009-03-25 20:46:11]:

> Ingo, Peter:
>
> There appears to be a minor race condition in sched.c where
> you can get a division by zero. I suspect that it only shows
> up when the kernel is compiled without optimization and the code
> loads rq->nr_running from memory twice.
>
> It's part of our SMP stabilization changes that I just posted to:
>
>     git://git.kernel.org/pub/scm/linux/kernel/git/piet/xtensa-2.6.27-smp.git
>
> I mentioned it to Johannes the other day and he suggested passing it on to you ASAP.
>

The latest version uses ACCESS_ONCE to get rq->nr_running and then
uses that value. I am not sure what version you are talking about, if
it is older, you should consider backporting from the current version.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
