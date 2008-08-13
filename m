Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m7D1NSQb030386
	for <linux-mm@kvack.org>; Wed, 13 Aug 2008 11:23:28 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7D1O7CZ168808
	for <linux-mm@kvack.org>; Wed, 13 Aug 2008 11:24:10 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7D1O6Qi003784
	for <linux-mm@kvack.org>; Wed, 13 Aug 2008 11:24:07 +1000
Message-ID: <48A237B8.6060004@linux.vnet.ibm.com>
Date: Wed, 13 Aug 2008 06:54:08 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 0/2] Memory rlimit fix crash on fork
References: <20080811100719.26336.98302.sendpatchset@balbir-laptop> <20080812171407.2f468729.akpm@linux-foundation.org>
In-Reply-To: <20080812171407.2f468729.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, xemul@openvz.org, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Mon, 11 Aug 2008 15:37:19 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> --- linux-2.6.27-rc1/mm/memory.c~memrlimit-fix-crash-on-fork	2008-08-11 14:57:48.000000000 +0530
>> +++ linux-2.6.27-rc1-balbir/mm/memory.c	2008-08-11 14:58:33.000000000 +0530
>> @@ -901,8 +901,12 @@ unsigned long unmap_vmas(struct mmu_gath
> 
> ^^ returns a long.
> 
>>  	unsigned long start = start_addr;
>>  	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
>>  	int fullmm = (*tlbp)->fullmm;
>> -	struct mm_struct *mm = vma->vm_mm;
>> +	struct mm_struct *mm;
>> +
>> +	if (!vma)
>> +		return;
> 
> ^^ mm/memory.c:907: warning: 'return' with no value, in function returning non-void
> 
> How does this happen?
> 
> I'll drop the patch.  The above mystery change needs a comment, IMO.

Oops.. I'll send the updated version. I'll comment it as well.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
