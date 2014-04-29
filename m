Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF7C6B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 05:37:05 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id fb1so6190307pad.24
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 02:37:05 -0700 (PDT)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id wh4si12258099pbc.477.2014.04.29.02.37.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 02:37:04 -0700 (PDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Tue, 29 Apr 2014 19:37:01 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 66956357805F
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 19:36:59 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3T9aiph7799250
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 19:36:44 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3T9awfd000941
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 19:36:58 +1000
Message-ID: <535F72B5.3000405@linux.vnet.ibm.com>
Date: Tue, 29 Apr 2014 15:06:53 +0530
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3 2/2] powerpc/pseries: init fault_around_order for pseries
References: <1398675690-16186-1-git-send-email-maddy@linux.vnet.ibm.com> <1398675690-16186-3-git-send-email-maddy@linux.vnet.ibm.com> <877g686fpb.fsf@rustcorp.com.au>
In-Reply-To: <877g686fpb.fsf@rustcorp.com.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com

On Tuesday 29 April 2014 07:48 AM, Rusty Russell wrote:
> Madhavan Srinivasan <maddy@linux.vnet.ibm.com> writes:
>> diff --git a/arch/powerpc/platforms/pseries/setup.c b/arch/powerpc/platforms/pseries/setup.c
>> index 2db8cc6..c87e6b6 100644
>> --- a/arch/powerpc/platforms/pseries/setup.c
>> +++ b/arch/powerpc/platforms/pseries/setup.c
>> @@ -74,6 +74,8 @@ int CMO_SecPSP = -1;
>>  unsigned long CMO_PageSize = (ASM_CONST(1) << IOMMU_PAGE_SHIFT_4K);
>>  EXPORT_SYMBOL(CMO_PageSize);
>>  
>> +extern unsigned int fault_around_order;
>> +
> 
> It's considered bad form to do this.  Put the declaration in linux/mm.h.
> 

ok. Will change it.

Thanks for review
With regards
Maddy

> Thanks,
> Rusty.
> PS.  But we're getting there! :)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
