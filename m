Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1F5Lkue014694
	for <linux-mm@kvack.org>; Fri, 15 Feb 2008 10:51:46 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1F5Lk6r1073262
	for <linux-mm@kvack.org>; Fri, 15 Feb 2008 10:51:46 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1F5LokE032224
	for <linux-mm@kvack.org>; Fri, 15 Feb 2008 05:21:50 GMT
Message-ID: <47B520B6.2020101@linux.vnet.ibm.com>
Date: Fri, 15 Feb 2008 10:48:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH 3/4] Reclaim from groups over their soft limit under
 memory pressure
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain> <20080213151242.7529.79924.sendpatchset@localhost.localdomain> <20080214163054.81deaf27.kamezawa.hiroyu@jp.fujitsu.com> <47B3F073.1070804@linux.vnet.ibm.com> <20080214174236.aa2aae9b.kamezawa.hiroyu@jp.fujitsu.com> <47B406E4.9060109@linux.vnet.ibm.com> <6599ad830802142017g7cdb1b9cid8bbc8cb97e2df68@mail.gmail.com> <47B51430.4090009@linux.vnet.ibm.com> <20080215140732.8b2dc04e.kamezawa.hiroyu@jp.fujitsu.com> <6599ad830802142116r1c942d78y7002d90c2690a498@mail.gmail.com>
In-Reply-To: <6599ad830802142116r1c942d78y7002d90c2690a498@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Herbert Poetzl <herbert@13thfloor.at>, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Rik Van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Thu, Feb 14, 2008 at 9:07 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>  We can free memory by just making memory.limit to smaller number.
>>  (This may cause OOM. If we added high-low watermark, making memory.high smaller
>>   can works well for memory freeing to some extent.)
>>
> 
> What about if we want to apply memory pressure to a cgroup to push out
> unused memory, but not push out memory that it's actively using?

Both watermarks and reducing the limit will reclaim from the inactive list
first. The reclaim logic is the same as that of the per zone LRU. It would be
right to assume that both would push out unused memory first. Am I missing
something?

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
