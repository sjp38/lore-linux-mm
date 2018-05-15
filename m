Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 972D66B0289
	for <linux-mm@kvack.org>; Tue, 15 May 2018 08:40:14 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x2-v6so168541wmc.3
        for <linux-mm@kvack.org>; Tue, 15 May 2018 05:40:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k13-v6si228830edl.323.2018.05.15.05.40.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 May 2018 05:40:11 -0700 (PDT)
Subject: Re: [PATCH v5 13/17] mm: Add hmm_data to struct page
From: Vlastimil Babka <vbabka@suse.cz>
References: <20180504183318.14415-1-willy@infradead.org>
 <20180504183318.14415-14-willy@infradead.org>
 <3a804ef2-9196-c946-895c-54dc7cab618b@suse.cz>
Message-ID: <d539c5a6-776f-e180-73ec-b17ddc98d8ee@suse.cz>
Date: Tue, 15 May 2018 14:40:08 +0200
MIME-Version: 1.0
In-Reply-To: <3a804ef2-9196-c946-895c-54dc7cab618b@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On 05/15/2018 11:32 AM, Vlastimil Babka wrote:
>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>> index 5a519279dcd5..fa05e6ca31ed 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -150,11 +150,15 @@ struct page {
>>  		/** @rcu_head: You can use this to free a page by RCU. */
>>  		struct rcu_head rcu_head;
>>  
>> -		/**
>> -		 * @pgmap: For ZONE_DEVICE pages, this points to the hosting
>> -		 * device page map.
>> -		 */
>> -		struct dev_pagemap *pgmap;
>> +		struct {
>> +			/**
>> +			 * @pgmap: For ZONE_DEVICE pages, this points to the
>> +			 * hosting device page map.
>> +			 */
>> +			struct dev_pagemap *pgmap;
>> +			unsigned long hmm_data;
>> +			unsigned long _zd_pad_1;	/* uses mapping */
>> +		};
> 
> Maybe move this above rcu_head and make the comments look more like for
> the other union variants?

With that you can add my acked-by as well, thanks.

> 
>>  	};
>>  
>>  	union {		/* This union is 4 bytes in size. */
>>
> 
