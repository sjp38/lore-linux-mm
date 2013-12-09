Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 788756B012D
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 18:35:33 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id rq2so6373706pbb.2
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 15:35:33 -0800 (PST)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id d2si8618070pba.301.2013.12.09.15.35.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 15:35:32 -0800 (PST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 05:05:28 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id D12221258051
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 05:06:33 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB9NZLlq53215468
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 05:05:21 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB9NZObq014344
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 05:05:24 +0530
Date: Tue, 10 Dec 2013 07:35:23 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/hwpoison: add '#' to hwpoison_inject
Message-ID: <52a653c4.c206440a.6a1a.ffffc3a3SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386322013-29554-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20131209162723.GA2236@hp530>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131209162723.GA2236@hp530>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <murzin.v@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Vladimir,
On Mon, Dec 09, 2013 at 05:27:27PM +0100, Vladimir Murzin wrote:
>Hi Wanpeng
>
>On Fri, Dec 06, 2013 at 05:26:53PM +0800, Wanpeng Li wrote:
>> Add '#' to hwpoison_inject just as done in madvise_hwpoison.
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  mm/hwpoison-inject.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>> 
>> diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
>> index 4c84678..146cead 100644
>> --- a/mm/hwpoison-inject.c
>> +++ b/mm/hwpoison-inject.c
>> @@ -55,7 +55,7 @@ static int hwpoison_inject(void *data, u64 val)
>>  		return 0;
>>  
>>  inject:
>> -	printk(KERN_INFO "Injecting memory failure at pfn %lx\n", pfn);
>> +	pr_info(KERN_INFO "Injecting memory failure at pfn %#lx\n", pfn);
>
>You don't need KERN_INFO here.
>

Ah, indeed, I will fix it. Thanks.

Regards,
Wanpeng Li 

>Vladimir
>
>>  	return memory_failure(pfn, 18, MF_COUNT_INCREASED);
>>  }
>>  
>> -- 
>> 1.7.7.6
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
