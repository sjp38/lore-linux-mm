Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D80C46B0082
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 03:17:49 -0500 (EST)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp08.in.ibm.com (8.14.3/8.13.1) with ESMTP id o137eJbK009248
	for <linux-mm@kvack.org>; Wed, 3 Feb 2010 13:10:19 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o138HiE72957420
	for <linux-mm@kvack.org>; Wed, 3 Feb 2010 13:47:44 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o138HiAv004314
	for <linux-mm@kvack.org>; Wed, 3 Feb 2010 19:17:44 +1100
Date: Wed, 3 Feb 2010 13:47:40 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [patch] sysctl: clean up vm related variable declarations
Message-ID: <20100203081740.GE19641@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <201002012302.37380.l.lunak@suse.cz>
 <alpine.DEB.2.00.1002011523280.19457@chino.kir.corp.google.com>
 <201002022210.06760.l.lunak@suse.cz>
 <alpine.DEB.2.00.1002021643240.3393@chino.kir.corp.google.com>
 <20100203105236.b4a60754.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002021809220.15327@chino.kir.corp.google.com>
 <20100203111224.8fe0e20c.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002021832160.5344@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002021832160.5344@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, minchan.kim@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* David Rientjes <rientjes@google.com> [2010-02-02 18:36:42]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, there are many "extern" declaration in kernel/sysctl.c. "extern"
> declaration in *.c file is not appreciated in general.
> And Hmm...it seems there are a few redundant declarations.
> 
> Because most of sysctl variables are defined in its own header file,
> they should be declared in the same style, be done in its own *.h file.
> 
> This patch removes some VM(memory management) related sysctl's
> variable declaration from kernel/sysctl.c and move them to
> proper places.
> 
> [rientjes@google.com: #ifdef fixlet]
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  include/linux/mm.h     |    5 +++++
>  include/linux/mmzone.h |    1 +
>  include/linux/oom.h    |    5 +++++
>  kernel/sysctl.c        |   16 ++--------------
>  mm/mmap.c              |    5 +++++
>  5 files changed, 18 insertions(+), 14 deletions(-)
>

Looks good to me 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
