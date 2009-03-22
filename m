Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 64E5C6B0047
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 09:37:44 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2MELgPp019757
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 19:51:42 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2MEIEgi3670206
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 19:48:15 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2MELf4U006349
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 19:51:41 +0530
Date: Sun, 22 Mar 2009 19:51:30 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/5] Memory controller soft limit refactor reclaim
	flags (v7)
Message-ID: <20090322142130.GB24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain> <20090319165744.27274.6335.sendpatchset@localhost.localdomain> <20090320124717.8c5da82e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090320124717.8c5da82e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-20 12:47:17]:

> On Thu, 19 Mar 2009 22:27:44 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > Impact: Refactor mem_cgroup_hierarchical_reclaim()
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > This patch refactors the arguments passed to
> > mem_cgroup_hierarchical_reclaim() into flags, so that new parameters don't
> > have to be passed as we make the reclaim routine more flexible
> > 
> seems nice :)
> 
>

Thanks! 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
