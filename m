Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 861026B0253
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 12:51:41 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s75so6127236pgs.12
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 09:51:41 -0700 (PDT)
Received: from out0-194.mail.aliyun.com (out0-194.mail.aliyun.com. [140.205.0.194])
        by mx.google.com with ESMTPS id y1si5175960pgc.766.2017.10.27.09.51.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Oct 2017 09:51:39 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: extract common code for calculating total memory
 size
References: <1508971740-118317-1-git-send-email-yang.s@alibaba-inc.com>
 <1508971740-118317-2-git-send-email-yang.s@alibaba-inc.com>
 <alpine.DEB.2.20.1710270459580.8922@nuc-kabylake>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <180e8cff-b0e9-bed7-2283-3a96d97fdf62@alibaba-inc.com>
Date: Sat, 28 Oct 2017 00:51:26 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1710270459580.8922@nuc-kabylake>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/27/17 3:00 AM, Christopher Lameter wrote:
> On Thu, 26 Oct 2017, Yang Shi wrote:
> 
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 935c4d4..e21b81e 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -2050,6 +2050,31 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn,
>>   static inline void zero_resv_unavail(void) {}
>>   #endif
>>
>> +static inline void calc_mem_size(unsigned long *total, unsigned long *reserved,
>> +				 unsigned long *highmem)
>> +{
> 
> Huge incline function. This needs to go into mm/page_alloc.c or
> mm/slab_common.c

It is used by lib/show_mem.c too. But since it is definitely on a hot 
patch, I think I can change it to non inline.

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
