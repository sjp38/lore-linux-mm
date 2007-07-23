Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6NKA6AU019283
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 16:10:06 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6NK8pWx410522
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 16:08:51 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6NK8pjM031690
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 16:08:51 -0400
Date: Mon, 23 Jul 2007 13:08:47 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] Memoryless nodes:  use "node_memory_map" for cpuset mems_allowed validation
Message-ID: <20070723200847.GB6036@us.ibm.com>
References: <20070711182219.234782227@sgi.com> <20070711182250.005856256@sgi.com> <Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com> <1184964564.9651.66.camel@localhost> <20070723190922.GA6036@us.ibm.com> <20070723122333.8b21b5fd.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070723122333.8b21b5fd.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Lee.Schermerhorn@hp.com, clameter@sgi.com, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On 23.07.2007 [12:23:33 -0700], Paul Jackson wrote:
> > Or perhaps we should adjust cpusets to make it so that the mems_allowed
> > member only includes nodes that are set in node_states[N_MEMORY]?
> > 
> > What do you think? Paul?
> 
> Do you mean the "mems_alloed member" of the task struct ?

I guess both that of the task_struct and that of the cpuset? I'm not
sure. Could we do it for both?

> That might make sense - changing task->mems_allowed to just include
> nodes with memory.

Yep.

> Someone would have to audit the entire kernel for uses of
> task->mems_allowed, to see if all uses would be ok with this change.

I am starting that now -- I'm first looking at every place (in -mm,
admittedly) that mems_allowed is assigned. Since now it's possible that
we'll have to do extra checking if some sort of rebinding to memoryless
nodes would occur (which we currently wouldn't even notice, AFAICT).

> I'm on vacation this week and next, so won't be doing that work right
> now.

Ok, thanks for taking the time to reply! I will try and spin something
up for you to review when you're back from vacation.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
