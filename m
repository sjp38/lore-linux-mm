Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1F6dNuI004878
	for <linux-mm@kvack.org>; Fri, 15 Feb 2008 17:39:23 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1F6dbuK2150478
	for <linux-mm@kvack.org>; Fri, 15 Feb 2008 17:39:37 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1F6ddSV018230
	for <linux-mm@kvack.org>; Fri, 15 Feb 2008 17:39:40 +1100
Message-ID: <47B532F2.8010902@linux.vnet.ibm.com>
Date: Fri, 15 Feb 2008 12:06:34 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH 3/4] Reclaim from groups over their soft limit under
 memory pressure
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain> <20080213151242.7529.79924.sendpatchset@localhost.localdomain> <20080214163054.81deaf27.kamezawa.hiroyu@jp.fujitsu.com> <47B3F073.1070804@linux.vnet.ibm.com> <20080214174236.aa2aae9b.kamezawa.hiroyu@jp.fujitsu.com> <47B406E4.9060109@linux.vnet.ibm.com> <6599ad830802142017g7cdb1b9cid8bbc8cb97e2df68@mail.gmail.com> <47B51430.4090009@linux.vnet.ibm.com> <20080215140732.8b2dc04e.kamezawa.hiroyu@jp.fujitsu.com> <6599ad830802142116r1c942d78y7002d90c2690a498@mail.gmail.com> <20080215142958.511a2732.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080215142958.511a2732.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Herbert Poetzl <herbert@13thfloor.at>, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Rik Van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 14 Feb 2008 21:16:48 -0800
> "Paul Menage" <menage@google.com> wrote:
> 
>> On Thu, Feb 14, 2008 at 9:07 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>>  We can free memory by just making memory.limit to smaller number.
>>>  (This may cause OOM. If we added high-low watermark, making memory.high smaller
>>>   can works well for memory freeing to some extent.)
>>>
>> What about if we want to apply memory pressure to a cgroup to push out
>> unused memory, but not push out memory that it's actively using?
>>
> Generally, only way to avoid pageout is mlock() because actively-used is just
> determeined by reference-bit and heavy pressure can do page-scanning too much.
> I hope that RvR's LRU improvement may change things better.

There are two other controllers, I plan to work on soon. The mlock() and virtual
memory limit controller. Hopefully that should fix the mlock() problem to some
extent.

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
