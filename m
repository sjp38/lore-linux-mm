Message-ID: <43FD39E6.7050701@yahoo.com.au>
Date: Thu, 23 Feb 2006 15:28:22 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][patch] mm: single pcp lists
References: <20060222143217.GI15546@wotan.suse.de> <43FCE394.9010502@austin.ibm.com>
In-Reply-To: <43FCE394.9010502@austin.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Joel Schopp wrote:
>> -struct per_cpu_pages {
>> +struct per_cpu_pageset {
>> +    struct list_head list;    /* the list of pages */
>>      int count;        /* number of pages in the list */
>> +    int cold_count;        /* number of cold pages in the list */
>>      int high;        /* high watermark, emptying needed */
>>      int batch;        /* chunk size for buddy add/remove */
>> -    struct list_head list;    /* the list of pages */
>> -};
> 
> 
> Any particular reason to move the list_head to the front?
> 

Nothing particular. I think it was for alignment at one stage
before cold_count was added.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
