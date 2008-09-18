Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m8INt9c6004531
	for <linux-mm@kvack.org>; Fri, 19 Sep 2008 09:55:09 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8INtgqB3325974
	for <linux-mm@kvack.org>; Fri, 19 Sep 2008 09:55:42 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8INtfg8015375
	for <linux-mm@kvack.org>; Fri, 19 Sep 2008 09:55:42 +1000
Message-ID: <48D2EA6B.9090504@linux.vnet.ibm.com>
Date: Thu, 18 Sep 2008 16:55:23 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 4/4] Add memrlimit controller accounting and control
 (v4)
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain> <20080514130951.24440.73671.sendpatchset@localhost.localdomain> <20080918135430.e2979ab1.akpm@linux-foundation.org>
In-Reply-To: <20080918135430.e2979ab1.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Wed, 14 May 2008 18:39:51 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> This patch adds support for accounting and control of virtual address space
>> limits.
>

[snip]

> 
> could you plese take a look at today's mmotm and see what needs to be
> done to salvage it?  Most of the code you were altering got moved into
> arch/x86/kernel/ds.c and got changed rather a lot.

I'll take a look tonight and see what needs to be done

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
