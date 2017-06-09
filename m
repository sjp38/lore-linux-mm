Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 234196B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 21:58:54 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m19so21422709pgd.14
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 18:58:54 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id f4si5696502plb.101.2017.06.08.18.58.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 18:58:53 -0700 (PDT)
Message-ID: <593A0080.4040806@huawei.com>
Date: Fri, 9 Jun 2017 09:57:20 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: correct the comment when reclaimed pages exceed the
 scanned pages
References: <1496824266-25235-1-git-send-email-zhongjiang@huawei.com> <20170608064658.GA9190@bbox>
In-Reply-To: <20170608064658.GA9190@bbox>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, akpm@linux-foundation.org
Cc: vinayakm.list@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2017/6/8 14:46, Minchan Kim wrote:
> On Wed, Jun 07, 2017 at 04:31:06PM +0800, zhongjiang wrote:
>> The commit e1587a494540 ("mm: vmpressure: fix sending wrong events on
>> underflow") declare that reclaimed pages exceed the scanned pages due
>> to the thp reclaim. it is incorrect because THP will be spilt to normal
>> page and loop again. which will result in the scanned pages increment.
>>
>> Signed-off-by: zhongjiang <zhongjiang@huawei.com>
>> ---
>>  mm/vmpressure.c | 5 +++--
>>  1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
>> index 6063581..0e91ba3 100644
>> --- a/mm/vmpressure.c
>> +++ b/mm/vmpressure.c
>> @@ -116,8 +116,9 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>>  
>>  	/*
>>  	 * reclaimed can be greater than scanned in cases
>> -	 * like THP, where the scanned is 1 and reclaimed
>> -	 * could be 512
>> +	 * like reclaimed slab pages, shrink_node just add
>> +	 * reclaimed page without a related increment to
>> +	 * scanned pages.
>>  	 */
>>  	if (reclaimed >= scanned)
>>  		goto out;
> Thanks for the fixing my fault!
>
> Acked-by: Minchan Kim <minchan@kernel.org>
>
> Frankly speaking, I'm not sure we need such comment in there at the cost
> of maintainance because it would be fragile but easy to fix by above simple
> condition so I think it would be better to remove that comment but others
> might be different. So, don't have any objection.
>
>
> .
>
 Thanks

 Regards
 zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
