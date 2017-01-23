Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 63DA86B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 06:57:52 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id f4so104273004qte.1
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 03:57:52 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id i15si1276974qke.96.2017.01.23.03.57.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Jan 2017 03:57:51 -0800 (PST)
Message-ID: <5885EE89.70809@huawei.com>
Date: Mon, 23 Jan 2017 19:52:41 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: do not export ioremap_page_range symbol for external
 module
References: <1485089881-61531-1-git-send-email-zhongjiang@huawei.com> <588558EB.2060505@huawei.com> <8088cdd7-7abb-94ed-3bea-44d819045573@nvidia.com>
In-Reply-To: <8088cdd7-7abb-94ed-3bea-44d819045573@nvidia.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: akpm@linux-foundation.org, minchan@kernel.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2017/1/23 9:30, John Hubbard wrote:
>
>
> On 01/22/2017 05:14 PM, zhong jiang wrote:
>> On 2017/1/22 20:58, zhongjiang wrote:
>>> From: zhong jiang <zhongjiang@huawei.com>
>>>
>>> Recently, I find the ioremap_page_range had been abusing. The improper
>>> address mapping is a issue. it will result in the crash. so, remove
>>> the symbol. It can be replaced by the ioremap_cache or others symbol.
>>>
>>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>>> ---
>>>  lib/ioremap.c | 1 -
>>>  1 file changed, 1 deletion(-)
>>>
>>> diff --git a/lib/ioremap.c b/lib/ioremap.c
>>> index 86c8911..a3e14ce 100644
>>> --- a/lib/ioremap.c
>>> +++ b/lib/ioremap.c
>>> @@ -144,4 +144,3 @@ int ioremap_page_range(unsigned long addr,
>>>
>>>      return err;
>>>  }
>>> -EXPORT_SYMBOL_GPL(ioremap_page_range);
>> self nack
>>
>
> heh. What changed your mind?
>
  Very sorry,  I mistake own kernel modules call it directly.  Thank you review
  the patch . I will take your changelog and send it in v2.

  Thanks
  zhongjiang
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
