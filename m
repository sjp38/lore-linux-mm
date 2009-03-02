Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7CA1B6B00C8
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 01:21:18 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n226LDLA004301
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 2 Mar 2009 15:21:15 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B8F645DD70
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 15:21:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E090145DD72
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 15:21:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C7835E08005
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 15:21:12 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 79DD71DB803C
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 15:21:09 +0900 (JST)
Date: Mon, 2 Mar 2009 15:19:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] Memory controller soft limit interface (v3)
Message-Id: <20090302151953.f222c761.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090302060726.GH11421@balbir.in.ibm.com>
References: <20090301062959.31557.31079.sendpatchset@localhost.localdomain>
	<20090301063011.31557.42094.sendpatchset@localhost.localdomain>
	<20090302110323.1a9b9e6b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302044631.GE11421@balbir.in.ibm.com>
	<20090302143518.43f5fcc2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302060726.GH11421@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Mar 2009 11:37:26 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02 14:35:18]:
> 
> > On Mon, 2 Mar 2009 10:16:31 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02 11:03:23]:
> > > 
> > > > On Sun, 01 Mar 2009 12:00:11 +0530
> > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > 
> > > > > 
> > > > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > > > 
> > > > > Changelog v2...v1
> > > > > 1. Add support for res_counter_check_soft_limit_locked. This is used
> > > > >    by the hierarchy code.
> > > > > 
> > > > > Add an interface to allow get/set of soft limits. Soft limits for memory plus
> > > > > swap controller (memsw) is currently not supported. Resource counters have
> > > > > been enhanced to support soft limits and new type RES_SOFT_LIMIT has been
> > > > > added. Unlike hard limits, soft limits can be directly set and do not
> > > > > need any reclaim or checks before setting them to a newer value.
> > > > > 
> > > > > Kamezawa-San raised a question as to whether soft limit should belong
> > > > > to res_counter. Since all resources understand the basic concepts of
> > > > > hard and soft limits, it is justified to add soft limits here. Soft limits
> > > > > are a generic resource usage feature, even file system quotas support
> > > > > soft limits.
> > > > > 
> > > > I don't convice adding more logics to res_counter is a good to do, yet.
> > > >
> > > 
> > > Even though it is extensible and you pay the cost only when soft
> > > limits is turned on? Can you show me why you are not convinced?
> > >  
> > Inserting more codes (like "if") to res_counter itself is not welcome..
> > I think res_counter is too complex as counter already.
> >
> 
> Darn.. we better stop all code development!
>  
I don't say such a thing. My point is we have to keep res_counter as light-weight
as possible. If there are alternatives, we should use that.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
