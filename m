Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7216B0591
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 02:23:36 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id f69-v6so11671798pfa.15
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 23:23:36 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id y17-v6si3656753pfb.196.2018.11.07.23.23.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 23:23:35 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 08 Nov 2018 12:53:33 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v2 3/4] mm: convert totalram_pages and totalhigh_pages
 variables to atomic
In-Reply-To: <5edc432c-b475-5d2e-6a87-700c32a8fad9@suse.cz>
References: <1541521310-28739-1-git-send-email-arunks@codeaurora.org>
 <1541521310-28739-4-git-send-email-arunks@codeaurora.org>
 <5edc432c-b475-5d2e-6a87-700c32a8fad9@suse.cz>
Message-ID: <7376dee0b5a62fe847c347e615abf868@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, mhocko@kernel.org, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On 2018-11-07 14:34, Vlastimil Babka wrote:
> On 11/6/18 5:21 PM, Arun KS wrote:
>> totalram_pages and totalhigh_pages are made static inline function.
>> 
>> Suggested-by: Michal Hocko <mhocko@suse.com>
>> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
>> Signed-off-by: Arun KS <arunks@codeaurora.org>
>> Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> One bug (probably) below:
> 
>> diff --git a/mm/highmem.c b/mm/highmem.c
>> index 59db322..02a9a4b 100644
>> --- a/mm/highmem.c
>> +++ b/mm/highmem.c
>> @@ -105,9 +105,7 @@ static inline wait_queue_head_t 
>> *get_pkmap_wait_queue_head(unsigned int color)
>>  }
>>  #endif
>> 
>> -unsigned long totalhigh_pages __read_mostly;
>> -EXPORT_SYMBOL(totalhigh_pages);
> 
> I think you still need to export _totalhigh_pages so that modules can
> use the inline accessors.

Thanks for pointing this. I missed that. Will do the same for 
_totalram_pages.

Regards,
Arun

> 
>> -
>> +atomic_long_t _totalhigh_pages __read_mostly;
>> 
>>  EXPORT_PER_CPU_SYMBOL(__kmap_atomic_idx);
>> 
