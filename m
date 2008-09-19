Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m8JLSkHI026563
	for <linux-mm@kvack.org>; Sat, 20 Sep 2008 07:28:46 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8JLTJuY3256550
	for <linux-mm@kvack.org>; Sat, 20 Sep 2008 07:29:19 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8JLTJFS012273
	for <linux-mm@kvack.org>; Sat, 20 Sep 2008 07:29:19 +1000
Message-ID: <48D4196D.6050003@linux.vnet.ibm.com>
Date: Fri, 19 Sep 2008 14:28:13 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 4/4] Add memrlimit controller accounting and control
 (v4)
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain> <20080514130951.24440.73671.sendpatchset@localhost.localdomain> <20080918135430.e2979ab1.akpm@linux-foundation.org> <20080919063823.GA27639@balbir.in.ibm.com> <20080919131405.1a95c491.akpm@linux-foundation.org>
In-Reply-To: <20080919131405.1a95c491.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 18 Sep 2008 23:38:23 -0700
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> * Andrew Morton <akpm@linux-foundation.org> [2008-09-18 13:54:30]:
>>
>>> On Wed, 14 May 2008 18:39:51 +0530
>>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>>
>>>> This patch adds support for accounting and control of virtual address space
>>>> limits.
>>>
>>> Large changes in linux-next's arch/x86/kernel/ptrace.c caused damage to
>>> the memrlimit patches.
>>>
>>> I decided to retain the patches because it looks repairable.  The
>>> problem is this reject from
>>> memrlimit-add-memrlimit-controller-accounting-and-control.patch:
>>>
>> Andrew,
>>
>> I could not apply mmotm to linux-next (both downloaded right now).
> 
> mmotm includes linux-next.patch.  mmotm is based upon the most recent
> 2.6.x-rcy.
> 

Thanks for the info

[snip]

> OK, we'll give it a shot, thanks.
> 

Thanks!

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
