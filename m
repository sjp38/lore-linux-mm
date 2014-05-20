Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1DBFB6B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 04:04:08 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id lf10so90507pab.34
        for <linux-mm@kvack.org>; Tue, 20 May 2014 01:04:07 -0700 (PDT)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id bu1si653109pbc.136.2014.05.20.01.04.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 20 May 2014 01:04:07 -0700 (PDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Tue, 20 May 2014 13:34:04 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 666FA1258054
	for <linux-mm@kvack.org>; Tue, 20 May 2014 13:33:08 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4K84P5v55509138
	for <linux-mm@kvack.org>; Tue, 20 May 2014 13:34:25 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4K840n6023115
	for <linux-mm@kvack.org>; Tue, 20 May 2014 13:34:01 +0530
Message-ID: <537B0C6E.4030501@linux.vnet.ibm.com>
Date: Tue, 20 May 2014 13:33:58 +0530
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V4 2/2] powerpc/pseries: init fault_around_order for pseries
References: <1399541296-18810-1-git-send-email-maddy@linux.vnet.ibm.com> <1399541296-18810-3-git-send-email-maddy@linux.vnet.ibm.com> <20140520002834.aefb5a90.akpm@linux-foundation.org>
In-Reply-To: <20140520002834.aefb5a90.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com

On Tuesday 20 May 2014 12:58 PM, Andrew Morton wrote:
> On Thu,  8 May 2014 14:58:16 +0530 Madhavan Srinivasan <maddy@linux.vnet.ibm.com> wrote:
> 
>> --- a/arch/powerpc/platforms/pseries/pseries.h
>> +++ b/arch/powerpc/platforms/pseries/pseries.h
>> @@ -17,6 +17,8 @@ struct device_node;
>>  extern void request_event_sources_irqs(struct device_node *np,
>>  				       irq_handler_t handler, const char *name);
>>  
>> +extern unsigned int fault_around_order;
> 
> This isn't an appropriate header file for exporting something from core
> mm - what happens if arch/mn10300 wants it?.
>
> I guess include/linux/mm.h is the place.
> 

Rusty already suggested this. My bad.  Reason for adding it here was
that, I did the performance test for this platform. Will change and send
it out.

Thanks for review
Regards
Maddy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
