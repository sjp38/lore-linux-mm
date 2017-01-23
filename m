Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CCA126B0033
	for <linux-mm@kvack.org>; Sun, 22 Jan 2017 20:30:48 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 75so181800550pgf.3
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 17:30:48 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id o21si11463670pgj.320.2017.01.22.17.30.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jan 2017 17:30:48 -0800 (PST)
Subject: Re: [PATCH] mm: do not export ioremap_page_range symbol for external
 module
References: <1485089881-61531-1-git-send-email-zhongjiang@huawei.com>
 <588558EB.2060505@huawei.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <8088cdd7-7abb-94ed-3bea-44d819045573@nvidia.com>
Date: Sun, 22 Jan 2017 17:30:46 -0800
MIME-Version: 1.0
In-Reply-To: <588558EB.2060505@huawei.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>, akpm@linux-foundation.org, minchan@kernel.org, mhocko@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 01/22/2017 05:14 PM, zhong jiang wrote:
> On 2017/1/22 20:58, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> Recently, I find the ioremap_page_range had been abusing. The improper
>> address mapping is a issue. it will result in the crash. so, remove
>> the symbol. It can be replaced by the ioremap_cache or others symbol.
>>
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  lib/ioremap.c | 1 -
>>  1 file changed, 1 deletion(-)
>>
>> diff --git a/lib/ioremap.c b/lib/ioremap.c
>> index 86c8911..a3e14ce 100644
>> --- a/lib/ioremap.c
>> +++ b/lib/ioremap.c
>> @@ -144,4 +144,3 @@ int ioremap_page_range(unsigned long addr,
>>
>>  	return err;
>>  }
>> -EXPORT_SYMBOL_GPL(ioremap_page_range);
> self nack
>

heh. What changed your mind?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
