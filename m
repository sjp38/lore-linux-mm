Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id EC3BC6B00DF
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 08:54:20 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id uz6so10813015obc.19
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 05:54:20 -0800 (PST)
Received: from mail-ob0-x22b.google.com (mail-ob0-x22b.google.com. [2607:f8b0:4003:c01::22b])
        by mx.google.com with ESMTPS id p8si29826918oek.4.2014.11.13.05.54.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 05:54:20 -0800 (PST)
Received: by mail-ob0-f171.google.com with SMTP id wp18so10962023obc.30
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 05:54:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141113000216.GA1074@bbox>
References: <1415803038-7913-1-git-send-email-opensource.ganesh@gmail.com>
	<20141113000216.GA1074@bbox>
Date: Thu, 13 Nov 2014 21:54:19 +0800
Message-ID: <CADAEsF-VBUBivo0j2cmxHHPzM7rkZOCfis9kzZNZG25YnA2YrA@mail.gmail.com>
Subject: Re: [PATCH] mm/zram: correct ZRAM_ZERO flag bit position
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, weijie.yang@samsung.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2014-11-13 8:02 GMT+08:00 Minchan Kim <minchan@kernel.org>:
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

Thanks!

>
> To be clear about "fixes this issue", it's not a bug but just clean up
> so it doesn't change any behavior.
>
> Thanks!
>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
