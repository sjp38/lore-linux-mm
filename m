Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1F4SDq8032078
	for <linux-mm@kvack.org>; Fri, 15 Feb 2008 15:28:13 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1F4SQFw3584116
	for <linux-mm@kvack.org>; Fri, 15 Feb 2008 15:28:27 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1F4SQT2030873
	for <linux-mm@kvack.org>; Fri, 15 Feb 2008 15:28:26 +1100
Message-ID: <47B51430.4090009@linux.vnet.ibm.com>
Date: Fri, 15 Feb 2008 09:55:20 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH 3/4] Reclaim from groups over their soft limit under
 memory pressure
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain> <20080213151242.7529.79924.sendpatchset@localhost.localdomain> <20080214163054.81deaf27.kamezawa.hiroyu@jp.fujitsu.com> <47B3F073.1070804@linux.vnet.ibm.com> <20080214174236.aa2aae9b.kamezawa.hiroyu@jp.fujitsu.com> <47B406E4.9060109@linux.vnet.ibm.com> <6599ad830802142017g7cdb1b9cid8bbc8cb97e2df68@mail.gmail.com>
In-Reply-To: <6599ad830802142017g7cdb1b9cid8bbc8cb97e2df68@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Herbert Poetzl <herbert@13thfloor.at>, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Rik Van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Thu, Feb 14, 2008 at 1:16 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  > Probably backgound-reclaim patch will be able to help this soft-limit situation,
>>  > if a daemon can know it should reclaim or not.
>>  >
>>
>>  Yes, I agree. I might just need to schedule the daemon under memory pressure.
>>
> 
> Can we also have a way to trigger a one-off reclaim (of a configurable
> magnitude) from userspace? Having a background daemon doing it may be
> fine as a default, but there will be cases when a userspace machine
> manager knows better than the kernel how frequently/hard to try to
> reclaim on a given cgroup.
> 
> Paul

We have that capability, but we cannot specify how much to reclaim.
There is a force_empty file that when written to, tries to reclaim all pages
from the cgroup. Depending on the need, it can be extended so that the number of
pages to be reclaimed can be specified.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
