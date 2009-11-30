Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9E883600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 04:17:09 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp05.au.ibm.com (8.14.3/8.13.1) with ESMTP id nAU9E4CP002030
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 20:14:04 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAU9DWWM1151058
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 20:13:32 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAU9H43B029812
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 20:17:04 +1100
Date: Mon, 30 Nov 2009 14:47:00 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: memcg: slab control
Message-ID: <20091130091700.GK2970@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
 <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>
 <20091126085031.GG2970@balbir.in.ibm.com>
 <d26f1ae00911260213t3e389ccfqa03d18c459210b2e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <d26f1ae00911260213t3e389ccfqa03d18c459210b2e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Suleiman Souhlal <suleiman@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@openvz.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Suleiman Souhlal <suleiman@google.com> [2009-11-26 02:13:17]:

> On 11/26/09, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >  I think it is easier to write a slab controller IMHO.
> 
> One potential problem I can think of with writing a slab controller
> would be that the user would have to estimate what fraction of the
> amount of memory slab should be allowed to use, which might not be
> ideal.
> 
> If you wanted to limit a cgroup to a total of 1GB of memory, you might
> not care if the job wants to use 0.9 GB of user memory and 0.1GB of
> slab or if it wants to use 0.9GB of slab and 0.1GB of user memory..
>

Hmm.. true, yes not caring about how memory usage is partitioned is
nice (we have memsw for very similar reasons).
 
> Because of this, it might be more practical to integrate the slab
> accounting in memcg.
> 

I tend to agree, but I would like to see the early design and
thoughts. Like Kame pointed, integrating their accounting can be an
issue.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
