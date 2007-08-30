Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id l7U9DTlH013837
	for <linux-mm@kvack.org>; Thu, 30 Aug 2007 19:13:29 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7U9H08r190026
	for <linux-mm@kvack.org>; Thu, 30 Aug 2007 19:17:00 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7U9DQd3011258
	for <linux-mm@kvack.org>; Thu, 30 Aug 2007 19:13:26 +1000
Message-ID: <46D68A2B.7040106@linux.vnet.ibm.com>
Date: Thu, 30 Aug 2007 14:43:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm PATCH] Memory controller improve user interface
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop> <1188413148.28903.113.camel@localhost> <46D5ED5C.9030405@linux.vnet.ibm.com> <1188425894.28903.140.camel@localhost> <6599ad830708291520t2bc9ea20m2bdcd9e042b3a423@mail.gmail.com> <1188426352.28903.143.camel@localhost> <46D5F517.1080809@linux.vnet.ibm.com> <20070830143859.e9d3511a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070830143859.e9d3511a.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 30 Aug 2007 04:07:11 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> 1. Several people recommended it
>> 2. Herbert mentioned that they've moved to that interface and it
>>    was working fine for them.
>>
> 
> I have no strong opinion. But how about Mega bytes ? (too big ?)
> There will be no rounding up/down problem.
> 

Here is what I am thinking, allow the user to input bytes/kilobytes/
megabytes or gigabytes. Store the data internally in kilobytes or
PFN. I prefer kilobytes (no rounding issues), but while implementing
limits we round up to the closest PFN.


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
