Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DC8FB6B00C4
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 01:07:33 -0500 (EST)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id n22678Hd009434
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 17:07:08 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2267lml471520
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 17:07:47 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2267TwF017914
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 17:07:29 +1100
Date: Mon, 2 Mar 2009 11:37:26 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] Memory controller soft limit interface (v3)
Message-ID: <20090302060726.GH11421@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090301062959.31557.31079.sendpatchset@localhost.localdomain> <20090301063011.31557.42094.sendpatchset@localhost.localdomain> <20090302110323.1a9b9e6b.kamezawa.hiroyu@jp.fujitsu.com> <20090302044631.GE11421@balbir.in.ibm.com> <20090302143518.43f5fcc2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090302143518.43f5fcc2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02 14:35:18]:

> On Mon, 2 Mar 2009 10:16:31 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02 11:03:23]:
> > 
> > > On Sun, 01 Mar 2009 12:00:11 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > 
> > > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > > 
> > > > Changelog v2...v1
> > > > 1. Add support for res_counter_check_soft_limit_locked. This is used
> > > >    by the hierarchy code.
> > > > 
> > > > Add an interface to allow get/set of soft limits. Soft limits for memory plus
> > > > swap controller (memsw) is currently not supported. Resource counters have
> > > > been enhanced to support soft limits and new type RES_SOFT_LIMIT has been
> > > > added. Unlike hard limits, soft limits can be directly set and do not
> > > > need any reclaim or checks before setting them to a newer value.
> > > > 
> > > > Kamezawa-San raised a question as to whether soft limit should belong
> > > > to res_counter. Since all resources understand the basic concepts of
> > > > hard and soft limits, it is justified to add soft limits here. Soft limits
> > > > are a generic resource usage feature, even file system quotas support
> > > > soft limits.
> > > > 
> > > I don't convice adding more logics to res_counter is a good to do, yet.
> > >
> > 
> > Even though it is extensible and you pay the cost only when soft
> > limits is turned on? Can you show me why you are not convinced?
> >  
> Inserting more codes (like "if") to res_counter itself is not welcome..
> I think res_counter is too complex as counter already.
>

Darn.. we better stop all code development!
 
> I'm now searching a way to reduce res_counter->lock ping-pong but have no
> good idea.
> 

I've been doing some detailed analysis on the memory controller
overhead. I have a set of patches that I am testing right now. I'll
share the details once I am done with them.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
