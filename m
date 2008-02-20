Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1KAFhBj006839
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 21:15:43 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1KAJW1a213176
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 21:19:32 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1KAFrLD017916
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 21:15:54 +1100
Message-ID: <47BBFCC2.5020408@linux.vnet.ibm.com>
Date: Wed, 20 Feb 2008 15:41:14 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0802191449490.6254@blonde.site> <47BBC15E.5070405@linux.vnet.ibm.com> <20080220.185821.61784723.taka@valinux.co.jp> <6599ad830802200206w23955c9cn26bf768e790a6161@mail.gmail.com>
In-Reply-To: <6599ad830802200206w23955c9cn26bf768e790a6161@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Feb 20, 2008 1:58 AM, Hirokazu Takahashi <taka@valinux.co.jp> wrote:
>>> 1. Have a boot option to turn on/off the memory controller
>> It will be much convenient if the memory controller can be turned on/off on
>> demand. I think you can turn it off if there aren't any mem_cgroups except
>> the root mem_cgroup,
> 
> Or possibly turned on when the memory controller is bound to a
> non-default hierarchy, and off when it's unbound?
> 

Dynamically turning on/off the memory controller, can/will lead to accounting
issues and deficiencies, since the memory controller would now have no idea of
how much memory has been allocated by which cgroup.

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
