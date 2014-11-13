Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5C46B00DF
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 20:28:46 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so581712pab.7
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 17:28:45 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id tl10si24360009pac.46.2014.11.12.17.28.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 12 Nov 2014 17:28:44 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NEY0056VERU0U90@mailout4.samsung.com> for
 linux-mm@kvack.org; Thu, 13 Nov 2014 10:28:42 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
References: <1415803038-7913-1-git-send-email-opensource.ganesh@gmail.com>
 <20141113000216.GA1074@bbox>
In-reply-to: <20141113000216.GA1074@bbox>
Subject: RE: [PATCH] mm/zram: correct ZRAM_ZERO flag bit position
Date: Thu, 13 Nov 2014 09:27:33 +0800
Message-id: <000001cffee1$28362ed0$78a28c70$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mahendran Ganesh' <opensource.ganesh@gmail.com>
Cc: 'Minchan Kim' <minchan@kernel.org>, ngupta@vflare.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 13, 2014 at 8:02 AM, Minchan Kim <minchan@kernel.org> wrote:
> On Wed, Nov 12, 2014 at 10:37:18PM +0800, Mahendran Ganesh wrote:
>> In struct zram_table_entry, the element *value* contains obj size and
>> obj zram flags. Bit 0 to bit (ZRAM_FLAG_SHIFT - 1) represent obj size,
>> and bit ZRAM_FLAG_SHIFT to the highest bit of unsigned long represent obj
>> zram_flags. So the first zram flag(ZRAM_ZERO) should be from ZRAM_FLAG_SHIFT
>> instead of (ZRAM_FLAG_SHIFT + 1).
>>
>> This patch fixes this issue.
>>
>> Also this patch fixes a typo, "page in now accessed" -> "page is now accessed"
>>
>> Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
> Acked-by: Minchan Kim <minchan@kernel.org>

Acked-by: Weijie Yang <weijie.yang@samsung.com>

> To be clear about "fixes this issue", it's not a bug but just clean up
> so it doesn't change any behavior.
>
> Thanks!
>
> --
> Kind regards,
> Minchan Kim
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
