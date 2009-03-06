Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5A5B86B010A
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 04:56:03 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n269u0Xf005341
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Mar 2009 18:56:00 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9671345DE51
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 18:56:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C2B345DD79
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 18:56:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C942E18005
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 18:56:00 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CC4541DB803A
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 18:55:59 +0900 (JST)
Date: Fri, 6 Mar 2009 18:54:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v4)
Message-Id: <20090306185440.66b92ca3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090306092323.21063.93169.sendpatchset@localhost.localdomain>
References: <20090306092323.21063.93169.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 06 Mar 2009 14:53:23 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> New Feature: Soft limits for memory resource controller.
> 
> Changelog v4...v3
> 1. Adopted suggestions from Kamezawa to do a per-zone-per-node reclaim
>    while doing soft limit reclaim. We don't record priorities while
>    doing soft reclaim
> 2. Some of the overheads associated with soft limits (like calculating
>    excess each time) is eliminated
> 3. The time_after(jiffies, 0) bug has been fixed
> 4. Tasks are throttled if the mem cgroup they belong to is being soft reclaimed
>    and at the same time tasks are increasing the memory footprint and causing
>    the mem cgroup to exceed its soft limit.
> 
I don't think this "4" is necessary.


> Changelog v3...v2
> 1. Implemented several review comments from Kosaki-San and Kamezawa-San
>    Please see individual changelogs for changes
> 
> Changelog v2...v1
> 1. Soft limits now support hierarchies
> 2. Use spinlocks instead of mutexes for synchronization of the RB tree
> 
> Here is v4 of the new soft limit implementation. Soft limits is a new feature
> for the memory resource controller, something similar has existed in the
> group scheduler in the form of shares. The CPU controllers interpretation
> of shares is very different though. 
> 
> Soft limits are the most useful feature to have for environments where
> the administrator wants to overcommit the system, such that only on memory
> contention do the limits become active. The current soft limits implementation
> provides a soft_limit_in_bytes interface for the memory controller and not
> for memory+swap controller. The implementation maintains an RB-Tree of groups
> that exceed their soft limit and starts reclaiming from the group that
> exceeds this limit by the maximum amount.
> 
> If there are no major objections to the patches, I would like to get them
> included in -mm.
> 
You got Nack from me, again ;) And you know why.
I'll post my one later, I hope that one will be good input for you.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
