Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 086746B00BD
	for <linux-mm@kvack.org>; Sun,  1 Mar 2009 23:46:40 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id n224kYsI022092
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 10:16:34 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n224hbRj1749022
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 10:13:37 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n224kXke020680
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 10:16:34 +0530
Date: Mon, 2 Mar 2009 10:16:31 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] Memory controller soft limit interface (v3)
Message-ID: <20090302044631.GE11421@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090301062959.31557.31079.sendpatchset@localhost.localdomain> <20090301063011.31557.42094.sendpatchset@localhost.localdomain> <20090302110323.1a9b9e6b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090302110323.1a9b9e6b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02 11:03:23]:

> On Sun, 01 Mar 2009 12:00:11 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > Changelog v2...v1
> > 1. Add support for res_counter_check_soft_limit_locked. This is used
> >    by the hierarchy code.
> > 
> > Add an interface to allow get/set of soft limits. Soft limits for memory plus
> > swap controller (memsw) is currently not supported. Resource counters have
> > been enhanced to support soft limits and new type RES_SOFT_LIMIT has been
> > added. Unlike hard limits, soft limits can be directly set and do not
> > need any reclaim or checks before setting them to a newer value.
> > 
> > Kamezawa-San raised a question as to whether soft limit should belong
> > to res_counter. Since all resources understand the basic concepts of
> > hard and soft limits, it is justified to add soft limits here. Soft limits
> > are a generic resource usage feature, even file system quotas support
> > soft limits.
> > 
> I don't convice adding more logics to res_counter is a good to do, yet.
>

Even though it is extensible and you pay the cost only when soft
limits is turned on? Can you show me why you are not convinced?
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
