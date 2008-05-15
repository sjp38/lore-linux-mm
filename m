Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m4FIdObL024418
	for <linux-mm@kvack.org>; Fri, 16 May 2008 04:39:24 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4FIdc744067374
	for <linux-mm@kvack.org>; Fri, 16 May 2008 04:39:42 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4FIdnNl031282
	for <linux-mm@kvack.org>; Fri, 16 May 2008 04:39:50 +1000
Message-ID: <482C8353.8080008@linux.vnet.ibm.com>
Date: Fri, 16 May 2008 00:09:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 1/4] Add memrlimit controller documentation (v4)
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain> <20080514130915.24440.56106.sendpatchset@localhost.localdomain> <482C7F70.2020102@qumranet.com>
In-Reply-To: <482C7F70.2020102@qumranet.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Avi Kivity wrote:
> Balbir Singh wrote:
>> +
>> +Advantages of providing this feature
>> +
>> +1. Control over virtual address space allows for a cgroup to fail
>> gracefully
>> +   i.e., via a malloc or mmap failure as compared to OOM kill when no
>> +   pages can be reclaimed.
>>   
> 
> Do you mean by this, limiting the number of pagetable pages (that are
> pinned in memory), this preventing oom by a cgroup that instantiates
> many pagetables?
> 
> 

This is not for page tables (that is in the long term TODO list). This is more
for user space calls to mmap(), malloc() or anything that causes the total
virtual memory of the process to go up (in our case cgroups). The motivation is
similar to the motivations of RLIMIT_AS.


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
