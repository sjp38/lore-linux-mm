Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2H1qjO6014178
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 12:52:45 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2H1ppRA4083842
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 12:51:51 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2H1poNS023451
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 12:51:51 +1100
Message-ID: <47DDCE5E.9020104@linux.vnet.ibm.com>
Date: Mon, 17 Mar 2008 07:20:22 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][0/3] Virtual address space control for cgroups
References: <20080316172942.8812.56051.sendpatchset@localhost.localdomain> <6599ad830803161626q1fcf261bta52933bb5e7a6bdd@mail.gmail.com>
In-Reply-To: <6599ad830803161626q1fcf261bta52933bb5e7a6bdd@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Mon, Mar 17, 2008 at 1:29 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> This is an early patchset for virtual address space control for cgroups.
>>  The patches are against 2.6.25-rc5-mm1 and have been tested on top of
>>  User Mode Linux.
> 
> What's the performance hit of doing these accounting checks on every
> mmap/munmap? If it's not totally lost in the noise, couldn't it be
> made a separate control group, so that it could be just enabled (and
> the performance hit taken) for users that actually want it?
> 

I am yet to measure the performance overhead of the accounting checks. I'll try
and get started on that today. I did not consider making it a separate system,
because I suspect that anybody wanting memory control would also want address
space control (for the advantages listed in the documentation). I am not against
the idea of making it a separate subsystem, but first let me get back with the
numbers.

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
