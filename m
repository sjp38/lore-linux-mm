Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 539DB6B0044
	for <linux-mm@kvack.org>; Wed,  7 Jan 2009 22:46:46 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id n083kaOe012917
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 09:16:36 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n083keYe3391508
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 09:16:40 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n083kZYa028241
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 14:46:36 +1100
Date: Thu, 8 Jan 2009 09:16:35 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/4] Memory controller soft limit patches
Message-ID: <20090108034634.GA7294@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090107184110.18062.41459.sendpatchset@localhost.localdomain> <20090107185627.GL4145@linux.vnet.ibm.com> <20090108093700.2ad10d85.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090108093700.2ad10d85.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-08 09:37:00]:

> On Thu, 8 Jan 2009 00:26:27 +0530
> Dhaval Giani <dhaval@linux.vnet.ibm.com> wrote:
> 
> > On Thu, Jan 08, 2009 at 12:11:10AM +0530, Balbir Singh wrote:
> > > 
> > > Here is v1 of the new soft limit implementation. Soft limits is a new feature
> > > for the memory resource controller, something similar has existed in the
> > > group scheduler in the form of shares. We'll compare shares and soft limits
> > > below. I've had soft limit implementations earlier, but I've discarded those
> > > approaches in favour of this one.
> > > 
> > > Soft limits are the most useful feature to have for environments where
> > > the administrator wants to overcommit the system, such that only on memory
> > > contention do the limits become active. The current soft limits implementation
> > > provides a soft_limit_in_bytes interface for the memory controller and not
> > > for memory+swap controller. The implementation maintains an RB-Tree of groups
> > > that exceed their soft limit and starts reclaiming from the group that
> > > exceeds this limit by the maximum amount.
> > > 
> > > This is an RFC implementation and is not meant for inclusion
> > > 
> > > TODOs
> > > 
> > > 1. The shares interface is not yet implemented, the current soft limit
> > >    implementation is not yet hierarchy aware. The end goal is to add
> > >    a shares interface on top of soft limits and to maintain shares in
> > >    a manner similar to the group scheduler
> > 
> > Just to clarify, when there is no contention, you want to share memory
> > proportionally?
> > 
> I don't like to add "share" as the kernel interface of memcg.
> We used "bytes" to do (hard) limit. Please just use "bytes".
>

Yes, we'll have soft limit in bytes, but for a hierarchical view,
shares do make a lot of sense. The user can use whichever interface
suits them the most.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
