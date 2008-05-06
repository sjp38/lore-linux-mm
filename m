Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m463ettn004854
	for <linux-mm@kvack.org>; Tue, 6 May 2008 13:40:55 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m463fYtk2965578
	for <linux-mm@kvack.org>; Tue, 6 May 2008 13:41:34 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m463fglk028923
	for <linux-mm@kvack.org>; Tue, 6 May 2008 13:41:43 +1000
Message-ID: <481FD342.2040707@linux.vnet.ibm.com>
Date: Tue, 06 May 2008 09:10:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 1/4] Setup the rlimit controller
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain> <20080503213736.3140.83278.sendpatchset@localhost.localdomain> <20080505151142.f52b9d9e.akpm@linux-foundation.org>
In-Reply-To: <20080505151142.f52b9d9e.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, rientjes@google.com, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Sun, 04 May 2008 03:07:36 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> +	*tmp = ((*tmp + PAGE_SIZE) >> PAGE_SHIFT) << PAGE_SHIFT;
> 
> Whatever this is doing, it should not be doing it this way ;)
> 
> perhaps
> 
> 	*tmp = ALIGN(*tmp, PAGE_SIZE);
> 
> or even
> 
> 	*tmp = PAGE_ALIGN(*tmp);
> 
> ?
> 

Good point, thanks for catching this.

> 
> <looks at PAGE_ALIGN>
> 
> Each architecture implements its own version and they of course do it
> differently.  It's crying out for a consolidated implementation but we have
> no include/linux/page.h into which to consolidate it.

May be we can move this to asm-generic/page.h?


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
