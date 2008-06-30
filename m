Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m5U42cYI007315
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 14:02:38 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5U40f0o087304
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 14:00:42 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5U40fVn017186
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 14:00:41 +1000
Message-ID: <48685A72.3090102@linux.vnet.ibm.com>
Date: Mon, 30 Jun 2008 09:30:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC 0/5] Memory controller soft limit introduction (v3)
References: <20080627151808.31664.36047.sendpatchset@balbir-laptop> <20080628133615.a5fa16cf.kamezawa.hiroyu@jp.fujitsu.com> <4867174B.3090005@linux.vnet.ibm.com> <20080630102054.ee214765.kamezawa.hiroyu@jp.fujitsu.com> <486855DF.2070100@linux.vnet.ibm.com> <20080630125737.4b14785f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080630125737.4b14785f.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Hmm, that is the case where "share" works well. Why soft-limit ?
> i/o conroller doesn't support share ? (I don' know sorry.)
> 

Share is a proportional allocation of a resource. Typically that resource is
soft-limits, but not necessarily. If we re-use resource counters, my expectation
is that

A share implementation would under-neath use soft-limits.

> yes. what I want to say is you should take care of this.
> 

Yes, it will

> Anyway, I think you should revisit the whole memory reclaim and fixes small bugs?
> which doesn't meet soft-limit.
> 

I'll revisit the full thing, I am revisiting parts of it as I write the soft
limit feature.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
