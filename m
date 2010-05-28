Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1CC69600385
	for <linux-mm@kvack.org>; Fri, 28 May 2010 10:20:58 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id o4SEKqFX008748
	for <linux-mm@kvack.org>; Sat, 29 May 2010 00:20:52 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4SEKrbJ1613998
	for <linux-mm@kvack.org>; Sat, 29 May 2010 00:20:53 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4SEKqBH005521
	for <linux-mm@kvack.org>; Sat, 29 May 2010 00:20:53 +1000
Date: Fri, 28 May 2010 19:50:48 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
Message-ID: <20100528142048.GF5579@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100528143605.7E2A.A69D9226@jp.fujitsu.com>
 <AANLkTikB-8Qu03VrA5Z0LMXM_alSV7SLqzl-MmiLmFGv@mail.gmail.com>
 <20100528145329.7E2D.A69D9226@jp.fujitsu.com>
 <20100528125305.GE11364@uudg.org>
 <20100528140623.GA11041@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100528140623.GA11041@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

* MinChan Kim <minchan.kim@gmail.com> [2010-05-28 23:06:23]:

> > I confess I failed to distinguish memcg OOM and system OOM and used "in
> > case of OOM kill the selected task the faster you can" as the guideline.
> > If the exit code path is short that shouldn't be a problem.
> > 
> > Maybe the right way to go would be giving the dying task the biggest
> > priority inside that memcg to be sure that it will be the next process from
> > that memcg to be scheduled. Would that be reasonable?
> 
> Hmm. I can't understand your point. 
> What do you mean failing distinguish memcg and system OOM?
> 
> We already have been distinguish it by mem_cgroup_out_of_memory.
> (but we have to enable CONFIG_CGROUP_MEM_RES_CTLR). 
> So task selected in select_bad_process is one out of memcg's tasks when 
> memcg have a memory pressure. 
>

We have a routine to help figure out if the task belongs to the memory
cgroup that cause the OOM. The OOM entry from memory cgroup is
different from a regular one. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
