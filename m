Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m3A9B7pp025828
	for <linux-mm@kvack.org>; Thu, 10 Apr 2008 14:41:07 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3A9B50m1327344
	for <linux-mm@kvack.org>; Thu, 10 Apr 2008 14:41:05 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m3A9B6gh030962
	for <linux-mm@kvack.org>; Thu, 10 Apr 2008 09:11:07 GMT
Message-ID: <47FDD947.8020600@linux.vnet.ibm.com>
Date: Thu, 10 Apr 2008 14:39:27 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm] Add an owner to the mm_struct (v8)
References: <20080404080544.26313.38199.sendpatchset@localhost.localdomain> <47F7BB69.3000502@linux.vnet.ibm.com> <6599ad830804051057n2f2802e4w6179f2e108467494@mail.gmail.com> <47F7CC08.4090209@linux.vnet.ibm.com> <6599ad830804051629k3649dbc4na92bb3d0cd7a0492@mail.gmail.com> <47F861C8.7080700@linux.vnet.ibm.com> <6599ad830804072337g2e7b4613hdcc05062dc2ca4e0@mail.gmail.com> <47FB162D.1020506@linux.vnet.ibm.com> <6599ad830804072357o2fd5e9bco3309d151e270e62e@mail.gmail.com> <47FB193A.8070801@linux.vnet.ibm.com> <6599ad830804080029v1d8f2ff7g5254f32362fd7cb9@mail.gmail.com>
In-Reply-To: <6599ad830804080029v1d8f2ff7g5254f32362fd7cb9@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Tue, Apr 8, 2008 at 12:05 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> Paul Menage wrote:
>>  > On Mon, Apr 7, 2008 at 11:52 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  >>  I agree, but like I said earlier, this was the easily available ready made
>>  >>  application I found. Do you know of any other highly threaded micro benchmark?
>>  >>
>>  >
>>  > How about a simple program that creates N threads that just sleep,
>>  > then has the main thread exit?
>>  >
>>
>>  That is not really representative of anything. I have that program handy. How do
>>  we measure the impact on throughput?
> 
> It's very representative of how much additional overhead in terms of
> mm->owner churn there is in a large multi-threaded application
> exiting, which is the thing that you're trying to optimize with the
> delayed thread group leader checks.
> 

I see almost no overhead after the notification change optimization (notify only
if owner belongs to a different cgroup).

My program creates n processes with k threads each and forces the thread group
leader to exit. For my experiment I created 10 processes with 800 threads each
(NOTE: you need to change ulimit -s for this to work).

I am going to remove the delay_group_leader() optimization and submit v9.

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
